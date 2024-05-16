import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:page_transition/page_transition.dart';
import 'package:stashmobile/app/chat/chat_view.dart';
import 'package:stashmobile/app/common_widgets/tag.dart';
import 'package:stashmobile/app/home/expanded_highlight.dart';
import 'package:stashmobile/app/note/bottom_panel.dart';
import 'package:stashmobile/app/note/expanded_prompt.dart';
import 'package:stashmobile/app/note/note_view_model.dart';
import 'package:stashmobile/app/workspace/resource_list_item.dart';
import 'package:stashmobile/app/workspace/workspace_view_model.dart';
import 'package:stashmobile/extensions/color.dart';
import 'package:stashmobile/models/note.dart';
import 'package:stashmobile/models/resource.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';

class NoteView extends StatefulWidget {

  /*
    
  */
  const NoteView({Key? key, required this.resource, required this.workspaceModel}) : super(key: key);
  final Resource resource;
  final WorkspaceViewModel workspaceModel;
  
  @override
  State<NoteView> createState() => _NoteViewState();
}

class _NoteViewState extends State<NoteView> {

  late NoteViewModel model;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    model = NoteViewModel(
      context: context,
      setState: setState,
      resource: widget.resource,
      workspaceModel: widget.workspaceModel
    );
  }

  @override
  void dispose() {

    model.dispose();
    super.dispose();

  }

  @override
  Widget build(BuildContext context) {
    
    return Container(
      child: NoteBody(model: model,)
      // child: PageView(
      //   controller: model.pageController,
      //   scrollDirection: Axis.horizontal,
      //   children: [
      //     RelatedResources(model: model,),
      //     NoteBody(model: model),
      //     //ChatView(tabModel: model.tabModel,),
      //   ],
      //   onPageChanged: model.onPageChanged,
      // ),
    );
  }
}

class NoteBody extends StatelessWidget {
  const NoteBody({Key? key, required this.model}) : super(key: key);
  final NoteViewModel model;

