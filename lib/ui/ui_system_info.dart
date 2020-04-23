import 'package:eso/model/system_info_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UISystemInfo extends StatefulWidget {
  const UISystemInfo({
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
        return Row(
          children: [
            Text(provider.level.toString(),
                style: TextStyle(color: Colors.white)),
            Container(
              padding: EdgeInsets.only(left: 10, right: 20),
              width: 27,
              height: 12,
              child: Stack(
                children: <Widget>[
                  Image.asset('lib/assets/reader_battery.png'),
                  Container(
                    margin: EdgeInsets.fromLTRB(2, 2, 2, 2),
                    width: 20 * provider.level / 100,
                    color: Color.fromARGB(255, 255, 255, 255),
                  )
                ],
              ),
            ),
            Text(provider.now, style: TextStyle(color: Colors.white)),
          ],
        );
      }),
    );
  }
}
