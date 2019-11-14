import 'package:eso/model/manga_page_provider.dart';
import 'package:eso/ui/ui_chapter_select.dart';
import 'package:eso/ui/ui_chapter_separate.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../database/search_item.dart';
import '../global.dart';
import 'langding_page.dart';

class MangaPage extends StatefulWidget {
  final SearchItem searchItem;

  const MangaPage({
    this.searchItem,
    Key key,
  }) : super(key: key);

  @override
  _MangaPageState createState() => _MangaPageState();
}

class _MangaPageState extends State<MangaPage> {
  Widget page;
  MangaPageProvider __provider;
  @override
  Widget build(BuildContext context) {
    if (page == null) {
      page = buildPage();
    }
    return page;
  }

  @override
  void dispose() {
    __provider?.dispose();
    super.dispose();
  }

  Widget buildPage() {
    return ChangeNotifierProvider<MangaPageProvider>.value(
      value: MangaPageProvider(searchItem: widget.searchItem),
      child: Scaffold(
        body: Consumer<MangaPageProvider>(
          builder: (BuildContext context, MangaPageProvider provider, _) {
            if (provider.content == null) {
              return LandingPage();
            }
            return GestureDetector(
              child: Stack(
                children: <Widget>[
                  _buildMangaContent(provider),
                  provider.showChapter
                      ? UIChapterSelect(
                          searchItem: widget.searchItem,
                          loadChapter: provider.loadChapter,
                        )
                      : Container(),
                  Positioned(
                    right: 10,
                    bottom: 0,
                    child: Container(
                      color: Colors.black.withAlpha(0x80),
                      child: Text(
                        '${provider.searchItem.durChapter} ${provider.content.length}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
              onTapUp: (TapUpDetails details) {
                final size = MediaQuery.of(context).size;
                if (details.globalPosition.dx > size.width * 3 / 8 &&
                    details.globalPosition.dx < size.width * 5 / 8 &&
                    details.globalPosition.dy > size.height * 3 / 8 &&
                    details.globalPosition.dy < size.height * 5 / 8) {
                  provider.showChapter = true;
                } else {
                  provider.showChapter = false;
                }
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildMangaContent(MangaPageProvider provider) {
    return ListView.builder(
      cacheExtent: double.infinity,
      padding: EdgeInsets.all(0),
      controller: provider.controller,
      itemCount: provider.content.length + 1,
      itemBuilder: (context, index) {
        if (index == provider.content.length) {
          return UIChapterSeparate(
            chapterName: provider.searchItem.durChapter,
            isLastChapter: (provider.searchItem.chaptersCount - 1) ==
                provider.searchItem.durChapterIndex,
            isLoading: provider.isLoading,
          );
        }
        final path = '${provider.content[index]}';
        return FadeInImage(
          placeholder: AssetImage(Global.waitingPath),
          image: NetworkImage(
            path,
            headers: provider.headers,
          ),
          fit: BoxFit.fitWidth,
        );
      },
    );
  }
}
