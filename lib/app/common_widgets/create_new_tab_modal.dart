import 'package:flutter/material.dart';
import 'package:stashmobile/extensions/color.dart';

class CreateNewTabModal extends StatefulWidget {
  const CreateNewTabModal({Key? key}) : super(key: key);

  @override
  State<CreateNewTabModal> createState() => _CreateNewTabModalState();
}

class _CreateNewTabModalState extends State<CreateNewTabModal> {

  final TextEditingController textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Container(
        width: MediaQuery.of(context).size.width,
        child: Column(
          children: [
            _buildHeader(),
            _buildInputField(),
            _buildDomainOptions(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Container(
        height: 50,
        width: double.infinity,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Text('Cancel',
                style: TextStyle(
                  color: Colors.amber
                ),
              ),
            ),
            Text('New Tab'),
            GestureDetector(
              child: Text('Go',
                style: TextStyle(
                  color: Colors.amber, 
                  fontWeight: FontWeight.w500
                ),
              ),
            )
          ]
        ),
      ),
    );
  }


  Widget _buildInputField() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: HexColor.fromHex('222222'))
      ),
      child: TextField(
        controller: textController,
        decoration: InputDecoration(
          border: InputBorder.none
        ),
        onSubmitted: (value) {
          
        },
      ),
    );
  }

  Widget _buildDomainOptions() {
    return ListView(
      scrollDirection: Axis.horizontal,
      children: [
        // google
        // bing
        // youtube
        // startupy
        // medium
        // 
      ],
    );
  }


}