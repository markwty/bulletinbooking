import 'dart:convert';

import 'custom_card2.dart';
import 'runnable_task.dart';
import 'website.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FriendPage extends StatefulWidget {
  FriendPage({Key key})
      : super(key: key);

  @override
  _FriendPageState createState() => _FriendPageState();
}

class _FriendPageState extends State<FriendPage>
    with AutomaticKeepAliveClientMixin {
  List<Size> sizes = [];
  double pageHeight = 0, stretch = 0, fontSize = 0;
  Map<String, String> mp = new Map();
  Future<List<Widget>> feedbackWidgets;
  List<Widget> fbWidgets = [];
  CollectionReference feedback = null;

  @override
  bool get wantKeepAlive => true;

  Future<List<Widget>> _init() async {
    RunnableTask runnableTask = RunnableTask(Website.url2 + '/questions.txt');
    await runnableTask.run();
    String result = runnableTask.result;
    List<CustomCard2> cards = [];
    if (result != "") {
      LineSplitter ls = new LineSplitter();
      List<String> lines = ls.convert(result);
      List<String> ln = [];
      for (String line in lines) {
        line = line.replaceAll(";;", "\n");
        ln = line.split("::");
        if (ln[0].endsWith("m")) {
          ln[0] = ln[0].substring(0, ln[0].length - 1);
          if (ln.length == 2) {
            if (ln[1].toLowerCase().contains('date')){
              cards.add(CustomCard2(ln[0], ln[1], useDate: true, color: Colors.orange));
            } else {
              cards.add(CustomCard2(ln[0], ln[1], color: Colors.orange));
            }
          } else if (ln.length >= 2) {
            cards.add(CustomCard2(ln[0], ln[1],
                options: ln.sublist(2), multiple: true, color: Colors.orange));
          }
        } else {
          if (ln.length == 2) {
            if (ln[1].toLowerCase().contains('date')){
              cards.add(CustomCard2(ln[0], ln[1], useDate: true, color: Colors.orange));
            } else {
              cards.add(CustomCard2(ln[0], ln[1], color: Colors.orange));
            }
          } else if (ln.length >= 2) {
            cards.add(CustomCard2(ln[0], ln[1],
                options: ln.sublist(2), color: Colors.orange));
          }
        }
      }
    }
    return cards;
  }

  void showMessage(String message, [Color color = Colors.black]) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(message, style: TextStyle(color: color)),
        backgroundColor: const Color.fromRGBO(230, 217, 200, 1),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(30.0)));
  }

  void submitForm() {
    if (fbWidgets.isEmpty) {
      return;
    }
    Map<String, dynamic> answers = {"time": Timestamp.now()};
    for (int i = 1; i <= fbWidgets.length; i++) {
      answers['answer' + i.toString()] = (fbWidgets[i-1] as CustomCard2).answer;
    }

    feedback.doc("list").collection("list").add(answers).catchError((onError) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(onError)));
    });
    showMessage("Thank you for your response!");
  }

  void getPosition(List<double> percentHorizontalOffsets,
      List<double> percentVerticalOffsets, Size deviceSize) {
    Size size = const Size(839, 1600);
    double widthFactor = deviceSize.width / size.width;
    double heightFactor = deviceSize.height / size.height;
    sizes.clear();
    if (heightFactor > widthFactor) {
      stretch = heightFactor;
      pageHeight = size.height * stretch;
      double offset = (heightFactor * size.width - deviceSize.width) / 2;
      for (var i = 0; i < percentHorizontalOffsets.length; i++) {
        sizes.add(Size(
            heightFactor * size.width * percentHorizontalOffsets[i] - offset,
            pageHeight * percentVerticalOffsets[i]));
      }
    } else {
      stretch = widthFactor;
      pageHeight = size.height * stretch;
      double offset = (widthFactor * size.height - pageHeight) / 2;
      for (var i = 0; i < percentHorizontalOffsets.length; i++) {
        sizes.add(Size(widthFactor * size.width * percentHorizontalOffsets[i],
                  pageHeight * percentVerticalOffsets[i] - offset));
      }
    }
    fontSize = 35 * stretch;
  }

  @override
  void initState() {
    super.initState();
    Firebase.initializeApp().then((firebaseApp) {
      feedback = FirebaseFirestore.instance.collection('answers');
    });
    feedbackWidgets = _init();
  }

  Future<void> refresh() async {
    setState(() {
      feedbackWidgets = _init();
    });
  }

  @override
  Widget build(BuildContext context) {
    getPosition([0.45], [0.35], MediaQuery.of(context).size);
    super.build(context);
    return Scaffold(
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: refresh,
            child: SingleChildScrollView(
              child: SizedBox(
                height: pageHeight,
                child: Stack(
                  children: [
                    /*
                    Image(
                        image: const AssetImage("assets/images/event_base.jpeg"),
                        width: MediaQuery.of(context).size.width,
                        height: pageHeight,
                        fit: BoxFit.cover,
                        alignment: Alignment.center),
                     */
                    Column(children: [
                      SizedBox(height: 50),
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: MediaQuery.of(context).size.width * 0.1),
                        child: FutureBuilder(
                            builder: (ctx, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.done) {
                                if (snapshot.hasData) {
                                  fbWidgets = snapshot.data as List<CustomCard2>;
                                  return Column(
                                    children: [
                                      Column(children: fbWidgets),
                                      ElevatedButton(
                                          style: ButtonStyle(
                                            backgroundColor:
                                            MaterialStateProperty.all(
                                                const Color.fromRGBO(
                                                    26, 16, 8, 0.7)),
                                            padding: MaterialStateProperty.all(
                                                const EdgeInsets.symmetric(
                                                    horizontal: 20, vertical: 10)),
                                          ),
                                          onPressed: () async {
                                            submitForm();
                                          },
                                          child: Text('SUBMIT RESPONSE',
                                              style: TextStyle(
                                                  fontSize: 20,
                                                  fontFamily: "OpenSans",
                                                  color: Colors.white)))
                                    ],
                                  );
                                }
                              }
                              return const SizedBox.shrink();
                            },
                            future: feedbackWidgets),
                      )
                    ])
                  ]
                )
              ))
          )
        ],
      ),
    );
  }
}
