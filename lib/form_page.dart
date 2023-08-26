import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:mailto/mailto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'advisory_page.dart';
import 'header.dart';
import 'parallax_shader_mask.dart';
import 'swapped_chip.dart';

class FormPage extends StatefulWidget {
  final double offset, headerFraction;
  final Future<Map<String, String>> info;

  FormPage(this.info, this.headerFraction, {Key key, this.offset = 0})
      : super(key: key);

  @override
  FormState createState() {
    return FormState();
  }
}

class FormState extends State<FormPage> with AutomaticKeepAliveClientMixin {
  int limit = 50;
  int oriSize, size;
  static const List<String> rv1_choices = ["Yes", "No", "Exempted"];
  final _rv1 = ValueNotifier<int>(1);
  String name, reason, formattedDate = "";

  final _showFrontSide = ValueNotifier<bool>(true);
  final _validate = ValueNotifier<bool>(false);
  final _validate2 = ValueNotifier<bool>(false);
  final _sizeUpdated = ValueNotifier<bool>(false);
  final _scrollOffset = ValueNotifier<double>(0.0);
  bool _mounted = false;

  SharedPreferences prefs;
  CollectionReference bookings;
  Widget swappedChip;

  @override
  bool get wantKeepAlive => true;

  String getUpcomingSunday({String format = 'd MMMM yyyy'}) {
    DateTime now = new DateTime.now();
    //DateTime now = DateTime.parse("2022-01-02 09:59:00Z");
    int weekDay = now.weekday;
    DateTime next;
    if (weekDay == 7 && ((now.hour == 11 && now.minute >= 0) || now.hour > 11)) {
      next = now.add(const Duration(days: 7));
    } else {
      next = now.add(Duration(days: 7 - weekDay));
    }
    DateFormat formatter = new DateFormat(format);
    return formatter.format(next);
  }

