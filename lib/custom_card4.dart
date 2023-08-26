import 'package:intl/intl.dart';

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:url_launcher/url_launcher.dart';

import 'calendar_utils.dart';
import 'website.dart';

class CustomCard4 extends StatelessWidget {
  static const double borderRadius = 15.0;
  final DateTime datetime;
  final DateTime end;
  final DateFormat formatter = DateFormat('EEE');
  final DateFormat formatter2 = DateFormat('MMM-dd');
  final List<Event> events;
  static Map<String, String> mapping;
  static Map<String, ImageProvider> downloaded = {};

  CustomCard4(this.datetime, this.events, {this.end});

  ImageProvider findImage(String text) {
    ImageProvider networkImage = null;
    for (String key in mapping.keys) {
      if (text.contains(key)) {
        if (downloaded.containsKey(mapping[key])) {
          networkImage = downloaded[mapping[key]];
        } else {
          networkImage = FadeInImage.memoryNetwork(
            placeholder: kTransparentImage,
            image: Website.url2 + '/' + mapping[key] + '.jpg',
            placeholderCacheWidth: 300,
            placeholderCacheHeight: 100,
          ).image;
          downloaded[mapping[key]] = networkImage;
        }
      }
    }
    return networkImage;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
        child: (end == null)
            ? Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 5.0),
                      child: SizedBox(
                          width: 50,
                          child: Column(children: [
                            Text(formatter.format(datetime),
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 18)),
                            Text(formatter2.format(datetime),
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 12)),
                          ])),
                    ),
                    Expanded(
                        child: ListView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            padding: const EdgeInsets.only(right: 5.0),
                            shrinkWrap: true,
                            itemCount: events.length,
                            itemBuilder: (context, index) {
                              String url = events[index].title.toString()
                                  .substring(events[index].title.toString().lastIndexOf("\n")+1);
                              ImageProvider imageProvider = findImage(
                                  events[index].title.toString().toLowerCase());
                              return Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(borderRadius),
                                  ),
                                  child: ClipRRect(
                                      borderRadius:
                                          BorderRadius.circular(borderRadius),
                                      child: /*Stack(
                                        children: [
                                          (imageProvider == null) ?
                                          Container(color:Colors.transparent):
                                          Image(image: imageProvider),
                                          ListTile(
                                              title: Padding(
                                                  padding:
                                                      const EdgeInsets.all(5),
                                                  child: Linkify(
                                                    onOpen: (link) async {
                                                      if (await canLaunch(
                                                          link.url)) {
                                                        await launch(link.url);
                                                      } else {
                                                        throw 'Could not launch $link';
                                                      }
                                                    },
                                                    text: utf8.decode(
                                                        events[index]
                                                            .title
                                                            .toString()
                                                            .codeUnits),
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.w600),
                                                    linkStyle: TextStyle(
                                                        color: Colors.red),
                                                  )))
                                        ],
                                      )*/
                                      Container(
                                        decoration: (imageProvider == null)
                                            ? null
                                            : BoxDecoration(
                                            image: DecorationImage(
                                                alignment: Alignment
                                                    .centerLeft,
                                                fit: BoxFit.fitHeight,
                                                colorFilter:
                                                new ColorFilter
                                                    .mode(
                                                    Colors
                                                        .black
                                                        .withOpacity(
                                                        0.5),
                                                    BlendMode
                                                        .dstATop),
                                                image: imageProvider)),
                                        child:
                                          ListTile(
                                            title: Padding(
                                                padding:
                                                const EdgeInsets.all(5),
                                                child: (!Uri.parse(url).isAbsolute)?
                                                  Linkify(
                                                    onOpen: (link) async {
                                                      if (await canLaunch(
                                                          link.url)) {
                                                        await launch(link.url);
                                                      } else {
                                                        throw 'Could not launch $link';
                                                      }
                                                    },
                                                    text: utf8.decode(
                                                        events[index]
                                                            .title
                                                            .toString()
                                                            .codeUnits),
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                        FontWeight.w600),
                                                    linkStyle: TextStyle(
                                                        color: Colors.red),
                                                  ):
                                                  GestureDetector(
                                                    onTap : () async {
                                                      if (await canLaunch(url)) {
                                                        await launch(url);
                                                      } else {
                                                        throw 'Could not launch $url';
                                                      }
                                                    },
                                                    child: Text(utf8.decode(
                                                        events[index]
                                                            .title
                                                            .toString().substring(0, events[index].title.toString().length-url.length-1)
                                                            .codeUnits),
                                                        textAlign: TextAlign.center,
                                                        style: TextStyle(
                                                            fontSize: 16,
                                                            fontWeight:
                                                            FontWeight.w600,
                                                            backgroundColor: Colors.yellow
                                                        ))
                                                  )
                                            ))
                                      )
                                  ));
                            }))
                  ])
            : IntrinsicHeight(
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 5.0),
                        child: SizedBox(
                            width: 50,
                            child: Column(children: [
                              Text(formatter.format(datetime),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 18)),
                              Text(formatter2.format(datetime),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 12)),
                              Text("—",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 18)),
                              Text(formatter.format(end),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 18)),
                              Text(formatter2.format(end),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 12))
                            ])),
                      ),
                      Expanded(
                        child: Builder(builder: (context) {
                          String url = events[0].title.toString()
                              .substring(events[0].title.toString().lastIndexOf("\n")+1);
                          ImageProvider imageProvider = findImage(
                              events[0].title.toString().toLowerCase());
                          return Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(borderRadius),
                            ),
                            child: ClipRRect(
                                borderRadius:
                                    BorderRadius.circular(borderRadius),
                                child: Container(
                                    decoration: (imageProvider == null)
                                        ? null
                                        : BoxDecoration(
                                            image: DecorationImage(
                                                alignment: Alignment.centerLeft,
                                                fit: BoxFit.fitHeight,
                                                colorFilter:
                                                    new ColorFilter.mode(
                                                        Colors.black
                                                            .withOpacity(0.5),
                                                        BlendMode.dstATop),
                                                image: imageProvider)),
                                    child: SizedBox.expand(
                                        child: Center(
                                            child: (!Uri.parse(url).isAbsolute)?
                                            Linkify(
                                                onOpen: (link) async {
                                                  if (await canLaunch(
                                                      link.url)) {
                                                    await launch(link.url);
                                                  } else {
                                                    throw 'Could not launch $link';
                                                  }
                                                },
                                                text: utf8.decode(events[0]
                                                    .title
                                                    .toString()
                                                    .codeUnits),
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight:
                                                        FontWeight.w600),
                                                linkStyle: TextStyle(
                                                    color: Colors.red))
                                            :GestureDetector(
                                                onTap : () async {
                                                  if (await canLaunch(url)) {
                                                    await launch(url);
                                                  } else {
                                                    throw 'Could not launch $url';
                                                  }
                                                },
                                                child: Text(utf8.decode(
                                                        events[0].title
                                                        .toString()
                                                        .codeUnits),
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                        FontWeight.w600))
                                            )
                                          )))),
                          );
                        }),
                      )
                    ]),
              ));
  }
}
