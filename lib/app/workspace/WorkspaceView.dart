/*

  Header
  Resource Contaienr
  Slide up panel?

*/

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stashmobile/app/workspace/WorkspaceViewModel.dart';
import 'package:stashmobile/constants/color_map.dart';
import 'package:stashmobile/extensions/color.dart';

import '../../models/resource.dart';

class WorkspaceView extends ConsumerWidget {

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final model = watch(workspaceViewProvider);
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Container(
          child: Column(
            children: [
              _buildHeader(context, model),
              _buildResourceContainer(context, model),
              _buildFooter(context, model)
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, WorkspaceViewModel model) {
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: HexColor.fromHex(model.workspaceHexColor)))
      ),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 5.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildBackButton(context, model),
            _buildTitle(context, model),
            _buildMoreButton(context, model),
          ],
        ),
      ),
    );
  }

  Widget _buildBackButton(BuildContext context, WorkspaceViewModel model) {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: Icon(Icons.arrow_back_ios, weight: 100,),
      ),
    );
  }

  Widget _buildTitle(BuildContext context, WorkspaceViewModel model) {
    return Expanded(
      child: Text(model.workspace.title ?? 'Untitled',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: HexColor.fromHex(colorMap[model.workspace.color ?? 'grey']!),
          fontSize: 20.0,
          overflow: TextOverflow.ellipsis
        ),
      )
    );
  }

  Widget _buildMoreButton(BuildContext context, WorkspaceViewModel model) {
    return GestureDetector(
      onTap: () => null,
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: Icon(Icons.more_vert_outlined),
      ),
    );
  }

  Widget _buildResourceContainer(BuildContext context, WorkspaceViewModel model) {
    return Expanded(
      child: Container(
        child: Column(
          children: model.visibleResources.map((resource) {
            return _buildTabListItem(resource, 
              onTap: () => model.openResource(context, resource)
            );
          }).toList()
        ),
      ),
    );
  }

  Widget _buildTabListItem(Resource resource, {VoidCallback? onTap}){
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 8.0),
        child: Container(
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 5.0),
                child: Container(
                  height: 26,
                  width: 26,
                  child: resource.favIconUrl != null 
                    ? Image.network(resource.favIconUrl!) 
                    : Icon(Icons.language, size: 30,)
                  ),
              ),
              Expanded(
                child: Text(resource.title ?? '', 
                  maxLines: 1,
                  style: TextStyle(
                    fontWeight: FontWeight.w300,
                    letterSpacing: 0.5,
                    fontSize: 18,  
                    overflow: TextOverflow.ellipsis),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context, WorkspaceViewModel model) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: HexColor.fromHex(model.workspaceHexColor), width: 0.5))
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          FooterIcon(icon: Icons.dynamic_feed),
          FooterIcon(icon: Icons.history),
          FooterIcon(icon: Icons.folder),
          FooterIcon(icon: Icons.inbox),
          FooterIcon(icon: Icons.short_text),
        ],
      ),
    );
  }
}

class FooterIcon extends StatelessWidget {
  const FooterIcon({Key? key, required this.icon, this.onTap}) : super(key: key);
  final IconData icon;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Icon(icon, size: 30,),
      ),
    );
  }
}
