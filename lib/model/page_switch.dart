import 'package:flutter/material.dart';

class PageSwitch with ChangeNotifier {
  PageController _pageController;
  PageController get pageController => _pageController;
  int _currentIndex;
  int get currentIndex => _currentIndex;

  PageSwitch([this._currentIndex = 0]) {
    if(_currentIndex == null){
      _currentIndex = 0;
    }
    updatePageController();
  }

  void updatePageController() {
    _pageController?.dispose();
    _pageController = PageController(initialPage: _currentIndex);
  }

  void changePage(int index, [bool needUpdatePage = true]) async {
    if (currentIndex != index) {
      _currentIndex = index;
      if (needUpdatePage) {
        await _pageController.animateToPage(index,
            duration: Duration(microseconds: 10), curve: Curves.linear);
      }
      notifyListeners();
    }
  }

  void refreshList(){
    notifyListeners();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
