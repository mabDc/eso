import 'package:eso/database/rule.dart';
import 'package:flutter/material.dart';
import '../../api/api.dart';

class DebugRulePage extends StatelessWidget {
  final Rule rule;
  const DebugRulePage({
    this.rule,
    Key key,
  }) : super(key: key);

  Text _buildBigText(String text) {
    return Text(
      text,
      style: TextStyle(
        color: Colors.black87,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Text _buildDetailsText(String text) {
    return Text(
      text,
      style: TextStyle(color: Colors.black54, fontSize: 16),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("测试"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildBigText('基础信息'),
          _buildDetailsText("""
创建时间：${DateTime.fromMicrosecondsSinceEpoch(rule.createTime)}
修改时间：${DateTime.fromMicrosecondsSinceEpoch(rule.modifiedTime)}
作者：${rule.author}
签名档：${rule.postScript}
名称：${rule.name}
域名：${rule.host}
类型：${API.getRuleContentTypeName(rule.contentType)}"""),
          SizedBox(height: 10),
          _buildBigText('发现测试'),
          FutureBuilder(builder: null), 
        ],
      ),
    );
  }
}
