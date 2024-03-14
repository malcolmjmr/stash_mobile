import 'package:flutter/material.dart';
import 'package:stashmobile/app/web/tab_model.dart';
import 'package:stashmobile/app/workspace/workspace_view_model.dart';
import 'package:stashmobile/models/chat.dart';
import 'package:stashmobile/models/resource.dart';

class ChatViewModel {

  Function(Function()) setState;
  BuildContext context;
  TabViewModel tabModel;
  WorkspaceViewModel get workspaceModel => tabModel.workspaceModel;
  Resource get resource => tabModel.resource;
  Chat get chat => tabModel.resource.chat!;

  ChatViewModel({
    required this.setState,
    required this.context,
    required this.tabModel,
  }) {
    load();
  }

  load() {

    if (chat.messages.isEmpty && workspaceModel.suggestedPrompts.isNotEmpty) {
      setShowPromptSuggestions(true);
    }
    
  }

  bool showExpandedMessage = true;
  bool showPromptSuggestions = false;

  setShowPromptSuggestions(bool value) {
    setState(() {
      showPromptSuggestions = value;
    });
  }

  setExpandedMessage(bool value) {
    setState(() {
      showExpandedMessage = value;
    });
  }

  Message messageToSend = Message();


      



}