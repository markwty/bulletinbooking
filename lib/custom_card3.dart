import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class CustomCard3 extends StatelessWidget {
  final String title;
  final String link;
  final Color color;

  CustomCard3(this.title, {this.link, this.color});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
          width: MediaQuery.of(context).size.width * 0.8,
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
                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        GestureDetector(
                          onTap: ()=> launch(link, forceWebView: true),
                          child: Text(title,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16, color: (color == null)? Colors.black: Colors.red)),
                        ),
                      ])))),
    );
  }
}
