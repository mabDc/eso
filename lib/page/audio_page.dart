import 'dart:ui';

import 'package:audioplayers/audioplayers.dart';
import 'package:eso/database/search_item.dart';
import 'package:eso/model/audio_page_controller.dart';
import 'package:eso/model/audio_service.dart';
import 'package:eso/ui/ui_chapter_select.dart';
import 'package:flutter/material.dart';
import 'package:flutter_seekbar/flutter_seekbar.dart';
import 'package:provider/provider.dart';

class AudioPage extends StatefulWidget {
  final SearchItem searchItem;

  const AudioPage({
    this.searchItem,
    Key key,
  }) : super(key: key);

  @override
  _AudioPageState createState() => _AudioPageState();
}

class _AudioPageState extends State<AudioPage>
    with SingleTickerProviderStateMixin {
  Widget _audioPage;
  AudioPageController __provider;
  AnimationController controller;

  @override
  Widget build(BuildContext context) {
    if (_audioPage == null) {
      _audioPage = _buildPage();
    }
    return _audioPage;
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
    __provider.dispose();
  }

  Widget _buildPage() {
    controller =
        AnimationController(duration: const Duration(seconds: 20), vsync: this);
    //动画开始、结束、向前移动或向后移动时会调用StatusListener
    controller.forward();
    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        //动画从 controller.forward() 正向执行 结束时会回调此方法
        print("status is completed");
        //重置起点
        controller.reset();
        //开启
        controller.forward();
      } else if (status == AnimationStatus.dismissed) {
        //动画从 controller.reverse() 反向执行 结束时会回调此方法
        print("status is dismissed");
      } else if (status == AnimationStatus.forward) {
        print("status is forward");
        //执行 controller.forward() 会回调此状态
      } else if (status == AnimationStatus.reverse) {
        //执行 controller.reverse() 会回调此状态
        print("status is reverse");
      }
    });
    return ChangeNotifierProvider<AudioPageController>.value(
      value: AudioPageController(searchItem: widget.searchItem),
      child: Consumer<AudioPageController>(
        builder: (BuildContext context, AudioPageController provider, _) {
          __provider = provider;
          final chapter =
              widget.searchItem.chapters[widget.searchItem.durChapterIndex];
          return Scaffold(
            body: Container(
              height: double.infinity,
              width: double.infinity,
              child: Stack(
                children: <Widget>[
                  Container(
                    height: double.infinity,
                    width: double.infinity,
                    child: Image.network(
                      chapter.cover ??
                          'http://api.52jhs.cn/api/random/api.php?type=pc',
                      fit: BoxFit.cover,
                    ),
                  ),
                  BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                    child: Container(color: Colors.black.withAlpha(50)),
                  ),
                  Column(
                    children: <Widget>[
                      SizedBox(
                        height: MediaQuery.of(context).padding.top,
                      ),
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        child: _buildTopRow(provider, chapter.name, chapter.time),
                      ),
                      Expanded(
                        child: Container(
                          child: Center(
                            child: RotationTransition(
                              //设置动画的旋转中心
                              alignment: Alignment.center,
                              //动画控制器
                              turns: controller,
                              child: Container(
                                height: 300,
                                width: 300,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  image: DecorationImage(
                                    image: NetworkImage(
                                      chapter.cover ??
                                          'http://api.52jhs.cn/api/random/api.php?type=pc',
                                    ),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        height: 100,
                        padding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            _buildProgressBar(provider),
                            _buildBottomController(provider),
                          ],
                        ),
                      ),
                    ],
                  ),
                  provider.showChapter
                      ? UIChapterSelect(
                          searchItem: widget.searchItem,
                          loadChapter: provider.loadChapter,
                        )
                      : Container(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTopRow(
      AudioPageController provider, String name, String author) {
    return Row(
      children: <Widget>[
        InkWell(
          child: Icon(
            Icons.arrow_back,
            color: Colors.white,
            size: 26,
          ),
          onTap: () => Navigator.of(context).pop(),
        ),
        SizedBox(
          width: 10,
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                '$name',
                maxLines: 1,
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.white70,
                ),
              ),
              Text(
                '$author',
                maxLines: 1,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          width: 10,
        ),
        InkWell(
          child: Icon(
            Icons.share,
            color: Colors.white,
            size: 26,
          ),
          onTap: provider.share,
        ),
      ],
    );
  }

  Widget _buildProgressBar(AudioPageController provider) {
    return Center(
      child: Row(
        children: <Widget>[
          Text(
            provider.positionDurationText,
            style: TextStyle(color: Colors.white),
          ),
          SizedBox(
            width: 10,
          ),
          Expanded(
            child: SeekBar(
              value: provider.seconds == 0
                  ? 0
                  : provider.postionSeconds / provider.seconds,
              max: 1,
              backgroundColor: Colors.white54,
              progresseight: 4,
              afterDragShowSectionText: true,
              onValueChanged: (progress) => provider
                  .seekSeconds((progress.value * provider.seconds).toInt()),
              indicatorRadius: 5,
            ),
          ),
          SizedBox(
            width: 10,
          ),
          Text(
            provider.durationText,
            style: TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomController(AudioPageController provider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        InkWell(
          child: Icon(
            provider.repeatMode == AudioService.REPEAT_ALL
                ? Icons.repeat
                : provider.repeatMode == AudioService.REPEAT_ONE
                    ? Icons.repeat_one
                    : Icons.label_outline,
            color: Colors.white,
            size: 26,
          ),
          onTap: provider.switchRepeatMode,
        ),
        InkWell(
          child: Icon(
            Icons.skip_previous,
            color: Colors.white,
            size: 26,
          ),
          onTap: provider.playPrev,
        ),
        InkWell(
          child: Icon(
            provider.state == AudioPlayerState.PLAYING
                ? Icons.pause_circle_outline
                : Icons.play_circle_outline,
            color: Colors.white,
            size: 42,
          ),
          onTap: provider.playOrPause,
        ),
        InkWell(
          child: Icon(
            Icons.skip_next,
            color: Colors.white,
            size: 26,
          ),
          onTap: provider.playNext,
        ),
        InkWell(
          child: Icon(
            Icons.menu,
            color: Colors.white,
            size: 26,
          ),
          onTap: () => provider.showChapter = !provider.showChapter,
        ),
      ],
    );
  }
}
