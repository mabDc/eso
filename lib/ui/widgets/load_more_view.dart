import 'dart:async';

import 'package:flutter/material.dart';

/// 加载更多
class LoadMoreView extends StatefulWidget {

  const LoadMoreView({Key key, this.msg, this.axis = Axis.horizontal, this.timeout}) : super(key: key);

  final String msg;
  final Axis axis;
  final int timeout;

 @override
  State<StatefulWidget> createState() => _LoadMoreViewState();
}

class _LoadMoreViewState extends State<LoadMoreView> {
  bool isTimeout = false;
  Timer _timer;

  @override
  void initState() {
    if (widget.timeout != null && widget.timeout > 0) {
      _timer = Timer(Duration(milliseconds: widget.timeout), () {
        if (this.mounted) {
          setState(() {
            isTimeout = true;
          });
        }
      });
    }
    super.initState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isTimeout == true)
      return Container();
    return Container(
        height: 50,
        alignment: Alignment.center,
        child: widget.axis == null || widget.axis == Axis.horizontal ?
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
              widget.msg ?? '',
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
              widget.msg ?? '',
              style: TextStyle(fontSize: 14, color: Theme.of(context).dividerColor),
            )
          ],
        )
    );
  }
}