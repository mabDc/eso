import 'package:flutter/material.dart';

/// 加载更多
class LoadMoreView extends StatelessWidget {

  const LoadMoreView({Key key, this.msg, this.axis = Axis.horizontal}) : super(key: key);

  final String msg;
  final Axis axis;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      alignment: Alignment.center,
      child: axis == null || axis == Axis.horizontal ?
      Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 12,
            height: 12,
            child: CircularProgressIndicator(strokeWidth: 1.0),
          ),
          SizedBox(width: 8),
          Text(
            msg ?? '',
            style: TextStyle(fontSize: 14, color: Theme.of(context).dividerColor),
          )
        ],
      ) : Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 1.0),
          ),
          SizedBox(height: 12),
          Text(
            msg ?? '',
            style: TextStyle(fontSize: 14, color: Theme.of(context).dividerColor),
          )
        ],
      )
    );
  }
}