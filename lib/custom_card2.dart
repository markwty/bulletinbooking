import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CustomCard2 extends StatefulWidget {
  final String id, question;
  final List<String> options;
  final Color color;
  final bool extended, multiple, useDate;
  List<bool> answers = [];
  String answer;

  CustomCard2(this.id, this.question,
      {this.color, this.options, this.extended, this.multiple, this.useDate});

  @override
  _CustomCardState createState() => _CustomCardState();
}

class _CustomCardState extends State<CustomCard2> {
  final _rv = ValueNotifier<int>(1);

  @override
  void initState() {
    super.initState();
    if (widget.options != null) {
      if (widget.multiple == null) {
        widget.answer = widget.options[0];
      } else {
        for (int i = 0; i < widget.options.length; i++) {
          widget.answers.add(false);
        }
        widget.answer = widget.answers.join(",");
      }
    }
  }

  @override
  void dispose() {
    _rv.dispose();
    super.dispose();
  }

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
            color: Colors.white,
            child: Padding(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      RichText(
                          text: TextSpan(children: [
                        TextSpan(
                            text: widget.question,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                color: (widget.color == null)
                                    ? Colors.black
                                    : widget.color))
                      ])),
                      (widget.options == null)
                          ? (widget.extended == null || !widget.extended)
                              ? (widget.useDate != null && widget.useDate)?
                                  DateTimeField(
                                    format: DateFormat("dd-MMM-yy hh:mm aa"),
                                    maxLines: null,
                                    keyboardType: TextInputType.multiline,
                                    initialValue: (widget.answer == null)? DateTime(2022, 6, 1, 12, 0):
                                      DateFormat("dd-MMM-yy hh:mm aa").parse(widget.answer),
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontFamily: "OpenSans",
                                        color: Colors.pinkAccent),
                                    autovalidateMode: AutovalidateMode.onUserInteraction,
                                    onShowPicker: (context, currentValue) async {
                                      final date = await showDatePicker(
                                          context: context,
                                          firstDate: DateTime(1900),
                                          initialDate: currentValue ?? DateTime.now(),
                                          lastDate: DateTime(2100));
                                      if (date != null) {
                                        final time = await showTimePicker(
                                          context: context,
                                          initialTime:
                                          TimeOfDay.fromDateTime(currentValue ?? DateTime.now()),
                                        );
                                        return DateTimeField.combine(date, time);
                                      } else {
                                        return currentValue;
                                      }
                                    },
                                    onChanged: (value) {
                                      widget.answer = DateFormat("dd-MMM-yy hh:mm aa").format(value);
                                    }
                                  )
                                : TextFormField(
                                    maxLines: null,
                                    keyboardType: TextInputType.multiline,
                                    textAlignVertical: TextAlignVertical.center,
                                    initialValue: widget.answer,
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontFamily: "OpenSans",
                                        color: Colors.pinkAccent),
                                    autocorrect: false,
                                    autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                                    onChanged: (value) {
                                      widget.answer = value;
                                    })
                              : SizedBox(
                                  height: 40,
                                  child: ListTile(
                                      leading: Text("Answer: ",
                                          style: TextStyle(
                                              fontSize: 18,
                                              fontFamily: "OpenSans",
                                              color: (widget.color == null)
                                                  ? Colors.black
                                                  : widget.color)),
                                      title: TextFormField(
                                          maxLines: 1,
                                          textAlignVertical:
                                              TextAlignVertical.center,
                                          initialValue: widget.answer,
                                          style: TextStyle(
                                              fontSize: 18,
                                              fontFamily: "OpenSans",
                                              color: Colors.pinkAccent),
                                          autocorrect: false,
                                          autovalidateMode: AutovalidateMode
                                              .onUserInteraction,
                                          onChanged: (value) {
                                            widget.answer = value;
                                          })),
                                )
                          : (widget.multiple == null || !widget.multiple)
                              ? ValueListenableBuilder(
                                  valueListenable: _rv,
                                  builder: (_, value, __) => ListView.builder(
                                      shrinkWrap: true,
                                      itemCount: widget.options.length,
                                      itemBuilder: (cc, ii) {
                                        return Row(children: <Widget>[
                                          Radio(
                                              value: ii,
                                              groupValue: value as int,
                                              onChanged: (int value) {
                                                _rv.value = value;
                                                widget.answer =
                                                    widget.options[value];
                                              },
                                              hoverColor: Color.fromRGBO(
                                                  150, 160, 150, 0.5)),
                                          Expanded(
                                            child: Text(
                                              widget.options[ii],
                                              style: TextStyle(
                                                  fontSize: 16.0,
                                                  color: Colors.black),
                                            ),
                                          )
                                        ]);
                                      }))
                              : ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: widget.options.length,
                                  itemBuilder: (cc, ii) {
                                    return Card(
                                      child: ListTile(
                                        title: Text(widget.options[ii]),
                                        leading: Checkbox(
                                            value: widget.answers[ii],
                                            onChanged: (bool value) {
                                              widget.answers[ii] = value;
                                              widget.answer =
                                                  widget.answers.join(",");
                                              setState(() {
                                                widget.answers[ii] = value;
                                              });
                                            }),
                                      ),
                                    );
                                  })
                    ]))));
  }
}
