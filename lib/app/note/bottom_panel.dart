
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:stashmobile/extensions/color.dart';

class NoteBottomPanel extends StatefulWidget {
  const NoteBottomPanel({Key? key, }) : super(key: key);

  @override
  State<NoteBottomPanel> createState() => _NoteBottomPanelState();
}

class _NoteBottomPanelState extends State<NoteBottomPanel> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

class BottomPanelListItem extends StatelessWidget {
  const BottomPanelListItem({
    Key? key, 
    required this.text,
    this.onTap,
    this.onDoubleTap,
    this.isSelected = false,
  }) : super(key: key);

  final String text;
  final Function()? onTap;
  final Function()? onDoubleTap;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    /*
      add to note
      send to top
      stash 
      open highlight
      search 


    */
    print('building bottom panel list item');
    return GestureDetector(
      onDoubleTap: onDoubleTap,
      child: Container(
        //width: 100,
        decoration: BoxDecoration(
          color: isSelected ? HexColor.fromHex('333333') : HexColor.fromHex('111111'),
          border: Border(bottom: BorderSide(color: HexColor.fromHex('333333')))
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 10),
          child: SelectableText(text, 
            onTap: onTap,
            onSelectionChanged: (selection, cause) => null, // let user compress text, thereby pinning 
            style: TextStyle(
              fontSize: 16
            ),
          ),
        ),
      ),
    );
  }
}