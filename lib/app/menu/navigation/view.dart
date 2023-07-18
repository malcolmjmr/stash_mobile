import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stashmobile/app/collections/collection/icon.dart';
import 'package:stashmobile/app/menu/model.dart';
import 'package:stashmobile/app/menu/more/collapsed.dart';
import 'package:stashmobile/app/model.dart';
import 'package:stashmobile/app/providers/app.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stashmobile/routing/app_router.dart';

class NavigationBar extends StatelessWidget {
  NavigationBar();
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      child: PageView(
        scrollDirection: Axis.vertical,
        children: [
          _buildNavigationBar(context),
          CollapsedMenu(),
        ],
      ),
    );
  }

  Widget _buildNavigationBar(BuildContext context) {
    final app = context.read(appProvider);
    final subLinkCount = app.treeView.rootNode.children.length;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildWebPageProgressBar(context, app.menuView),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              GestureDetector(
                onLongPress: () => app.viewModel.goBack(context, location: 0),
                onTap: () => app.viewModel.goBack(context),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Icon(
                    Icons.arrow_back,
                    size: 30,
                    color: app.viewModel.canGoBack
                        ? null
                        : Theme.of(context).disabledColor,
                  ),
                ),
              ),
              CollectionIcon(
                app.collections.currentCollection!,
                onTap: () => Navigator.of(context).pushNamed(
                  AppRoutes.collectionHome,
                  arguments: app.collections.currentCollection!,
                ),
                padding: const EdgeInsets.all(8),
                size: 30,
              ),
              GestureDetector(
                onTap: () => app.menuView.addNodeToTree(context),
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                  child: Icon(Icons.add_circle, size: 45),
                ),
              ),
              app.menuView.getShowViewIcon(context)
                  ? GestureDetector(
                      onTap: () => app.menuView.viewDocument(context),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(Icons.wysiwyg, size: 30),
                      ),
                    )
                  : GestureDetector(
                      onTap: () => app.menuView.viewTree(context),
                      child: Container(
                        width: 46,
                        child: Center(
                          child: Stack(
                            children: [
                              Center(child: Icon(Icons.account_tree, size: 26)),
                              subLinkCount > 0
                                  ? Positioned(
                                      right: 5,
                                      bottom: 0,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(20),
                                        child: Container(
                                          color:
                                              Theme.of(context).highlightColor,
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                left: 3.0, right: 3.0),
                                            child: Text(
                                              subLinkCount.toString(),
                                              style:
                                                  GoogleFonts.lato(fontSize: 8),
                                            ),
                                          ),
                                        ),
                                      ),
                                    )
                                  : Container()
                            ],
                          ),
                        ),
                      ),
                    ),
              GestureDetector(
                onTap: () => app.viewModel.goForward(context),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(
                    Icons.arrow_forward,
                    size: 30,
                    color: app.viewModel.canGoForward
                        ? null
                        : Theme.of(context).disabledColor,
                  ),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWebPageProgressBar(BuildContext context, MenuViewModel model) {
    final hideProgressBar = !context.read(appViewProvider).webViewIsOpen ||
        model.webPageProgress == 1.0;
    final screenWidth = MediaQuery.of(context).size.width;
    return hideProgressBar
        ? Container()
        : Container(
            height: 3,
            child: Row(children: [
              Container(
                  color: Theme.of(context).highlightColor,
                  width: screenWidth * model.webPageProgress),
              Container(width: screenWidth * (1 - model.webPageProgress))
            ]),
          );
  }
}
