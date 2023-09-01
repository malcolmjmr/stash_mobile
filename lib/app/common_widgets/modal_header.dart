import 'package:flutter/material.dart';

class ModalHeader extends StatelessWidget {
  const ModalHeader({Key? key,
    required this.titleText,
    this.cancelText = 'Cancel',
    this.doneText = 'Done'
  }) : super(key: key);
  final String cancelText;
  final String titleText;
  final String doneText;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 10),
      child: Container(
        height: 50,
        width: double.infinity,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(cancelText,
                  style: TextStyle(
                    color: Colors.amber,
                    fontSize: 16
                  ),
                ),
              ),
            ),
           Expanded(
             child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: FittedBox(
                  fit: BoxFit.fitWidth,
                  child: Material(
                    type: MaterialType.transparency,
                    child: Text(titleText,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.w500, 
                        fontSize: 30,
                      ),
                    ),
                  ),
                ),
              ),
           ),
            GestureDetector(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(doneText,
                  style: TextStyle(
                    color: Colors.amber, 
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                ),
              ),
            )
          ]
        ),
      ),
    );
  }

}