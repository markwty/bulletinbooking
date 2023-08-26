import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AdvisoryBanner extends StatelessWidget {
  final String title;
  final Widget widget;
  final Color color;

  AdvisoryBanner(this.title, this.widget, {this.color, Key key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      child: Container(
          margin: EdgeInsets.symmetric(vertical: 10),
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
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => AdvisoryPage(widget)));
                          },
                          child: Text(title,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: (color == null)
                                      ? Colors.black
                                      : Colors.red)),
                        ),
                      ])))),
    );
  }
}

class AdvisorySingle extends StatelessWidget {
  final String title;
  final String link;
  final Color color;

  AdvisorySingle(this.title, this.link, {this.color, Key key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      child: Container(
          margin: EdgeInsets.symmetric(vertical: 10),
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
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: (color == null)
                                      ? Colors.black
                                      : Colors.red)),
                        ),
                      ])))),
    );
  }
}

class AdvisoryPage extends StatelessWidget {
  final Widget widget;

  AdvisoryPage(this.widget, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: widget
    ));
  }
}
