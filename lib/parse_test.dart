import 'dart:convert';
import 'package:html/parser.dart' show parse;

class Chapter {
  final String name;
  final String url;

  Chapter({this.name, this.url});

  static Future<String> parseJson(String jsonString) async{
    DateTime start = DateTime.now();
    final json = jsonDecode(jsonString);
    final chapters = (json["Data"]["Chapters"] as List)
        .skip(1)
        .map((c) => Chapter(name: "${c["V"] == 1 ? "🔒":""}${c["N"]}", url: "https://vipreader.qidian.com/chapter/3357187/${c["C"]}"))
        .toList();
    int time = DateTime.now().difference(start).inMilliseconds;
    return '''
json带vip解析耗时 $time ms
第一章：
${chapters.first.name}
${chapters.first.url}

最后一章：
${chapters.last.name}
${chapters.last.url}
''';
  }

  static Future<String> parseHTML(String htmlString) async {
    DateTime start = DateTime.now();
    final dom = parse(htmlString);
    final chapters = dom.querySelectorAll('#readerlist a')
        .map((a) =>
        Chapter(name: a.text,
            url: 'http://www.iqiwx.com/book/12/12732/${a.attributes["href"]}'))
        .toList();
    int time = DateTime
        .now()
        .difference(start)
        .inMilliseconds;
    return '''
HTML带vip解析耗时 $time ms
第一章：
${chapters.first.name}
${chapters.first.url}

最后一章：
${chapters.last.name}
${chapters.last.url}
''';
  }
}

