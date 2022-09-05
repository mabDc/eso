import 'dart:convert';

import 'package:eso/api/api_js_engine.dart';
import 'package:eso/menu/menu.dart';
import 'package:eso/model/moreKeys.dart';
import 'package:eso/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_qjs/flutter_qjs.dart';
import 'package:logger/logger.dart';
import 'package:win32/win32.dart';

class ksfenlei extends StatefulWidget {
  const ksfenlei({Key key}) : super(key: key);

  @override
  State<ksfenlei> createState() => _ksfenleiState();
}

class _ksfenleiState extends State<ksfenlei> {
  final _controller = TextEditingController();
  final _regexp_controller = TextEditingController();
  final _reg1_controller = TextEditingController();
  final _reg2_controller = TextEditingController();
  final _replace_controller = TextEditingController();
  final _morekeys_controller = TextEditingController();
  final _title_controller = TextEditingController();
  final _req_controller = TextEditingController();

  bool _isJson = false;

  Set<dynamic> listFilters = Set();

  bool _showList = false;

  // String dropdownValue = "去空";
  String oldText = "";

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: CupertinoPageScaffold(
        backgroundColor: CupertinoColors.systemGroupedBackground,
        navigationBar: CupertinoNavigationBar(
          middle: Text("快速分类"),
          border: null,
          backgroundColor: CupertinoDynamicColor.withBrightness(
            color: Color(0xF0F9F9F9),
            darkColor: Color(0xF01D1D1D),
          ),
        ),
        child: ListView.builder(
          itemCount: 1,
          itemBuilder: (context, index) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(left: 20, right: 20, top: 20),
                child: SizedBox(
                  height: 200,
                  child: TextField(
                    keyboardType: TextInputType.multiline,
                    // focusNode: FocusNode(),
                    //placeholder: "请输入分类标签HTML",
                    controller: _controller,
                    maxLines: 50,
                    decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(
                            1.0,
                          ),
                        ),
                        borderSide: BorderSide(
                          width: 1.0,
                          color: Theme.of(context).backgroundColor,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(
                            1.0,
                          ),
                        ),
                        borderSide: BorderSide(
                          width: 2.0,
                          color: Theme.of(context).backgroundColor,
                        ),
                      ),
                      hintText: "请输入分类标签HTML",
                      border: OutlineInputBorder(
                        borderSide: BorderSide(
                          width: 1.0,
                          color: Theme.of(context).backgroundColor,
                        ),
                        borderRadius: BorderRadius.circular(1.0),
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                  left: 20,
                  top: 10,
                ),
                child: Wrap(
                  runSpacing: 15,
                  //runAlignment: WrapAlignment.spaceAround,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    OutlinedButton(
                      onPressed: () {
                        try {
                          final _text = _controller.text;
                          oldText = _text;

                          final res = RegExp(
                                  "<(a|option)[\\s\\S]*?(href|value)\\s*?=\\s*?[\"'][\\s\\S]*?[\"'][\\s\\S]*?>[\\s\\S]*?<\/(a|option)>")
                              .allMatches(_text);
                          List<String> result = <String>[];
                          res.forEach((x) {
                            final tmp = x[0].replaceAll(
                                "<(span.*?|\/span|div.*?|\/div)>", "");
                            final list = RegExp(
                                    "<(a|option)[\\s\\S]*?(href|value)\\s*?=\\s*?[\"']([\\s\\S]*?)[\"'][\\s\\S]*?>([\\s\\S]*?)<\/(a|option)>")
                                .firstMatch(tmp);
                            result.add("${list[4].trim()}::${list[3].trim()}");
                            // if (dropdownValue == "去空") {
                            //   result.add("${list[4].trim()}::${list[3].trim()}");
                            // } else {
                            //   result.add("${list[4]}::${list[3]}");
                            // }
                            _controller.text = result.join("\n");
                          });
                        } catch (e) {
                          _controller.text = e;
                        }

                        setState(() {});
                      },
                      child: Text("转换"),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    OutlinedButton(
                      onPressed: () {
                        _controller.text = oldText;
                      },
                      child: Text("源数据"),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    OutlinedButton(
                      onPressed: () async {
                        await Clipboard.setData(
                            ClipboardData(text: _controller.text));
                        Utils.toast("已复制到剪辑板");
                      },
                      child: Text("复制"),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    OutlinedButton(
                      onPressed: () async {
                        final decString = await JSEngine.evaluate(
                            "decodeURI(${jsonEncode(_controller.text)})");
                        _controller.text = decString;

                        // print(decString);

                        setState(() {});
                      },
                      child: Text("URI解码"),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    OutlinedButton(
                      onPressed: () {
                        _controller.text = "";
                        oldText = "";
                        setState(() {});
                      },
                      child: Text("清空"),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    OutlinedButton(
                      onPressed: () async {
                        showCupertinoDialog(
                          context: context,
                          builder: (context) {
                            return CupertinoAlertDialog(
                              title: Text('添加到列表'),
                              content: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Divider(),
                                  Text(
                                    "将已处理好的数据(RequestFilters)添加到列表(list)\n请务必检查格式,分类{n}后边跟一个换行之后分类标签::标签数值继续换行.多个分类是两个换行连接:末尾一个换行再新起一个换行\ncat\n都市::dushi\n玄幻::xuanhuan\n奇幻::qihuan\n\nstatus\n连载::1\n完结::2\n全部::0",
                                    style:
                                        TextStyle(fontWeight: FontWeight.w600),
                                  ),
                                  Divider(),
                                  Row(
                                    children: [
                                      Text("标题:"),
                                      SizedBox(width: 10),
                                      SizedBox(
                                        height: 30,
                                        width: 100,
                                        child: CupertinoTextField(
                                          padding: EdgeInsets.only(
                                            top: 0,
                                            bottom: 0,
                                            left: 5,
                                            right: 5,
                                          ),
                                          controller: _title_controller,
                                          placeholder: "title",
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                                width: 1.0,
                                                color: Theme.of(context)
                                                    .backgroundColor),
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                              actions: [
                                CupertinoDialogAction(
                                  child: Text('取消'),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                                CupertinoDialogAction(
                                  child: Text('加入'),
                                  onPressed: () {
                                    //try {
                                    final title = _title_controller.text;
                                    if (title.isEmpty) {
                                      Utils.toast("标题为空");
                                      return;
                                    }

                                    final _text =
                                        _controller.text.replaceAll("\r", "");

                                    final lf = ListFilters.fromJson({
                                      'title': title,
                                      'requestFilters': _text
                                    });

                                    if (_isJson) {
                                      listFilters.add(lf);
                                    } else {
                                      listFilters.add({
                                        'title': title,
                                        'requestFilters': _text
                                      });
                                    }

                                    setState(() {});

                                    // provider.handleSelect([rule], MenuEditSource.fuben);
                                    Navigator.of(context).pop();
                                    // } catch (e) {
                                    //   print(e);

                                    //   Utils.toast("格式错误");
                                    // }
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      },
                      child: Text("添加列表"),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    OutlinedButton(
                      onPressed: () {
                        listFilters.clear();
                        setState(() {});
                      },
                      child: Text("清空列表"),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    OutlinedButton(
                      onPressed: () {
                        _showList = !_showList;
                        setState(() {});
                      },
                      child: Text(_showList ? "隐藏列表" : "显示列表"),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      "JSON数据",
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    CupertinoSwitch(
                      value: _isJson,
                      onChanged: (value) {
                        _isJson = value;
                        setState(() {});
                      },
                    )
                  ],
                ),
              ),
              _showList && listFilters.isNotEmpty
                  ? Padding(
                      padding: EdgeInsets.only(left: 0, top: 10, bottom: 10),
                      child: Column(
                        children: List.generate(listFilters.length, (index) {
                          final _list_controller = TextEditingController();
                          final lf = listFilters.elementAt(index);

                          _list_controller.text = (lf is ListFilters)
                              ? lf.toString()
                              : jsonEncode(lf);

                          return Padding(
                            padding:
                                EdgeInsets.only(left: 20, right: 20, top: 20),
                            child: SizedBox(
                              height: 35,
                              //height: 100,
                              child: TextField(
                                focusNode: FocusNode(),
                                controller: _list_controller,
                                maxLines: 1,
                                readOnly: true,
                                onChanged: ((value) {}),
                                decoration: InputDecoration(
                                  suffix: Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(4, 1, 8, 1),
                                    child: InkWell(
                                      child: Container(
                                        width: 16.0,
                                        height: 16.0,
                                        child: Icon(Icons.clear,
                                            color:
                                                Theme.of(context).dividerColor,
                                            size: 14.0),
                                      ),
                                      onTap: () => this.setState(() {
                                        listFilters.remove(
                                            listFilters.elementAt(index));
                                      }),
                                    ),
                                  ),
                                  contentPadding: EdgeInsets.only(
                                      top: 0, left: 5, right: 5, bottom: 0),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(
                                        1.0,
                                      ),
                                    ),
                                    borderSide: BorderSide(
                                      width: 1.0,
                                      color: Theme.of(context).backgroundColor,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(
                                        1.0,
                                      ),
                                    ),
                                    borderSide: BorderSide(
                                      width: 1.5,
                                      color: Theme.of(context).backgroundColor,
                                    ),
                                  ),
                                  hintText: "正则表达式",
                                  // hintStyle: TextStyle(fontSize: 12),
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      width: 1.0,
                                      color: Theme.of(context).backgroundColor,
                                    ),
                                    borderRadius: BorderRadius.circular(1.0),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    )
                  : Container(),
              Padding(
                padding: EdgeInsets.only(left: 20, top: 10),
                child: Text(
                  "正则操作",
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 20, right: 20, top: 20),
                child: SizedBox(
                  //height: 100,
                  child: TextField(
                    minLines: 1,
                    focusNode: FocusNode(),
                    //placeholder: "请输入分类标签HTML",
                    controller: _regexp_controller,
                    maxLines: 50,
                    onChanged: ((value) {
                      final result =
                          RegExp(value).allMatches(_controller.text).toList();
                      final allResult =
                          result.map((x) => x.group(0)).join("\n");

                      final subResult = result.map((e) {
                        final r = List.generate(
                                e.groupCount,
                                (index) =>
                                    "\$${index + 1}：${e.group(index + 1)}")
                            .join("\t");

                        return r;
                      }).join("\n");
                      if (subResult.trim().isEmpty) {
                        _reg2_controller.clear();
                      } else {
                        _reg2_controller.text = subResult;
                      }

                      if (allResult.trim().isEmpty) {
                        _reg1_controller.clear();
                      } else {
                        _reg1_controller.text = allResult;
                      }
                    }),
                    decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(
                            1.0,
                          ),
                        ),
                        borderSide: BorderSide(
                          width: 1.0,
                          color: Theme.of(context).backgroundColor,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(
                            1.0,
                          ),
                        ),
                        borderSide: BorderSide(
                          width: 2.0,
                          color: Theme.of(context).backgroundColor,
                        ),
                      ),
                      hintText: "正则表达式",
                      border: OutlineInputBorder(
                        borderSide: BorderSide(
                          width: 1.0,
                          color: Theme.of(context).backgroundColor,
                        ),
                        borderRadius: BorderRadius.circular(1.0),
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                  left: 20,
                  top: 10,
                  right: 20,
                ),
                child: Wrap(
                  runSpacing: 15,
                  children: [
                    SizedBox(
                      height: 150,
                      width: MediaQuery.of(context).size.width / 2 - 25,
                      child: TextField(
                        readOnly: true,
                        controller: _reg1_controller,
                        maxLines: 100,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.only(
                            top: 20,
                            right: 10,
                            left: 10,
                            bottom: 10,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(
                                1.0,
                              ),
                            ),
                            borderSide: BorderSide(
                              width: 1.0,
                              color: Theme.of(context).backgroundColor,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(
                                1.0,
                              ),
                            ),
                            borderSide: BorderSide(
                              width: 2.0,
                              color: Theme.of(context).backgroundColor,
                            ),
                          ),
                          disabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(
                                1.0,
                              ),
                            ),
                            borderSide: BorderSide(
                              width: 1.0,
                              color: Theme.of(context).backgroundColor,
                            ),
                          ),
                          hintText: "匹配结果",
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    SizedBox(
                      height: 150,
                      width: MediaQuery.of(context).size.width / 2 - 25,
                      child: TextField(
                        controller: _reg2_controller,
                        maxLines: 100,
                        readOnly: true,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.only(
                            top: 20,
                            right: 10,
                            left: 10,
                            bottom: 10,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(
                                1.0,
                              ),
                            ),
                            borderSide: BorderSide(
                              width: 1.0,
                              color: Theme.of(context).backgroundColor,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(
                                1.0,
                              ),
                            ),
                            borderSide: BorderSide(
                              width: 2.0,
                              color: Theme.of(context).backgroundColor,
                            ),
                          ),
                          disabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(
                                1.0,
                              ),
                            ),
                            borderSide: BorderSide(
                              width: 1.0,
                              color: Theme.of(context).backgroundColor,
                            ),
                          ),
                          hintText: "子匹配结果",
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 20, right: 20, top: 10),
                child: Wrap(
                  runSpacing: 15,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width / 2,
                      //height: 100,
                      child: TextField(
                        minLines: 1,
                        focusNode: FocusNode(),
                        //placeholder: "请输入分类标签HTML",
                        controller: _replace_controller,
                        maxLines: 50,
                        // onChanged: ((value) {
                        // }),
                        decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(
                                1.0,
                              ),
                            ),
                            borderSide: BorderSide(
                              width: 1.0,
                              color: Theme.of(context).backgroundColor,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(
                                1.0,
                              ),
                            ),
                            borderSide: BorderSide(
                              width: 2.0,
                              color: Theme.of(context).backgroundColor,
                            ),
                          ),
                          hintText: "替换数据",
                          border: OutlineInputBorder(
                            borderSide: BorderSide(
                              width: 1.0,
                              color: Theme.of(context).backgroundColor,
                            ),
                            borderRadius: BorderRadius.circular(1.0),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 20),
                    SizedBox(
                      // width: 100,
                      height: 45,
                      child: OutlinedButton(
                        onPressed: () async {
                          print("object");
                          try {
                            final _regexp = _regexp_controller.text;
                            final _replace = _replace_controller.text;
                            String _text = _controller.text;
                            String jscode =
                                'let reg = new RegExp(${jsonEncode(_regexp)},\'g\');${jsonEncode(_text)}.replace(reg,\'${_replace}\')';

                            Logger().d(jscode);
                            String result = await JSEngine.evaluate(jscode);
                            _controller.text = result;
                          } catch (e) {
                            Utils.toast("错误:$e");
                          }
                        },
                        child: Text("替换"),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 20, right: 20, top: 10),
                child: SizedBox(
                  //width: MediaQuery.of(context).size.width / 2-,
                  //height: 100,
                  child: TextField(
                    minLines: 5,
                    focusNode: FocusNode(),
                    controller: _morekeys_controller,
                    maxLines: 50,
                    onChanged: ((value) {}),
                    decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(
                            1.0,
                          ),
                        ),
                        borderSide: BorderSide(
                          width: 1.0,
                          color: Theme.of(context).backgroundColor,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(
                            1.0,
                          ),
                        ),
                        borderSide: BorderSide(
                          width: 2.0,
                          color: Theme.of(context).backgroundColor,
                        ),
                      ),
                      hintText: "MoreKeys",
                      border: OutlineInputBorder(
                        borderSide: BorderSide(
                          width: 1.0,
                          color: Theme.of(context).backgroundColor,
                        ),
                        borderRadius: BorderRadius.circular(1.0),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 20),
              Padding(
                padding: EdgeInsets.only(left: 20, top: 10, right: 10),
                child: Wrap(
                  runSpacing: 15,
                  children: [
                    SizedBox(
                      // width: 100,
                      height: 45,
                      child: OutlinedButton(
                        onPressed: () {
                          final _list = listFilters.map((e) {
                            final l = (e is ListFilters)
                                ? asT<ListFilters>(e)
                                : asT<Map>(e);
                            return l;
                          }).toList();

                          print(_list);
                          _morekeys_controller.text =
                              jsonEncode({"isWrap": true, "list": _list});

                          // print();

                          // listFilters.map((e) => e.toJson())
                        },
                        child: Text("生成MoreKeys"),
                      ),
                    ),
                    SizedBox(
                      width: 15,
                    ),
                    SizedBox(
                      // width: 100,
                      height: 45,
                      child: OutlinedButton(
                        onPressed: () async => await Clipboard.setData(
                            ClipboardData(text: _morekeys_controller.text)),
                        child: Text("复制"),
                      ),
                    ),
                    SizedBox(
                      width: 15,
                    ),
                    SizedBox(
                      // width: 100,
                      height: 45,
                      child: OutlinedButton(
                        onPressed: () => _morekeys_controller.text = "",
                        child: Text("清空"),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 20),
              Padding(
                padding: EdgeInsets.only(left: 20, right: 20, top: 10),
                child: SizedBox(
                  //width: MediaQuery.of(context).size.width / 2-,
                  // height: 100,
                  child: TextField(
                    minLines: 5,
                    focusNode: FocusNode(),
                    controller: _req_controller,
                    maxLines: 50,
                    onChanged: ((value) {}),
                    decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(
                            1.0,
                          ),
                        ),
                        borderSide: BorderSide(
                          width: 1.0,
                          color: Theme.of(context).backgroundColor,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(
                            1.0,
                          ),
                        ),
                        borderSide: BorderSide(
                          width: 2.0,
                          color: Theme.of(context).backgroundColor,
                        ),
                      ),
                      hintText: "请求规则",
                      border: OutlineInputBorder(
                        borderSide: BorderSide(
                          width: 1.0,
                          color: Theme.of(context).backgroundColor,
                        ),
                        borderRadius: BorderRadius.circular(1.0),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 20),
              Padding(
                padding: EdgeInsets.only(left: 20, top: 10, right: 10),
                child: Wrap(
                  runSpacing: 15,
                  children: [
                    SizedBox(
                      // width: 100,
                      height: 45,
                      child: OutlinedButton(
                        onPressed: () {
                          final _list = listFilters.map((e) {
                            final l = (e is ListFilters)
                                ? asT<ListFilters>(e)
                                : asT<Map>(e);
                            return l;
                          }).toList();

                          _morekeys_controller.text =
                              jsonEncode({"isWrap": true, "list": _list});

                          final moreKeys = ItemMoreKeys.fromJson(
                              {"isWrap": true, "list": _list});

                          String _s = "";

                          for (int i = 0; i < moreKeys.list.length; i++) {
                            final _title = moreKeys.list[i].title;
                            final _requestFilters =
                                moreKeys.list[i].requestFilters;

                            final _filters =
                                "let {${List.generate(_requestFilters.length, (index) => "${_requestFilters[index].key}${index == _requestFilters.length - 1 ? "" : ","}").join()}} = params.filters;";
                            final _expression =
                                "   if (params.tabIndex == ${i}){\n       // ${_title}\n      ${_filters}\n\n   }\n";

                            _s += _expression;
                          }
                          print("${_s}");
                          // print(_list);

                          String _js =
                              "@js:\n(async()=> {\n   let url;\n${_s}\n    return {\"url\": url };\n})()";
                          _req_controller.text = _js;

                          // final _list = listFilters.map((e) {
                          //   final l = (e is ListFilters)
                          //       ? asT<ListFilters>(e)
                          //       : asT<Map>(e);
                          //   return l;
                          // }).toList();
                          // print(_list);
                          // _morekeys_controller.text =
                          //     jsonEncode({"isWrap": true, "list": _list});
                        },
                        child: Text("生成请求规则"),
                      ),
                    ),
                    SizedBox(
                      width: 15,
                    ),
                    SizedBox(
                      // width: 100,
                      height: 45,
                      child: OutlinedButton(
                        onPressed: () async => await Clipboard.setData(
                            ClipboardData(text: _req_controller.text)),
                        child: Text("复制"),
                      ),
                    ),
                    SizedBox(
                      width: 15,
                    ),
                    SizedBox(
                      // width: 100,
                      height: 45,
                      child: OutlinedButton(
                        onPressed: () => _req_controller.text = "",
                        child: Text("清空"),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
