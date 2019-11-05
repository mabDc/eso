import 'package:eso/database/search_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_seekbar/flutter_seekbar.dart';

class AudioPage extends StatefulWidget {
  final SearchItem searchItem;

  const AudioPage({
    this.searchItem,
    Key key,
  }) : super(key: key);

  @override
  _AudioPageState createState() => _AudioPageState();
}

class _AudioPageState extends State<AudioPage> {
  Widget _audioPage;

  @override
  Widget build(BuildContext context) {
    if (_audioPage == null) {
      _audioPage = _buildPage();
    }
    return _audioPage;
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget _buildPage() {
    return Scaffold(
      body: Container(
        height: double.infinity,
        width: double.infinity,
        child: Column(
          children: <Widget>[
            SizedBox(
              height: MediaQuery.of(context).padding.top,
            ),
            Container(
              height: 50,
              color: Colors.black.withAlpha(30),
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: _buildTopRow(),
            ),
            Expanded(
              child: Container(),
            ),
            Container(
              height: 100,
              color: Colors.black.withAlpha(30),
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  _buildProgressBar(),
                  _buildBottomController(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopRow() {
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
                '${widget.searchItem.name}',
                maxLines: 1,
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.white70,
                ),
              ),
              Text(
                '${widget.searchItem.author}',
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
          onTap: () {},
        ),
      ],
    );
  }

  Widget _buildProgressBar() {
    return Center(
      child: Row(
        children: <Widget>[
          Text('00:00'),
          SizedBox(
            width: 10,
          ),
          Expanded(
            child: SeekBar(
              value: 50,
              max: 100,
              backgroundColor: Colors.white54,
              progresseight: 2,
              afterDragShowSectionText: true,
              onValueChanged: (progress) {},
              indicatorRadius: 4,
            ),
          ),
          SizedBox(
            width: 10,
          ),
          Text('00:00'),
        ],
      ),
    );
  }

  Widget _buildBottomController() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        InkWell(
          child: Icon(
            Icons.skip_previous,
            color: Colors.white,
            size: 26,
          ),
          onTap: () {},
        ),
        SizedBox(
          width: 30,
        ),
        InkWell(
          child: Icon(
            Icons.play_circle_outline,
            color: Colors.white,
            size: 36,
          ),
          onTap: () {},
        ),
        SizedBox(
          width: 30,
        ),
        InkWell(
          child: Icon(
            Icons.skip_next,
            color: Colors.white,
            size: 26,
          ),
          onTap: () {},
        ),
      ],
    );
  }
}
