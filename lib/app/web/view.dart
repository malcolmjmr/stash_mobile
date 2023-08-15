import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:stashmobile/app/web/tab.dart';
import 'package:stashmobile/app/workspace/workspace_view.dart';
import 'package:stashmobile/app/workspace/workspace_view_model.dart';
import 'package:stashmobile/extensions/color.dart';


class WorkspaceWebView extends StatelessWidget {
  final WorkspaceViewModel model;
  final Function() onExitWebView;
  WorkspaceWebView({ required this.model, required this.onExitWebView});
  @override
  Widget build(BuildContext context) {

    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            WebViewHeader(model: model, onExitWebView: onExitWebView),
            Container(
              height: MediaQuery.of(context).size.height - 130,
              child: IndexedStack(
                index: model.workspace.activeTabIndex,
                children: model.tabs
              )
            ),
            WebViewNavBar(model: model,),
          ],
        ),
      ),
    );
  }
}

final showHeadingProvider = StateProvider<bool>((ref) => true);

class WebViewNavBar extends StatelessWidget {

  final WorkspaceViewModel model;
  const WebViewNavBar({Key? key, required this.model}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return Container(
       decoration: BoxDecoration(
        color: Colors.black
        // border: model.app.currentWorkspace != null 
        // ? Border(
        //     top: BorderSide(
        //       color: model.workspaceColor,
        //       width: 3.0
        //     )
        //   ) 
        // : null
      ),
      height: 70,
      width: MediaQuery.of(context).size.width,
      child: Column(
        children: [
          //Icon(Icons.arrow_drop_up),
          Expanded(
            child: PageView(
              scrollDirection: Axis.vertical,
              children: model.workspace.tabs.map((tab) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 10.0),
                  child: TabListItem(
                    isFirstListItem: true,
                    isLastListItem: true,
                    model: model, 
                    resource: tab, 
                    onTap: () => null
                  ),
                );
              }).toList(),
              onPageChanged: model.onPageChanged,
              controller: PageController(initialPage: model.workspace.activeTabIndex!),
            ),
          ),
          //Icon(Icons.arrow_drop_down),
        ],
      )
      
      // Column(
      //   children: [
      //     _buildUrlField(context, model, webManager),
      //     _buildNavigationButtons(context, model)
      //   ],
      // ),
    );
  }

}

class NavIconButton extends StatelessWidget {
  const NavIconButton({Key? key, 
    required this.icon, 
    this.onTap, 
    this.color, 
    this.size
  }) : super(key: key);

  final VoidCallback? onTap;
  final IconData icon;
  final Color? color;
  final double? size;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Icon(
        icon, 
        color: color,
        fill: 0,
        weight: 100,
        size: size ?? 30,
      ),
    );
  }
}


class WebViewHeader extends ConsumerWidget {
  const WebViewHeader({Key? key, required this.model, required this.onExitWebView}) : super(key: key);

  final Function() onExitWebView;
  final WorkspaceViewModel model;

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final workspaceColor = HexColor.fromHex(model.workspaceHexColor);
    return Container(
      height: 40, 
      width: double.infinity, 
      padding: EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.black
        // border: model.app.currentWorkspace != null 
        // ? Border(
        //     bottom: BorderSide(
        //       color: model.workspaceColor,
        //       width: 3.0
        //     )
        //   ) 
        // : null
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: onExitWebView,
            child: Row(
              children: [
                Icon(Icons.arrow_back_ios,
                  color: workspaceColor,
                ),
                Material(
                  type: MaterialType.transparency,
                  child: Hero(
                    tag: model.workspace.title ?? '',
                    child: Text(model.workspace.title ?? '',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: workspaceColor,
                        fontSize: 20
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.more_horiz, 
            color: workspaceColor
          )
        ],
      ),
    );
  }
}
