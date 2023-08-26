import 'dart:math';
//import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'advisory_page.dart';
import 'header.dart';

class MyHomePage extends StatefulWidget {
  final PageController pageController;
  final Future<Map<String, String>> info;
  final double headerFraction;

  MyHomePage(this.info, this.headerFraction, {Key key, this.pageController})
      : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  final Color peachColor = Color.fromRGBO(240, 217, 185, 1);
  final double offset = 0.05, logoScale = 0.45;
  AnimationController _controller;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    final Animation<double> _animation =
        TweenSequence(<TweenSequenceItem<double>>[
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
        child: Stack(
          children: [
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
                          if(data.length == 1){
                            if(data.keys.first.trim() == ""){
                              return const SizedBox.shrink();
                            }
                            return AdvisorySingle(data.keys.first, data.values.first, color: Colors.red);
                          }
                          return AdvisoryBanner("Latest church update",
                              wrap(generateWidgets(data)),
                              color: Colors.red);
                        }
                      }
                      return SizedBox.shrink();
                    },
                    future: widget.info),
              ),
              Container(
                color: Colors.transparent,
                child: Column(children: <Widget>[
                  //Container(color: Colors.white, height: size.height * 55 / 1080),
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
                      color: Colors.transparent,
                      height: size.height * 30 / 1080),
                  Container(
                      color: Colors.transparent,
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            GestureDetector(
                              onTap: () {
                                if (widget.pageController != null) {
                                  widget.pageController.animateTo(1,
                                      duration:
                                          const Duration(milliseconds: 500),
                                      curve: Curves
                                          .linear); //2 * MediaQuery.of(context).size.width
                                }
                              },
                              child: Row(
                                children: [
                                  Transform.rotate(
                                      angle: pi,
                                      child:
                                          Icon(Icons.double_arrow, size: 40)),
                                  Column(children: <Widget>[
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          1.0, 1.0, 1.0, 0),
                                      child: Text("F O R",
                                          style: TextStyle(
                                              fontFamily: 'Abril-Fatface',
                                              fontSize: 14)),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          1.0, 0, 1.0, 1.0),
                                      child: Text(
                                          "B\u{00A0}U\u{00A0}L\u{00A0}L\u{00A0}E\u{00A0}T\u{00A0}I\u{00A0}N",
                                          style: TextStyle(
                                              fontFamily: 'Abril-Fatface',
                                              fontSize: 14)),
                                    ),
                                    Text("CLICK HERE",
                                        style: TextStyle(
                                            fontFamily: 'JosefinSans',
                                            fontSize: 14,
                                            fontWeight: FontWeight.w300))
                                  ])
                                ],
                              ),
                            ),
                            SizedBox(
                                width:
                                    MediaQuery.of(context).size.width * 0.15),
                            GestureDetector(
                              onTap: () {
                                if (widget.pageController != null) {
                                  widget.pageController.animateTo(
                                      MediaQuery.of(context).size.width * 1.99,
                                      duration:
                                          const Duration(milliseconds: 500),
                                      curve: Curves
                                          .linear); //2 * MediaQuery.of(context).size.width
                                }
                              },
                              child: Row(
                                children: [
                                  Column(children: <Widget>[
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          1.0, 1.0, 1.0, 0),
                                      child: Text("F O R",
                                          style: TextStyle(
                                              fontFamily: 'Abril-Fatface',
                                              fontSize: 14)),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          1.0, 0, 1.0, 1.0),
                                      child: Text(
                                          "C\u{00A0}A\u{00A0}L\u{00A0}E\u{00A0}N\u{00A0}D\u{00A0}A\u{00A0}R",
                                          style: TextStyle(
                                              fontFamily: 'Abril-Fatface',
                                              fontSize: 14)),
                                    ),
                                    Text("CLICK HERE",
                                        style: TextStyle(
                                            fontFamily: 'JosefinSans',
                                            fontSize: 14,
                                            fontWeight: FontWeight.w300))
                                  ]),
                                  Icon(Icons.double_arrow, size: 40)
                                ],
                              ),
                            )
                          ])),
                  Container(
                      color: Colors.transparent,
                      height: size.height * 30 / 1080)
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
                      right: size.height * offset,
                      bottom: size.height * offset),
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
                              shape: BoxShape.circle),
                          height: size.height * logoScale),
                    )),
                Container(
                  margin: EdgeInsets.only(top: size.height * offset / 2),
                  height: size.height * logoScale,
                  decoration: BoxDecoration(
                      color: Color.fromRGBO(81, 81, 81, 1),
                      shape: BoxShape.circle),
                )
                /*
                Center(
                    child: GestureDetector(
                        onTap: () {
                          _controller.forward(from: 0.0);
                        },
                        child: Container(
                            height: size.height *
                                (logoScale + offset),
                            decoration: BoxDecoration(
                                color: Color.fromRGBO(81, 81, 81, 1),
                                shape: BoxShape.circle),
                            child: AnimatedBuilder(
                                animation: _animation,
                                child: Image(
                                  image: AssetImage("assets/images/icon.png"),
                                  width: size.height *
                                      logoScale,
                                  height: size.height *
                                      logoScale,
                                  color: null,
                                  fit: BoxFit.scaleDown,
                                  alignment: Alignment.center,
                                ),
                                builder: (context, child) {
                                  return Transform.rotate(
                                      angle: _animation.value, child: child);
                                }))
                        ))*/
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
                            /*
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text("View Events ", //"14 ARUMUGUM RD",
                                    style: TextStyle(
                                        fontFamily: 'JosefinSans',
                                        fontSize: 14,
                                        fontWeight: FontWeight.w300),
                                    textAlign: TextAlign.center),
                                Icon(Icons.calendar_today_rounded,
                                    color: Colors.black, size: 24.0)
                              ],
                            ),
                              */
                            Container(
                              color: peachColor,
                              height: size.height * 0.008,
                            )
                          ])),
                  /*
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
                          angle: -pi / 2,
                          child: Icon(Icons.arrow_back_ios_new_rounded,
                              color: Colors.black, size: 24.0)))
                   */
                ],
              ),
              //SizedBox(height: size.height / 36),
              SizedBox(height: size.height / 60),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                Flexible(
                  flex: 2,
                  child:
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Container(
                        padding: const EdgeInsets.all(10.0),
                        decoration: BoxDecoration(
                            color: Color.fromRGBO(238, 37, 54, 50),//237, 41, 57
                            borderRadius: BorderRadius.all(Radius.circular(10))
                        ),
                        child: InkWell(
                        hoverColor: Colors.transparent,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Text("\n",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                    fontFamily: 'JosefinSans',
                                    fontWeight: FontWeight.w100)),
                            Text("COMMUNIQUE",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontFamily: 'JosefinSans',
                                    fontWeight: FontWeight.w100))
                          ],
                        ),
                        onTap: () => launch(
                            "https://tinyurl.com/communique26032023",
                            forceWebView: true)
                ),
                      ),
                    )),
                Flexible(
                    flex: 2,
                    child:
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Container(
                        padding: const EdgeInsets.all(10.0),
                        decoration: BoxDecoration(
                            color: Color.fromRGBO(238, 37, 54, 50),//Color.fromRGBO(41, 155, 237, 50),
                            borderRadius: BorderRadius.all(Radius.circular(10))
                        ),
                        child: InkWell(
                            hoverColor: Colors.transparent,
                            child:
                            Text("LOVE\nSINGAPORE",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontFamily: 'JosefinSans',
                                    fontWeight: FontWeight.w100
                                )
                            ),
                            /*
                            DefaultTextStyle(
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontFamily: 'Abril-Fatface',
                                fontWeight: FontWeight.w100
                              ),
                              child: AnimatedTextKit(
                                animatedTexts: [
                                  RotateAnimatedText('LOVE'),
                                  RotateAnimatedText('SINGAPORE'),
                                  RotateAnimatedText('LOVE\nSINGAPORE'),
                                ],
                                totalRepeatCount: 1
                              )
                            ),
                            */
                            onTap: () => launch(
                                "http://lovesingapore.org.sg/",
                                forceWebView: true)
                        ),
                      ),
                    ))
              ]),
              /*
              Stack(
                children: [
                  Center(
                    child: Image(
                      image: AssetImage("assets/images/letter.png"),
                      width: size.width*0.1,
                      fit: BoxFit.cover,
                      alignment: Alignment.center,
                    ),
                  ),
                  Center(
                    child: InkWell(
                        hoverColor: Colors.transparent,
                        child: Text("church premise appeal letter",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Color.fromRGBO(237, 41, 57, 50),
                                fontSize: 20,
                                fontFamily: 'Abril-Fatface',
                                fontWeight: FontWeight.w400)),
                        onTap: () => launch(
                            "https://tinyurl.com/churchpremiseappealletter",
                            forceWebView: true)
                    ),
                  ),
                ],
              )
              */
              /*
              Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Flexible(
                      flex: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: InkWell(
                            hoverColor: Colors.transparent,
                            child: Column(children: [
                              Text("40.day2022\nPrayer Guide",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: Colors.pink,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w300)),
                              Text(
                                  "Available online one day at a time from 0001hr",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold))
                            ]),
                            onTap: () => launch(
                                "https://www.lovesingapore.org.sg/40day/2022",
                                forceWebView: true)),
                      ),
                    ),
                    Flexible(flex: 1, child: SizedBox.shrink(),),
                    Flexible(
                      flex: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: InkWell(
                            hoverColor: Colors.transparent,
                            child: Column(
                              children: [
                                Text("40天2022\n祷告指引",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: Colors.pink,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w300)),
                                Padding(
                                  padding: const EdgeInsets.all(5.0),
                                  child: Text("祷告指引将会上载网站每天可以0001时起上网查阅",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold)),
                                )
                              ],
                            ),
                            onTap: () => launch(
                                "https://www.lovesingapore.org.sg/40day/mandarin/2022",
                                forceWebView: true)),
                      ),
                    )
                  ])
              */
              /*
              GestureDetector(
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => FriendPage()));
                  },
                  child:
                BubbleSpecialThree(
                    isSender: false,
                    text: "Friendship Month",
                    tail: true,
                    textStyle: TextStyle(
                        fontFamily: 'JosefinSans',
                        fontSize: 20,
                        fontWeight: FontWeight.w300,
                        color: Colors.pink
                    ))
                  )*/
            ]),
          ],
        ),
      ),
    );
  }
}
