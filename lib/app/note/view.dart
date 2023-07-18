import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'model.dart';

class NoteView extends StatelessWidget {
  final double? height;
  NoteView({this.height});
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => NoteViewModel(context),
      child: Consumer<NoteViewModel>(builder: (context, model, _) {
        return Container(
            height: height ?? MediaQuery.of(context).size.height,
            color: Theme.of(context).primaryColorDark,
            child: Column(
              children: [
                _buildBody(model),
                _buildMenu(model),
              ],
            ));
      }),
    );
  }

  Widget _buildBody(NoteViewModel model) => Expanded(
        child: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: TextField(
            autofocus: true,
            controller: model.textController,
            focusNode: model.textFocusNode,
            maxLines: null,
            decoration:
                InputDecoration(isCollapsed: true, border: InputBorder.none),
            onChanged: (text) => model.updateBody(text),
          ),
        ),
      );

  Widget _buildMenu(NoteViewModel model) => Container(
        height: 50,
        child: Row(
          children: [
            GestureDetector(
              onTap: model.keyboardDown,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(Icons.keyboard_hide),
              ),
            )
          ],
        ),
      );
}
