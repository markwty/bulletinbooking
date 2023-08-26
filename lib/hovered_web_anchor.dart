import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class HoveredWebAnchor extends StatefulWidget {
  HoveredWebAnchor(
      {Key key,
        this.label,
        this.url,
        this.underlined = true})
      : assert(label != null),
        assert(url != null),
        assert(underlined != null),
        super(key: key);

  final String label;
  final String url;
  final bool underlined;

  @override
  _HoveredWebAnchorState createState() => _HoveredWebAnchorState();
}

class _HoveredWebAnchorState extends State<HoveredWebAnchor> {
  TextStyle _defaultStyle = TextStyle(
    color: Colors.blue,
    fontSize: 16,
    fontFamily: "JosefinSans",
    fontWeight: FontWeight.w300
  );
  TextStyle _textStyle = TextStyle(
    color: Colors.blue,
    fontSize: 16,
    fontFamily: "JosefinSans",
    fontWeight: FontWeight.w300
  );

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child:
        Row(
          children: <Widget>[
            Icon(Icons.double_arrow_rounded, color: Colors.blueGrey),
            Flexible(
              child: InkWell(
                hoverColor: Colors.transparent,
                child: Padding(
                  padding: const EdgeInsets.only(top: 3.0),
                  child: Text(
                      widget.label,
                      style: _textStyle
                  ),
                ),
                onHover: (hovered) {
                  setState(() {
                    if (hovered) {
                      _textStyle = _defaultStyle;
                      if (widget.underlined) {
                        _textStyle = _textStyle.copyWith(
                          decoration: TextDecoration.underline,
                        );
                      }
                    } else {
                      _textStyle = _defaultStyle;
                    }
                  });
                },
                onTap: () => launch(widget.url, forceWebView: true)
              ),
            )
          ]
        )
    );
  }
}