import 'dart:math';
import 'package:flutter/material.dart';

class SizeChip extends StatelessWidget {
  final int number;
  final String text;

  SizeChip(this.number, this.text);

  @override
  Widget build(BuildContext context) {
    return Chip(
      labelPadding: EdgeInsets.all(2.0),
      avatar: CircleAvatar(
        backgroundColor: Colors.white70,
        child: Text((number == null) ? "-" : number.toString()),
      ),
      label: Text(
        text,
        style: TextStyle(
          color: Colors.white,
        ),
      ),
      backgroundColor: Color(0xFF60230b),
      elevation: 6.0,
      shadowColor: Colors.grey[60],
      padding: EdgeInsets.all(8.0),
    );
  }
}

class SwappedChip extends StatelessWidget {
  final int size, oriSize;
  final ValueNotifier<bool> _showFrontSide;

  SwappedChip(this.size, this.oriSize, this._showFrontSide);

  @override
  Widget build(BuildContext context) {
    return Positioned(
        right: 15,
        top: 15,
        child: ValueListenableBuilder(
            valueListenable: _showFrontSide,
            builder: (_, value, __) => AnimatedSwitcher(
                duration: Duration(milliseconds: 600),
                transitionBuilder:
                    (Widget widget, Animation<double> animation) {
                  final _animation =
                  Tween(begin: pi, end: 0.0).animate(animation);
                  return AnimatedBuilder(
                      animation: _animation,
                      child: widget,
                      builder: (context, widget) {
                        final isUnder = (ValueKey(false) != widget.key);
                        var tilt =
                            ((animation.value - 0.5).abs() - 0.5) * 0.003;
                        tilt *= isUnder ? -1.0 : 1.0;
                        final value = isUnder
                            ? min(_animation.value, pi / 2)
                            : _animation.value;
                        return Transform(
                            transform: Matrix4.rotationY(value)
                              ..setEntry(3, 0, tilt),
                            child: widget,
                            alignment: Alignment.center);
                      });
                },
                layoutBuilder: (widget, list) =>
                    Stack(children: [widget, ...list]),
                child: _showFrontSide.value
                    ? Container(key: ValueKey<int>(0), child: SizeChip(oriSize, "forms submitted"))
                    : Container(
                    key: ValueKey<int>(1), child: SizeChip(size, "forms submitted")))));
  }
}