import 'package:eso/eso_theme.dart';
import 'package:eso/model/system_info_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'battery_view.dart';

class UISystemInfo extends StatefulWidget {
  final String mangaInfo;
  final int mangaCount;
  final int mangeCurrent;
  const UISystemInfo({
    this.mangaInfo,
    this.mangaCount,
    this.mangeCurrent,
    Key key,
  }) : super(key: key);

  @override
  _UISystemInfoState createState() => _UISystemInfoState();
}

class _UISystemInfoState extends State<UISystemInfo> {
  Widget page;
  SystemInfoProvider __provider;

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
    return ChangeNotifierProvider<SystemInfoProvider>.value(
      value: SystemInfoProvider(),
      child: Consumer<SystemInfoProvider>(
          builder: (BuildContext context, SystemInfoProvider provider, _) {
        __provider = provider;
        return SafeArea(
          child: Material(
            color: Colors.black.withOpacity(0.5),
            borderRadius: BorderRadius.horizontal(
              left: Radius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 2,
                horizontal: 10,
              ),
              child: DefaultTextStyle(
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontFamily: ESOTheme.staticFontFamily,
                  textBaseline: TextBaseline.alphabetic,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(width: 2),
                    Flexible(
                      child: Text(
                        '${widget.mangaInfo} ',
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    // Text(' ${widget.mangeCurrent}/'),
                    Text('${widget.mangaCount}'),
                    SizedBox(width: 8),
                    Text('${provider.now}'),
                    SizedBox(width: 6),
                    BatteryView(electricQuantity: provider.level, height: 11, width: 20),
                  ],
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
