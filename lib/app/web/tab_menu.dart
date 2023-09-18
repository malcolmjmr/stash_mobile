import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:stashmobile/app/common_widgets/fav_icon.dart';
import 'package:stashmobile/app/workspace/workspace_view_model.dart';
import 'package:stashmobile/extensions/color.dart';
import 'package:stashmobile/models/resource.dart';

class TabMenu extends StatelessWidget {
  const TabMenu({Key? key, 
    required this.resource, 
    required this.workspaceModel
  }) : super(key: key);

  final Resource resource;
  final WorkspaceViewModel workspaceModel;


  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Container(
        
        height: 300, //MediaQuery.of(context).size.height * 50,
        decoration: BoxDecoration(
          color: Colors.black,
        ),
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: CustomScrollView(
            slivers: [
              // SliverToBoxAdapter(
              //   child: _buildTabInfo(),
              // ),
              SliverToBoxAdapter(
                child: _buildTabActions(),
              ),
              SliverToBoxAdapter(
                child: _buildBookmarkActions(),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabInfo() {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 5.0),
              child: FavIcon(resource: resource,)
            ),
            Expanded(
              child: Text(resource.title ?? '', 
                maxLines: 1,
                style: TextStyle(
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0.5,
                  fontSize: 16,  
                  overflow: TextOverflow.ellipsis),
                ),
              ),
            if (resource.isSaved == true) 
            Icon(Icons.bookmark_outline),
          ],
        ),
        Text(resource.url!,
          style: TextStyle(
            fontSize: 16,
          ),
          maxLines: 2,
        )
      ],
    );
  }

  Widget _buildTabActions() {
    return SectionContainer(
      child: Column(
        children: [
          MenuItem(
            title: 'Close', 
            icon: Symbols.close,
            onTap: () => workspaceModel.closeTab(resource),
          ),
          
          MenuItem(
            title: 'Save', 
            icon: Symbols.close,
            onTap: () => workspaceModel.closeTab(resource),
          )
        ],
      )
    );
  }

  Widget _buildBookmarkActions() {
    return Container(
      child: Column(
        children: [

        ],
      ),
    );
  }

  
}

class SectionContainer extends StatelessWidget {
  final Widget child;
  const SectionContainer({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: HexColor.fromHex('444444')
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: child,
      ),
    );
  }
}

class MenuItem extends StatelessWidget {
  final String title;
  final IconData icon;
  final Function()? onTap;
  const MenuItem({
    Key? key,
    required this.title, 
    required this.icon,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title),
          Icon(icon)
        ],
      ),
    );
  }
}


