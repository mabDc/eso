import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:text_composition/text_composition.dart';

void main() => runApp(MaterialApp(home: MyApp()));

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final bookName = "book name";
    return TextCompositionPage(
      controller: TextComposition(
        // Global.prefs.containsKey(TextConfigKey) ? Global.prefs.getString(TextConfigKey) : {}
        config: TextCompositionConfig(animation: 'curl'),
        loadChapter: (index) => Future.delayed(Duration(seconds: 1)).then((value) =>
            List.generate(
                123 + math.Random().nextInt(34),
                (i) =>
                    "chapter $index, " + "paragraph $i. " * math.Random().nextInt(12))),
        chapters: List.generate(1234, (i) => "chapter $i, chapter name"),
        percent: 0.000001,
        onSave: (TextCompositionConfig config, double percent) {
          // Global.prefs.setString(TextConfigKey, config);
          // searchItem.durContentIndex = (percent * NovelContentTotal).floor();
          print("save config: $config");
          print("save percent: $percent");
        },
        name: bookName,
      ),
    );
  }
}
