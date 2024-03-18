import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:stashmobile/app/chat/chat_view_model.dart';
import 'package:stashmobile/app/chat/default_prompts.dart';
import 'package:stashmobile/app/modals/text_selection/text_selection_modal.dart';
import 'package:stashmobile/app/web/tab_model.dart';
import 'package:stashmobile/extensions/color.dart';
import 'package:stashmobile/models/chat.dart';

class ChatView extends StatefulWidget {
  const ChatView({Key? key, required this.tabModel}) : super(key: key);

  final TabViewModel tabModel;

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {

  late ChatViewModel model;

  @override
  void initState() {

    super.initState();

    model = ChatViewModel(
      setState: setState,
      context: context,
      tabModel: widget.tabModel,
    );
    
  }

  @override
  Widget build(BuildContext context) {
    /*
      messages
      inputModal
        prompts
        textField


      Stack
        messages
        messageInput
          selectedText
          textField
          promptSuggestions
        
    */

    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      color: Colors.black,
      child: Stack(
        children: [
          GestureDetector(
            onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
            child: model.chat.messages.isEmpty 
              ? _buildBackground() // _buildPromptScreen()
              : _buildMessages(),
          ),
          if (!model.workspaceModel.showTextSelectionMenu)
          Positioned(
            child: _buildMessageInput(), 
            bottom: 0,
          ),
        ],
      ),
    );
  }

  Widget _buildBackground() {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: Center(
        child: Container(
          height: 100,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(Symbols.forum_rounded, fill: 0, size: 50,),
              ),
              Text('New Chat',
                style: TextStyle(
                  fontSize: 24,
                )
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPromptScreen() {

    return Container(
      child: Wrap(
        children: defaultPrompts.map((prompt) {
          return GestureDetector(
            onTap: () => model.sendMessageWithPrompt(prompt),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: HexColor.fromHex('222222')
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(prompt.symbol ?? prompt.name),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMessages() {
    final messages = widget.tabModel.resource.chat!.messages;
    return Container(
      //color: Colors.amber,
      width: MediaQuery.of(context).size.width,
      child: ListView.builder(
        itemCount: messages.length + 1,
        itemBuilder: (context, index) {
          
          if (index == messages.length) {
            return Padding(padding: EdgeInsets.only(bottom: 100));
          }
          final message = messages[index];
          return MessageView(message: message, model: model,);
        }
      ),
    );
  }

  Widget _buildMessageInput() {
    /*
      if (messages.isEmpty || showFullScreenMessageInput)
    */

    //model.showExpandedMessage = false;

    return Container(
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border(top: BorderSide(color: HexColor.fromHex('222222')))
      ),
      child: Column(
        children: [
          if (model.messageToSend.textSelection != null)
          _buildTextSelection()
          else if (model.messageToSend.resourceId != null)
          _buildResourcePreview()
          else if (model.messageToSend.imageUrl != null)
          _buildImage(),
          if (model.chat.messages.isNotEmpty)
          _buildPromptSuggestions(),
          Container(
            child: _buildInputField()
          ),
        ],
      ),
    );
  }

  Widget _buildTextSelection() {
    return Container();
  }

  Widget _buildResourcePreview() {
    return Container();
  }

  Widget _buildImage() {
    return Container();
  }

  Widget _buildExpandedMessageInput() {
    return Container();
  }

  Widget _buildCollapsedMessageInput() {
    return Container();
  }

  Widget _buildInputToolbar() {
    return Container(
      height: 115,
      child: Padding(
        padding: EdgeInsets.all(8),
        child: Column(
          children: [
            _buildPromptSuggestions(),
            _buildInputField(),
          ],
        ),
      )
    );
  }

  _buildInputField() {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, bottom: 8, right: 8),
      child: Container(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Container(
                child: TextField(
                  controller: model.messageController,
                  autofocus: true,
                  maxLines: null,
                  decoration: InputDecoration(
                    hintText: 'Enter message',
                    border: InputBorder.none,
                    
                  ),
                  
                  onChanged: (value) {
                    widget.tabModel.messageText = value;
                  },
                  // onSubmitted: (value) {
                  //   tabModel.submitMessage(value);
                  // },
                )
              ),
            ),
            GestureDetector(
              onTap: model.submitMessage,
              child: Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100),
                    color: HexColor.fromHex(widget.tabModel.workspaceModel.workspaceHexColor),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Icon(Symbols.arrow_upward_alt_rounded,
                      color: Colors.black,
                    
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  _buildPromptSuggestions() {
    
    return Container(
      height: 45,
      width: MediaQuery.of(context).size.width,
      child: Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: ListView.builder(
          shrinkWrap: true,
          scrollDirection: Axis.horizontal,
          itemCount: defaultPrompts.length,
          itemBuilder: (context, index) {
            final prompt =  defaultPrompts[index];
            return GestureDetector(
              onTap: () {
                model.messageController.text = prompt.text;
              },
              onLongPress: () => model.sendMessageWithPrompt(prompt),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: HexColor.fromHex('222222'),
                      borderRadius: BorderRadius.circular(8)
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 5),
                      child: Text(prompt.symbol ?? prompt.name,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                      
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }
        ),
      ),
    );
  }
}


class MessageView extends StatelessWidget {
  const MessageView({Key? key, required this.message, required this.model}) : super(key: key);

  final ChatViewModel model;
  final Message message;

  /*

    incorporate quotes, reference, image i

  */
  @override
  Widget build(BuildContext context) {
    if (message.role == Role.system) {
      return Container();
    }
  return Container(
    color: message.role == Role.assistant 
      ? HexColor.fromHex('222222') 
      : Colors.black,
    child: Padding(
      padding: const EdgeInsets.all(15.0),
      child: Container(
        decoration: message.textSelection != null 
          ? BoxDecoration(border: Border(left: BorderSide(color: HexColor.fromHex('444444'), width: 5)))
          : null,
        child: Padding(
          padding: message.textSelection != null 
            ? EdgeInsets.only(left: 8) 
            : EdgeInsets.all(0),
          child: message.text  != null
            ? SelectableText(message.text!,
              onSelectionChanged: (selection, cause) => model.onSelectionChanged(message.text!, selection, cause),
              style: TextStyle(
                  fontSize: 16
                )
              )
            : message.imageUrl != null
              ? Image.network(message.imageUrl!)
              : Container(),
        )
        ),
      ),
    );
  }
}


