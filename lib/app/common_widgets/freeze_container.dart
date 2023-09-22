import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:stashmobile/extensions/color.dart';

class FreezeContainer extends StatelessWidget {

  final Widget child;
  const FreezeContainer({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        new Center(
          child: new ClipRect(
            child: new BackdropFilter(
              filter: new ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
              child: new Container(
                width: MediaQuery.of(context).size.width,
                height: double.infinity,
                decoration: new BoxDecoration(
                  color: HexColor.fromHex('333333').withOpacity(0.85)
                ),
                child: child,
              ),
            ),
          ),
        ),
      ],
    );
  }
}