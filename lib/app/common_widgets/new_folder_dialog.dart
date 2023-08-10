import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stashmobile/extensions/color.dart';

class NewFolderDialog extends StatelessWidget {
  const NewFolderDialog({Key? key, this.onSave}) : super(key: key);

  final Function(String)? onSave;

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController();
    return CupertinoAlertDialog(
      title: Text('New Folder',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 24,
        ),
      ),
      content: Material(
        type: MaterialType.transparency,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 5.0, bottom: 20),
              child: Text('Enter a name for this folder.'),
            ),
            Container(
              height: 38,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  width: 1,
                  color: HexColor.fromHex('333333')
                )
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Name',
                    //contentPadding: EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        CupertinoDialogAction(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel', 
            style: TextStyle(
              color: Colors.deepOrange
            ),
          ),
        ),
        CupertinoDialogAction(
          onPressed: onSave?.call(controller.text),
          child: Text('Save', 
            style: TextStyle(
              color: Colors.amber
            ),
          ),
        )
      ],
    );
  }
}