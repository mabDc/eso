import 'package:eso/model/system_info_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'battery_view.dart';

class UISystemInfo extends StatefulWidget {
  final String mangaInfo;
  final int mangaCount;
  const UISystemInfo({
    this.mangaInfo,
    this.mangaCount,
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
        return Container(
          height: 20,
          alignment: Alignment.bottomRight,
          padding: EdgeInsets.symmetric(horizontal: 8.0),
          decoration: BoxDecoration(color: Color.fromARGB(100, 0, 0, 0)),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                '${widget.mangaInfo} 共${widget.mangaCount}页 ${provider.now} ${provider.level}',
                style: TextStyle(color: Colors.white),
              ),
              Padding(padding: EdgeInsets.only(left: 4)),
              BatteryView(electricQuantity: provider.level / 100),
            ],
          ),
        );
      }),
    );
  }
}
