import 'package:flutter/material.dart';
import 'package:stashmobile/app/web/tab_edit_model.dart';
import 'package:stashmobile/app/workspace/workspace_view_model.dart';
import 'package:stashmobile/extensions/color.dart';
import 'package:stashmobile/models/resource.dart';


/*
  search results 
  - resources that match 

  url field
    - type url
    - or search
*/


class TabEditModal extends StatefulWidget {
  final Resource tab;
  final WorkspaceViewModel workspaceModel;
  const TabEditModal({Key? key, required this.tab, required this.workspaceModel}) : super(key: key);

  @override
  State<TabEditModal> createState() => _TabEditModalState();
}

class _TabEditModalState extends State<TabEditModal> {


  late TabEditModel model;
  bool isLoaded = false;
  

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    model = TabEditModel(
      setState: setState, 
      workspaceModel: widget.workspaceModel,
      tab: widget.tab,

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

  Widget _buildUrlField() {
    return Hero(
      tag: 'activetab' + model.tab.url!,
      child: Container(
        color: Colors.black,
        height: 50,
        width: MediaQuery.of(context).size.width,
        child: Row(
          children: [
            GestureDetector(
              onTap: () => model.createNewTab(context),
              child: Padding(
                padding: const EdgeInsets.only(left: 5.0),
                child: Icon(Icons.add, size: 30,),
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                child: Container(
                  decoration: BoxDecoration(
                    color: HexColor.fromHex('333333'),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: model.inputController,
                            autocorrect: false,
                            maxLines: 1,
                            keyboardType: TextInputType.text,
                            textInputAction: TextInputAction.go,
                            onChanged: (value) {
                              model.input = value;
                              model.searchWorkspace();
                            },
                            onSubmitted: (value) {
                              model.updateTab(context);
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
                        if (model.input.isNotEmpty)
                        GestureDetector(
                          onTap: () => model.clearInput(),
                          child: Padding(
                            padding: const EdgeInsets.only(top: 3.0, bottom: 3.0),
                            child: Icon(Icons.close_outlined),
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
      ),
    );
  }
}