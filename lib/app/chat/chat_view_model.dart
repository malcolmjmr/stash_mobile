import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:stashmobile/app/web/tab_model.dart';
import 'package:stashmobile/app/workspace/workspace_view_model.dart';
import 'package:stashmobile/models/chat.dart';
import 'package:stashmobile/models/resource.dart';
import 'package:stashmobile/services/llm.dart';

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

  TextEditingController messageController = TextEditingController();

  dispose() {
    messageController.dispose();
  }

  load() {

    if (chat.messages.length < 1) {
      setShowPromptSuggestions(true);

      messageToSend = chat.messages
        .firstWhereOrNull((Message m) => 
          m.content.firstWhereOrNull((c) => c.isTextSelection) != null
        ) ?? Message();

      chat.messages = [];

    } else {

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


  sendMessageWithPrompt(Prompt prompt) async {
    messageToSend.content.add(MessageContent(text: prompt.text));
    chat.messages.add(messageToSend);

    final response = await LLM().mistralChatCompletion(
      messages: chat.messages.map((m) => m.toJson(forRequest: true)).toList()
    );
    setState(() {
      chat.messages.add(Message.text(text: response, role: Role.assistant));
      messageToSend = Message();
    });

  }

  sendMessage(String prompt) async {

    // if message contains selection 

    chat.messages.add(Message.text(text: prompt));

    final response = await LLM().mistralChatCompletion(prompt: prompt);

    setState(() {
      chat.messages.add(Message.text(text: response, role: Role.assistant));
      messageToSend = Message();
    });



  }


  
  onSelectionChanged(String text, TextSelection textSelection, SelectionChangedCause? cause) {
    setState(() {
       print('text seleciton change');
      final value = text.substring(textSelection.start, textSelection.end);
      final selection = workspaceModel.selectedText.toString();
      workspaceModel.selectedText = value;

      if (selection.isEmpty && value.isNotEmpty) {
        
        workspaceModel.setShowTextSelectionMenu(true);
      } else if (selection.isNotEmpty && value.isEmpty) {

        workspaceModel.setShowTextSelectionMenu(false);
    
      }
    });
   
  }

    submitMessage() async  {

      if (messageController.text.isEmpty) return;
      print('submitting message');
        HapticFeedback.mediumImpact();
        resource.chat!.messages.add(Message.text(text: messageController.text));
        final messages = resource.chat!.messages.map((m) => m.toJson(forRequest: true)).toList();
        print(messages);
        final response = await LLM().openAiChatCompletion(messages: messages);
        print('got response');
        print(response);
        if (response == null) return;
      setState(() {
        
        resource.chat!.messages.add(Message.text(role: Role.assistant, text: response));
        workspaceModel.saveResource(resource);
        messageController.text = '';
      });
      
    
    }

}