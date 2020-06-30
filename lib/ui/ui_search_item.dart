import 'package:eso/api/api.dart';
import 'package:eso/ui/ui_image_item.dart';
import 'package:flutter/material.dart';
import '../database/search_item.dart';
import '../utils.dart';

class UiSearchItem extends StatelessWidget {
  final SearchItem item;
  final bool showType;

  const UiSearchItem({
    @required this.item,
    this.showType = false,
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _UiSearchItem(
      origin: showType ? item.origin : "",
      cover: item.cover,
      name: item.name,
      author: item.author,
      chapter: item.chapter,
      description: item.description,
      contentTypeName: showType ? API.getRuleContentTypeName(item.ruleContentType) : "",
    );
  }
}

class _UiSearchItem extends StatelessWidget {
  final String origin;
  final String cover;
  final String name;
  final String author;
  final String chapter;
  final String description;
  final String contentTypeName;

  const _UiSearchItem({
    this.origin,
    this.cover,
    this.name,
    this.author,
    this.chapter,
    this.description,
    this.contentTypeName,
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _txtStyle = TextStyle(
      color: Theme.of(context).textTheme.bodyText1.color.withOpacity(0.75),
    );
    return Container(
      constraints: BoxConstraints(minHeight: 110, minWidth: double.infinity),
      padding: const EdgeInsets.only(top: 8, bottom: 8),
      child: DefaultTextStyle(
        style: TextStyle(fontSize: 13, color: Theme.of(context).hintColor, height: 1.5),
        overflow: TextOverflow.ellipsis,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(width: 8),
            SizedBox(
              width: 80,
              height: 104,
              child: UIImageItem(cover: cover, hero: '$name.$cover'),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          name?.trim() ?? '',
                          maxLines: 2,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).textTheme.bodyText1.color,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      contentTypeName != null && contentTypeName.isNotEmpty
                          ? Container(
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor,
                                borderRadius: BorderRadius.circular(2),
                              ),
                              margin: const EdgeInsets.only(left: 6),
                              padding: EdgeInsets.symmetric(horizontal: 3, vertical: 0),
                              alignment: Alignment.centerLeft,
                              child: Text(
                                contentTypeName,
                                style: TextStyle(
                                  fontSize: 11,
                                  height: 1.4,
                                  color: Colors.white,
                                  textBaseline: TextBaseline.alphabetic,
                                ),
                              ),
                            )
                          : SizedBox(),
                    ],
                  ),
                  SizedBox(height: 5),
                  Row(
                    children: [
                      Icon(
                        Icons.supervised_user_circle,
                        size: 14,
                        color:
                            Theme.of(context).textTheme.bodyText1.color.withOpacity(0.75),
                      ),
                      SizedBox(width: 2),
                      Expanded(
                        child: Text(
                          (Utils.empty(author?.trim()) ? "" : "${author.trim()}  |  "),
                          maxLines: 1,
                          style: _txtStyle,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        (Utils.empty(origin?.trim()) ? "" : "${origin.trim()}"),
                        maxLines: 1,
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.fiber_new,
                        size: 14,
                        color:
                            Theme.of(context).textTheme.bodyText1.color.withOpacity(0.75),
                      ),
                      SizedBox(width: 2),
                      Flexible(
                        child: Text(
                          chapter?.trim() ?? "",
                          maxLines: 1,
                          style: _txtStyle,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.description,
                        size: 14,
                        color:
                            Theme.of(context).textTheme.bodyText1.color.withOpacity(0.75),
                      ),
                      SizedBox(width: 2),
                      Flexible(
                        child: Text(
                          description?.trim() ?? "",
                          style: TextStyle(fontSize: 12),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(width: 8),
          ],
        ),
      ),
    );
  }
}