  void showMessage(String message, [Color color = Colors.black]) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(message, style: TextStyle(color: color)),
        backgroundColor: Color.fromRGBO(230, 217, 200, 1),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(30.0)));
  }

  void submitForm() {
    bookings.doc(formattedDate).get().then((val) {
      size = val.data()["size"];
      if (size >= limit) {
        showMessage("Limit exceeded please call Rachel Tan or Poh Huai Ching");
      } else {
        bookings
            .doc(formattedDate)
            .update({"size": FieldValue.increment(1)}).then((_) {
          bookings.doc(formattedDate).collection("list").add({
            "time": Timestamp.now(),
            "name": name,
            "choice": rv1_choices[_rv1.value - 1],
            "reason": (_rv1.value == 2) ? reason : ""
          }).then((value) => refresh());
        });
        showMessage("You have successfully registered");
      }
    }).catchError((onError) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(onError)));
    });
  }

  Widget form() {
    return Column(
      children: <Widget>[
        SizedBox(height: MediaQuery.of(context).size.height * 0.1),
        SizedBox(
          height: MediaQuery.of(context).size.height * widget.headerFraction,
          child: FutureBuilder(
              builder: (ctx, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.hasData) {
                    final Map<String, String> data =
                        snapshot.data as Map<String, String>;
                    return AdvisoryBanner(
                        "Latest church update", wrap(generateWidgets(data)),
                        color: Colors.red);
                  }
                }
                return SizedBox.shrink();
              },
              future: widget.info),
        ),
        /*
        AnimatedBuilder(
            animation: _animation,
            child: SizedBox(
                width: MediaQuery.of(context).size.width * 5 / 6,
                height: MediaQuery.of(context).size.width * 5 / 6 * 10 / 16,
                child:
                    Image.asset("assets/images/form.jpg", fit: BoxFit.cover)),
            builder: (context, child) {
              return ClipRect(
                  child: Container(
                      child: Align(
                          alignment: Alignment.center,
                          widthFactor: _animation.value + 0.6,
                          heightFactor: _animation.value + 0.6,
                          child: child)));
            }),
         */
        //FitShaderMask("assets/images/form.jpg", "assets/images/form.jpg", Color.fromRGBO(252, 244, 228, 1)),
        ParallaxShaderMask(
            MediaQuery.of(context).size.width - widget.offset,
            "assets/images/form.jpg",
            Color.fromRGBO(252, 244, 228, 1),
            _scrollOffset),
        Wrapper(Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[HeaderText(formattedDate)],
        )),
        Wrapper(Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              RichText(
                  text: TextSpan(
                      text: "Name",
                      style: TextStyle(fontSize: 18.0, color: Colors.black),
                      children: [
                    TextSpan(
                        text: ' *',
                        style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                            fontSize: 18))
                  ])),
              ValueListenableBuilder(
                  valueListenable: _validate,
                  builder: (_, value, __) => TextFormField(
                        initialValue: name,
                        style: TextStyle(color: Colors.black),
                        decoration: InputDecoration(
                            enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.black))),
                        autocorrect: false,
                        autovalidateMode: value
                            ? AutovalidateMode.always
                            : AutovalidateMode.onUserInteraction,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter name';
                          }
                          //validate.value = false;
                          return null;
                        },
                        onChanged: (value) {
                          name = value;
                        },
                      ))
            ])),
        Wrapper(Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              RichText(
                  text: TextSpan(
                      text:
                          "Have you received full Covid-19 Vaccination (two doses)?",
                      style: TextStyle(fontSize: 18.0, color: Colors.black),
                      children: [
                    TextSpan(
                        text: ' *\n',
                        style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                            fontSize: 18))
                  ])),
              ValueListenableBuilder(
                valueListenable: _rv1,
                builder: (_, value, __) => Column(children: <Widget>[
                  Row(children: <Widget>[
                    Radio(
                        value: 1,
                        groupValue: value as int,
                        onChanged: (int value) {
                          _rv1.value = value;
                        },
                        hoverColor: Color.fromRGBO(150, 160, 150, 0.5)),
                    Text(
                      rv1_choices[0],
                      style: TextStyle(fontSize: 16.0, color: Colors.black),
                    )
                  ]),
                  Row(children: <Widget>[
                    Radio(
                        value: 2,
                        groupValue: value as int,
                        onChanged: (int value) {
                          _rv1.value = value;
                        },
                        hoverColor: Color.fromRGBO(150, 160, 150, 0.5)),
                    Text(
                      rv1_choices[1],
                      style: TextStyle(fontSize: 16.0, color: Colors.black),
                    )
                  ]),
                  Row(children: <Widget>[
                    Radio(
                        value: 3,
                        groupValue: value as int,
                        onChanged: (int value) {
                          _rv1.value = value;
                        },
                        hoverColor: Color.fromRGBO(150, 160, 150, 0.5)),
                    Text(
                      rv1_choices[2],
                      style: TextStyle(fontSize: 16.0, color: Colors.black),
                    )
                  ]),
                ]),
              )
            ])),
        ValueListenableBuilder(
            valueListenable: _rv1,
            builder: (_, value, __) => Wrapper(Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text("If No, please state reason\n",
                          style: TextStyle(
                              fontSize: 18.0,
                              color:
                                  (value != 2) ? Colors.grey : Colors.black)),
                      ValueListenableBuilder(
                          valueListenable: _validate2,
                          builder: (_, value2, __) => TextFormField(
                                readOnly: (value != 2),
                                enabled: (value == 2),
                                initialValue: reason,
                                style: TextStyle(
                                    color: (value != 2)
                                        ? Colors.grey
                                        : Colors.black),
                                decoration: InputDecoration(
                                    enabledBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                            color: (value != 2)
                                                ? Colors.grey
                                                : Colors.black))),
                                autocorrect: false,
                                autovalidateMode: value2
                                    ? AutovalidateMode.always
                                    : AutovalidateMode.onUserInteraction,
                                validator: (value3) {
                                  if (value as int == 2 &&
                                      (value3 == null || value3.isEmpty)) {
                                    return "Please fill in a reason";
                                  }
                                  //validate2.value = false;
                                  return null;
                                },
                                onChanged: (value) {
                                  reason = value;
                                },
                              ))
                    ]))),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: ElevatedButton(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Color(0xFF60230b)),
              padding: MaterialStateProperty.all(EdgeInsets.all(20)),
            ),
            onPressed: () async {
              size = (await bookings.doc(formattedDate).get()).data()["size"];
              if (size >= limit) {
                showMessage(
                    "Limit exceeded please call Rachel Tan or Poh Huai Ching",
                    Colors.red);
                return;
              } else if (name.isEmpty) {
                _validate.value = true;
                _validate2.value = true;
                showMessage("Please fill in your name", Colors.red);
                return;
              } else if (_rv1.value == 2 && reason.isEmpty) {
                _validate2.value = true;
                showMessage("Please give a reason for not taking vaccination",
                    Colors.red);
                return;
              }
              DateFormat formatter = new DateFormat('d MMMM yyyy');
              DateFormat formatter2 = new DateFormat('d MMMM yyyy HH:mm:ss');
              DateTime next = formatter.parse(formattedDate);
              next = new DateTime(next.year, next.month, next.day, 10, 0, 0);

              String formattedDatePrefs =
                  prefs.getString("form/formattedDate") ?? "";
              String namesPrefs = prefs.getString("form/names") ?? "";
              List<String> names = namesPrefs.split("::");
              List<String> formattedDates = formattedDatePrefs.split("::");

              int idx = -1;
              for (int i = 0; i < names.length; i++) {
                String nm = names[i];
                if (nm.isNotEmpty && (nm.contains(name) || name.contains(nm))) {
                  idx = i;
                  break;
                }
              }
              if (idx == -1) {
                String now = formatter2.format(DateTime.now());
                formattedDates.add(now);
                submitForm();
                prefs.setString(
                    "form/formattedDate", formattedDates.join("::"));
                names.add(name);
                prefs.setString("form/names", names.join("::"));
              } else if (formattedDates.length > idx) {
                DateTime date = formatter2.parse(formattedDates[idx]);
                if (date.isBefore(next) &&
                    date.isAfter(next.subtract(const Duration(days: 7)))) {
                  showDialog<void>(
                    context: context,
                    barrierDismissible: false,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Take note'),
                        content: SingleChildScrollView(
                          child: ListBody(
                            children: <Widget>[
                              Text("It is detected that you have submitted a form \n" +
                                  "for ${names[idx]} on ${formattedDates[idx]} on this platform.\n" +
                                  "Continue to submit?"),
                              Text('If unsure, you can submit again.')
                            ],
                          ),
                        ),
                        actions: <Widget>[
                          TextButton(
                            child: const Text('Yes'),
                            onPressed: () {
                              Navigator.of(context).pop();
                              formattedDates[idx] =
                                  formatter2.format(DateTime.now());
                              submitForm();
                              prefs.setString("form/formattedDate",
                                  formattedDates.join("::"));
                              names[idx] = name;
                              prefs.setString("form/names", names.join("::"));
                            },
                          ),
                          TextButton(
                            child: const Text('No'),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      );
                    },
                  );
                } else {
                  formattedDates[idx] = formatter2.format(DateTime.now());
                  submitForm();
                  prefs.setString(
                      "form/formattedDate", formattedDates.join("::"));
                  names[idx] = name;
                  prefs.setString("form/names", names.join("::"));
                }
              } else {
                String now = formatter2.format(DateTime.now());
                submitForm();
                prefs.setString("form/formattedDate", now);
                prefs.setString("form/names", name);
              }
              prefs.setString("form/1", name);
              prefs.setInt("form/2", _rv1.value);
              prefs.setString("form/3", (_rv1.value == 2) ? reason : "");
            },
            child: Text('Submit', style: TextStyle(color: Colors.white)),
          ),
        ),
        const SizedBox(height: 50)
      ],
    );
  }

  Future<void> refresh() async {
    _sizeUpdated.value = !_sizeUpdated.value;
    while (_showFrontSide.value) {
      await Future.delayed(const Duration(seconds: 1));
    }
  }

  /*
  Future<ui.Image> load(String asset) async {
    final ByteData assetImageByteData = await rootBundle.load(asset);
    //im.Image baseSizeImage = im.decodeNamedImage(assetImageByteData.buffer.asUint8List(), asset);
    ui.Codec codec =
    await ui.instantiateImageCodec(assetImageByteData.buffer.asUint8List());
    //print(codec.toString());
    ui.FrameInfo frameInfo = await codec.getNextFrame();
    return frameInfo.image;
  }
   */

  @override
  void initState() {
    super.initState();
    Firebase.initializeApp().then((firebaseApp) {
      setState(() {
        bookings = FirebaseFirestore.instance.collection('bookings');
        formattedDate = getUpcomingSunday();
        bookings.doc("info").get().then((doc) {
          if (!doc.exists) {
            bookings.doc("info").set({"limit": 50});
          } else {
            bookings.doc("info").get().then((doc) {
              limit = doc.data()["limit"];
            });
          }
        });
        bookings.doc(formattedDate).get().then((doc) {
          if (!doc.exists) {
            bookings.doc(formattedDate).set({"size": 0});
          }
        });
      });
    });
    //_animController.forward(from: 0.0);
  }

  @override
  void dispose() {
    _rv1.dispose();
    _showFrontSide.dispose();
    _validate.dispose();
    _validate2.dispose();
    _sizeUpdated.dispose();
    _mounted = true;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
        backgroundColor: Color.fromRGBO(250, 243, 225, 1),
        body: Row(children: [
          SizedBox(
              width: MediaQuery.of(context).size.width - widget.offset,
              child: RefreshIndicator(
                  onRefresh: refresh,
                  color: Colors.white,
                  child: Stack(children: <Widget>[
                    Center(
                      child:
                          /*
                            NestedScrollView(
                              headerSliverBuilder:
                                  (BuildContext context, bool innerBoxIsScrolled) {
                                return <Widget>[
                                  SliverAppBar(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    expandedHeight: 400.0,
                                    floating: false,
                                    pinned: true,
                                    flexibleSpace: FlexibleSpaceBar(
                                      background: Container(
                                          height: 400,
                                          decoration: BoxDecoration(
                                              shape: BoxShape.rectangle,
                                              image: DecorationImage(
                                                  fit: BoxFit.cover,
                                                  image: AssetImage(
                                                      'assets/images/form.jpeg')))),
                                    ),
                                  ),
                                ];
                              },
                              body:
                             */
                          NotificationListener<ScrollNotification>(
                        onNotification: (notification) {
                          double offset = notification.metrics.pixels;
                          if (offset <= 40 / 0.3) {
                            _scrollOffset.value = offset;
                          }
                          return false;
                        },
                        child: SingleChildScrollView(
                            child: (prefs == null)
                                ? FutureBuilder(
                                    builder: (ctx, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.done) {
                                        if (snapshot.hasData) {
                                          prefs = snapshot.data
                                              as SharedPreferences;
                                          name =
                                              prefs.getString("form/1") ?? "";
                                          _rv1.value =
                                              prefs.getInt("form/2") ?? 3;
                                          reason =
                                              prefs.getString("form/3") ?? "";
                                          return form();
                                        }
                                      }
                                      return SizedBox.shrink();
                                    },
                                    future: SharedPreferences.getInstance())
                                : form()),
                      ),
                    ),
                    ValueListenableBuilder(
                        valueListenable: _sizeUpdated,
                        builder: (_, value, __) => (bookings != null)
                            ? FutureBuilder<DocumentSnapshot>(
                                future: bookings.doc(formattedDate).get(),
                                builder: (context,
                                    AsyncSnapshot<DocumentSnapshot> snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.done) {
                                    if (snapshot.hasData) {
                                      oriSize = size;
                                      if (!snapshot.data.exists) {
                                        size = 0;
                                      } else {
                                        Map<String, dynamic> data =
                                            snapshot.data.data();
                                        size = data["size"];
                                      }
                                      if (!_mounted) {
                                        _showFrontSide.value = true;
                                      }
                                      Future.delayed(const Duration(seconds: 1),
                                          () {
                                        if (!_mounted) {
                                          _showFrontSide.value = false;
                                        }
                                      });
                                      swappedChip = SwappedChip(
                                          size, oriSize, _showFrontSide);
                                      return swappedChip;
                                    } else if (snapshot.hasError) {
                                      print(snapshot.error);
                                    }
                                  }
                                  return (oriSize == null)
                                      ? Positioned(
                                          right: 15,
                                          top: 15,
                                          child: CircularProgressIndicator())
                                      : swappedChip;
                                })
                            : (swappedChip != null)
                                ? swappedChip //swappedChip
                                : const SizedBox.shrink())
                  ]))),
          SizedBox(width: widget.offset)
        ]));
  }
}

