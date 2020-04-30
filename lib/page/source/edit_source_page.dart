import 'package:eso/utils/adapt_util.dart';
import 'package:flutter/material.dart';

//图源编辑
class EditSourcePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('图源'),
      ),
      body: ListView.separated(
        separatorBuilder: (context, index) => Container(),
        itemCount: 100,
        padding: EdgeInsets.all(10),
        physics: BouncingScrollPhysics(),
        itemBuilder: (BuildContext context, int index) {
          return _buildItem(context);
        },
      ),
    );
  }

  Widget _buildItem(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.amberAccent,
      child: SwitchListTile(
        onChanged: (value) {},
        value: true,
        activeColor: Theme.of(context).primaryColor,
        title: Text(
          '源名称',
          textAlign: TextAlign.start,
          style: TextStyle(
              color: Colors.black87, fontSize: AdaptUtil.adaptSize(12)),
        ),
        subtitle: Text(
          '作者 - 网址\n源创建时间 - 源更新时间',
          textAlign: TextAlign.start,
          style: TextStyle(
              color: Colors.black54, fontSize: AdaptUtil.adaptSize(10)),
        ),
      ),
    );
  }
}
