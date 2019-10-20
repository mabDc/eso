import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../database/fake_data.dart';
import '../global.dart';
import '../ui/ui_search_item.dart';
import 'content_page.dart';

class ChapterPage extends StatefulWidget {
  const ChapterPage({Key key}) : super(key: key);

  @override
  _ChapterPageState createState() => _ChapterPageState();
}

class _ChapterPageState extends State<ChapterPage> {
  String type = "大列表";
  int durChapterIndex = 0;

  @override
  Widget build(BuildContext context) {
    final item = FakeData.shelfItem;
    final chapters = FakeData.chapterList;
    return Scaffold(
      appBar: AppBar(
        title: Text('${item["title"]}'),
      ),
      body: Column(
        children: <Widget>[
          UiSearchItem(
            cover: '${item["cover"]}!cover-400',
            title: '${item["title"]}',
            origin: "漫客栈💰",
            author: '${item["author_title"]}',
            chapter: '${item["chapter_title"]}',
            description: '${item["feature"]}',
          ),
          Container(
            height: 30,
            margin: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            alignment: Alignment(0, 0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    '章节',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                buildButton(context, "大列表"),
                buildButton(context, "小列表"),
                buildButton(context, "宫格"),
              ],
            ),
          ),
          Expanded(child: buildChapter(chapters)),
        ],
      ),
    );
  }

  MaterialButton buildButton(BuildContext context, String _type) {
    return MaterialButton(
      onPressed: () {
        setState(() {
          type = _type;
        });
      },
      shape: RoundedRectangleBorder(
        side: BorderSide(
          color: Theme.of(context).primaryColor,
          width: 1,
        ),
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
      minWidth: 8,
      child: Text(_type),
    );
  }

  Widget buildChapter(List chapters) {
    switch (type) {
      case "大列表":
        return ListView.builder(
          itemCount: chapters.length,
          itemBuilder: (context, index) {
            final chapter = chapters[index];
            final time = DateTime.fromMillisecondsSinceEpoch(int.parse(chapter["start_time"])*1000);
            return buildChild(
                context,
                index,
                Container(
                  padding: EdgeInsets.all(8),
                  alignment: FractionalOffset.centerLeft,
                  child: SizedBox(
                    height: 60,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        SizedBox(
                          width: 100,
                          height: double.infinity,
                          child: chapter["cover"] == null
                              ? Image.asset(
                                  Global.waitingPath,
                                  fit: BoxFit.cover,
                                )
                              : Image.network(
                                  '${chapter["cover"]}!cover-400',
                                  fit: BoxFit.cover,
                                ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text(chapter["title"]),
                              Text('$time'.substring(0, 16)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ));
          },
        );
      case "小列表":
        return GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, childAspectRatio: 3),
          itemCount: chapters.length,
          itemBuilder: (context, index) {
            final chapter = chapters[index];
            return buildChild(
              context,
              index,
              Container(
                padding: EdgeInsets.only(left: 8),
                alignment: FractionalOffset.centerLeft,
                child: Text(
                  chapter["title"],
                  textAlign: TextAlign.start,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            );
          },
        );
      default:
        return GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5, childAspectRatio: 1.5),
          itemCount: chapters.length,
          itemBuilder: (context, index) {
            return buildChild(
              context,
              index,
              Center(child: Text('${index + 1}')),
            );
          },
        );
    }
  }

  InkWell buildChild(BuildContext context, int index, Widget child) {
    return InkWell(
      onTap: () {
        setState(() {
          durChapterIndex = index;
        });
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => ContentPage()));
      },
      child: Card(
        color: durChapterIndex == index
            ? Theme.of(context).primaryColor
            : Colors.white,
        child: child,
      ),
    );
  }
}
