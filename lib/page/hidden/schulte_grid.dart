import 'package:eso/main.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class SchulteGrid extends StatefulWidget {
  @override
  _SchulteGridState createState() => _SchulteGridState();
}

class _SchulteGridState extends State<SchulteGrid> with SingleTickerProviderStateMixin {
  int count;
  int nextNum;
  int curNum;
  int secondsPassed;
  int millPassed;
  List<int> data = List<int>();
  AnimationController controller;
  Animation<Color> animation;
  Timer timer;
  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 250),
    );
    init(16);
  }

  void init(int count) {
    timer?.cancel();
    this.count = count;
    nextNum = 0;
    curNum = 0;
    secondsPassed = 0;
    millPassed = 0;
    animation = ColorTween(
      begin: Colors.white,
      end: Colors.purple,
    ).animate(controller);
    data = List.generate(count, (index) => index + 1)..shuffle();
  }

  void startTick() {
    timer = Timer.periodic(Duration(milliseconds: 100), (Timer t) {
      ++millPassed;
      if (millPassed == 10) {
        millPassed = 0;
        ++secondsPassed;
      }
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: globalDecoration,
      child: Scaffold(
          appBar: AppBar(
            title: Text("舒尔特方格"),
            centerTitle: true,
          ),
          body: ListView(
            children: <Widget>[
              Container(
                alignment: Alignment.center,
                height: 65,
                child: Text(
                  '计时 $secondsPassed.$millPassed',
                  style: TextStyle(fontSize: 38),
                ),
              ),
              GridView.builder(
                shrinkWrap: true,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: count == 16 ? 4 : 5,
                ),
                itemCount: count,
                itemBuilder: (BuildContext context, int index) {
                  return InkWell(
                    onTap: () async {
                      if (nextNum == 0 && (timer == null || !timer.isActive)) {
                        startTick();
                      }
                      curNum = data[index];
                      if (nextNum + 1 == curNum) {
                        ++nextNum;
                        animation = ColorTween(
                          begin: Colors.transparent,
                          end: Colors.purple,
                        ).animate(controller)
                          ..addListener(() {
                            if (mounted) setState(() {});
                          });
                      } else {
                        animation = ColorTween(
                          begin: Colors.transparent,
                          end: Colors.red,
                        ).animate(controller)
                          ..addListener(() {
                            if (mounted) setState(() {});
                          });
                      }
                      await controller.forward();
                      await controller.reverse();
                      if (nextNum == count) {
                        nextNum++;
                        timer.cancel();
                        showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: Text("恭喜！"),
                                content: Text("您的成绩为 $secondsPassed.$millPassed"),
                                actions: <Widget>[
                                  TextButton(
                                      onPressed: () {
                                        init(count);
                                        if (mounted) setState(() {});
                                        Navigator.of(context).pop();
                                      },
                                      child: Text("再来一次")),
                                ],
                              );
                            });
                      }
                    },
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        border: Border.all(width: 1),
                        color:
                            curNum == data[index] ? animation.value : Colors.transparent,
                      ),
                      child: Text(
                        '${data[index]}',
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                  );
                },
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  OutlinedButton(
                    // color: Colors.blue,
                    style: ButtonStyle(
                      padding: MaterialStateProperty.all(EdgeInsets.zero),
                      backgroundColor:
                          MaterialStateProperty.all(Theme.of(context).cardColor),
                    ),
                    child: Text('16格子'),
                    onPressed: () {
                      init(16);
                      if (mounted) setState(() {});
                    },
                  ),
                  SizedBox(width: 20),
                  OutlinedButton(
                    style: ButtonStyle(
                      padding: MaterialStateProperty.all(EdgeInsets.zero),
                      backgroundColor:
                          MaterialStateProperty.all(Theme.of(context).cardColor),
                    ),
                    child: Text('25格子'),
                    onPressed: () {
                      init(25);
                      if (mounted) setState(() {});
                    },
                  ),
                ],
              ),
            ],
          )),
    );
  }
}
