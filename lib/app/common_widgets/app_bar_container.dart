import 'package:flutter/material.dart';

class AppBarContainer extends StatelessWidget {
  final String title;
  AppBarContainer({required this.title});
  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Icon(Icons.arrow_back_ios),
        ),
      ),
      title: Text(title),
    );
  }
}
