import 'package:eso/global.dart';
import 'package:flutter/material.dart';

UiSearchItem buildUiSearchItem(itemInfo){
  final info = {"comic_id":"206800","chapter_id":"713011","start_chapter_id":"471790","title":"都市喵奇谭","cover":"http://oss.mkzcdn.com/comic/cover/20170712/596584cf25704-1309x1745.jpg","author_title":"橘花散里&saremi","chapter_num":"37","chapter_title":"番外：发糖？！","feature":"猫妖续命，交易灵魂","finish":"2","theme_id":"6,12"};
  return UiSearchItem(
    cover: '${info["cover"]}!cover-400',
    title: info["title"],
    origin: "漫客栈💰",
    author: info["author_title"],
    chapter: '${info["chapter_title"]}',
    description: info["feature"],
  );
}

class UiSearchItem extends StatelessWidget {
  final String origin;
  final String cover;
  final String title;
  final String author;
  final String chapter;
  final String description;

  const UiSearchItem({
    this.origin,
    this.cover,
    this.title,
    this.author,
    this.chapter,
    this.description,
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
        height: 100,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              width: 70,
              height: double.infinity,
              child: cover == null
                  ? Image.asset(
                      Global.waitingPath,
                      fit: BoxFit.cover,
                    )
                  : Image.network(
                      cover,
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
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          '$title',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      Text(
                        '$origin',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Theme.of(context)
                              .textTheme
                              .body1
                              .color
                              .withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '$author',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Theme.of(context)
                          .textTheme
                          .body1
                          .color
                          .withOpacity(0.7),
                    ),
                  ),
                  Text(
                    '$chapter',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '$description',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
