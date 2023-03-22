import 'analyzer.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart' as parser;

class AnalyzerHtml implements Analyzer {
  Element _element;

  @override
  AnalyzerHtml parse(content) {
  //   final d = parser.parse('''<div class="path test">
  //   <div class="p"><a href="/">顶点小说</a> &gt; <a href="/ebook/33715.html">自律的我简直无敌了最新章节</a>
  //   <span class="oninfo"><a rel="nofollow" href="javascript:addBookCase('33715');">加入书架</a></span></div></div>
	// ''').documentElement;
  //   for (var it in d.querySelectorAll(".path.test a")) {
  //     print(it.outerHtml);
  //   }
    if (content is Element) {
      _element = content;
    } else if (content is Document) {
      _element = content.documentElement;
    } else if (content is String) {
      _element = parser.parse(content).documentElement;
    } else if (content is List<String>) {
      _element = parser.parse(content.join("\n")).documentElement;
    } else if (content is List<Element>) {
      if (content.length == 1) {
        _element = content.first;
      } else {
        _element =
            parser.parse(content.map((e) => e.outerHtml).join("\n")).documentElement;
      }
    } else if (content is List) {
      _element = parser.parse(content.join("\n")).documentElement;
    } else {
      _element = parser.parse('$content').documentElement;
    }
    return this;
  }

