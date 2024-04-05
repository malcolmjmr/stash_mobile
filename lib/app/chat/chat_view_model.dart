import 'dart:async';
import 'dart:convert';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:stashmobile/app/providers/search.dart';
import 'package:stashmobile/app/providers/speech_to_text.dart';
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
  ItemScrollController scrollController = ItemScrollController();
  ScrollOffsetListener scrollOffsetListener = ScrollOffsetListener.create();
  ItemPositionsListener itemPositionsListener = ItemPositionsListener.create();
  
  double scrolloffset = 0;
  double lastScrollPosition = 0;
  String scrollDirection = '';
  double scrollPositionOnDirectionChange = 0;
  bool reachedScrollThreshold = false;
  final scrollThreshold = 30;

  dispose() {
    messageController.dispose();
    if (_singleTapTimer != null) {
      _singleTapTimer!.cancel();
      _singleTapTimer = null;
    }
    if (_longPressTimer != null) {
      _longPressTimer!.cancel();
      _longPressTimer = null;
    }
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

    getQuestions();

    scrollOffsetListener.changes.listen(onScrollChange);
    setForwardAndBackFunctions();
    itemPositionsListener.itemPositions.addListener(() {
      final index = itemPositionsListener.itemPositions.value.first.index;
      currentThread = chat.messages[index];

      if (currentThread!.role == Role.assistant) {
        currentThread = chat.messages[index];
      }
      checkCanGoBackandForward();
    
    });
  }

  checkCanGoBackandForward() {
    final index = currentIndex;
    if (index > 1 && !tabModel.canGoBack) {
      tabModel.setCanGoBack(true);
    } else if (tabModel.canGoBack && index < 2) {
      tabModel.setCanGoBack(false);
    }
    if (tabModel.canGoForward && index > chat.messages.length - 2) {
      tabModel.setCanGoForward(false);
    } else if (!tabModel.canGoForward && index < chat.messages.length - 1) {
      tabModel.setCanGoBack(true);
    }
  }

  

  onScrollChange(double offset) {
    final currentScrollPosition = offset;
      
    // Check if scrolling down
    final isScrollingDown = !offset.isNegative;

    // Update lastScrollPosition for the next scroll event
    lastScrollPosition = currentScrollPosition;

    if (isScrollingDown && scrollDirection != 'down') {
      scrollDirection = 'down';
      scrollPositionOnDirectionChange = currentScrollPosition;
      workspaceModel.setShowToolbar(false);
    } else if (!isScrollingDown && scrollDirection != 'up') {
      scrollDirection = 'up';
      scrollPositionOnDirectionChange = currentScrollPosition;
      workspaceModel.setShowToolbar(true);
    }

    // if (!reachedScrollThreshold && scrollDirection == 'up') {
    //     final scrollDelta = scrollPositionOnDirectionChange - currentScrollPosition;

    //   if (scrollDelta > scrollThreshold || currentScrollPosition < 5) {

    //     print('up');
    //     workspaceModel.setShowToolbar(true);
    //     reachedScrollThreshold = true;

    //   }
    // }
  }

  TapGestureRecognizer textGestureRecognizer = TapGestureRecognizer();
  Timer? _singleTapTimer;
  Timer? _longPressTimer; 

  int tapCount = 0;

  onTextTapUp(String text) {
    if (tapCount == 1) {
      _longPressTimer?.cancel();
    }
  }

  onTextTapDown(String text) {

    if (tapCount < 3) {
      tapCount += 1;
    } else {
      tapCount = 0;
    }

    if (tapCount == 1) {
      _longPressTimer = Timer(Duration(milliseconds: 2000), () {
        tapCount = 0;
      //workspaceModel.searchSelectedText(text: text)
        Focus.of(context).unfocus();
        workspaceModel
          .createNewTab(
            url: context.read(searchProvider)
              .getExaSearchUrlforResource(prompt: text)
          );
      });
    } else if (tapCount == 2) {
      if (_longPressTimer?.isActive ?? false) {
        _longPressTimer!.cancel();
      }
      if (_singleTapTimer?.isActive ?? false) {
        _singleTapTimer?.cancel();
      }

      messageController.text = 'Explain this further: \n' + text;
      submitMessage();
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
      
      Message newMessage = Message.text(text: messageController.text);

      if (resource.title == null || resource.title!.isEmpty || resource.title == 'New Chat') {
        newMessage.content.add(
            MessageContent(text: '''
              Also provide a short name for this chat and put the text for the name within xml tags at the bottom of the response. Here is an example:)

              <name>
                The name of this chat.
              </name>
            '''),
        );
      }

      newMessage.content.add(
          MessageContent(text: '''
            Also provide suggested follow up prompts and put these prompts in a section with xml tags <prompts></prompts>. Do not answer the prompts. 
            In the prompt section create a list of JSON objects with the fields "name" (the name of the prompt), "text" (the prompt text), "symbol" (an UTF-8 encoding emoji that represents the prompt text)').
            Here is an example:

            <prompts>
              [
                { 
                  "text": "Simplify the explanation of this text, making it accessible to a younger audience.", 
                  "name": "Simplify", 
                  "symbol": "👶"
                },
                {
                  "text": "How does this viewpoint differ from other perspectives on the same issue?", 
                  "name": "Contrast", 
                  "symbol": "⚖️"
                },
                ...
              ]
            </prompts>

          ''')
      );

      resource.chat!.messages.add(newMessage);

      final messages = resource.chat!.messages.map((m) => m.toJson(forRequest: true, basicSchema: true)).toList();

      final response = CompletionResponse(await LLM().mistralChatCompletion(messages: messages, maxTokens: 2000));

      final message = Message.text(
        text: response.text,
        role: Role.assistant,
      );

      if (response.chatName != null && response.chatName!.isNotEmpty) {
        resource.title = response.chatName;
      }

      if (response.prompts.isNotEmpty) {
        tabModel.suggestedPrompts = response.prompts;
      } else {
        tabModel.suggestedPrompts = [];
      }
      
      workspaceModel.extractTagsFromSelectedText(textToUse: response.text);

      setState(() {
        resource.chat!.messages.add(message);
        if (!tabModel.canGoBack) {
          tabModel.setCanGoBack(true);
        }
        tabModel.suggestedPrompts = response.prompts;
        //workspaceModel.saveResource(resource);
        messageController.text = '';
      });

      scrollController.scrollTo(
        index: resource.chat!.messages.length - 1, 
        duration: Duration(milliseconds: 1000)
      );
    }


    onMessageTextChanged(String value) {
      if (value.length == 0 || value.length == 1) {
        setState(() {
          messageController.text;
        });
      }
    }

    List<Resource> questionPrompts = [];
    getQuestions() {
      questionPrompts = workspaceModel.allResources
        .where((r) => r.highlights.any((h) => h.text.contains('?')))
        .toList();
    }

  setMessageText(String text) {
    setState(() {
      messageController.text = text;
    });
  }

  Message? currentThread;
  int get currentIndex {
    if (currentThread == null) return 0;
    return chat.messages.indexWhere((m) => m == currentThread);
  }

  setForwardAndBackFunctions() {

    tabModel.goForwardFunction = () {
      if (tabModel.canGoForward)
      scrollController
        .scrollTo(
          index: currentIndex + 1, 
          duration: Duration(seconds: 1)
        ); 
    };

    tabModel.goBackFunction = () {
      if (tabModel.canGoBack)
      scrollController
        .scrollTo(
          index: currentIndex - 1, 
          duration: Duration(seconds: 1)
        ); 
    };
  }
  
  startSpeechToText(LongPressStartDetails details) async {
    HapticFeedback.mediumImpact();
    final status = await Permission.microphone.status;
    if (!status.isGranted) {
      await Permission.microphone.request();
    }
    await context.read(speechProvider).listen(
      onResult: (result) {
        messageController.text = result.recognizedWords;
      },
      listenFor: const Duration(seconds: 30),
      localeId: "en_En",
    );
  }

  stopSpeechToText(LongPressEndDetails details) async {
    await context.read(speechProvider).stop();
  }
}


class CompletionResponse {
  late String text;
  String? chatName;
  List<Prompt> prompts = [];
  String response;

  CompletionResponse(this.response) {
    parseResponse();
  }

  parseResponse() {
    text = response;
    chatName = extractSectionData('name');
    final promptsString = extractSectionData('prompts');
    if (promptsString != null) {
      prompts = List<Prompt>.from(jsonDecode(promptsString).map((json) => Prompt.fromJson(json)));
    }
  }

  extractSectionData(tagName) {
    String? result;
    final split = text.split('<'+ tagName + '>');
    if (split.length <= 1) return result;
    final startSplit = split[1];
    final endSplit = startSplit.split('</'+ tagName + '>');
    result = endSplit[0];
    text = split[0];
    if (endSplit.length > 1) {
      text += endSplit[1];
    }
    return result;
  }



  

}

class ChatSuggestions {

}