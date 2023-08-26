import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
//import 'package:zflutter/zflutter.dart' hide Axis;
import 'animated_object_shape.dart';
import 'bulletin_page.dart';
import 'calendar_page2.dart';
import 'custom_vertical_tabs.dart';
import 'form_page.dart';
//import 'icon_zshape.dart';
import 'my_home_page.dart';
import 'runnable_task.dart';
import 'website.dart';

class BoxSwipe extends StatefulWidget {
  BoxSwipe({Key key}) : super(key: key);

  @override
  _BoxSwipeState createState() => _BoxSwipeState();
}

class _BoxSwipeState extends State<BoxSwipe>
    with SingleTickerProviderStateMixin {
  final PageController _horiPageController = PageController(initialPage: 1);
  double currentPageValue = 1.0;
  final double xOffset = 50,
      logoScale = 0.4,
      offset = 0.05,
      depth = 10,
      zOffset = -30,
      headerFraction = 0.1;
  Future<Map<String, String>> info;

  final ValueNotifier<double> _scrollVal = new ValueNotifier<double>(1);
  final ValueNotifier<double> _vertVal = new ValueNotifier<double>(0);
  List<Widget> _pages, _constPages, constWidgets;
  Widget _reverseVerticalTabs;
  AnimationController _animController;
  Animation _animation;
  final PageController _vertPageController = new PageController();

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
  void initState() {
    info = _initExtraInfo();
    super.initState();
    _horiPageController.addListener(() {
      setState(() {
        currentPageValue = _horiPageController.page;
      });
    });
    _animController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = TweenSequence(<TweenSequenceItem<double>>[
      TweenSequenceItem<double>(
        tween: Tween<double>(begin: 1.0, end: 0.0)
            .chain(CurveTween(curve: Curves.elasticOut)),
        weight: 1.0,
      )
    ]).animate(_animController);
    _animController.forward(from: 0);
  }

  @override
  void dispose() {
    _horiPageController.dispose();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_pages == null) {
      /*
      _constPages = [
        MyHomePage(info, headerFraction, pageController: _horiPageController),
        CalendarPage(vertVal: _vertVal, vertController: _vertPageController)
      ];
      _reverseVerticalTabs = CustomVerticalTabs(
          initialIndex: 1,
          tabsWidth: 0,
          contentScrollAxis: Axis.vertical,
          tabs: <Tab>[Tab(text: ""), Tab(text: "")],
          contents: _constPages,
          listener: (double offset) {
            _vertVal.value = offset;
          },
          pageController: _vertPageController);
      _pages = [
        BulletinPage(info, headerFraction, offset: xOffset),
        CustomVerticalTabs(
            tabsWidth: 0,
            contentScrollAxis: Axis.vertical,
            tabs: <Tab>[Tab(text: ""), Tab(text: "")],
            contents: _constPages,
            //MyHomePage(scrollVal: _scrollVal)
            listener: (double offset) {
              _vertVal.value = offset;
            },
            pageController: _vertPageController),
        FormPage(info, headerFraction, offset: xOffset)
      ];
       */
      _pages = [
        BulletinPage(info, headerFraction, offset: xOffset),
        MyHomePage(info, headerFraction, pageController: _horiPageController),
        CalendarPage2(info, headerFraction, offset: xOffset)
      ];
      constWidgets = [
        AnimatedObjectShapeStatic(
            "assets/images/icon.png", _animation, offset, logoScale),
        /*
        AnimatedBuilder(
            animation: _animation,
            child: IconZShape(logoScale + offset, depth,
                color: Color.fromRGBO(190, 30, 45, 1)),
            builder: (context, child) => ZPositioned(
                rotate: ZVector.only(x: _animation.value), child: child)
                )
         */
      ];
    }
    return Stack(children: [
      PageView.builder(
        physics: PageScrollPhysics(),
        controller: _horiPageController,
        itemCount: _pages.length,
        itemBuilder: (context, position) {
          if (position == 0) {
            return Transform.translate(
              offset: Offset(xOffset * (currentPageValue - position - 1), 0),
              child: Transform(
                alignment: Alignment.centerRight,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.001)
                  ..rotateY(pi / 2 * (currentPageValue - position)),
                child: _pages[position],
              ),
            );
          } else if (position == 2) {
            return Transform.translate(
              offset: Offset(-xOffset * (position - currentPageValue - 1), 0),
              child: Transform(
                alignment: Alignment.centerLeft,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.001)
                  ..rotateY(pi / 2 * (currentPageValue - position)),
                child: _pages[position],
              ),
            );
          } else if (position == 1) {
            _scrollVal.value = currentPageValue;
            if (currentPageValue.floor() == 0) {
              return Transform.translate(
                offset: Offset(xOffset * (currentPageValue - position), 0),
                child: Transform(
                  alignment: Alignment.centerLeft,
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.001)
                    ..rotateY(pi / 2 * (currentPageValue - position)),
                  child: (_vertVal.value == 1)
                      ? _reverseVerticalTabs
                      : _pages[position],
                ),
              );
            } else if (currentPageValue.floor() == 1) {
              return Transform.translate(
                offset: Offset(xOffset * (currentPageValue - position), 0),
                child: Transform(
                  alignment: Alignment.centerRight,
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.001)
                    ..rotateY(pi / 2 * (currentPageValue - position)),
                  child: (_vertVal.value == 1)
                      ? _reverseVerticalTabs
                      : _pages[position],
                ),
              );
            } else {
              return _pages[position];
            }
          } else {
            return _pages[position];
          }
        },
      ),
      Center(
        child: Transform.translate(
            offset: Offset(
                -(MediaQuery.of(context).size.width / 2 - offset) *
                    (_scrollVal.value - 1),
                MediaQuery.of(context).size.height * (-0.23 + headerFraction) +
                    75), //* 0.04 + 75
            child: AnimatedObjectShape(
                constWidgets[0],
                null,
                _scrollVal,
                _vertVal,
                _horiPageController,
                _animController,
                logoScale,
                offset,
                depth,
                zOffset))
      )
      /*
        child: SizedBox(
            width: MediaQuery.of(context).size.height * logoScale,
            height: MediaQuery.of(context).size.height * logoScale,
            child: AnimatedObject(_scrollVal, "assets/images/guitarSequence", 120))
      */
    ]);
  }
}
