import 'dart:ui';
//import 'package:FS/calendar_page2.dart';
import 'package:flutter/material.dart';
//import 'package:rive_splash_screen/rive_splash_screen.dart';
import 'box_swipe.dart';

void main() {
  runApp(MyApp());
}

class MyCustomScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
      };
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Shalom FS',
        theme: ThemeData(
          primarySwatch: Colors.red,
          accentColor: Colors.green[100],
          brightness: Brightness.light,
          primaryColor: Colors.amber[500],
          canvasColor: Color.fromRGBO(211, 221, 220, 1),
          unselectedWidgetColor: Colors.blueGrey,
          //fontFamily: 'PTSans'
        ),
        home:
        /*
        SplashScreen.navigate(
          name: 'assets/animations/splash.riv',
          next: (_) => BoxSwipe(),
          until: () => Future.delayed(Duration(milliseconds: 200)),
          loopAnimation: 'Animation 1'
        ),
         */
        BoxSwipe(),
        debugShowCheckedModeBanner: false,
        scrollBehavior: MyCustomScrollBehavior().copyWith(scrollbars: false));
  }
}