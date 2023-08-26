import 'package:flutter/material.dart';
import 'hovered_web_anchor.dart';

class CustomCard extends StatelessWidget {
  final String title;
  final String link;
  final Color color;

  CustomCard(this.title, {this.link, this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.only(bottom: 15),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          boxShadow: [
            BoxShadow(
              color: Colors.black,
              spreadRadius: 1,
              offset: Offset(5, 5),
            ),
            BoxShadow(
              color: Colors.blueGrey,
              offset: Offset(5, 5),
            )
          ],
        ),
        child: Card(
            margin: EdgeInsets.only(top: 0),
            shape: RoundedRectangleBorder(
                side: BorderSide(color: Colors.black, width: 1.0),
                borderRadius: BorderRadius.circular(4.0)),
            child: Padding(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(title,
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 20, color: (color == null)? Colors.black: Colors.red)),
                      (link != null) ? HoveredWebAnchor(label: link, url: link) : SizedBox(height:0)
                    ]))));
  }
}
