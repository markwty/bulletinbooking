import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'advisory_page.dart';
import 'custom_card.dart';
import 'header.dart' as Header;
import 'hovered_web_anchor.dart';
import 'runnable_task.dart';
import 'website.dart';

class BulletinPage extends StatefulWidget {
  final double offset;
  final Future<Map<String, String>> info;
  final double headerFraction;

  BulletinPage(this.info, this.headerFraction, {Key key, this.offset = 0})
      : super(key: key);

  @override
  _BulletinPageState createState() => _BulletinPageState();
}

class _BulletinPageState extends State<BulletinPage>
    with SingleTickerProviderStateMixin {
  final ScrollController _controller = ScrollController();
  Future<List<Widget>> topWidgets, futureWidgets;
  final _initialised = ValueNotifier<bool>(false);
  final _toggled = ValueNotifier<bool>(true);
  bool _mounted = true;
  final int offset = 200;
  final DateTime now = DateTime.now();
  AnimationController _animController;
  Animation<double> _animation;

  //DateTime now = DateTime.parse("2023-03-12 06:01:00Z");
  Map<String, String> mp = new Map();

  Future<List<Widget>> getLatestList() async {
    List<Widget> content = [];
    int weekDay = now.weekday;
    DateTime next;
    bool pass = false;//(weekDay == 7 && now.hour >= 6);

    if (weekDay == 7 && now.hour >= 11) {
      next = now.add(const Duration(days: 7));
    } else {
      next = now.add(Duration(days: 7 - weekDay));
    }

    DateFormat formatter = new DateFormat('d MMM yyyy');
    content.add(Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
        child: Align(
            alignment: Alignment.centerLeft,
            child: Stack(
              children: [
                Text('L A T E S T',
                    style: TextStyle(
                        fontFamily: "Abril-Fatface",
                        fontWeight: FontWeight.bold,
                        fontSize: 30,
                        foreground: Paint()
                          ..style = PaintingStyle.stroke
                          ..strokeWidth = 6
                          ..color = Colors.black45,
                    )),
                Text('L A T E S T',
                    style: TextStyle(
                      fontFamily: "Abril-Fatface",
                      fontWeight: FontWeight.bold,
                      fontSize: 30,
                      color: Color.fromRGBO(160, 190, 161, 1)
                    ))
              ]
            ))));

    DateFormat formatter2 = new DateFormat('ddMMyyyy');
    String formattedDate = formatter2.format(next);

    if (mp.containsKey(formattedDate)) {
      formattedDate = mp[formattedDate];
    }
    String link = 'https://tinyurl.com/ebulletin$formattedDate';
    http.Client httpClient = new http.Client();
    //Future<http.Response> response = httpClient.head(Uri.parse(link));

    content.add(Padding(
      padding: const EdgeInsets.all(5.0),
      child: Align(
          alignment: Alignment.centerLeft,
          child: Text('Bulletin (${formatter.format(next)})',
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 20))),
    ));

    http.StreamedResponse res = await httpClient.head(Uri.parse(link)).then((
        res) {
      pass = (res.statusCode == 200);
    }).catchError((error) {
      print(error.toString());
      pass = true;
    });

    if (pass) {
      content.add(new HoveredWebAnchor(label: '$link', url: link));
    } else {
      content.add(Row(children: <Widget>[
        Icon(Icons.double_arrow_rounded, color: Colors.blueGrey),
        Padding(
          padding: const EdgeInsets.only(top: 3.0),
          child: Text('Link is not available',
              style: const TextStyle(
                  color: Colors.red,
                  fontSize: 16,
                  fontFamily: "JosefinSans",
                  fontWeight: FontWeight.w300)),
        )
      ]));
    }
    return content;
  }

  List<Widget> getLatestListDefault() {
    List<Widget> content = [];
    int weekDay = now.weekday;
    DateTime next;
    if (weekDay == 7 && now.hour >= 11) {
      next = now.add(const Duration(days: 7));
    } else {
      next = now.add(Duration(days: 7 - weekDay));
    }

    DateFormat formatter = new DateFormat('d MMM yyyy');
    content.add(Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
      child: Align(
          alignment: Alignment.centerLeft,
          child: Stack(
            children: [
              Text('L A T E S T',
                  style: TextStyle(
                    fontFamily: "Abril-Fatface",
                    fontWeight: FontWeight.bold,
                    fontSize: 30,
                    foreground: Paint()
                      ..style = PaintingStyle.stroke
                      ..strokeWidth = 6
                      ..color = Colors.black45,
                    //color: Color.fromRGBO(160, 190, 161, 1)
                  )),
              Text('L A T E S T',
                  style: TextStyle(
                      fontFamily: "Abril-Fatface",
                      fontWeight: FontWeight.bold,
                      fontSize: 30,
                      color: Color.fromRGBO(160, 190, 161, 1)
                  ))
            ]
          ))
    ));

    content.add(Padding(
      padding: const EdgeInsets.all(5.0),
      child: Align(
          alignment: Alignment.centerLeft,
          child: Text('Bulletin (${formatter.format(next)})',
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 20))),
    ));

    content.add(Align(
        alignment: Alignment.centerLeft,
        child: Text(" Loading",
            style: const TextStyle(
                color: Colors.blueGrey,
                fontSize: 16,
                fontFamily: "JosefinSans",
                fontWeight: FontWeight.w300))));
    return content;
  }

  Future<List<Widget>> getLastWeekList({int weekNum = 1}) async {
    List<Widget> content = [];
    int weekDay = now.weekday;
    DateTime previous;
    if (weekDay == 7 && now.hour >= 11) {
      previous = now;
    } else {
      previous = now.subtract(Duration(days: weekDay));
    }
    DateFormat formatter = new DateFormat('d MMM yyyy');
    String formattedDate = formatter.format(previous);
    DateFormat formatter2 = new DateFormat('ddMMyyyy');
    String formattedDate2 = formatter2.format(previous);
    if (mp.containsKey(formattedDate2)) {
      formattedDate2 = mp[formattedDate2];
    }
    String link = 'https://tinyurl.com/ebulletin$formattedDate2';
    content.add(new CustomCard('$formattedDate', link: link));
    for (int i = 0; i < weekNum - 1; i++) {
      previous = previous.subtract(Duration(days: 7));
      formattedDate = formatter.format(previous);
      formattedDate2 = formatter2.format(previous);
      if (mp.containsKey(formattedDate2)) {
        formattedDate2 = mp[formattedDate2];
      }
      link = 'https://tinyurl.com/ebulletin$formattedDate2';
      content.add(new CustomCard('$formattedDate', link: link));
    }

    return content;
  }

  /*
  Widget wrap2(List<Widget> widgets, ScrollController controller) {
    return ListView(
        //shrinkWrap: true,
        controller: controller,
        padding: const EdgeInsets.all(20.0),
        children: widgets);
  }
   */

  Widget wrap(List<Widget> widgets, ScrollController controller) {
    return AnimationLimiter(
        child: ListView.builder(
      controller: controller,
      padding: const EdgeInsets.all(20.0),
      itemCount: widgets.length,
      itemBuilder: (BuildContext context, int index) {
        return AnimationConfiguration.staggeredList(
          position: index,
          duration: const Duration(milliseconds: 375),
          child: SlideAnimation(
              verticalOffset: 50.0,
              child: FadeInAnimation(
                child: widgets[index],
              )),
        );
      },
    ));
  }

  Future<void> _init() async {
    RunnableTask runnableTask = RunnableTask(Website.url2 + '/summary.txt');
    await runnableTask.run();
    String result = runnableTask.result;
    if (result != "") {
      LineSplitter ls = new LineSplitter();
      List<String> lines = ls.convert(result);
      List<String> ln = [];
      for (String line in lines) {
        ln = line.split("::");
        if (ln.length == 2) {
          mp[ln[0]] = ln[1];
        }
      }
    }
  }

  @override
  void initState() {
    _animController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _animation = TweenSequence(<TweenSequenceItem<double>>[
      TweenSequenceItem<double>(
        tween: Tween<double>(begin: 2.0, end: 0.0)
            .chain(CurveTween(curve: Curves.fastOutSlowIn)),
        weight: 1.0,
      )
    ]).animate(_animController);
    super.initState();
    _init().then((_) {
      futureWidgets = getLastWeekList(weekNum: 4);
      topWidgets = getLatestList();
      if (_mounted) {
        _initialised.value = true;
      }
    });
    _animController.forward(from: 0.0);
  }

  @override
  void dispose() {
    _initialised.dispose();
    _toggled.dispose();
    _animController.dispose();
    _mounted = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Row(
          children: [
            SizedBox(width: widget.offset),
            SingleChildScrollView(
              child: SizedBox(
                width: MediaQuery.of(context).size.width - widget.offset,
                child: Stack(children: <Widget>[
                  /*
                    Center(
                      child: Container(
                        width: widget.size.width * 5/6,
                        decoration: BoxDecoration(
                          shape: BoxShape.rectangle,
                          image: DecorationImage(
                            fit: BoxFit.contain,
                            image: AssetImage('images/bulletin.png')
                          )
                        )
                      ),
                    ),
                     */
                  Column(
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height *
                            widget.headerFraction,
                        /*
                        child: FutureBuilder(
                            builder: (ctx, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.done) {
                                if (snapshot.hasData) {
                                  final Map<String, String> data =
                                      snapshot.data as Map<String, String>;
                                  return AdvisoryBanner("Latest church update",
                                      Header.wrap(Header.generateWidgets(data)),
                                      color: Colors.red);
                                }
                              }
                              return SizedBox.shrink();
                            },
                            future: widget.info),
                         */
                      ),
                      Container(
                          margin: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 15),
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          height: 150,
                          alignment: Alignment.topRight,
                          decoration: BoxDecoration(
                              color: Color.fromRGBO(240, 217, 185, 1),
                              border:
                                  Border.all(width: 5, color: Colors.black)),
                          child: ValueListenableBuilder(
                              valueListenable: _initialised,
                              builder: (_, value, __) => FutureBuilder(
                                  builder: (ctx, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.done) {
                                      if (snapshot.hasData) {
                                        final List<Widget> data =
                                            snapshot.data as List<Widget>;
                                        return AnimatedBuilder(
                                            animation: _animation,
                                            child: Column(children: data),
                                            builder: (context, child) {
                                              return Transform.translate(
                                                  offset: Offset(0,
                                                      -_animation.value * 20),
                                                  child: child);
                                            });
                                      }
                                    }
                                    return AnimatedBuilder(
                                        animation: _animation,
                                        child: Column(
                                            children: getLatestListDefault()),
                                        builder: (context, child) {
                                          return Transform.translate(
                                              offset: Offset(
                                                  0, -_animation.value * 20),
                                              child: child);
                                        });
                                  },
                                  future: topWidgets))),
                    ],
                  ),
                  Column(children: <Widget>[
                    SizedBox(
                        height:
                            150 + MediaQuery.of(context).size.height * 0.15),
                    Container(
                        alignment: Alignment.topRight,
                        decoration: BoxDecoration(
                            color: Color.fromRGBO(250, 243, 225, 0.7),
                            shape: BoxShape.rectangle),
                        child: ValueListenableBuilder(
                            valueListenable: _initialised,
                            builder: (_, value, __) => FutureBuilder(
                                builder: (ctx, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.done) {
                                    if (snapshot.hasData) {
                                      final List<Widget> data =
                                          snapshot.data as List<Widget>;
                                      return Container(
                                          height: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.85 -
                                              offset,
                                          child: wrap(data, _controller));
                                    }
                                  }
                                  return Container(
                                      height:
                                          MediaQuery.of(context).size.height *
                                                  0.85 -
                                              offset);
                                },
                                future: futureWidgets)))
                  ])
                ]),
              ),
            ),
          ],
        ),
        floatingActionButton: AnimatedBuilder(
            animation: _animation,
            child: ValueListenableBuilder(
              valueListenable: _toggled,
              builder: (_, value, __) => FloatingActionButton(
                  child: value
                      ? const Icon(Icons.arrow_drop_down)
                      : const Icon(Icons.arrow_drop_up),
                  onPressed: () {
                    _controller.animateTo(
                      value ? _controller.position.maxScrollExtent : 0.0,
                      curve: Curves.easeOut,
                      duration: const Duration(milliseconds: 300),
                    );
                    _toggled.value = !_toggled.value;
                  }),
            ),
            builder: (context, child) {
              return Transform.translate(
                  offset: Offset(0, _animation.value * 20), child: child);
            }));
  }
}
