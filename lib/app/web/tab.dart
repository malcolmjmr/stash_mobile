import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:stashmobile/app/chat/chat_view.dart';
import 'package:stashmobile/app/note/note_view.dart';
import 'package:stashmobile/app/web/tab_journey.dart';

import 'package:stashmobile/app/web/tab_model.dart';
import 'package:stashmobile/app/workspace/workspace_view_model.dart';
import 'package:stashmobile/models/resource.dart';

enum TabViewType {
  web, 
  note,
  chat,
}

class TabView extends StatefulWidget {
  TabView({Key? key, 
    required this.model,
    this.windowId,
    this.lazyLoad = true,
    this.incognito = false,
  }) : super(key: UniqueKey());

  final bool lazyLoad;
  final TabViewModel model;
  final int? windowId;
  final bool incognito;

  //final Function(TabViewModel model, InAppWebViewController controller, Uri? uri) onTabUpdated;

  // final Function() onWindowCreated
  // final Function() onWindowClosed

  

  @override
  State<TabView> createState() => _TabViewState();
}

class _TabViewState extends State<TabView> {

  

  @override
  void dispose() {
    // TODO: implement dispose
    widget.model.dispose();
    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    widget.model.init(setState, context);
    
  }

  Widget build(BuildContext context) {
    final resource = widget.model.resource;
    
    if (widget.model.showTabJourney) {
      return TabJourney(tabModel: widget.model,);
    }

    if (widget.model.viewType == TabViewType.web) {
      return _buildWebView();
    } else if (widget.model.viewType == TabViewType.note) {
      return NoteView(
        resource: resource, 
        workspaceModel: widget.model.workspaceModel
      );
    } else if (widget.model.viewType == TabViewType.chat) {
      return ChatView(tabModel: widget.model,);
    } else {
      return Container();
    }
  }


  Widget _buildWebView() {
    return InAppWebView(
      windowId: widget.windowId,
      initialUrlRequest: widget.lazyLoad || widget.windowId != null ? null : URLRequest(url: Uri.parse(widget.model.resource.url!)),
      pullToRefreshController: PullToRefreshController(
        options: PullToRefreshOptions(),
      ),
      gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>[
        new Factory<OneSequenceGestureRecognizer>(
          () => new EagerGestureRecognizer(),
        ),
      ].toSet(),
      
      onWebViewCreated: widget.model.setController,
      onLoadStart: (controller, uri) => widget.model.onWebsiteLoadStart(context, controller, uri),
      onProgressChanged: (controller, progress) => widget.model.onWebsiteProgressChanged(context, controller, progress),
      onLoadStop: (controller, uri) => widget.model.onWebsiteLoadStop(context, controller, uri),
      onConsoleMessage: (controller, msg) {
        print('JS console:\n$msg');
      },
      //onScrollChanged: (controller, x, y) => widget.model.onScrollChanged,
      onCloseWindow: (controller) => widget.model.onCloseWindow(context, controller),
      onCreateWindow:(controller, createWindowAction) => widget.model.onCreateWindow(context, controller, createWindowAction),
      shouldOverrideUrlLoading: (controller, navigationAction) => widget.model.checkNavigation(context, navigationAction),
      // contextMenu: ContextMenu(
      //   menuItems: [
      //     ContextMenuItem(title: 'Add Vocab', iosId: 'add-vocab', ),
      //   ],
      //   //options: ContextMenuOptions(hideDefaultSystemContextMenuItems: true)
      // ),

      initialOptions: InAppWebViewGroupOptions(
      
        crossPlatform: InAppWebViewOptions(
          disableHorizontalScroll: true,
          useShouldOverrideUrlLoading: true,
          incognito: widget.incognito,
          // javaScriptEnabled: true,
          userAgent: 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/114.0.0.0 Mobile Safari/537.36',
          // javaScriptCanOpenWindowsAutomatically: true,
          //disableContextMenu: true
          
        ),
        ios: IOSInAppWebViewOptions(
          allowsBackForwardNavigationGestures: true,
          disableLongPressContextMenuOnLinks: true,
          allowsLinkPreview: false,
          disallowOverScroll: true,
          // sharedCookiesEnabled: true,
          // applePayAPIEnabled: true,
          //applePayAPIEnabled: true,

        
        ),
      ),
    );
  }
}


