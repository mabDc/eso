import 'dart:async';

import 'package:easy_refresh/easy_refresh.dart';
import 'package:floor/floor.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class CustomScrollDelegate extends SliverChildBuilderDelegate {
  Function(int firstIndex, int lastIndex, double leadingScrollOffset,
      double trailingScrollOffset) scrollCallBack;
  Function(int firstIndex, int lastIndex) layoutFinishCallBack;

  int Function(Key key) findChildIndexCallback;

  CustomScrollDelegate(NullableIndexedWidgetBuilder builder,
      {int itemCount,
      this.scrollCallBack,
      this.findChildIndexCallback,
      this.layoutFinishCallBack})
      : super(builder,
            childCount: itemCount,
            findChildIndexCallback: findChildIndexCallback);
  @override
  void didFinishLayout(int firstIndex, int lastIndex) {
    super.didFinishLayout(firstIndex, lastIndex);
    if (layoutFinishCallBack != null) {
      layoutFinishCallBack(firstIndex, lastIndex);
    }
  }

  @override
  double estimateMaxScrollOffset(int firstIndex, int lastIndex,
      double leadingScrollOffset, double trailingScrollOffset) {
    if (scrollCallBack != null) {
      scrollCallBack(
          firstIndex, lastIndex, leadingScrollOffset, trailingScrollOffset);
    }
    return super.estimateMaxScrollOffset(
        firstIndex, lastIndex, leadingScrollOffset, trailingScrollOffset);
  }
}

class MangaList {
  List<String> urls;
  String name;
  MangaList({List<String> this.urls, String this.name});
}

class testListView extends StatefulWidget {
  const testListView({Key key}) : super(key: key);

  @override
  State<testListView> createState() => _testListViewState();
}

class _testListViewState extends State<testListView> {
  List<MangaList> list = [
    MangaList(
        name: "章节0",
        urls: List.generate(20, (index) => "item:${index}").toList())
  ];

  List<MangaList> prev_list = [
    // MangaList(
    //     name: "章节1",
    //     urls: List.generate(20, (index) => "item:${index}").toList())
  ];

  ScrollController _controller = ScrollController();
  StreamController<int> _streamController = StreamController.broadcast();

  final _easyRefreshController = EasyRefreshController(
      controlFinishRefresh: true, controlFinishLoad: true);
  PageController _pageController;

