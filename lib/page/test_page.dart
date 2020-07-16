import 'package:eso/ui/edit/edit_view.dart';
import 'package:eso/ui/widgets/app_bar_ex.dart';
import 'package:eso/utils.dart';
import 'package:eso/utils/flutter_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_js/flutter_js.dart';

class TestPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {

  String code, resp;
  int id;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarEx(
        title: Text("JS 引擎功能测试"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  FlatButton(child: Text("初始化引擎"), onPressed: () async {
                    if (id != null && id != 0) return;
                    id = await FlutterJs.initEngine();
                  }),
                  FlatButton(child: Text("运行"), onPressed: () async {
                    if (id == null || id == 0) {
                      Utils.toast("请先初始化引擎");
                      return;
                    }
                    resp = (await FlutterJs.evaluate(code, id)).toString();
                    setState(() {});
                  }),
                  FlatButton(child: Text("释放引擎"), onPressed: () async {
                    if (id == null || id == 0) return;
                    await FlutterJs.close(id);
                    id = null;
                  }),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(12),
              color: Colors.grey.withOpacity(0.1),
              constraints: BoxConstraints(minHeight: 200),
              child: EditView(
                value: code,
                onChanged: (v) {
                  code = v;
                },
              ),
            ),
            SizedBox(height: 16),
            Text("运行结果："),
            SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              color: Colors.green.withOpacity(0.05),
              constraints: BoxConstraints(minHeight: 100),
              child: Text(resp ?? ''),
            ),
          ],
        ),
      ),
    );
  }
}