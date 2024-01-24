import 'package:flutter/material.dart';
import 'package:stashmobile/app/note/note_view_model.dart';

class NoteView extends StatefulWidget {

  /*
    
  */
  const NoteView({Key? key}) : super(key: key);

  @override
  State<NoteView> createState() => _NoteViewState();
}

class _NoteViewState extends State<NoteView> {

  late NoteViewModel model;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    model = NoteViewModel();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          PageView(

          ),
         // _buildFooter(),
        ],
      ),
    );
  }
}