import 'dart:math';
import 'package:flutter/material.dart';
import 'package:zflutter/zflutter.dart';

class AnimatedObjectShape extends StatelessWidget {
  final ValueNotifier<double> scrollVal, vertVal;
  final double logoScale,
      offset,
      depth,
      zOffset,
      sizeFrac = 0.0,
      yFrac = 0.23 - 0.1,//-headerFrac
      xFrac = 0.4;
  final Widget widget, widget2;
  final PageController _pageController;
  final AnimationController _animController;

  AnimatedObjectShape(this.widget, this.widget2, this.scrollVal, this.vertVal,
      this._pageController, this._animController, this.logoScale, this.offset
      , this.depth, this.zOffset, {Key key})
      : super(key: key);

  Widget build(BuildContext context) {
    return ValueListenableBuilder<double>(
        valueListenable: vertVal,
        child: widget,
        builder: (_, value, child) => (value == 1)
            ? SizedBox.shrink()
            : SizedBox(
                height: (scrollVal.value != 1)
                    ? 0
                    : MediaQuery.of(context).size.height * (logoScale + offset),
                width: (scrollVal.value != 1)
                    ? 0
                    : MediaQuery.of(context).size.height * (logoScale + offset),
                child: GestureDetector(
                    onTap: () => _animController.forward(from: 0.0),
                    onHorizontalDragUpdate: (DragUpdateDetails details){
                      _pageController.jumpTo(_pageController.offset - details.delta.dx);
                    },
                    child: ZIllustration(children: [
                      ZPositioned(
                          rotate: ZVector.only(
                              x: 0, y: (scrollVal.value - 1) * pi / 2),
                          child: ZGroup(
                              sortMode: SortMode.stack,
                              children: <Widget>[
                            ZPositioned(
                                translate: ZVector.only(
                                    y: value *
                                        -MediaQuery.of(context).size.height,
                                    z: zOffset - depth / 2 - 1),
                                child:
                              ZCylinder(
                                diameter: MediaQuery.of(context).size.height *
                                    (logoScale + offset),
                                length: depth,
                                color: Color.fromRGBO(81, 81, 81, 1),
                              )),
                            ZPositioned(
                                scale: ZVector(value * (sizeFrac - 1) + 1,
                                    value * (sizeFrac - 1) + 1, 1),
                                translate: ZVector(
                                    value *
                                        (0.5 - xFrac) *
                                        -MediaQuery.of(context).size.width,
                                    value *
                                            (0.5 - yFrac) *
                                            -MediaQuery.of(context)
                                                .size
                                                .height -
                                        value * 50, //0.34
                                    zOffset),
                                child: child)
                          ]))
                    ]))));
  }
}

class AnimatedObjectShapeStatic extends StatelessWidget {
  final String assetName;
  final double offset, logoScale;
  final Animation _animation;

  AnimatedObjectShapeStatic(
      this.assetName, this._animation, this.offset, this.logoScale,
      {Key key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ZToBoxAdapter(
        height: MediaQuery.of(context).size.height * (logoScale + offset),
        width: MediaQuery.of(context).size.height * (logoScale + offset),
        child: Container(
            decoration: BoxDecoration(
                color: Colors.transparent, //Color.fromRGBO(81, 81, 81, 1)
                shape: BoxShape.circle),
            child: AnimatedBuilder(
                animation: _animation,
                child: Image(
                  image: AssetImage(assetName),
                  width: MediaQuery.of(context).size.height * logoScale,
                  color: null,
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.center,
                ),
                builder: (context, child) {
                  return Transform.rotate(
                      angle: _animation.value, child: child);
                })));
  }
}
