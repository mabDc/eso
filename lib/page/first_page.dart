import 'package:eso/eso_theme.dart';
import 'package:flutter/material.dart';

class FirstPage extends StatelessWidget {
  const FirstPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          SizedBox(
            height: 150,
            width: double.infinity,
          ),
          Stack(
            alignment: Alignment.center,
            children: <Widget>[
              Container(
                height: 80.0,
                width: 80.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF18D191),
                ),
                child: new Icon(
                  Icons.library_books,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              Container(
                margin: EdgeInsets.only(right: 90.0, top: 80.0),
                height: 80.0,
                width: 80.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF45E0EC),
                ),
                child: Icon(
                  Icons.photo_library,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              Container(
                margin: EdgeInsets.only(left: 10.0, top: 90.0),
                height: 80.0,
                width: 80.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFFFCE56),
                ),
                child: Icon(
                  Icons.library_music,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              Container(
                margin: EdgeInsets.only(left: 100.0, top: 70.0),
                height: 80.0,
                width: 80.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFFC6A7F),
                ),
                child: Icon(
                  Icons.video_library,
                  color: Colors.white,
                  size: 32,
                ),
              )
            ],
          ),
          SizedBox(
            height: 20,
          ),
          // Container(
          //   height: 100,
          //   width: 100,
          //   child: Image.asset(
          //     Global.logoPath,
          //     fit: BoxFit.fill,
          //   ),
          // ),
          Text(
            'ESO',
            style: TextStyle(
              fontSize: 80,
              fontWeight: FontWeight.bold,
              fontStyle: FontStyle.italic,
              fontFamily: ESOTheme.staticFontFamily,
              letterSpacing: 6,
              color: Color.fromARGB(255, 40, 185, 130),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Text(
            'my custom reader & player in one app',
            style: TextStyle(
              color: Colors.grey,
            ),
          ),
          Spacer(),
        ],
      ),
    );
  }
}
