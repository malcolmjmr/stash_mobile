import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart' hide WebView;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stashmobile/app/providers/web.dart';
import 'package:stashmobile/app/web/model.dart';
import 'package:stashmobile/app/web/tab.dart';
import 'package:stashmobile/app/workspace/workspace_view.dart';
import 'package:stashmobile/app/workspace/workspace_view_model.dart';
import 'package:stashmobile/extensions/color.dart';


class WebView extends ConsumerWidget {
  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final webManager = watch(webManagerProvider);
    final model = watch(webViewProvider);
    final tabIndex = watch(tabIndexProvider);
    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            const WebViewHeader(),
            Container(
              height: MediaQuery.of(context).size.height - 130,
              child: IndexedStack(
                index: tabIndex.state,
                children: model
                  .tabs.asMap().entries
                  .map((e) => TabView(index: e.key, url: e.value.url!))
                  .toList(),
              )
            ),
            const WebViewNavBar(),
          ],
        ),
      ),
    );
  }
}

final showHeadingProvider = StateProvider<bool>((ref) => true);

class WebViewNavBar extends ConsumerWidget {
  const WebViewNavBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final webManager = watch(webManagerProvider);
    final model = watch(webViewProvider);
    final tabIndex = watch(tabIndexProvider).state;
    final WorkspaceViewModel workspaceViewModel = watch(workspaceViewProvider);
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
              children: model.workspaceViewModel.tabs.map((tab) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 10.0),
                  child: TabListItem(
                    isFirstListItem: true,
                    isLastListItem: true,
                    model: workspaceViewModel, 
                    resource: tab, 
                    onTap: () => null
                  ),
                );
              }).toList(),
              onPageChanged: model.onPageChanged,
              controller: PageController(initialPage: tabIndex),
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

  Widget _buildUrlField(BuildContext context, WebViewModel model, WebManager webManager) {
    final controller = TextEditingController(text: model.resourceTitle);
    print(controller.text);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 5.0),
      child: Container(
        height: 30,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: HexColor.fromHex('888888'),
        ),
        padding: EdgeInsets.symmetric(horizontal: 5.0),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  
                ),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationButtons(BuildContext context, WebViewModel model) {

    return model.showNavBar ? Container(
      decoration:  BoxDecoration(
        color: Colors.black,
        // border: model.app.currentWorkspace != null 
        // ? Border(
        //     top: BorderSide(
        //       color: model.workspaceColor,
        //       width: 3.0
        //     )
        //   ) 
        // : null
      ),
      height: 50, 
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 15.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Opacity(
            opacity: model.canGoBack ? 1.0 : .5,
            child: NavIconButton(
              icon: Icons.arrow_back_ios, 
              onTap: () => model.goBack()
              ,
            ),
          ),
          NavIconButton(
            icon: Icons.home_outlined,
            onTap: () => Navigator.pop(context),
            
          ),
          NavIconButton(
            icon: Icons.add_box_outlined, 
            onTap: () => model.createNewTab(),
          ),
          NavIconButton(
            icon: Icons.folder_outlined, 
            onTap: () => model.viewWorkspace(context),
          ),
          Opacity(
            opacity: model.canGoForward ? 1.0 : .5,
            child: NavIconButton(
              icon: Icons.arrow_forward_ios, 
              onTap: () => model.goForward(),
            ),
          ),
        ],
      ),
    ) : Container();
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
  const WebViewHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final model = watch(webViewProvider);
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
            onTap: () => Navigator.pop(context),
            child: Row(
              children: [
                Icon(Icons.arrow_back_ios,
                  color: model.workspaceColor,
                ),
                Material(
                  type: MaterialType.transparency,
                  child: Hero(
                    tag: model.workspaceTitle,
                    child: Text(model.workspaceTitle,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: model.workspaceColor,
                        fontSize: 20
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.more_horiz, 
            color: model.workspaceColor
          )
        ],
      ),
    );
  }
}