  static String getHtmlString(String outerHtml) {
    /// 内部处理文字规则，图文混排
    /// 去掉script和style节点;img标签单独成段，块级元素换行 其他标签直接移除
    /// 块级元素 https://developer.mozilla.org/zh-CN/docs/Web/HTML/Block-level_elements
    /// <article> <dd> <div> <dl> <h1>, <h2>, <h3>, <h4>, <h5>, <h6> <hr> <p> <br>
    /// 网页编码转文本
    /*
         *北方酱保佑代码能用**********************************
        ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣀⣀⣀⣀⣤⠤⢤⣤⣄⣀⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
        ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⣠⠤⠖⠚⠉⠉⠉⠉⠀⠀⠀⠀⠀⠀⠀⠈⠉⠑⠲⠤⣄⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
        ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⣠⠖⠋⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠙⠲⣤⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
        ⠀⠀⠀⠀⠀⠀⠀⠀⢶⣒⡒⠒⠒⠋⠉⠁⠀⠀⠀⠀⠀⠀⠀⢀⣀⠀⠀⠀⣠⡄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠲⣄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
        ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠉⠛⢛⡖⠀⠀⠀⠀⠀⠀⣆⡤⠚⢩⠏⠀⣠⠞⠁⠹⣄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡄⡀⠀⠀⠀⠈⠳⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀
        ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣠⠏⠀⠀⠀⠀⣠⠞⠙⠋⠀⠀⢸⠖⠚⠁⠀⠀⠀⠈⠳⣄⡞⠳⡄⠀⠀⠀⠀⠀⢿⣍⠛⠲⣄⡀⠀⠹⡄⠀⠀⠀⠀⠀⠀⠀⠀
        ⠀⠀⠀⠀⠀⠀⠀⠀⠀⣠⣴⠏⠀⠀⠀⣠⡾⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠹⡄⠀⠀⠀⠀⠘⣧⠀⠀⠀⣙⣶⡀⢳⠀⠀⠀⠀⠀⠀⠀⠀
        ⠀⠀⠀⠀⠀⠀⠀⠀⡞⢡⠇⠀⠀⠀⢐⡟⠁⠀⠀⠀⠀⠀⣀⣠⠴⠀⠀⠀⠀⠤⣄⠀⠀⠀⠀⠀⢹⡀⣆⠀⠀⠀⢿⡀⣠⣾⣿⣿⠁⠈⣇⠀⠀⠀⠀⠀⠀⠀
        ⠀⠀⠀⠀⠀⠀⠀⠀⠳⡿⢸⡆⠀⠀⡏⠀⠀⠀⠀⠀⠙⠉⠁⠀⠀⠀⠀⠀⠀⠀⠈⠙⠓⠲⠀⠀⠀⠓⢾⠀⠀⠀⢸⣿⣿⣿⡟⠁⠀⠀⢸⡄⠀⠀⠀⠀⠀⠀
        ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠁⢸⠃⠀⢸⠀⠀⠀⣀⣤⣤⣄⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣀⣀⣀⡀⠀⠀⢸⠀⠀⠀⠈⣿⠟⠋⠀⠀⠀⠀⠀⢧⠀⠀⠀⠀⠀⠀
        ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣸⠀⠀⣸⠀⢀⡞⡭⣤⡤⣌⠻⣆⠀⠀⠀⠀⠀⠀⠀⢠⠟⢩⣬⣭⣙⠳⣄⣽⠀⠀⠀⠀⣿⠀⠀⠀⠀⠀⠀⠀⠘⡆⠀⠀⠀⠀⠀
        ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡏⠀⠀⢹⠀⡜⣼⣿⣿⣿⡿⡆⠙⠀⠀⠀⠀⠀⠀⠀⠋⣼⣾⣿⣿⣿⣧⠈⣿⠀⠀⠀⠀⢹⠀⠀⠀⠀⠀⠀⠀⠀⢷⠀⠀⠀⠀⠀
        ⠀⠀⠀⠀⠀⠀⠀⠀⠀⢠⡇⠀⠀⢸⠀⠃⣿⣿⣿⣯⣷⡇⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⣿⣿⢻⣿⣺⠄⣿⠀⠀⠀⠀⢸⠀⠀⠀⠀⠀⠀⠀⠀⢸⠀⠀⠀⠀⠀
        ⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⠀⠀⠀⢸⠀⠀⢻⡿⣿⣿⡿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠘⣿⣿⣿⣿⣿⣿⠀⣿⠀⠀⠀⠀⢸⠀⠀⠀⠀⠀⠀⠀⠀⢸⠀⠀⠀⠀⠀
        ⠀⠀⠀⠀⠀⠀⠀⠀⠀⣾⠀⠀⡼⠉⠀⠀⠀⠙⠛⠋⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠻⠿⠽⠞⠁⠀⡟⠀⠀⠀⠀⢸⠀⠀⠀⠀⠀⠀⠀⠀⢸⡇⠀⠀⠀⠀
        ⠀⠀⠀⠀⢀⡤⠤⣄⣠⡇⠀⡀⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡇⠀⠀⠀⠀⢸⠀⠀⠀⠀⠀⢀⣀⠠⣸⡇⠀⠀⠀⠀
        ⠀⠀⠀⠀⢸⣄⠀⠀⠈⠑⢻⣷⡞⣆⡀⢀⣠⣶⢖⣄⠀⠀⢀⣀⣤⣤⠀⠀⢀⣀⣤⡦⣄⠀⠀⠀⠀⢀⡇⠀⠀⠀⠀⢸⠀⣠⣶⡔⠋⠁⠀⠀⣠⣇⠀⠀⠀⠀
        ⠀⡠⠚⠉⠉⠉⠁⠀⠀⠀⢸⣿⣿⣴⣿⣿⣿⣿⣯⣮⣷⣮⣿⣿⣿⣿⣷⣶⣿⣿⣿⣿⣧⣷⢦⢔⢋⣹⠀⠀⠀⠀⠀⣿⣐⣿⣿⡷⠀⠀⠀⠈⠉⠉⠑⠢⡀⠀
        ⠀⣇⠀⠀⠀⠀⠀⠀⠀⢀⣾⣿⡟⢿⣛⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⠀⠀⠀⠀⠀⣿⣿⣿⣿⣿⣆⣀⡀⠀⠀⠀⠀⠀⢸⠀
        ⠀⠈⠑⠒⠒⠒⠚⣿⡿⣿⠟⠋⠃⠀⠻⣿⣟⡿⣿⣿⣿⣿⣿⣿⣿⣟⣿⢟⡟⣿⣿⣿⠿⢿⠋⣸⣻⠃⠀⠀⠀⠀⢸⡿⠛⠁⠛⠛⠿⢿⣿⠉⠛⠒⠛⢻⡁⠀
        ⠀⠀⠀⠀⠀⠀⠀⢸⡇⠙⣆⠀⠀⠀⠀⢸⡟⠉⠁⠀⠈⠛⠛⠉⠀⠀⠈⠑⠊⠊⠁⠀⠀⠀⠙⢡⠃⠀⠀⠀⠀⠀⡾⠀⠀⠀⠀⠀⣠⠃⠀⠁⠀⠀⠀⠈⢷⠀
        ⠀⠀⠀⠀⠀⠀⠀⠘⡇⠀⠘⣆⠀⠀⠀⢸⠇⠀⠀⠀⠀⠀⠀⠀⠀⣀⡀⠀⠀⠀⠀⠀⠀⠀⢀⡏⠀⠀⠀⠀⠀⣼⡇⠀⠀⠀⠀⡰⠃⠀⠀⠀⠀⠀⠀⠀⢸⡆
        ⠀⠀⠀⠀⠀⠀⠀⠀⢳⡀⠀⠘⣆⠀⠀⡾⠀⠀⠀⠀⠀⠀⣾⣿⣿⣿⡇⠀⠀⠀⠀⠀⠀⠀⢸⠃⠀⠀⠀⠀⡴⠁⡇⠀⠀⢀⡼⠁⠀⠀⠀⠀⠀⠀⠀⠀⣸⠀
        ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠓⠦⡄⠀⠀⡼⠁⠀⠀⠀⠀⠀⠀⠛⠻⠻⠛⠁⠀⠀⠀⠀⠀⠀⠀⢸⠀⠀⠀⢀⡼⠁⠀⢹⡀⠀⠚⠀⠀⠀⠀⠀⠀⠀⠀⣀⡴⠃⠀
        ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡾⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠘⠀⢀⡠⠊⠀⠀⠀⠀⠳⠀⠀⠀⠀⠀⠀⠀⠀⠐⠊⠁⠀⠀⠀
         */
    final imgReg = RegExp(r"<img[^>]*>");
    final html = outerHtml
        .replaceAllMapped(imgReg, (match) => "\n" + match.group(0) + "\n")
        .replaceAll(RegExp(r"</?(?:div|p|br|hr|h\d|article|dd|dl)[^>]*>"), "\n");
    //  .replaceAll(RegExp(r"^\s*|</?(?!img)\w+[^>]*>"), "");
    return html.splitMapJoin(
      imgReg,
      onMatch: (match) => match.group(0) + "\n",
      onNonMatch: (noMatch) => noMatch.trim().isEmpty
          ? ""
          : parser.parse("$noMatch").documentElement.text + "\n",
    );
  }

