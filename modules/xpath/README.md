# xpath
[![Pub](https://img.shields.io/pub/v/xpath_parse.svg?style=flat-square)](https://pub.dartlang.org/packages/xpath_parse)
[![support](https://img.shields.io/badge/platform-flutter%7Cdart%20vm-ff69b4.svg?style=flat-square)](https://github.com/codingfd/xpath)<br>
XPath selector based on html.
## Get started
### Add dependency
```yaml
dependencies:
  xpath_parse: lastVersion
```
### Super simple to use

```dart
final String html = '''
<html>
<div><a href='https://github.com'>github.com</a></div>
<div class="head">head</div>
<table><tr><td>1</td><td>2</td><td>3</td><td>4</td></tr></table>
<div class="end">end</div>
</html>
''';

XPath.source(html).query("//div/a/text()").list()

```

more simple refer to [this](https://github.com/codingfd/xpath/blob/master/test/xpath_test.dart)

## Syntax supported:
<table>
    <tr>
        <td width="100">Name</td>
        <td width="100">Expression</td>
    </tr>
    <tr>
        <td>immediate parent</td>
        <td>/</td>
    </tr>
    <tr>
        <td>parent</td>
        <td>//</td>
    </tr>
    <tr>
        <td>attribute</td>
        <td>[@key=value]</td>
    </tr>
    <tr>
        <td>nth child</td>
        <td>tag[n]</td>
    </tr>
    <tr>
        <td>attribute</td>
        <td>/@key</td>
    </tr>
    <tr>
        <td>wildcard in tagname</td>
        <td>/*</td>
    </tr>
    <tr>
        <td>function</td>
        <td>function()</td>
    </tr>
</table>

### Extended syntax supported:

These XPath syntax are extended only in Xsoup (for convenience in extracting HTML, refer to Jsoup CSS Selector):

<table>
    <tr>
        <td width="100">Name</td>
        <td width="100">Expression</td>
        <td>Support</td>
    </tr>
    <tr>
        <td>attribute value not equals</td>
        <td>[@key!=value]</td>
        <td>yes</td>
    </tr>
    <tr>
        <td>attribute value start with</td>
        <td>[@key~=value]</td>
        <td>yes</td>
    </tr>
    <tr>
        <td>attribute value end with</td>
        <td>[@key$=value]</td>
        <td>yes</td>
    </tr>
    <tr>
        <td>attribute value contains</td>
        <td>[@key*=value]</td>
        <td>yes</td>
    </tr>
    <tr>
        <td>attribute value match regex</td>
        <td>[@key~=value]</td>
        <td>yes</td>
    </tr>
</table>