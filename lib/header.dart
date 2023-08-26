import 'package:flutter/material.dart';
import 'custom_card3.dart';

/*
List<Widget> generateWidgets(Map<String, String> info){
  List<Widget> widgets = [];
  info.forEach((i, value) {
    widgets.add(CustomCard(i, link: value, color: Colors.red));
  });
  return widgets;
)
 */

List<Widget> generateWidgets(Map<String, String> info){
  List<Widget> widgets = [];
  info.forEach((i, value) {
    print("${i.trim()} eei");
    if(i.trim() != "") {
      widgets.add(CustomCard3(i, link: value, color: Colors.red));
    }
  });
  return widgets;
}

Widget wrap(List<Widget> widgets) {
  return ListView(
      padding: const EdgeInsets.all(20.0),
      children: widgets);
  /*
  return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
          children: widgets)
    );
   */
}