  @override
  Widget build(BuildContext context) {

    return KeyboardVisibilityBuilder(
      builder: (context, keyboardIsVisible) {

        if (model.keyboardIsVisible && !keyboardIsVisible && model.needToSave) {
          model.saveNote();
        } 
        model.keyboardIsVisible = keyboardIsVisible;
        if (keyboardIsVisible && model.bottomPanelType != null) {
          model.bottomPanelType = null;
          model.selectedText = null;
        }
        if (model.keyboardHeight == 0) {
          model.keyboardHeight = View.of(context).viewInsets.bottom;
        }

        final toolbarHeight =  (keyboardIsVisible ? 80 : 50) / MediaQuery.of(context).size.height;
        final bottomPanelList = model.bottomPanelListItems;

        return Container(
          height: MediaQuery.of(context).size.height,
          color: Colors.black,
          child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child: Container(
                height: MediaQuery.of(context).size.height, // - (MediaQuery.of(context).viewInsets.bottom + MediaQuery.of(context).viewPadding.bottom),
                width: MediaQuery.of(context).size.width,
                child: Stack(
                  children: [
                    if ((model.prompt != null || model.highlightPrompt != null) && !model.transcribed)
                    _buildPrompt(context),
                    _buildTextField(context, keyboardIsVisible),
                  ],
                ),
              ),
            ),
            if (keyboardIsVisible || model.bottomPanelType != null)
            DraggableScrollableSheet(
              minChildSize: keyboardIsVisible ? toolbarHeight : .25 ,
              initialChildSize: keyboardIsVisible ? toolbarHeight : .5,
              //snap: true,
              //snapSizes: keyboardIsVisible ? null : [toolbarHeight, .5, 1.0],
              maxChildSize: keyboardIsVisible ? toolbarHeight : 1,
              //snap: true,
              builder: (context, scrollController) {
                if (model.bottomPanelScrollController == null) {
                  model.setBottomPanelScrollController(scrollController);
                }
                return Column(
                  children: [
                    //_buildToolbar(context),
                    Expanded(
                      child: CustomScrollView(
                        controller: scrollController,
                        slivers: [
                          SliverAppBar(
                            title: Container(
                              color: Colors.black,
                              child: _buildToolbar(context),
                            ),
                            automaticallyImplyLeading: false,
                            pinned: true,
                            leadingWidth: 0,
                            leading: null,
                            toolbarHeight: 52,
                            titleSpacing: 0,
                            backgroundColor: Colors.black,
                            shadowColor: Colors.black,
                            //foregroundColor: Colors.black,
                            surfaceTintColor: Colors.black,
                          ),
                      
                          if (model.bottomPanelType != null) 
                          SliverToBoxAdapter(child: _buildBottomPanel())
                          // SliverList.builder(
                            
                          //   itemCount: bottomPanelList.length,
                          //   itemBuilder: (context, index) {
                          //     final text = bottomPanelList[index];
                          //     return BottomPanelListItem(
                          //       text: text, 
                          //       isSelected: text == model.selectedText,
                          //       onTap: () => model.setSelectedText(text),
                          //       onDoubleTap: () => null,
                          //     );
                          //   }
                          // ),
                          
                        ],
                      ),
                    ),
                  ],
                );
              }
            ),
            
          ],
        ),
        );
      }
    );
  }


  Widget _buildTextField(BuildContext context, bool keyboardIsVisible) {

   
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Container(
        //color: Colors.black,
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height - (keyboardIsVisible ? 295 : 0), // - (MediaQuery.of(context).viewInsets.bottom + MediaQuery.of(context).viewPadding.bottom) ,
        child: QuillProvider(
          configurations: QuillConfigurations(
            controller: model.quillController,
          ),
          child: QuillEditor(
            scrollController: model.scrollController,
            focusNode: model.focusNode,
            configurations: QuillEditorConfigurations(
              readOnly: false,
              //scrollable: false,
              autoFocus: model.tabModel.loaded, 
              //placeholder: 'What\'s on your mind?',
              keyboardAppearance: Brightness.dark,
              floatingCursorDisabled: true,
              customStyles: DefaultStyles(
                paragraph: DefaultTextBlockStyle(
                  TextStyle(
                    color: Colors.white,
                    fontWeight:
                        FontWeight.w500,
                    fontSize: 18,
                    letterSpacing: 0.5,
                    height: 1.2
                  ),
                  VerticalSpacing(0, 0),
                  VerticalSpacing(0, 0),
                  null
                ),
              ),
            ),
          ),
        )
        // child: TextField(
        //   focusNode: model.focusNode,
        //   autofocus: model.tabModel.loaded,
        //   controller: model.textController,
        //   maxLines: null,
        //   expands: true,
        //   //onTapOutside: (e) => model.saveNote(),
        //   onTap: () => model.onTextFieldTapped(),
        //   //selectionControls: CupertinoTextSelectionControls().,
        //   onChanged: model.onTextChanged,
        //   decoration: InputDecoration(
        //     border: InputBorder.none,
        //     hintMaxLines: 5,
        //     hintText: (model.prompt ?? model.highlightPrompt) 
        //       != null ? 'What about this speaks to you?' 
        //       : 'Start writing...'
        //   ),
        //   style: TextStyle(
        //     fontSize: 18
        //   ),
        // ),
      ),
    );
  }

  Widget _buildPrompt(BuildContext context) {
    final text = model.prompt ?? model.highlightPrompt!.summary ?? model.highlightPrompt!.text;
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Container(
        // decoration: BoxDecoration(
        //   color: HexColor.fromHex(model.workspaceModel.workspaceHexColor),
        //   borderRadius: BorderRadius.circular(10)
        // ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0.0),
          child: Text(text,
            maxLines: 200,
            //overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 18,
              color: Colors.white30,
              fontWeight: FontWeight.w500,
              overflow: TextOverflow.ellipsis,
              letterSpacing: 0.5,
              height: 1.2
              
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildToolbar(BuildContext context) {
    /*

      continuation
      suggestion
      question
      format
      topics
      checklist
      speech to text
    */
    
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: HexColor.fromHex('333333')),
          bottom: BorderSide(color: HexColor.fromHex('333333'))
        )
      ),
      child: model.selectedText != null 
        ? _buildSelectionToolbar()
        : Column(
          children: [
            if (model.selectedSuggestions.isNotEmpty)
            _buildSelectedSuggestions(),
            _buildToolbarActions(context)
          ],
        ),
    );
  }

  Widget _buildSelectedSuggestions() {
    
    return Container(
      height: 130,
      child: PageView(
        scrollDirection: Axis.horizontal,
        children: model.selectedSuggestions.map((suggestion) {
          return GestureDetector(
            onTap: () => model.toggleSuggestionSelection(suggestion),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 5),
              child: Container(
                width: MediaQuery.of(model.context).size.width ,
                decoration: BoxDecoration(
                  color: HexColor.fromHex(model.tabModel.workspaceModel.workspaceHexColor),
                  borderRadius: BorderRadius.circular(10)
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(suggestion,
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w600
                    ),
                  
                  ),
                ),
              ),
            ),
          );
        }).toList()
      ),
    );
  }

  Widget _buildToolbarActions(BuildContext context) {

    return Container(
      
      width: MediaQuery.of(context).size.width,
      height: 50,
      child: Row(
        children: [
          Expanded(
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildActionButton(
                  title: 'Continue',
                  onTap: model.continueText,
                  icon: Symbols.text_select_move_forward_character_rounded,
                ),
                _buildActionButton(
                  title: 'Suggest',
                  onTap: () => model.generateSuggestions(),
                  icon: Symbols.tooltip_rounded,
                ),
                _buildActionButton(
                  title: 'Question',
                  onTap: model.generateQuestions,
                  icon: Symbols.question_mark_rounded,
                ),
                _buildActionButton(
                  title: 'Task List',
                  onTap: model.toggleTask,
                  icon: Symbols.task_alt_rounded,
                ),
                _buildActionButton(
                  title: 'Format',
                  onTap: model.openFormatModal,
                  icon: Symbols.text_format_rounded,
                ),
                _buildActionButton(
                  title: 'Related',
                  onTap: model.showRelated,
                  onDoubleTap: () =>  model.searchSelectedText(),
                  icon: Symbols.join_left_rounded,
                ),
            
                _buildActionButton(
                  title: 'Stash',
                  onTap: model.stashText,
                  icon: Symbols.move_to_inbox_rounded,
                ),
                _buildActionButton(
                  title: 'Compress',
                  onTap: model.compressText,
                  icon: Symbols.compress_rounded,
                ),
                _buildActionButton(
                  title: 'Expand',
                  onTap: model.expandText,
                  icon: Symbols.expand_rounded
                ),
                _buildActionButton(
                  title: 'Style',
                  onTap: model.styleText,
                  icon: Symbols.format_paint
                ),
                _buildActionButton(
                  title: 'More',
                  //onTap: model.styleText,
                  icon: Symbols.tune_rounded,
                ),
                
              ],
            ),
            
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(left: BorderSide(color: HexColor.fromHex('333333')))
            ),
            child: Row(
              children: [
                  _buildActionButton(
                  title: 'Speak',
                  onTap: () => null,
                  icon: Symbols.mic_rounded
                ),
                KeyboardDismisser(
                  child: _buildActionButton(
                    title: 'Keyboard',
                    icon: Symbols.keyboard_hide_rounded,
                    // onTap: () {
                    //   model.workspaceModel.setShowToolbar(true);
                    // }
                  ),
                ),
              ]
            ),
          )
        ],
      ),
    );
  }

  Widget _buildBottomPanel() {
    /*

        title: 'Suggest',
        title: 'Question',
        title: 'Format',
        title: 'Related',
        title: 'Stash',

    */
    Widget view;
    if (model.bottomPanelType == BottomPanelType.format) {
      view = _buildFormatPanel();
    } else if (model.bottomPanelType == BottomPanelType.question) {
      view = _buildQuestionPanel();
    } else if (model.bottomPanelType == BottomPanelType.suggest) {
      view = _buildSuggestionPanel();
    } else if (model.bottomPanelType == BottomPanelType.related) {
      view = _buildRelatedPanel();
    } else if (model.bottomPanelType == BottomPanelType.stash) {
      view = _buildStashPanel();
    } else {
      view = Container();
    }

    return Container(
      height: MediaQuery.of(model.context).size.height,
      width: MediaQuery.of(model.context).size.width,
      child: Column(
        children: [
          Expanded(child: view),
          if (model.selectedText != null)
          _buildSelectionToolbar()
        ],
      ),
    );
  }

  Widget _buildFormatPanel() {
    return Container(
      child: Center(
        child: Text(
          'Format Text'
        )
      ),
    );
  }

  Widget _buildQuestionPanel() {
    return Container(
      child: ListView.builder(
        itemCount: model.questions.length,
        itemBuilder: (context, index) {
          final text = model.questions[index];
          return BottomPanelListItem(
            text: text, 
            isSelected: text == model.selectedText,
            onTap: () => model.setSelectedText(text),
            onDoubleTap: () => null,
          );
        }
      ),
    );
  }

  Widget _buildSuggestionPanel() {
    return Container(
      height: 250,
      width: MediaQuery.of(model.context).size.width,
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: HexColor.fromHex('333333')))
      ),
      //width: MediaQuery.of(xo),
      child: ListView.builder(
        itemCount: model.suggestions.length,
        itemBuilder: (context, index) {
          final text = model.suggestions[index];
          return BottomPanelListItem(
              text: text, 
              isSelected: text == model.selectedText,
              onTap: () => model.setSelectedText(text),
              //onDoubleTap: () => null,
            );
        }
      ),
    );
  }

  Widget _buildRelatedPanel() {
    return Container(
      child: ListView.builder(
        itemCount: model.relatedResources.length,
        itemBuilder: (context, index) {
          final Resource resource = model.relatedResources[index];
          final highlight = resource.highlights.firstWhereOrNull((h) => model.keywords.any((k) => h.text.contains(k.substring(0, min(4, k.length)))))?.text;
          if (highlight == null) {
            return Container();
          } else {
            return BottomPanelListItem(
              text: highlight, 
              isSelected: highlight == model.selectedText,
              onTap: () => model.setSelectedText(highlight),
              //onDoubleTap: () => null,
            );
          
          }
          
        }
      ),
    );
  }

  Widget _buildStashPanel() {
    return Container(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: HexColor.fromHex('222222')))
      ),
      child: ListView.builder(
        itemCount: model.stashedText.length,
        itemBuilder: (context, index) {
          final text = model.stashedText[index];
          return BottomPanelListItem(
              text: text, 
              isSelected: text == model.selectedText,
              onTap: () => model.setSelectedText(text),
              //onDoubleTap: () => null,
          );
        }
      ),
    );
  }

  Widget _buildSelectionToolbar() {

    
    return Container(
      width: MediaQuery.of(model.context).size.width,
      decoration: BoxDecoration(
        color: Colors.black,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Container(
          height: 50,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildActionButton(
                title: 'Add to note',
                onTap: () {
                  model.addText(model.selectedText!);
                },
                icon: Symbols.text_select_move_up_rounded,
              ),
              _buildActionButton(
                title: 'Search',
                onTap: () {
                  model.workspaceModel.searchSelectedText(text: model.selectedText, openInNewTab: true);
                  model.setSelectedText(null);
                },
                icon: Symbols.travel_explore_rounded,
              ),
              _buildActionButton(
                title: 'Open',
                onTap: () {
                  
                  model.workspaceModel.createNewTab(
                    resource: model.relatedResources
                      .firstWhere((r) => r.highlights.any((h) => h.text == model.selectedText))
                  );
                  model.setSelectedText(null);
                } ,
                icon: Symbols.open_in_new_rounded,
              ),
              _buildActionButton(
                title: 'Copy',
                onTap: () => null,
                icon: Symbols.content_copy,
              ),
              _buildActionButton(
                title: 'Move to top',
                onTap: () => null,
                icon: Symbols.priority_high_rounded
              ),
             
              
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    Function()? onTap,
    Function()? onDoubleTap,
    Function()? onLongPress,
    String? title,
    String? emoji,
    IconData? icon,
    double fill = 1,

 
  }) {
    return GestureDetector(
      onTap: onTap,
      onDoubleTap: onDoubleTap,
      onLongPress: onLongPress,
      child: Padding(
        padding: const EdgeInsets.only(top: 8, bottom: 8.0, left: 10, right: 15),
        child: emoji != null
          ? Text(emoji)
          : Icon(icon,
            fill: fill
          ),
      ),
    );
  }

}



class RelatedResources extends StatelessWidget {
  const RelatedResources({Key? key, required this.model}) : super(key: key);
  final NoteViewModel model;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: _buildHeader(),
          ), 
          SliverToBoxAdapter(
            child: _buildTerms(),
          ),
          SliverList.builder(
            itemCount: model.visibleResources.length,
            itemBuilder: (context, index) {
              final resource = model.visibleResources[index];
              return ResourceListItem(
                model: model.workspaceModel, 
                resource: resource, 
                onTap: () => model.workspaceModel.createNewTab(resource: resource),
              );
            }
          )
          // header
          // selected terms
          // results
        ],
      ),
    );
  }

  _buildHeader() {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: HexColor.fromHex('222222')))
      ),
      child: Row(
        children: [
          Text('Related Resources',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w600
            ),
          )
          
        ],
      ),
    );
  }

  _buildTerms() {
    return Container(
      child: Wrap(
        children: model.visibleTags.map((tag) {
          return TagChip(
            tag: tag,
            isSelected: tag.isSelected,
            onTap: () => model.toggleTagSelection(tag),
          );
        }).toList(),
      ),
    );
  }
}

class NoteChat extends StatelessWidget {
  const NoteChat({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
