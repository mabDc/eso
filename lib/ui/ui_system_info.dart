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
          padding: const EdgeInsets.only(
            bottom: 6,
            right: 16,
          ),
          child: Wrap(
            children: [
              Material(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.horizontal(
                  left: Radius.circular(10),
                  right: Radius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 2,
                    horizontal: 10,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(
                          '${widget.mangaInfo}',
                          style: TextStyle(
                            color: Colors.white,
                            textBaseline: TextBaseline.alphabetic,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        ' | ${widget.mangaCount}P ${provider.now} ${provider.level}',
                        style: TextStyle(
                          color: Colors.white,
                          textBaseline: TextBaseline.alphabetic,
                        ),
                      ),
                      SizedBox(width: 4),
                      BatteryView(electricQuantity: provider.level / 100),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
