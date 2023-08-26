import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'calendar_utils.dart';
import 'custom_card4.dart';
import 'runnable_task.dart';
import 'website.dart';

class CalendarPage2 extends StatefulWidget {
  final ValueNotifier<double> vertVal;
  final PageController vertController;
  final double offset, headerFraction;
  final Future<Map<String, String>> info;

  const CalendarPage2(this.info, this.headerFraction,
      {Key key, this.vertVal, this.vertController, this.offset = 0})
      : super(key: key);

  @override
  CalendarState createState() {
    return CalendarState();
  }
}

class CalendarState extends State<CalendarPage2> {
  Future<Map<DateTime, List<Event>>> futureEvents;
  final scrollDirection = Axis.vertical;
  AutoScrollController controller;
  Map<String, String> mapping = {};

  //@override
  //bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    controller = AutoScrollController(
        viewportBoundaryGetter: () =>
            Rect.fromLTRB(0, 0, 0, MediaQuery.of(context).padding.bottom),
        axis: scrollDirection);
    _init2();
    futureEvents = _init();
  }

  Future<Map<DateTime, List<Event>>> _init() async {
    RunnableTask runnableTask = RunnableTask(Website.url2 + '/events.txt');
    await runnableTask.run();
    String result = runnableTask.result;
    Map<DateTime, List<Event>> _kEventSource = Map();
    if (result != "") {
      LineSplitter ls = new LineSplitter();
      List<String> lines = ls.convert(result);
      List<String> ln = [];
      DateFormat inputFormat = DateFormat('dd/MM/yyyy');

      for (String line in lines) {
        ln = line.split("::");
        if (ln.length == 2) {
          DateTime dt = inputFormat.parse(ln[0]);
          ln[1] = ln[1].replaceAll('||', '\n');
          if (_kEventSource.containsKey(dt)) {
            _kEventSource[dt].add(Event(ln[1]));
          } else {
            _kEventSource[dt] = [Event(ln[1])];
          }
        }
      }
    }
    return _kEventSource;
  }

  Future<void> _init2() async {
    RunnableTask runnableTask = RunnableTask(Website.url2 + '/calendar.txt');
    await runnableTask.run();
    String result = runnableTask.result;
    if (result != "") {
      LineSplitter ls = new LineSplitter();
      List<String> lines = ls.convert(result);
      List<String> ln = [];
      for (String line in lines) {
        ln = line.split("::");
        if (ln.length == 2) {
          for (String value in ln[1].split("||")){
            mapping[value] = ln[0];
          }
        }
      }
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //super.build(context);
    return Scaffold(
      backgroundColor: Color.fromRGBO(240, 217, 185, 1),
      body:
        Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width - widget.offset,
          child: FutureBuilder(
            builder: (ctx, snapshot) {
              if (snapshot.connectionState ==
                  ConnectionState.done) {
                if (snapshot.hasData) {
                  final Map<DateTime, List<Event>> data = snapshot.data as Map<DateTime, List<Event>>;
                  CustomCard4.mapping = mapping;
                  List<CustomCard4> widgets = [];
                  data.forEach((k, v) => widgets.add(CustomCard4(k, v)));
                  widgets.sort((a, b) => a.datetime.compareTo(b.datetime));
                  String eventName = "null";
                  DateTime datetime = null;
                  int endIndex = 0;
                  for (int i = widgets.length-1; i>=0; i--){
                    if (widgets[i].events.length == 1 && eventName == widgets[i].events[0].title){
                      if (datetime == null){
                        datetime = widgets[i+1].datetime;
                        endIndex = i+1;
                      }
                    } else {
                      if (datetime != null){
                        widgets.insert(i+1, CustomCard4(widgets[i+1].datetime, [Event(eventName)], end: datetime));
                        widgets.removeRange(i+2, endIndex+2);
                      }
                      if (widgets[i].events.length == 1) {
                        eventName = widgets[i].events[0].title;
                      } else {
                        eventName = "null";
                      }
                      datetime = null;
                    }
                  }
                  DateTime now = new DateTime.now();
                  now = DateTime(now.year, now.month, now.day, 0, 0);
                  int offset = 0;
                  for (CustomCard4 widget in widgets){
                    if (widget.datetime.isAfter(now.subtract(Duration(seconds:1)))){
                      break;
                    }
                    offset = offset + 1;
                  }
                  controller.scrollToIndex(offset, duration: const Duration(seconds:2), preferPosition: AutoScrollPosition.begin);
                  return
                  /*
                    ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      controller: controller,
                      padding: const EdgeInsets.all(20.0),
                      itemCount: widgets.length,
                      itemBuilder: (context, index) {
                        return widgets[index];
                      }
                    );
                  */
                    ListView(
                      scrollDirection: scrollDirection,
                      controller: controller,
                      children: <Widget>[...List.generate(widgets.length, (index) {
                          return AutoScrollTag(
                            key: ValueKey(index),
                            controller: controller,
                            index: index,
                            child: widgets[index]
                          );
                        }),
                      ],
                    );
                }
              }
              return SizedBox.shrink();
            },
            future: futureEvents
          ),
        )
    );
  }
}