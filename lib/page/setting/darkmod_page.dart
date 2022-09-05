// import 'package:cupertino_list_tile/cupertino_list_tile.dart';
// import 'package:cupertino_lists/cupertino_lists.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../profile.dart';

class DarkModpage extends StatelessWidget {
  const DarkModpage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final darklist = [
      Profile.dartModeDark,
      Profile.dartModeLight,
      Profile.dartModeAuto,
    ];
    return Material(
        child: CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      navigationBar: CupertinoNavigationBar(
        middle: Text("夜间模式"),
        border: null,
        backgroundColor: CupertinoDynamicColor.withBrightness(
          color: Color(0xF0F9F9F9),
          darkColor: Color(0xF01D1D1D),
        ),
      ),
      child: Consumer<Profile>(
        builder: (BuildContext context, Profile profile, Widget widget) {
          return Padding(
            padding:
                EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.1),
            child: CupertinoListSection.insetGrouped(
              children: List.generate(
                  darklist.length,
                  (index) => CupertinoListTile.notched(
                        title: Text(darklist[index]),
                        leading: Icon(
                          CupertinoIcons.moon_stars,
                          color: Colors.blue,
                        ),
                        trailing: const CupertinoListTileChevron(),
                      )),
            ),
          );

          // ListView.builder(
          //   itemCount: darklist.length,
          //   itemBuilder: (BuildContext context, int index) {
          //     return _buildColorListTile(darklist[index]);
          //   },
          // );
        },
      ),
    ));
  }

  Widget _buildColorListTile(String darkMod) {
    return Consumer<Profile>(
      builder: (BuildContext context, Profile profile, Widget widget) {
        return CupertinoListTile(title: Text("data"));

        return ListTile(
            title: Text(darkMod),
            trailing: darkMod == profile.darkMode
                ? Icon(
                    Icons.done,
                    size: 32,
                    color: Theme.of(context).primaryColor,
                  )
                : null,
            onTap: () => profile.darkMode = darkMod);
      },
    );
  }
}
