import 'package:flutter/material.dart';

class FitShaderMask extends StatelessWidget {
  final String mask, image;
  final Color color;
  FitShaderMask(this.mask, this.image, this.color);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Center(
          child: SizedBox(
              width: MediaQuery.of(context).size.width * 5 / 6,
              height: MediaQuery.of(context).size.width * 5 / 6 * 10 / 16,
              child: Image.asset(image, fit: BoxFit.cover)),
        ),
        Center(
          child: ShaderMask(
              blendMode: BlendMode.softLight, //BlendMode.xor//srcATop
              shaderCallback: (Rect bounds) {
                /*
                //Not working on flutter web on phone (HTML renderer)
                return ImageShader(
                  image,
                  TileMode.mirror,
                  TileMode.mirror,
                  Matrix4.identity().storage,
                );
                 */
                return LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.blueGrey,
                      Colors.red
                    ]).createShader(bounds);
              },
              child: Container(
                margin: const EdgeInsets.all(5.0),
                child: SizedBox(
                    width: MediaQuery.of(context).size.width * 5 / 6,
                    height: MediaQuery.of(context).size.width * 5 / 6 * 10 / 16,
                    child: Image.asset(mask,
                        fit: BoxFit.cover)),
              )),
        ),
        //Hide lines from ShaderMask on phone
        Align(
            alignment: Alignment.centerRight,
            child: Container(
                color: color,
                width: MediaQuery.of(context).size.width * (1 - 5 / 6) / 2,
                height: MediaQuery.of(context).size.width * 5 / 6 * 10 / 16)),
        Positioned(
            bottom: 0,
            child: Container(
                color: color,
                width: MediaQuery.of(context).size.width,
                height: 10))
      ],
    );
  }
}