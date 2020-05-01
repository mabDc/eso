import 'package:eso/database/rule.dart';
import 'package:eso/global.dart';
import 'package:eso/page/source/edit_rule_page.dart';
import 'package:eso/utils/adapt_util.dart';
import 'package:flutter/material.dart';
import 'package:toast/toast.dart';
import 'package:intl/intl.dart' as intl;

//图源编辑
class EditSourcePage extends StatefulWidget {
  @override
  _EditSourcePageState createState() => _EditSourcePageState();
}

class _EditSourcePageState extends State<EditSourcePage> {
  @override
  Widget build(BuildContext context) {
    GlobalKey<AnimatedListState> _key = GlobalKey();
    final primaryColor = Theme.of(context).primaryColor;
    return Scaffold(
      appBar: AppBar(
        title: Text('图源'),
        actions: [
          _buildpopupMenu(context),
        ],
      ),
      body: FutureBuilder<List<Rule>>(
        future: Global.ruleDao.findAllRules(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.data.length == 0) {
            return Center(
              child: Text(
                '请点击右上角添加规则',
                style: TextStyle(color: Colors.grey[700]),
              ),
            );
          }
          final rules = snapshot.data;
          return AnimatedList(
            key: _key,
            initialItemCount: rules.length,
            padding: EdgeInsets.all(10),
            physics: BouncingScrollPhysics(),
            itemBuilder:
                (BuildContext context, int index, Animation animation) {
              return _buildItem(
                  context, primaryColor, rules[index], index, _key);
            },
          );
        },
      ),
    );
  }

  PopupMenuButton _buildpopupMenu(BuildContext context) {
    const ADD_RULE = 0;
    const FROM_CLIPBOARD = 1;
    const FROM_FILE = 2;
    const FROM_CLOUD = 3;
    final primaryColor = Theme.of(context).primaryColor;
    return PopupMenuButton<int>(
      elevation: 20,
      icon: Icon(Icons.add),
      offset: Offset(0, 40),
      onSelected: (int value) {
        switch (value) {
          case ADD_RULE:
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (context) => EditRulePage()));
            break;
          case FROM_CLIPBOARD:
            Toast.show("从剪贴板导入", context);
            break;
          case FROM_FILE:
            Toast.show("从本地文件导入", context);
            break;
          case FROM_CLOUD:
            Toast.show("从网络导入", context);
            break;
          default:
        }
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<int>>[
        PopupMenuItem(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text('新建规则'),
              Icon(
                Icons.code,
                color: primaryColor,
              ),
            ],
          ),
          value: ADD_RULE,
        ),
        PopupMenuItem(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text('剪贴板'),
              Icon(
                Icons.content_paste,
                color: primaryColor,
              ),
            ],
          ),
          value: FROM_CLIPBOARD,
        ),
        PopupMenuItem(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text('文件导入'),
              Icon(
                Icons.file_download,
                color: primaryColor,
              ),
            ],
          ),
          value: FROM_FILE,
        ),
        PopupMenuItem(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text('网络导入'),
              Icon(
                Icons.cloud_download,
                color: primaryColor,
              ),
            ],
          ),
          value: FROM_CLOUD,
        ),
      ],
    );
  }

  String formatTime(int t) {
    return intl.DateFormat("yy-MM-dd HH:mm:ss")
        .format(DateTime.fromMicrosecondsSinceEpoch(t));
  }

  Widget _buildItem(BuildContext context, Color primaryColor, Rule rule,
      int index, GlobalKey<AnimatedListState> key) {
    return Dismissible(
      onDismissed: (DismissDirection direction) {
        Global.ruleDao.deleteRule(rule);
        key.currentState.removeItem(index, (_, __) => Container());
        // Show a snackbar! This snackbar could also contain "Undo" actions.
        Scaffold.of(context).showSnackBar(SnackBar(
          content: Text("${rule.host} 已删除"),
          action: SnackBarAction(
            label: '撤销',
            onPressed: () {
              Global.ruleDao.insertOrUpdateRule(rule);
              key.currentState.insertItem(index);
            },
          ),
        ));
      },
      key: Key(rule.id),
      child: Card(
        elevation: 0,
        color: Colors.amberAccent,
        child: SwitchListTile(
          onChanged: (value) async {
            rule.enableDiscover = value;
            final result = await Global.ruleDao.insertOrUpdateRule(rule);
            print(result);
          },
          value: rule.enableDiscover,
          activeColor: primaryColor,
          title: Text(
            '${rule.name}',
            textAlign: TextAlign.start,
            style: TextStyle(
                color: Colors.black87, fontSize: AdaptUtil.adaptSize(12)),
          ),
          subtitle: Text(
            '${rule.author} - ${rule.host}\n${formatTime(rule.createTime)} - ${formatTime(rule.modifiedTime)}',
            textAlign: TextAlign.start,
            style: TextStyle(
                color: Colors.black54, fontSize: AdaptUtil.adaptSize(10)),
          ),
        ),
      ),
    );
  }
}
