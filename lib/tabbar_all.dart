import 'dart:convert';

import 'package:FS/runnable_task.dart';
import 'package:FS/website.dart';
import 'package:flutter/material.dart';

import 'bulletin_page.dart';
import 'calendar_page.dart';
import 'custom_vertical_tabs.dart';
import 'form_page.dart';
import 'my_home_page2.dart';

class TabBarAll extends StatefulWidget {
  TabBarAll({Key key}) : super(key: key);

  @override
  _TabBarAllState createState() => _TabBarAllState();
}

class _TabBarAllState extends State<TabBarAll> {
  Future<Map<String, String>> info;
  final double headerFraction = 0.1;

  @override
  void initState() {
    super.initState();
    info = _initExtraInfo();
  }

  Future<Map<String, String>> _initExtraInfo() async {
    Map<String, String> info = new Map();
    RunnableTask runnableTask = RunnableTask(Website.url2 + '/extra.txt');
    await runnableTask.run();
    String result = runnableTask.result;
    if (result != "") {
      LineSplitter ls = new LineSplitter();
      List<String> lines = ls.convert(result);
      List<String> ln = [];
      for (String line in lines) {
        ln = line.split("::");
        info[ln[0]] = ln[1];
      }
    }
    return info;
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      initialIndex: 1,
      child: Scaffold(
          body: TabBarView(
            physics: ClampingScrollPhysics(),
            children: [
              BulletinPage(info, headerFraction),
              CustomVerticalTabs(
                tabsWidth: 0,
                contentScrollAxis: Axis.vertical,
                tabs: <Tab>[Tab(text: ""), Tab(text: "")],
                contents: <Widget>[MyHomePage2(info, headerFraction), CalendarPage(info, headerFraction)],
              ),
              FormPage(info, headerFraction)
            ],
          )),
    );
  }
}