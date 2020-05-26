import 'dart:isolate';
import 'dart:ui';

import 'package:eso/api/api_from_rule.dart';
import 'package:eso/database/database.dart';
import 'package:eso/database/search_item.dart';
import 'package:eso/global.dart';
import 'package:eso/ui/ui_search_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_isolate/flutter_isolate.dart';
import 'package:provider/provider.dart';

class SearchPage extends StatefulWidget {
  SearchPage({Key key}) : super(key: key);

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => SearchProvider(),
      builder: (context, child) => Scaffold(
        appBar: AppBar(
          titleSpacing: 0,
          title: TextField(
            cursorColor: Theme.of(context).primaryColor,
            cursorRadius: Radius.circular(2),
            selectionHeightStyle: BoxHeightStyle.includeLineSpacingMiddle,
            decoration: InputDecoration(
              filled: true,
              fillColor: Theme.of(context).textTheme.bodyText1.color.withOpacity(0.1),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(color: Colors.transparent),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(color: Colors.transparent),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(color: Colors.transparent),
              ),
              hintText: "search keyword",
              hintStyle: TextStyle(
                color: Theme.of(context).textTheme.bodyText1.color.withOpacity(0.7),
                fontSize: 12,
              ),
              isDense: true,
              contentPadding: EdgeInsets.only(bottom: 4),
              prefixIcon: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                child: Icon(
                  Icons.search,
                  color: Theme.of(context).textTheme.bodyText1.color.withOpacity(0.7),
                ),
              ),
              prefixIconConstraints: BoxConstraints(),
            ),
            maxLines: 1,
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyText1.color,
              height: 1.25,
            ),
            onSubmitted: Provider.of<SearchProvider>(context, listen: false).search,
          ),
        ),
        body: Consumer<SearchProvider>(
          builder: (context, provider, child) {
            if (provider.searchList.length == 0) {
              return Container();
            }
            return ListView.separated(
              padding: EdgeInsets.all(8),
              separatorBuilder: (context, index) => SizedBox(height: 8),
              itemCount: provider.searchList.length,
              itemBuilder: (BuildContext context, int index) {
                return UiSearchItem(item: provider.searchList[index]);
              },
            );
          },
        ),
      ),
    );
  }
}

class SearchProvider with ChangeNotifier {
  final int threadCount;
  final List<SearchItem> searchList = <SearchItem>[];
  SearchProvider({this.threadCount = 5});

  void search(String value) async {
    print("search $value");
    searchList.clear();
    notifyListeners();
    query = value;
    final rules =
        (await Global.ruleDao.findAllRules()).where((e) => e.enableSearch).toList();
    // 0 -> 0
    // 1-5 -> 1
    // 6-10 -> 2
    // 11-15 -> 3
    for (var i = 0; i < threadCount; i++) {
      final count = rules.length - 1 - i;
      asyncParse(
        searchList,
        () => notifyListeners(),
        List.generate(
          count < 0 ? 0 : count ~/ threadCount + 1,
          (j) => rules[j * threadCount + i].id,
        ),
      );
    }
  }

  @override
  void dispose() {
    searchList.clear();
    super.dispose();
  }
}

String query = "";
//这里以计算斐波那契数列为例，返回的值是Future，因为是异步的
void asyncParse(
    List<SearchItem> searchList, VoidCallback callback, List<String> ids) async {
  //首先创建一个ReceivePort，为什么要创建这个？
  //因为创建isolate所需的参数，必须要有SendPort，SendPort需要ReceivePort来创建
  final response = new ReceivePort();
  //开始创建isolate,Isolate.spawn函数是isolate.dart里的代码,_isolate是我们自己实现的函数
  //_isolate是创建isolate必须要的参数。
  await FlutterIsolate.spawn(_isolate, response.sendPort);
  //获取sendPort来发送数据
  final sendPort = await response.first as SendPort;
  //接收消息的ReceivePort
  final answer = new ReceivePort();
  //获得数据并返回
  answer.listen((message) {
    searchList.addAll((message as List).map((json) => SearchItem.fromJson(json)));
    callback();
  });
  //发送数据
  sendPort.send([ids, answer.sendPort]);
}

//创建isolate必须要的参数
void _isolate(SendPort initialReplyTo) {
  final port = new ReceivePort();
  //绑定
  initialReplyTo.send(port.sendPort);
  //监听
  port.listen((message) async {
    //获取数据并解析
    final ids = message[0] as List<String>;
    final send = message[1] as SendPort;
    //返回结果
    final database = await $FloorAppDatabase.databaseBuilder('eso_database.db').build();
    for (final id in ids) {
      try {
        final api = APIFromRUle(await database.ruleDao.findRuleById(id));
        print(api.rule.name);
        final items = await api.search(query, 0, 20);
        send.send(items.map((e) => e.toJson()).toList());
      } catch (e) {
        print(e);
      }
    }
  });
}

// //这里以计算斐波那契数列为例，返回的值是Future，因为是异步的
// void asyncFibonacci(int n) async {
//   //首先创建一个ReceivePort，为什么要创建这个？
//   //因为创建isolate所需的参数，必须要有SendPort，SendPort需要ReceivePort来创建
//   final response = new ReceivePort();
//   //开始创建isolate,Isolate.spawn函数是isolate.dart里的代码,_isolate是我们自己实现的函数
//   //_isolate是创建isolate必须要的参数。
//   await Isolate.spawn(_isolate, response.sendPort);
//   //获取sendPort来发送数据
//   final sendPort = await response.first as SendPort;
//   //接收消息的ReceivePort
//   final answer = new ReceivePort();
//   //发送数据
//   sendPort.send([n, answer.sendPort]);
//   answer.forEach((element) {
//     print(22);
//   });
//   //获得数据并返回
// }

// //创建isolate必须要的参数
// void _isolate(SendPort initialReplyTo) {
//   final port = new ReceivePort();
//   //绑定
//   initialReplyTo.send(port.sendPort);
//   //监听
//   port.listen((message) {
//     //获取数据并解析
//     final data = message[0] as int;
//     final send = message[1] as SendPort;
//     //返回结果
//     send.send(syncFibonacci(data));
//     send.send(syncFibonacci(data));
//     send.send(syncFibonacci(data));
//   });
// }

// int syncFibonacci(int n) {
//   return n < 2 ? n : syncFibonacci(n - 2) + syncFibonacci(n - 1);
// }
