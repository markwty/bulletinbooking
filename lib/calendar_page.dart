import 'dart:collection';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:url_launcher/url_launcher.dart';
import 'calendar_utils.dart';
import 'runnable_task.dart';
import 'website.dart';

class CalendarPage extends StatefulWidget {
  final ValueNotifier<double> vertVal;
  final PageController vertController;
  final double offset, headerFraction;
  final Future<Map<String, String>> info;

  const CalendarPage(this.info, this.headerFraction,
      {Key key, this.vertVal, this.vertController, this.offset = 0})
      : super(key: key);

  @override
  CalendarState createState() {
    return CalendarState();
  }
}

class CalendarState extends State<CalendarPage>
    with AutomaticKeepAliveClientMixin {
  PageController _pageController;
  DateTime _selectedDay;
  ValueNotifier<List<Event>> _selectedEvents;
  final ValueNotifier<DateTime> _focusedDay = ValueNotifier(DateTime.now());
  bool _mounted = true;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  final RangeSelectionMode _rangeSelectionMode = RangeSelectionMode.disabled;
  final Map<DateTime, List<Event>> _kEventSource = new Map();
  LinkedHashMap kEvents = new LinkedHashMap();
  final List<ValueNotifier<double>> listVals = [];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    if (!_mounted) {
      return;
    }
    _selectedDay = _focusedDay.value;
    _selectedEvents = ValueNotifier(_getEventsForDay(_focusedDay.value));
    _init();
  }

  Future<void> _init() async {
    RunnableTask runnableTask = RunnableTask(Website.url2 + '/events.txt');
    await runnableTask.run();
    String result = runnableTask.result;
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
    /*
    _kEventSource[DateTime.now()] = [
      Event("Event 1"),
      Event("Event 2"),
      Event("Event 3"),
      Event("Event 4"),
      Event("Event 5"),
      Event("Event 6")
    ];
     */

    kEvents = LinkedHashMap<DateTime, List<Event>>(
      equals: isSameDay,
      hashCode: getHashCode,
    )..addAll(_kEventSource);

    DateTime now = DateTime.now();
    _selectedDay = now;
    if (!_mounted) {
      return;
    }
    _selectedEvents.value = _getEventsForDay(now);
    _focusedDay.value = now;
  }

  @override
  void dispose() {
    _focusedDay.dispose();
    _selectedEvents.dispose();
    _mounted = false;
    for (ValueNotifier<double> animVal in listVals) {
      animVal.dispose();
    }
    super.dispose();
  }

  List<Event> _getEventsForDay(DateTime day) {
    return kEvents[day] ?? [];
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    _selectedDay = selectedDay;
    if (!_mounted) {
      return;
    }
    _selectedEvents.value = _getEventsForDay(selectedDay);
    _focusedDay.value = focusedDay;
    for (ValueNotifier<double> animVal in listVals) {
      animVal.value = -15 / 70;
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: Color.fromRGBO(240, 217, 185, 1),
      body: Row(
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width - widget.offset,
            child: Column(
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height *
                      widget.headerFraction,
                  /*
                  child: FutureBuilder(
                      builder: (ctx, snapshot) {
                        if (snapshot.connectionState == ConnectionState.done) {
                          if (snapshot.hasData) {
                            final Map<String, String> data =
                                snapshot.data as Map<String, String>;
                            return AdvisoryBanner("Latest church update",
                                wrap(generateWidgets(data)),
                                color: Colors.red);
                          }
                        }
                        return SizedBox.shrink();
                      },
                      future: widget.info),
                   */
                ),
                Container(
                    color: Color.fromRGBO(216, 220, 220, 1),
                    child: Column(children: [
                      ValueListenableBuilder<DateTime>(
                        valueListenable: _focusedDay,
                        builder: (context, value, _) {
                          return _CalendarHeader(
                              focusedDay: value,
                              onLeftArrowTap: () {
                                _pageController.previousPage(
                                  duration: Duration(milliseconds: 300),
                                  curve: Curves.easeOut,
                                );
                              },
                              onRightArrowTap: () {
                                _pageController.nextPage(
                                  duration: Duration(milliseconds: 300),
                                  curve: Curves.easeOut,
                                );
                              },
                              vertVal: widget.vertVal);
                        },
                      ),
                      ValueListenableBuilder<DateTime>(
                          valueListenable: _focusedDay,
                          builder: (context, value, _) {
                            return TableCalendar<Event>(
                                firstDay: kFirstDay,
                                lastDay: kLastDay,
                                focusedDay: value,
                                headerVisible: false,
                                selectedDayPredicate: (day) =>
                                    _selectedDay == day,
                                calendarFormat: _calendarFormat,
                                rangeSelectionMode: _rangeSelectionMode,
                                eventLoader: _getEventsForDay,
                                onDaySelected: _onDaySelected,
                                //onRangeSelected: _onRangeSelected,
                                onCalendarCreated: (controller) =>
                                    _pageController = controller,
                                onPageChanged: (focusedDay) =>
                                    _focusedDay.value = focusedDay,
                                onFormatChanged: (format) {
                                  if (_calendarFormat != format) {
                                    for (ValueNotifier<double> animVal
                                        in listVals) {
                                      animVal.value = -15 / 70;
                                    }
                                    setState(() {
                                      _calendarFormat = format;
                                    });
                                  } /*else if (offsetDifference < -15) {
                                    widget.vertController.animateTo(0,
                                        duration: const Duration(milliseconds: 500),
                                        curve: Curves.linear);
                                  }*/
                                });
                          }),
                      Container(
                          color: Color.fromRGBO(216, 220, 220, 1), height: 8.0)
                    ])),
                Expanded(
                  child: ValueListenableBuilder<List<Event>>(
                    valueListenable: _selectedEvents,
                    builder: (context, value, _) {
                      /*
                      return NotificationListener<OverscrollNotification>(
                          child: NotificationListener<ScrollUpdateNotification>(
                              child: ListView.builder(
                                itemCount: value.length,
                                itemBuilder: (context, index) {
                                  if (index >= listVals.length) {
                                    ValueNotifier<double> animVal =
                                        ValueNotifier(-15 / 70);
                                    listVals.add(animVal);
                                    return TagBox('${value[index]}', animVal, index);
                                  }
                                  return TagBox(
                                      '${value[index]}', listVals[index], index);
                                },
                              ),
                              onNotification: (notification) {
                                double value =
                                    (notification.metrics.pixels - 15) / 70;
                                listVals[value.floor() + 1].value = value;
                                if (value.floor() >= 0) {
                                  listVals[value.floor()].value = value;
                                }
                                return true;
                              }),
                          onNotification: (notification) {
                            if (notification.overscroll < -2) {
                              /*
                              widget.vertController.jumpTo(
                                  widget.vertController.offset +
                                      notification.overscroll * 2.5);
                               */
                              widget.vertController.animateTo(0,
                                  duration: const Duration(milliseconds: 500),
                                  curve: Curves.linear);
                            }
                            return true;
                          });
                       */
                      return NotificationListener<ScrollUpdateNotification>(
                          child: ListView.builder(
                            itemCount: value.length,
                            itemBuilder: (context, index) {
                              if (index >= listVals.length) {
                                ValueNotifier<double> animVal =
                                    ValueNotifier(-15 / 70);
                                listVals.add(animVal);
                                return TagBox(
                                    '${value[index]}', animVal, index);
                              }
                              return TagBox(
                                  '${value[index]}', listVals[index], index);
                            },
                          ),
                          onNotification: (notification) {
                            double value =
                                (notification.metrics.pixels - 15) / 70;
                            listVals[value.floor() + 1].value = value;
                            if (value.floor() >= 0) {
                              listVals[value.floor()].value = value;
                            }
                            return true;
                          });
                    },
                  ),
                ),
                SizedBox(width: widget.offset)
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CalendarHeader extends StatelessWidget {
  final DateTime focusedDay;
  final VoidCallback onLeftArrowTap;
  final VoidCallback onRightArrowTap;

  //final VoidCallback onTodayButtonTap;
  //final VoidCallback onClearButtonTap;
  final bool clearButtonVisible;
  final ValueNotifier<double> vertVal;
  final double offset = 0.05,
      logoScale = 0.4,
      sizeFrac = 0.13,
      yFrac = 0.23 - 0.1,
      xFrac = 0.4; //-headerFrac

  const _CalendarHeader(
      {Key key,
      this.focusedDay,
      this.onLeftArrowTap,
      this.onRightArrowTap,
      //this.onTodayButtonTap,
      //this.onClearButtonTap,
      this.clearButtonVisible,
      this.vertVal})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final headerText = DateFormat.yMMM().format(focusedDay);
    return Stack(children: [
      Row(
        children: [
          const SizedBox(width: 16.0),
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: SizedBox(
                  width: 120.0,
                  child: Text(
                    headerText,
                    style: TextStyle(fontSize: 26.0),
                  )),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                icon: Icon(Icons.chevron_left),
                onPressed: onLeftArrowTap,
              ),
              IconButton(
                icon: Icon(Icons.chevron_right),
                onPressed: onRightArrowTap,
              )
            ],
          ),
        ],
      ),
      /*
      (vertVal != null)
          ? ValueListenableBuilder<double>(
              valueListenable: vertVal,
              child: Positioned(
                  left: MediaQuery.of(context).size.width * xFrac -
                      MediaQuery.of(context).size.height * (logoScale + offset)/2 * sizeFrac,
                  top: -11 + MediaQuery.of(context).size.height * (yFrac - (logoScale + offset)/2 * sizeFrac),
                  child: Container(
                    /*
                      decoration: BoxDecoration(
                          color: Color.fromRGBO(81, 81, 81, 1),
                          shape: BoxShape.circle),
                     */
                      child: Image(
                        image: AssetImage("assets/images/icon.png"),
                        width: MediaQuery.of(context).size.height * (logoScale + offset) * sizeFrac,
                        color: Colors.black,
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.center,
                      ))),
              builder: (_, value, child) =>
                  (value == 1) ? child : SizedBox.shrink())
          : SizedBox.shrink()*/
    ]);
  }
}

