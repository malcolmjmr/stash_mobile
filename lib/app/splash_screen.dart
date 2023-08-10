import 'dart:math';

import 'package:flutter/material.dart';
import 'package:random_color/random_color.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        height: double.infinity,
        width: double.infinity,
        color: RandomColor().randomColor(),
        child: Center(
          child: Hero(
            tag: 'Stash',
            child: Text('Stash', 
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 50, 
                color: Colors.black,
                ),
              ),
          )
        ),
      ),
    );
  }
}