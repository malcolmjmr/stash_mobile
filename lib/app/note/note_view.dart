import 'package:flutter/material.dart';
import 'package:stashmobile/app/note/note_view_model.dart';
import 'package:stashmobile/app/workspace/workspace_view_model.dart';
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
      child: Column(
        children: [
          PageView(
            scrollDirection: Axis.horizontal,
            children: [
              RelatedResources(),
              NoteBody(model: model),
              NoteChat(),
            ],
          ),
         // _buildFooter(),
        ],
      ),
    );
  }
}

class NoteBody extends StatelessWidget {
  const NoteBody({Key? key, required this.model}) : super(key: key);
  final NoteViewModel model;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: TextField(
        controller: model.textController,
        onTapOutside: (e) => model.saveNote(),
        expands: true,
      ),
    );
  }
}

class RelatedResources extends StatelessWidget {
  const RelatedResources({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

class NoteChat extends StatelessWidget {
  const NoteChat({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}