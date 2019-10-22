import 'package:flutter/material.dart';

class SearchPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: Theme.of(context).iconTheme.copyWith(color: Colors.black54),
        actions: <Widget>[
          IconButton(icon: Icon(Icons.clear),),
        ],
        title: TextField(style: TextStyle(color: Colors.black87),),
      ),
      body: Container(),
    );
  }
}
