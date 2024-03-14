import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:stashmobile/app/chat/chat_view_model.dart';
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
      child: Stack(
        children: [
          model.showPromptSuggestions 
            ? _buildPromptScreen()
            : _buildMessages(),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildPromptScreen() {
    return Container();
  }

  Widget _buildMessages() {
    return Container(
      color: Colors.amber,
      child: ListView.builder(
        itemCount: widget.tabModel.resource.chat!.messages.length,
        itemBuilder: (context, index) {
          final message = widget.tabModel.resource.chat!.messages[index];
          return MessageView(message: message,);
        }
      ),
    );
  }

  Widget _buildMessageInput() {
    /*
      if (messages.isEmpty || showFullScreenMessageInput)
    */

    return Container(
      child: Column(
        children: [
          if (model.messageToSend.textSelection != null)
          _buildTextSelection()
          else if (model.messageToSend.resourceId != null)
          _buildResourcePreview()
          else if (model.messageToSend.imageUrl != null)
          _buildImage(),
          Container(
            height: model.showExpandedMessage
              ? MediaQuery.of(context).size.height
              : 60,
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
    return Container(
      child: Row(
        children: [
          Expanded(
            child: Container(
              child: TextField(
                controller: widget.tabModel.messageController,
                autofocus: true,
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
            onTap: widget.tabModel.submitMessage,
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
    );
  }

  _buildPromptSuggestions() {
    return Container(
      height: 50,
      child: ListView.builder(
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        itemCount: widget.tabModel.workspaceModel.selectionPrompts.length,
        itemBuilder: (context, index) {
          final promptName = widget.tabModel.workspaceModel.selectionPrompts[index].name;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Container(
              child: Text(promptName),
            ),
          );
        }
      ),
    );
  }
}


class MessageView extends StatelessWidget {
  const MessageView({Key? key, required this.message}) : super(key: key);

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
      ? HexColor.fromHex('333333') 
      : Colors.black,
    child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        child: message.text  != null
          ? Text(message.text!,
              style: TextStyle(
            
              )
            )
          : message.imageUrl != null
            ? Image.network(message.imageUrl!)
            : Container()
        ),
      ),
    );
  }
}