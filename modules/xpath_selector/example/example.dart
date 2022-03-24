import 'package:html/parser.dart';
import 'package:xpath_selector/xpath_selector.dart';

final String htmlString = '''
<html lang="en">
<body>
<div><a href='https://github.com/simonkimi'>author</a></div>
<div class="head">div head</div>
<div class="container">
    <table>
        <tbody>
          <tr>
              <td class="first1">1</td>
              <td class="first1">2</td>
              <td class="first2">3</td>
              <td class="first2">4</td>

              <td class="second1">one</td>
              <td class="second1">two</td>
              <td class="second1">three</td>
              <td class="second2">four</td>
          </tr>
        </tbody>
    </table>
</div>
<div class="end">end</div>

</body>
</html>
''';

void main() {
  // You can create xpath selector by html
  final xpath = XPath.html(htmlString);

  print(xpath.query('//td[1]').nodes);

  print(xpath.query('//div/a').nodes);

  // Or by html dom
  final htmlDom = parse(htmlString).documentElement!;
  final xpathFrom = XPath.htmlElement(htmlDom);
  print(xpathFrom.query('//div/a').nodes);

  // Or by element
  print(htmlDom.queryXPath(r'//div/a').nodes);

  print('-' * 10 + 'example' + '-' * 10);

  print('\n//div/a');
  print(htmlDom.queryXPath(r'//div/a').node);

  print('\n//div/a/@href');
  print(htmlDom.queryXPath(r'//div/a/@href').attr);

  print('\n//div/a/text()');
  print(htmlDom.queryXPath(r'//div/a/text()').attr);

  print('\n//tr/node()');
  print(htmlDom.queryXPath(r'//tr/node()').nodes);

  print('\n//td[1]/text()');
  print(htmlDom.queryXPath(r'//td[1]/text()').attrs);

  print('\n//td[last()]/text()');
  print(htmlDom.queryXPath(r'//td[last()]/text()').attrs);

  print('\n//td[last()-1]/text()');
  print(htmlDom.queryXPath(r'//td[last()-1]/text()').attrs);

  print('\n//td[@class="first1"]');
  print(htmlDom.queryXPath(r'//td[@class="first1"]/text()').attrs);

  print('\n//td[@class^="first"]');
  print(htmlDom.queryXPath(r'//td[@class^="fir"]/text()').attrs);

  print('\n//td[@class^="second" or position()>=7]');
  print(htmlDom
      .queryXPath(r'//td[@class="first1" or position()>=7]/text()')
      .attrs);

  print('\n//tr/child::*/text()');
  print(htmlDom.queryXPath(r'//tr/child::*/text()').attrs);
}