  String _getResult(Element e, String lastRule) {
    switch (lastRule) {
      case 'text':
        return e.text.trim();
      case 'textNodes':
        return e.children
            .map((e) => e.text)
            .where((e) => e.isNotEmpty)
            .join("\n")
            .trim(); // 适用于文字类正文 用换行符
      case 'id':
        return e.id;
      case 'outerHtml':
        return e.outerHtml.trim();
      case 'innerHtml':
        return e.innerHtml.trim();
      case 'html':

        /// 内部处理文字规则，图文混排
        /// 去掉script和style节点;img标签单独成段，块级元素换行 其他标签直接移除
        /// 块级元素 https://developer.mozilla.org/zh-CN/docs/Web/HTML/Block-level_elements
        /// <article> <dd> <div> <dl> <h1>, <h2>, <h3>, <h4>, <h5>, <h6> <hr> <p> <br>
        /// 网页编码转文本
        /*
         *北方酱保佑代码能用**********************************
        ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣀⣀⣀⣀⣤⠤⢤⣤⣄⣀⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
        ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⣠⠤⠖⠚⠉⠉⠉⠉⠀⠀⠀⠀⠀⠀⠀⠈⠉⠑⠲⠤⣄⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
        ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⣠⠖⠋⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠙⠲⣤⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
        ⠀⠀⠀⠀⠀⠀⠀⠀⢶⣒⡒⠒⠒⠋⠉⠁⠀⠀⠀⠀⠀⠀⠀⢀⣀⠀⠀⠀⣠⡄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠲⣄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
        ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠉⠛⢛⡖⠀⠀⠀⠀⠀⠀⣆⡤⠚⢩⠏⠀⣠⠞⠁⠹⣄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡄⡀⠀⠀⠀⠈⠳⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀
        ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣠⠏⠀⠀⠀⠀⣠⠞⠙⠋⠀⠀⢸⠖⠚⠁⠀⠀⠀⠈⠳⣄⡞⠳⡄⠀⠀⠀⠀⠀⢿⣍⠛⠲⣄⡀⠀⠹⡄⠀⠀⠀⠀⠀⠀⠀⠀
        ⠀⠀⠀⠀⠀⠀⠀⠀⠀⣠⣴⠏⠀⠀⠀⣠⡾⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠹⡄⠀⠀⠀⠀⠘⣧⠀⠀⠀⣙⣶⡀⢳⠀⠀⠀⠀⠀⠀⠀⠀
        ⠀⠀⠀⠀⠀⠀⠀⠀⡞⢡⠇⠀⠀⠀⢐⡟⠁⠀⠀⠀⠀⠀⣀⣠⠴⠀⠀⠀⠀⠤⣄⠀⠀⠀⠀⠀⢹⡀⣆⠀⠀⠀⢿⡀⣠⣾⣿⣿⠁⠈⣇⠀⠀⠀⠀⠀⠀⠀
        ⠀⠀⠀⠀⠀⠀⠀⠀⠳⡿⢸⡆⠀⠀⡏⠀⠀⠀⠀⠀⠙⠉⠁⠀⠀⠀⠀⠀⠀⠀⠈⠙⠓⠲⠀⠀⠀⠓⢾⠀⠀⠀⢸⣿⣿⣿⡟⠁⠀⠀⢸⡄⠀⠀⠀⠀⠀⠀
        ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠁⢸⠃⠀⢸⠀⠀⠀⣀⣤⣤⣄⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣀⣀⣀⡀⠀⠀⢸⠀⠀⠀⠈⣿⠟⠋⠀⠀⠀⠀⠀⢧⠀⠀⠀⠀⠀⠀
        ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣸⠀⠀⣸⠀⢀⡞⡭⣤⡤⣌⠻⣆⠀⠀⠀⠀⠀⠀⠀⢠⠟⢩⣬⣭⣙⠳⣄⣽⠀⠀⠀⠀⣿⠀⠀⠀⠀⠀⠀⠀⠘⡆⠀⠀⠀⠀⠀
        ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡏⠀⠀⢹⠀⡜⣼⣿⣿⣿⡿⡆⠙⠀⠀⠀⠀⠀⠀⠀⠋⣼⣾⣿⣿⣿⣧⠈⣿⠀⠀⠀⠀⢹⠀⠀⠀⠀⠀⠀⠀⠀⢷⠀⠀⠀⠀⠀
        ⠀⠀⠀⠀⠀⠀⠀⠀⠀⢠⡇⠀⠀⢸⠀⠃⣿⣿⣿⣯⣷⡇⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⣿⣿⢻⣿⣺⠄⣿⠀⠀⠀⠀⢸⠀⠀⠀⠀⠀⠀⠀⠀⢸⠀⠀⠀⠀⠀
        ⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⠀⠀⠀⢸⠀⠀⢻⡿⣿⣿⡿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠘⣿⣿⣿⣿⣿⣿⠀⣿⠀⠀⠀⠀⢸⠀⠀⠀⠀⠀⠀⠀⠀⢸⠀⠀⠀⠀⠀
        ⠀⠀⠀⠀⠀⠀⠀⠀⠀⣾⠀⠀⡼⠉⠀⠀⠀⠙⠛⠋⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠻⠿⠽⠞⠁⠀⡟⠀⠀⠀⠀⢸⠀⠀⠀⠀⠀⠀⠀⠀⢸⡇⠀⠀⠀⠀
        ⠀⠀⠀⠀⢀⡤⠤⣄⣠⡇⠀⡀⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡇⠀⠀⠀⠀⢸⠀⠀⠀⠀⠀⢀⣀⠠⣸⡇⠀⠀⠀⠀
        ⠀⠀⠀⠀⢸⣄⠀⠀⠈⠑⢻⣷⡞⣆⡀⢀⣠⣶⢖⣄⠀⠀⢀⣀⣤⣤⠀⠀⢀⣀⣤⡦⣄⠀⠀⠀⠀⢀⡇⠀⠀⠀⠀⢸⠀⣠⣶⡔⠋⠁⠀⠀⣠⣇⠀⠀⠀⠀
        ⠀⡠⠚⠉⠉⠉⠁⠀⠀⠀⢸⣿⣿⣴⣿⣿⣿⣿⣯⣮⣷⣮⣿⣿⣿⣿⣷⣶⣿⣿⣿⣿⣧⣷⢦⢔⢋⣹⠀⠀⠀⠀⠀⣿⣐⣿⣿⡷⠀⠀⠀⠈⠉⠉⠑⠢⡀⠀
        ⠀⣇⠀⠀⠀⠀⠀⠀⠀⢀⣾⣿⡟⢿⣛⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⠀⠀⠀⠀⠀⣿⣿⣿⣿⣿⣆⣀⡀⠀⠀⠀⠀⠀⢸⠀
        ⠀⠈⠑⠒⠒⠒⠚⣿⡿⣿⠟⠋⠃⠀⠻⣿⣟⡿⣿⣿⣿⣿⣿⣿⣿⣟⣿⢟⡟⣿⣿⣿⠿⢿⠋⣸⣻⠃⠀⠀⠀⠀⢸⡿⠛⠁⠛⠛⠿⢿⣿⠉⠛⠒⠛⢻⡁⠀
        ⠀⠀⠀⠀⠀⠀⠀⢸⡇⠙⣆⠀⠀⠀⠀⢸⡟⠉⠁⠀⠈⠛⠛⠉⠀⠀⠈⠑⠊⠊⠁⠀⠀⠀⠙⢡⠃⠀⠀⠀⠀⠀⡾⠀⠀⠀⠀⠀⣠⠃⠀⠁⠀⠀⠀⠈⢷⠀
        ⠀⠀⠀⠀⠀⠀⠀⠘⡇⠀⠘⣆⠀⠀⠀⢸⠇⠀⠀⠀⠀⠀⠀⠀⠀⣀⡀⠀⠀⠀⠀⠀⠀⠀⢀⡏⠀⠀⠀⠀⠀⣼⡇⠀⠀⠀⠀⡰⠃⠀⠀⠀⠀⠀⠀⠀⢸⡆
        ⠀⠀⠀⠀⠀⠀⠀⠀⢳⡀⠀⠘⣆⠀⠀⡾⠀⠀⠀⠀⠀⠀⣾⣿⣿⣿⡇⠀⠀⠀⠀⠀⠀⠀⢸⠃⠀⠀⠀⠀⡴⠁⡇⠀⠀⢀⡼⠁⠀⠀⠀⠀⠀⠀⠀⠀⣸⠀
        ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠓⠦⡄⠀⠀⡼⠁⠀⠀⠀⠀⠀⠀⠛⠻⠻⠛⠁⠀⠀⠀⠀⠀⠀⠀⢸⠀⠀⠀⢀⡼⠁⠀⢹⡀⠀⠚⠀⠀⠀⠀⠀⠀⠀⠀⣀⡴⠃⠀
        ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡾⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠘⠀⢀⡠⠊⠀⠀⠀⠀⠳⠀⠀⠀⠀⠀⠀⠀⠀⠐⠊⠁⠀⠀⠀
         */
        e.querySelectorAll("script,style").forEach((element) => element.remove());
        return getHtmlString(e.outerHtml);
      default:
        final r = e.attributes[lastRule];
        return null == r ? '' : r.trim();
    }
  }

  @override
  List<String> getString(String rule) {
    return getStringList(rule);
  }

  @override
  List<String> getStringList(String rule) {
    if (!rule.contains('@')) {
      return <String>[_getResult(_element, rule)];
    }
    final result = <String>[];
    final split = rule.lastIndexOf("@");
    final lastRule = rule.substring(split + 1);
    final elementList = _element.querySelectorAll(rule.substring(0, split));
    for (var e in elementList) {
      final r = _getResult(e, lastRule);
      if (r.isNotEmpty) result.add(r);
    }
    return result;
  }

  @override
  List<Element> getElements(String rule) {
    return _element.querySelectorAll(rule);
  }
}
