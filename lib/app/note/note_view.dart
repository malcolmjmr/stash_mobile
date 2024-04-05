import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stashmobile/app/chat/chat_view.dart';
import 'package:stashmobile/app/common_widgets/tag.dart';
import 'package:stashmobile/app/note/note_view_model.dart';
import 'package:stashmobile/app/workspace/resource_list_item.dart';
import 'package:stashmobile/app/workspace/workspace_view_model.dart';
import 'package:stashmobile/extensions/color.dart';
import 'package:stashmobile/models/note.dart';
import 'package:stashmobile/models/resource.dart';

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
  Widget build(BuildContext context) {
    
    return Container(
      child: PageView(
        controller: model.pageController,
        scrollDirection: Axis.horizontal,
        children: [
          RelatedResources(model: model,),
          NoteBody(model: model),
          ChatView(tabModel: model.tabModel,),
        ],
        onPageChanged: model.onPageChanged,
      ),
    );
  }
}

class NoteBody extends StatelessWidget {
  const NoteBody({Key? key, required this.model}) : super(key: key);
  final NoteViewModel model;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 15, right: 15),
          child: Container(
            child: TextField(
              controller: model.textController,
              maxLines: null,
              expands: true,
              //onTapOutside: (e) => model.saveNote(),
              onTap: () => model.onTextFieldTapped(),
              //selectionControls: CupertinoTextSelectionControls().,
              
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'What do you want to write about?'
              ),
              style: TextStyle(
                fontSize: 18
              ),
            ),
          ),
        ),
        _buildToolbar(),
      ],
    );
  }

  Widget _buildToolbar() {
    /*

    */
    return Container();
  }

  Widget _buildSelectionMenu() {
    return Container(
      child: Row(
        children: [
          /*
            copy
            create note
            explain
            critique
            
          */
          
        ],
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