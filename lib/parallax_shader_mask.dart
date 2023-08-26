import 'package:flutter/material.dart';

class ParallaxShaderMask extends StatelessWidget {
  final double border = 20.0, borderWidth = 15.0, width;
  final String image;
  final Color color;
  final ValueNotifier<double> _scrollOffset;

  ParallaxShaderMask(this.width, this.image, this.color, this._scrollOffset);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ValueListenableBuilder(
            valueListenable: _scrollOffset,
            child: SizedBox(
              width: width * 5 / 6 + borderWidth,
              child: Image.asset(image, fit: BoxFit.fitHeight),
            ),
            builder: (_, value, child) => Positioned(
                left: border/2,
                top: -0.3 * value + 5,
                child: child)),
        Column(
          children: [
            Container(
                width: width * 5 / 6 + borderWidth + border,
                height: (width * 5 / 6 + borderWidth) * 10 / 16 - border + borderWidth,
                color: Colors.transparent,
                child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(border)),
                      border: Border.all(width: borderWidth, color: color),
                      shape: BoxShape.rectangle),
                )
              ),
          ],
        ),
        Positioned(
            bottom: -2,
            child: SizedBox(
                width: width,
                height: 10,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                      color: color
                  ),
                ))),
        Positioned(
          top: 0,
          child: SizedBox(
              width: width,
              height: 10,
              child: DecoratedBox(
                decoration: BoxDecoration(
                    color: color
                ),
              )),
        )
      ],
    );
  }
}
