/*
 * Copyright (c) 2020 CHANGLEI. All rights reserved.
 */

import 'package:flutter/material.dart';

/// Created by changlei on 2020/5/20.
///
/// 保持state生命周期，详情请看[AutomaticKeepAliveClientMixin]
class KeepAliveWidget extends StatefulWidget {
  final bool wantKeepAlive;
  final Widget child;

  const KeepAliveWidget({
    Key key,
    @required this.wantKeepAlive,
    @required this.child,
  })  : assert(wantKeepAlive != null),
        super(key: key);

  @override
  _KeepAliveWidgetState createState() => _KeepAliveWidgetState();
}

class _KeepAliveWidgetState extends State<KeepAliveWidget> with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }

  @override
  bool get wantKeepAlive => widget.wantKeepAlive;
}
