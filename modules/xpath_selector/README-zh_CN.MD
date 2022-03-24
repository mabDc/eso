# xpath_selector

[![Pub](https://img.shields.io/pub/v/xpath_selector.svg?style=flat-square)](https://pub.dartlang.org/packages/xpath_selector)

一款用于定位Html和Xml元素的XPath选择器

[English](https://github.com/simonkimi/xpath_selector/blob/master/README.md) | 简体中文

## 轻松使用

您有三种方法可以进行XPath查询

```dart
// 通过字符串创建
final result1 = XPath.html(html).query('//div');
final result2 = XPath.xml(html).query('//child');

// 或通过htmlh或xml包的dom创建
final result3 = XPath.htmlElement(htmlDom).query('//div');
final result4 = XPath.xmlElement(xmlRoot).query('//child');

// 或直接通过Element查询
final result5 = htmlDom.queryXPath('//div');
final result6 = xmlRoot.queryXPath('//child');


// 获取查询结果的所有节点
print(result1.nodes);

// 获取查询结果的第一个节点
print(result1.node);

// 获取查询结果的所有属性
print(result1.attrs);

// 获取查询结果的第一个有效属性
print(result1.attr);
```

更多的例子可以参考 [Xml测试例](https://github.com/simonkimi/xpath_selector/blob/master/test/xml_test.dart) | [Html测试例](https://github.com/simonkimi/xpath_selector/blob/master/test/html_test.dart)

## 使用自定义的解析器
此库使用了 [html](https://pub.flutter-io.cn/packages/html) 和 [xml](https://pub.flutter-io.cn/packages/xml) 作为默认解析库

如果您想用其他的解析库(例如[universal_html](https://pub.flutter-io.cn/packages/universal_html)), 请参照 [`HtmlNodeTree`](https://github.com/simonkimi/xpath_selector/blob/master/lib/src/model/html.dart) 创建您自己的模型.

## 扩展语法

在属性选择器中, 本解析器以css风格扩展了如下属性选择器

| 表达式              | css             | 描述                             |
|------------------|-----------------|--------------------------------|
| [@attr='value']  | [attr="value"]  | 选择带有 attr="value" 属性的所有元素。     |
| [@attr~='value'] | [attr~="value"] | 选择 attr 属性包含单词 "value" 的所有元素。  |
| [@attr^='value'] | [attr^="value"] | 选择其 attr 属性值以 "value" 开头的元素。   |
| [@attr$='value'] | [attr$="value"] | 选择其 attr 属性值以 "value" 结尾的元素。   |
| [@attr*='value'] | [attr*="value"] | 选择其 attr 属性值中包含 "value" 子串的元素。 |

## 破坏性改动
### 1.x => 2.0
1. 移除类`XPathElement`, 与`XPathNode`类合并
2. `XPathResult`中`elements`改为`nodes`, `elements`改为`element`

## 提示
- 在解析html时, 一些不标准的的结构可能发生改变, 例如缺少`tbody`的`table`会被补上`tbody`, 这可能导致查询问题.