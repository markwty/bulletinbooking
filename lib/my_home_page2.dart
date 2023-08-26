import 'dart:math';
import 'package:flutter/material.dart';
import 'header.dart';

class MyHomePage2 extends StatefulWidget {
  final Future<Map<String, String>> info;
  final double headerFraction;

  MyHomePage2(this.info, this.headerFraction, {Key key}) : super(key: key);

  @override
  _MyHomePage2State createState() => _MyHomePage2State();
}

class _MyHomePage2State extends State<MyHomePage2>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  final Color peachColor = Color.fromRGBO(240, 217, 185, 1);
  final double offset = 0.05, logoScale = 0.45;
  AnimationController _controller;
  Animation<double> _animation;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = TweenSequence(<TweenSequenceItem<double>>[
      TweenSequenceItem<double>(
        tween: Tween<double>(begin: 1.0, end: 0.0)
            .chain(CurveTween(curve: Curves.elasticOut)),
        weight: 1.0,
      )
    ]).animate(_controller);
    super.initState();
    _controller.forward(from: 0.0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
            child: Stack(children: [
          Image(
            image: AssetImage("assets/images/background.jpg"),
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            fit: BoxFit.cover,
            alignment: Alignment.center,
          ),
          Column(children: <Widget>[
            SizedBox(
              height:
                  MediaQuery.of(context).size.height * widget.headerFraction,
              child: FutureBuilder(
                  builder: (ctx, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      if (snapshot.hasData) {
                        final Map<String, String> data =
                            snapshot.data as Map<String, String>;
                        return wrap(generateWidgets(data));
                      }
                    }
                    return SizedBox.shrink();
                  },
                  future: widget.info),
            ),
            Container(
              color: Colors.transparent,
              child: Column(children: <Widget>[
                //Container(
                //    color: Colors.white, height: size.height * 5 / 1080),//55/1080
                Stack(children: <Widget>[
                  Container(
                      color: Colors.transparent, height: size.height * 0.008),
                  Align(
                      alignment: Alignment.center,
                      child: Container(
                          color: peachColor,
                          height: size.height * 0.008,
                          width: size.width * 0.85))
                ]),
                Container(
                    color: Colors.transparent, height: size.height * 30 / 1080),
                Container(
                    color: Colors.transparent,
                    child: TabBar(tabs: <Widget>[
                      Column(children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.fromLTRB(4.0, 4.0, 4.0, 0),
                          child: Text("F O R",
                              style: TextStyle(
                                  fontFamily: 'Abril-Fatface', fontSize: 14)),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(4.0, 0, 4.0, 4.0),
                          child: Text(
                              "B\u{00A0}U\u{00A0}L\u{00A0}L\u{00A0}E\u{00A0}T\u{00A0}I\u{00A0}N",
                              style: TextStyle(
                                  fontFamily: 'Abril-Fatface', fontSize: 14)),
                        ),
                        Text("CLICK HERE",
                            style: TextStyle(
                                fontFamily: 'JosefinSans',
                                fontSize: 14,
                                fontWeight: FontWeight.w300)),
                      ]),
                      Stack(children: [
                        Align(
                            alignment: Alignment.centerLeft, child: Text("<<")),
                        Align(
                            alignment: Alignment.centerRight, child: Text(">>"))
                      ]),
                      Column(children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.fromLTRB(4.0, 4.0, 4.0, 0),
                          child: Text("F O R",
                              style: TextStyle(
                                  fontFamily: 'Abril-Fatface', fontSize: 14)),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(4.0, 0, 4.0, 4.0),
                          child: Text(
                              "B\u{00A0}O\u{00A0}O\u{00A0}K\u{00A0}I\u{00A0}N\u{00A0}G",
                              style: TextStyle(
                                  fontFamily: 'Abril-Fatface', fontSize: 14)),
                        ),
                        Text("CLICK HERE",
                            style: TextStyle(
                                fontFamily: 'JosefinSans',
                                fontSize: 14,
                                fontWeight: FontWeight.w300))
                      ])
                    ])),
                Container(
                    color: Colors.transparent, height: size.height * 30 / 1080)
              ]),
            ),
            Stack(children: <Widget>[
              Column(children: <Widget>[
                Container(
                    color: Colors.transparent,
                    height: size.height * logoScale / 2),
                Container(
                    color: peachColor,
                    height: size.height * (logoScale / 2 + offset))
              ]),
              Padding(
                padding: EdgeInsets.only(
                    right: size.height * offset, bottom: size.height * offset),
                child: Center(
                  child: Container(
                      decoration: BoxDecoration(
                          color: peachColor, shape: BoxShape.circle),
                      height: size.height * logoScale),
                ),
              ),
              Padding(
                  padding: EdgeInsets.only(
                      left: size.height * offset, top: size.height * offset),
                  child: Center(
                    child: Container(
                        decoration: BoxDecoration(
                          color: Color.fromRGBO(236, 241, 245, 1),
                          shape: BoxShape.circle,
                          /*
                                  image: new DecorationImage(
                                    image: AssetImage("assets/images/background.jpg"),
                                    fit: BoxFit.cover)*/
                        ),
                        height: size.height * logoScale),
                  )),
              Center(
                  child: GestureDetector(
                      onTap: () {
                        _controller.forward(from: 0.0);
                      },
                      child: Container(
                          margin:
                              EdgeInsets.only(top: size.height * offset / 2),
                          height: size.height * logoScale,
                          decoration: BoxDecoration(
                              color: Color.fromRGBO(81, 81, 81, 1),
                              shape: BoxShape.circle),
                          child: AnimatedBuilder(
                              animation: _animation,
                              child: Image(
                                image: AssetImage("assets/images/icon.png"),
                                width: size.height * logoScale,
                                height: size.height * logoScale,
                                color: null,
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.center,
                              ),
                              builder: (context, child) {
                                return Transform.rotate(
                                    angle: _animation.value, child: child);
                              }))))
            ]),
            Column(
              children: [
                Container(
                    color: peachColor,
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          SizedBox(height: size.height / 18),
                          Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Text("F A I T H     S A N C T U A R Y",
                                  style: TextStyle(
                                      fontFamily: 'Abril-Fatface',
                                      fontSize: 14),
                                  textAlign: TextAlign.center)),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("View Events ",//"14 ARUMUGUM RD",
                                  style: TextStyle(
                                      fontFamily: 'JosefinSans',
                                      fontSize: 14,
                                      fontWeight: FontWeight.w300),
                                  textAlign: TextAlign.center),
                              Icon(Icons.calendar_today_rounded,
                                  color: Colors.black, size: 24.0)
                            ],
                          ),
                          Container(
                            color: peachColor,
                            height: size.height * 0.008,
                          )
                        ])),
                Stack(children: <Widget>[
                  Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                          color: peachColor,
                          height: size.height * 0.008,
                          width: size.width * 0.075)),
                  Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                          color: peachColor,
                          height: size.height * 0.008,
                          width: size.width * 0.075))
                ]),
                Container(
                    color: peachColor,
                    width: MediaQuery.of(context).size.width,
                    height: size.height * 30 / 1080,
                    child: Transform.rotate(
                      angle: - pi / 2,
                      child: Icon(Icons.arrow_back_ios_new_rounded,
                          color: Colors.black, size: 24.0),
                    ))
              ],
            )
          ])
        ])));
  }
}