class HeaderText extends StatelessWidget {
  final String formattedDate;

  HeaderText(this.formattedDate);

  @override
  Widget build(BuildContext context) {
    final mailtoLink =
        Mailto(to: ['faithsanctuaryoffice@gmail.com'], subject: 'FS booking');
    return Column(children: <Widget>[
      Text("Sunday Worship, $formattedDate",
          style: TextStyle(color: Colors.black, fontSize: 30)),
      Center(
        child: RichText(
            text: TextSpan(
          children: [
            TextSpan(text: """
                            
9.30am - 11.00am

This form will update to the following week past 11.00am every Sunday. 

Please use ONE form per person (Child or Adult).

If you are a duty personnel on $formattedDate, you do not need to fill this form.

""", style: TextStyle(color: Colors.black)),
            const TextSpan(
                text: 'Please contact ', style: TextStyle(color: Colors.black)),
            TextSpan(
                text: '',
                style: TextStyle(color: Colors.blue),
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    launch('$mailtoLink');
                  }),
            const TextSpan(
              text: ' if you need assistance with your booking.',
              style: TextStyle(color: Colors.black),
            )
          ],
        )),
      )
    ]);
  }
}

class Wrapper extends StatelessWidget {
  final Widget widget;

  Wrapper(this.widget);

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: const EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.0),
          shape: BoxShape.rectangle,
        ),
        padding: const EdgeInsets.all(10.0),
        child: widget);
  }
}
