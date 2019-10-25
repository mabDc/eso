import 'package:eso/database/search_item.dart';
import 'package:eso/database/search_item_manager.dart';
import 'package:eso/model/discover_page_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../api/api_manager.dart';
import '../ui/ui_discover_item.dart';
import 'chapter_page.dart';
import 'langding_page.dart';

class DiscoverPage extends StatelessWidget {
  const DiscoverPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final allAPI = APIManager.allAPI;
    return Scaffold(
      appBar: AppBar(
        title: Text('发现'),
      ),
      body: ListView.separated(
        separatorBuilder: (context, index) {
          return SizedBox(
            height: 4,
          );
        },
        padding: EdgeInsets.all(6),
        itemCount: allAPI.length,
        itemBuilder: (context, index) {
          return Card(
            child: ListTile(
              title: Text(allAPI[index].origin),
              trailing: Switch(
                activeColor: Theme.of(context).primaryColor,
                value: true,
                onChanged: (enable) {},
              ),
              onTap: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => DiscoverItemPage(
                      originTag: allAPI[index].originTag,
                      origin: allAPI[index].origin))),
            ),
          );
        },
      ),
    );
  }
}

class DiscoverItemPage extends StatefulWidget {
  final String originTag;
  final String origin;

  const DiscoverItemPage({
    this.originTag,
    this.origin,
    Key key,
  }) : super(key: key);

  @override
  _DiscoverItemPageState createState() => _DiscoverItemPageState();
}

class _DiscoverItemPageState extends State<DiscoverItemPage> {
  Widget _discover;

  @override
  Widget build(BuildContext context) {
    if (_discover == null) {
      _discover = _buildDiscover();
    }
    return _discover;
  }

  Widget _buildDiscover() {
    return ChangeNotifierProvider<DiscoverPageController>.value(
      value: DiscoverPageController(
          originTag: widget.originTag, origin: widget.origin),
      child: Consumer<DiscoverPageController>(
        builder:
            (BuildContext context, DiscoverPageController pageController, _) {
          return Scaffold(
            appBar: pageController.isSearching
                ? AppBar(
                    backgroundColor: Colors.white,
                    iconTheme: IconThemeData(color: Colors.grey),
                    actionsIconTheme: IconThemeData(color: Colors.grey),
                    textTheme: Theme.of(context)
                        .textTheme
                        .apply(bodyColor: Colors.black87),
                    leading: IconButton(
                      icon: Icon(Icons.arrow_back),
                      onPressed: pageController.toggleSearching,
                    ),
                    actions: pageController.queryController.text == ''
                        ? <Widget>[]
                        : <Widget>[
                            IconButton(
                              icon: Icon(Icons.clear),
                              onPressed: pageController.clearInputText,
                            ),
                          ],
                    title: TextField(
                      controller: pageController.queryController,
                      autofocus: true,
                      decoration: InputDecoration(
                        hintStyle: TextStyle(color: Colors.black87),
                        hintText: '搜索 ${widget.origin}',
                        border: InputBorder.none,
                      ),
                      style: TextStyle(color: Colors.black87),
                      cursorColor: Theme.of(context).primaryColor,
                      textInputAction: TextInputAction.search,
                      onSubmitted: (query) => pageController.search(),
                    ),
                  )
                : AppBar(
                    title: Text(pageController.origin),
                    actions: <Widget>[
                      IconButton(
                        icon: Icon(Icons.search),
                        onPressed: pageController.toggleSearching,
                      ),
                      IconButton(
                        icon: Icon(Icons.filter_list),
                        onPressed: () {},
                      ),
                    ],
                  ),
            body: pageController.isLoading
                ? LandingPage()
                : RefreshIndicator(
                    onRefresh: pageController.search,
                    child: buildDiscoverResult(pageController.items, pageController.controller),
                  ),
          );
        },
      ),
    );
  }

  Widget buildDiscoverResult(List<SearchItem> items, ScrollController controller) {
    return GridView.builder(
      controller: controller,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.8,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
      ),
      padding: EdgeInsets.all(8.0),
      itemCount: items.length+1,
      itemBuilder: (BuildContext context, int index) {
        if(index == items.length){
          return Align(alignment: Alignment(0,-0.5),child: Text('加载下一页...', style: TextStyle(fontSize:  20),),);
        }
        SearchItem searchItem = items[index];
        if (SearchItemManager.isFavorite(searchItem.url)) {
          searchItem = SearchItemManager.searchItem
              .firstWhere((item) => item.url == searchItem.url);
        }
        return InkWell(
          child: UIDiscoverItem(item: searchItem),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
                builder: (context) => ChapterPage(searchItem: searchItem)),
          ),
        );
      },
    );
  }
}