class TagBox extends StatelessWidget {
  final String text;
  final ValueNotifier<double> animVal;
  final int index;

  const TagBox(this.text, this.animVal, this.index);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<double>(
        valueListenable: animVal,
        builder: (context, value, _) => Container(
            padding: (value.floor() == index - 1 && value >= index - 0.1)
                ? EdgeInsets.lerp(
                    EdgeInsets.fromLTRB(20.0, 15, 20.0, 10),
                    EdgeInsets.fromLTRB(0.0, 15, 0.0, 10),
                    (value - index) * 10 + 1)
                : (value.floor() >= index)
                    ? EdgeInsets.fromLTRB(0.0, 15, 0.0, 10)
                    : EdgeInsets.fromLTRB(20.0, 15, 20.0, 10),
            color: const Color.fromRGBO(240, 217, 185, 1),
            child: Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                    color: (value.floor() == index - 1)
                        ? Color.lerp(
                            Color.fromRGBO(181, 167, 158, 1),
                            Color.fromRGBO(216, 220, 220, 1),
                            pow(value - index + 1, 5))
                        : (value.floor() >= index)
                            ? Color.fromRGBO(216, 220, 220, 1)
                            : Color.fromRGBO(181, 167, 158, 1),
                    borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(15),
                        topRight: const Radius.circular(15),
                        bottomLeft: (value.floor() == index - 1 &&
                                value >= index - 0.1)
                            ? Radius.lerp(
                                Radius.circular(15),
                                Radius.elliptical(
                                    MediaQuery.of(context).size.width - 40, 80),
                                (value - index) * 10 + 1)
                            : (value.floor() >= index)
                                ? Radius.elliptical(
                                    MediaQuery.of(context).size.width - 40, 80)
                                : Radius.circular(15),
                        bottomRight: (value.floor() == index - 1 &&
                                value >= index - 0.1)
                            ? Radius.lerp(
                                Radius.circular(15),
                                Radius.elliptical(
                                    MediaQuery.of(context).size.width - 40, 80),
                                (value - index) * 10 + 1)
                            : (value.floor() >= index)
                                ? Radius.elliptical(
                                    MediaQuery.of(context).size.width - 40, 80)
                                : Radius.circular(15))),
                child: Center(
                  child: Padding(
                      padding: const EdgeInsets.all(5),
                      child: /*Text(
                    utf8.decode(text.toString().codeUnits),//emoji support
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: HSLColor.fromAHSL(
                              (value.floor() == index - 1)
                                  ? -1 * pow(value - index + 1, 4) + 1
                                  : (value.floor() >= index)
                                      ? 0
                                      : 1,
                              220,
                              0.3,
                              0.3)
                          .toColor(),
                    ),*/
                          Linkify(
                        onOpen: (link) async {
                          if (await canLaunch(link.url)) {
                            await launch(link.url);
                          } else {
                            throw 'Could not launch $link';
                          }
                        },
                        text: utf8.decode(text.toString().codeUnits),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: HSLColor.fromAHSL(
                                  (value.floor() == index - 1)
                                      ? -1 * pow(value - index + 1, 4) + 1
                                      : (value.floor() >= index)
                                          ? 0
                                          : 1,
                                  220,
                                  0.3,
                                  0.3)
                              .toColor(),
                        ),
                        linkStyle: TextStyle(color: Colors.red),
                      )),
                ))));
  }
}
