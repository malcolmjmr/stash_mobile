import 'package:flutter/material.dart';
import 'package:stashmobile/app/common_widgets/fav_icon.dart';
import 'package:stashmobile/app/modals/create_new_tab/create_new_tab_model.dart';
import 'package:stashmobile/app/workspace/workspace_view_model.dart';
import 'package:stashmobile/extensions/color.dart';
import 'package:stashmobile/models/domain.dart';

class CreateNewTabModal extends StatefulWidget {

  const CreateNewTabModal({Key? key}) : super(key: key);

  @override
  State<CreateNewTabModal> createState() => _CreateNewTabModalState();
}

class _CreateNewTabModalState extends State<CreateNewTabModal> {


  late CreateNewTabModel model;
  bool isLoaded = false;
  

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    model = CreateNewTabModel(
      context,
      setState, 
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    model.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Container(
          width: screenSize.width,
          color: Colors.transparent,
          child: Column(
            children: [
              _buildBackground(),
              _buildCreateOptions(),
              _buildUrlField(),
            ],
          ),
        )
      ),
    );
  }

  Widget _buildBackground() {
    return Expanded(
      child: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          color: Colors.transparent,
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    return Container();
  }

  Widget _buildCreateOptions() {
    return Container();
  }

  Widget _buildUrlField() {
    return Container(
      color: Colors.black,
      height: 50,
      width: MediaQuery.of(context).size.width,
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              child: Container(
                decoration: BoxDecoration(
                  color: HexColor.fromHex('333333'),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: model.inputController,
                          autocorrect: false,
                          maxLines: 1,
                          keyboardType: TextInputType.text,
                          textInputAction: TextInputAction.go,
                          onChanged: (value) => model.onInputChanged(),
                          onSubmitted: (value) {
                            model.createTab();
                          },
                          autofocus: true,
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.only(bottom: 8),
                            border: InputBorder.none,
                            hintStyle: TextStyle(
                              color: Colors.white.withOpacity(0.8)
                            )
                          ),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16
                          ),
                        ),
                      ),
                      if (model.textInput.isNotEmpty)
                      GestureDetector(
                        onTap: () => model.clearInput(),
                        child: Padding(
                          padding: const EdgeInsets.all(5),
                          child: Container(
                            height: 20, 
                            width: 20,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(100),
                              color: HexColor.fromHex('555555'),
                            ),
                            child: Center(child: Icon(Icons.close_outlined, size: 18,))),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
