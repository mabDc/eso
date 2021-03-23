import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:text_composition/text_composition.dart';

void main() => runApp(MaterialApp(home: MyApp()));

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final bookName = "book name";
    return TextComposition(
      controller: TextCompositionController(
        // Global.prefs.containsKey(TextConfigKey) ? Global.prefs.getString(TextConfigKey) : {}
        config: TextCompositionConfig(
          animation: 'curl',
        ),
        loadChapter: (index) => List.generate(
            12 + math.Random().nextInt(34), (i) => "chapter $index, " + "paragraph $i. " * math.Random().nextInt(12)),
        chapters: List.generate(1234, (i) => "chapter $i, chapter name"),
        percent: 0.0001,
        onSave: (TextCompositionConfig config, double percent) {
          // Global.prefs.setString(TextConfigKey, config.toString());
          // searchItem.durContentIndex = (percent * NovelContentTotal).floor();
          print("save config: $config");
          print("save percent: $percent");
        },
        name: bookName,
      ),
      lastPage: Container(
        width: double.infinity,
        height: double.infinity,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(bookName),
            SizedBox(height: 10),
            Text("loading or nothing more"),
          ],
        ),
      ),
    );
  }
}
