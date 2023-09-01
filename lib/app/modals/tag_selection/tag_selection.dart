import 'package:flutter/material.dart';
import 'package:stashmobile/app/modals/tag_selection/tag_selection_model.dart';
import 'package:stashmobile/models/resource.dart';

class TagSelectionModal extends StatefulWidget {
  final Resource resource;
  const TagSelectionModal({Key? key, required this.resource}) : super(key: key);

  @override
  State<TagSelectionModal> createState() => _TagSelectionModalState();
}

class _TagSelectionModalState extends State<TagSelectionModal> {

  late TagSelectionModel model;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    model = TagSelectionModel(
      context,
      setState,
      resource: widget.resource,
    );
  }
  @override
  Widget build(BuildContext context) {
    /*

      
    */
    return const Placeholder();
  }
}