import 'package:flutter/material.dart';

/*

  Todo:
  - edit title
  - set color
  - add to favorites 
  - set as incognito
  - set parent spaces 
  - close
  - delete
  

*/

class WorkspaceMenu extends StatelessWidget {
  const WorkspaceMenu({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container()
      ),
    );
  }
}