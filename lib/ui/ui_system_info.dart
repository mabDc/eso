import 'package:eso/model/system_info_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UISystemInfo extends StatefulWidget {
  final String mangaInfo;
  const UISystemInfo({
    this.mangaInfo,
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
          width: double.infinity,
          alignment: Alignment.bottomRight,
          padding: EdgeInsets.symmetric(horizontal: 8.0),
          decoration: BoxDecoration(
            color: Color.fromARGB(100, 0, 0, 0),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                '${widget.mangaInfo} ${provider.now} ${provider.level}%',
                style: TextStyle(color: Colors.white),
              ),
              Padding(padding: EdgeInsets.only(left: 2)),
              Container(
                width: 27,
                height: 12,
                child: Stack(
                  children: <Widget>[
                    Image.asset('lib/assets/reader_battery.png'),
                    Container(
                      margin: EdgeInsets.fromLTRB(2, 2, 2, 2),
                      width: 20 * provider.level / 100,
                      color: Color.fromARGB(255, 255, 255, 255),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
