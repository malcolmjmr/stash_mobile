import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stashmobile/app/home/create_workspace_modal.dart';
import 'package:stashmobile/app/home/workspace_listitem.dart';
import 'package:flutter/material.dart';
import 'package:stashmobile/extensions/color.dart';
import 'home_view_model.dart';

class HomeView extends ConsumerWidget {
  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final model = watch(homeViewProvider);
    return model.isLoading 
      ? CircularProgressIndicator() 
      : Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Header(model: model),
              Expanded(
                child: ListView.builder(
                 itemCount: model.workspaces.length,
                 itemBuilder: (context, index) {
                  final workspace = model.workspaces[index];
                  return WorkspaceListItem(
                    workspace: workspace,
                    onTap: () => model.openWorkspace(context, workspace),
                  );
                 }
                  ),
              ),
              Footer(model: model)
            ]
          ),
        );
  }
}


class Header extends StatelessWidget {
  const Header({Key? key, required this.model}) : super(key: key);
  final HomeViewModel model;
  
  @override
  Widget build(BuildContext context) {
    return  Container(
      height: 50,
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: HexColor.fromHex('333333'), width: 0.5) )
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10.0),
        child: Container(
          decoration: BoxDecoration(
            color: HexColor.fromHex('444444'),
            borderRadius: BorderRadius.circular(5.0),
            
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(Icons.search, size: 25.0,),
                Text('Search', style: TextStyle(fontSize: 22),),
              ],
            ),
          ),
        ),
      ),
    );

  }
}

class Footer extends StatelessWidget {
  const Footer({Key? key, required this.model}) : super(key: key);

  final HomeViewModel model;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50.0,
      width: double.infinity,
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              width: 0.5,
              color: HexColor.fromHex('333333'), 
              style: BorderStyle.solid, 
              )
            )
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CreateFolderButton(onTap: () => {
                showBottomSheet(
                  context: context, 
                  builder: (context) => CreateWorkspaceModal(model: model))
              }),
              CreateTabButton(onTap:() =>  model.createNewTab(context)),
            ],
          ),
        ),
      )
    );
  }
}

class CreateFolderButton extends StatelessWidget {
  const CreateFolderButton({Key? key, required this.onTap}) : super(key: key);

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.all(5), 
        child: Icon(Icons.create_new_folder_outlined, size: 35.0, weight: 100.0, color: Colors.amber),
      ),
    );
  }
}

class CreateTabButton extends StatelessWidget {
  const CreateTabButton({Key? key, required this.onTap}) : super(key: key);
  
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.all(5), 
        child: Icon(Icons.add_box_outlined, size: 35.0, weight: 100.0, color: Colors.amber,),
      ),
    );
  }
}