  @override
  void dispose() {
    _streamController.close();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 1.0);
  }

  @override
  Widget build(BuildContext context) {
    final centerKey = ValueKey<String>("bottom-sliver-list");

    return Scaffold(
      appBar: AppBar(
        title: Text("view"),
      ),
      body: Stack(
        children: [
          EasyRefresh(
            controller: _easyRefreshController,

            header: CupertinoHeader(position: IndicatorPosition.above),
            footer: CupertinoFooter(position: IndicatorPosition.above),

            // header: BuilderHeader(
            //     // triggerWhenReach: true,
            //     triggerOffset: 50,
            //     clamping: false,
            //     // safeArea: false,
            //     position: IndicatorPosition.above,
            //     infiniteOffset: null,
            //     processedDuration: Duration.zero,
            //     builder: (context, state) {
            //       try {
            //         final maxScrollExtent =
            //             _controller.position.maxScrollExtent;
            //         print("maxScrollExtent:${maxScrollExtent}");
            //       } catch (e) {}
            //       print("state.mode:${state.mode}");
            //       final _mode = state.mode;
            //       bool isRun = false;
            //       bool isFinish = false;
            //       switch (_mode) {
            //         case IndicatorMode.ready:
            //         case IndicatorMode.processing:
            //         case IndicatorMode.processed:
            //           isRun = true;
            //           break;
            //         case IndicatorMode.done:
            //           isFinish = true;
            //           break;
            //         default:
            //       }
            //       if (isFinish || _mode == IndicatorMode.inactive) {
            //         return SizedBox();
            //       }
            //       return Stack(
            //         children: [
            //           SizedBox(
            //             height: state.offset,
            //             width: double.infinity,
            //           ),
            //           Positioned(
            //             top: 1,
            //             // bottom: 5,
            //             left: 0,
            //             right: 0,
            //             child: Container(
            //               alignment: Alignment.center,
            //               width: double.infinity,
            //               height: 40,
            //               child: state.result == IndicatorResult.noMore
            //                   ? Text("没有数据")
            //                   : Row(
            //                       mainAxisAlignment: MainAxisAlignment.center,
            //                       children: [
            //                         CupertinoActivityIndicator(
            //                           radius: 10,
            //                           // color: Theme.of(context).colorScheme.primary,
            //                         ),
            //                         SizedBox(
            //                           width: 10,
            //                         ),
            //                         Text(
            //                             "${isRun ? "正在" : state.offset > 50 ? "松开" : "下拉"}加载下一章",
            //                             style: TextStyle(fontSize: 15)),
            //                       ],
            //                     ),
            //             ),
            //           )
            //         ],
            //       );
            //     }),
            // footer: BuilderFooter(
            //     // triggerWhenReach: true,
            //     triggerOffset: 50,
            //     clamping: false,
            //     // safeArea: false,
            //     position: IndicatorPosition.above,
            //     infiniteOffset: null,
            //     processedDuration: Duration.zero,
            //     builder: (context, state) {
            //       print("state.mode:${state.mode}");
            //       final _mode = state.mode;
            //       bool isRun = false;
            //       bool isFinish = false;
            //       switch (_mode) {
            //         case IndicatorMode.ready:
            //         case IndicatorMode.processing:
            //         case IndicatorMode.processed:
            //           isRun = true;
            //           break;
            //         case IndicatorMode.done:
            //           isFinish = true;
            //           break;
            //         default:
            //       }
            //       if (isFinish || _mode == IndicatorMode.inactive) {
            //         return SizedBox();
            //       }
            //       return Stack(
            //         children: [
            //           SizedBox(
            //             height: state.offset,
            //             width: double.infinity,
            //           ),
            //           Positioned(
            //             // top: 1,
            //             bottom: 5,
            //             left: 0,
            //             right: 0,
            //             child: Container(
            //               alignment: Alignment.center,
            //               width: double.infinity,
            //               height: 40,
            //               child: state.result == IndicatorResult.noMore
            //                   ? Text("没有数据")
            //                   : Row(
            //                       mainAxisAlignment: MainAxisAlignment.center,
            //                       children: [
            //                         CupertinoActivityIndicator(
            //                           radius: 10,
            //                           // color: Theme.of(context).colorScheme.primary,
            //                         ),
            //                         SizedBox(
            //                           width: 10,
            //                         ),
            //                         Text(
            //                             "${isRun ? "正在" : state.offset > 50 ? "松开" : "下拉"}加载下一章",
            //                             style: TextStyle(fontSize: 15)),
            //                       ],
            //                     ),
            //             ),
            //           )
            //         ],
            //       );
            //     }),

            onLoad: () async {
              await Future.delayed(Duration(seconds: 2));
              _easyRefreshController.finishLoad();
              _easyRefreshController.resetFooter();
              // list.add(MangaList(
              //     name: "章节${list.length + 1}",
              //     urls:
              //         List.generate(20, (index) => "item:${index}").toList()));

              // list.add(MangaList(
              //     name: "章节${list.length + 1}",
              //     urls:
              //         List.generate(20, (index) => "item:${index}").toList()));

              setState(() {});
            },
            onRefresh: () async {
              print("offset:刷新回调");
              await Future.delayed(Duration(seconds: 2));
              _easyRefreshController.finishRefresh();
              _easyRefreshController.resetHeader();

              list.first.urls.insertAll(0,
                  List.generate(20, (index) => "item:${10 + index}").toList());

              // list.insert(
              //     0,
              //     MangaList(
              //         name: "章节${list.length}",
              //         urls: List.generate(20, (index) => "item:${index}")
              //             .toList()));

              // prev_list.add(MangaList(
              //     name: "章节${prev_list.length + 1}",
              //     urls:
              //         List.generate(20, (index) => "item:${index}").toList()));

              setState(() {});
            },
            // child: PageView.custom(
            //   // pageSnapping: false,
            //   allowImplicitScrolling: false,
            //   controller: _pageController,
            //   childrenDelegate: CustomScrollDelegate(
            //     (context, index) {
            //       return Container(
            //         alignment: Alignment.center,
            //         decoration: BoxDecoration(
            //           border: Border.all(color: Colors.black, width: 0.2),
            //           color: Colors.blueAccent,
            //         ),
            //         width: double.infinity,
            //         height: 100,
            //         child: Text(
            //             "index:${index} ${list.first.urls[index]} ${list.first.name}"),
            //       );
            //     },
            //     itemCount: list.first.urls.length,
            //   ),
            //   padEnds: false,
            // ),
            child: CustomScrollView(
              scrollDirection: Axis.horizontal,
              center: centerKey,
              controller: _controller,
              // reverse: true,
              // shrinkWrap: true,
              // cacheExtent: 0.0,
              clipBehavior: Clip.none,
              slivers: [
                SliverPadding(
                  padding: EdgeInsets.zero,
                  sliver: PageView.builder(
                    key: centerKey,
                    itemBuilder: (context, index) {
                      return Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black, width: 0.2),
                          color: Colors.blueAccent,
                        ),
                        // width: double.infinity,
                        height: double.infinity,
                        child: Text("item:${index} ${list[index].name}"),
                      );
                    },
                    itemCount: 1,
                  ),
                ),

                // HeaderLocator.sliver(),
                // SliverList(
                //   delegate: CustomScrollDelegate(
                //     (context, index) {
                //       return Container(
                //         alignment: Alignment.center,
                //         decoration: BoxDecoration(
                //           border: Border.all(color: Colors.black, width: 0.2),
                //           color: Colors.blueAccent,
                //         ),
                //         width: double.infinity,
                //         height: 100,
                //         child: Text("item:${index} ${list[index].name}"),
                //       );
                //       // return Column(
                //       //   mainAxisSize: MainAxisSize.min,
                //       //   crossAxisAlignment: CrossAxisAlignment.start,
                //       //   children: prev_list[i]
                //       //       .urls
                //       //       .map(
                //       //         (m) => Container(
                //       //           alignment: Alignment.center,
                //       //           decoration: BoxDecoration(
                //       //             border: Border.all(
                //       //                 color: Colors.black, width: 0.2),
                //       //             color: Colors.blueAccent[50],
                //       //           ),
                //       //           width: double.infinity,
                //       //           height: 100,
                //       //           child: Text("${prev_list[i].name} ${m}"),
                //       //         ),
                //       //       )
                //       //       .toList(),
                //       // );
                //     },
                //     itemCount: prev_list.length,
                //   ),
                // ),
                // SliverList(
                //   // key: centerKey,
                //   delegate: CustomScrollDelegate(
                //     (context, index) {
                //       return PageView.builder(
                //         itemBuilder: (context, index) {
                //           return Container(
                //             alignment: Alignment.center,
                //             decoration: BoxDecoration(
                //               border:
                //                   Border.all(color: Colors.black, width: 0.2),
                //               color: Colors.blueAccent,
                //             ),
                //             // width: double.infinity,
                //             height: double.infinity,
                //             child: Text("item:${index} ${list[index].name}"),
                //           );
                //         },
                //         itemCount: 1,
                //       );
                //       // return Column(
                //       //   mainAxisSize: MainAxisSize.min,
                //       //   crossAxisAlignment: CrossAxisAlignment.start,
                //       //   children: list[i]
                //       //       .urls
                //       //       .map(
                //       //         (m) => Container(
                //       //           alignment: Alignment.center,
                //       //           decoration: BoxDecoration(
                //       //             border: Border.all(
                //       //                 color: Colors.black, width: 0.2),
                //       //             color: Colors.blue,
                //       //           ),
                //       //           width: double.infinity,
                //       //           height: 100,
                //       //           child: Text("${list[i].name} ${m}"),
                //       //         ),
                //       //       )
                //       //       .toList(),
                //       // );
                //     },
                //     itemCount: list.length,
                //   ),
                // ),
              ],
            ),
          ),
          Positioned(
            bottom: 200,
            right: 10,
            child: Container(
              height: 50,
              width: 50,
              child: StreamBuilder<int>(
                stream: _streamController.stream,
                initialData: 0,
                builder: (context, snapshot) {
                  return TextButton(
                    onPressed: () {},
                    child: Text("${snapshot.data}"),
                  );
                },
              ),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.all(
                  Radius.circular(50),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 10,
            right: 10,
            child: Container(
              height: 50,
              width: 50,
              child: TextButton(
                onPressed: () {
                  final mangaList = MangaList(
                      name: "章节${list.length + 1}",
                      urls: List.generate(20, (index) => "item:${100 + index}")
                          .toList());
                  list.insert(list.length, mangaList);
                  setState(() {});
                },
                child: Text("加入"),
              ),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.all(
                  Radius.circular(50),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 100,
            right: 10,
            child: Container(
              height: 50,
              width: 50,
              child: TextButton(
                onPressed: () {
                  list.clear();
                  list.add(MangaList(
                      name: "章节1",
                      urls: List.generate(20, (index) => "item:${index}")
                          .toList()));
                  setState(() {});
                },
                child: Text("重置"),
              ),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.all(
                  Radius.circular(50),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
