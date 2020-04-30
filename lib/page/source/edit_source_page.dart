import 'package:eso/utils/adapt_util.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

//图源编辑
class EditSourcePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return EditSourcePageState();
  }
}

class EditSourcePageState extends State<EditSourcePage> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text('图源'),
      ),
      body: ListView.builder(
          itemCount: 100,
          physics: BouncingScrollPhysics(),
          itemBuilder: (BuildContext context, int index) {
            return _buildItem();
          }),
    );
  }

  Widget _buildItem() {
    Widget itemView = Column(
      children: <Widget>[
        Container(
          padding: EdgeInsets.fromLTRB(15, 5, 10, 15),
          child: Column(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          '源名称',
                          textAlign: TextAlign.start,
                          style: TextStyle(
                              color: Colors.black87, fontSize: AdaptUtil
                              .adaptSize(12)),
                        ),
                        Text(
                          '作者 - 网址',
                          textAlign: TextAlign.start,
                          style: TextStyle(
                              color: Colors.black54, fontSize: AdaptUtil
                              .adaptSize(10)),
                        ),
                        Text(
                          '源创建时间 - 源更新时间',
                          textAlign: TextAlign.start,
                          style: TextStyle(
                              color: Colors.black54, fontSize: AdaptUtil
                              .adaptSize(10)),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    child: Switch(
                      activeColor: Theme
                          .of(context)
                          .primaryColor,
                      value: true,
                      onChanged: (bool isChecked) {},
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Divider(color: Colors.black26, height: 0.5,),
      ],
    );
    return itemView;
  }
}
