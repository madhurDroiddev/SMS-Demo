import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttersmsdemo/ContactBody.dart';
import 'package:sms/sms.dart';

import 'SmsBody.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  List<SmsMessage> messages;

  StreamController<List<SmsMessage>> listController =
      StreamController.broadcast();
  StreamController<int> bottomController = StreamController.broadcast();

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    listController.close();
    bottomController.close();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _tabController = new TabController(length: 2, vsync: this);
    _tabController.addListener(listener);
  }

  TabController _tabController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: TabBarView(
        physics: NeverScrollableScrollPhysics(),
        // Add tabs as widgets
        children: <Widget>[
          SmsBody(),
          ContactBody(),
        ],
        // set the _controller
        controller: _tabController,
      ),
      bottomNavigationBar: StreamBuilder<int>(
          stream: bottomController.stream,
          initialData: 0,
          builder: (context, snapshot) {
            return BottomNavigationBar(
                currentIndex: snapshot.data,
                onTap: (index) => _tabController.animateTo(index),
                items: [
                  BottomNavigationBarItem(
                      icon: Icon(Icons.sms), title: Text("Messages")),
                  BottomNavigationBarItem(
                      icon: Icon(Icons.person), title: Text("Contacts"))
                ]);
          }),
    );
  }

  void listener() {
    bottomController.sink.add(_tabController.index);
  }
}
