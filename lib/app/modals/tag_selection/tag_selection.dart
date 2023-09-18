import 'package:flutter/material.dart';
import 'package:stashmobile/app/common_widgets/search_field.dart';
import 'package:stashmobile/app/common_widgets/tag.dart';
import 'package:stashmobile/app/modals/tag_selection/tag_selection_model.dart';
import 'package:stashmobile/models/resource.dart';

class TagSelectionModal extends StatefulWidget {
  final Resource resource;
  final Function()? onDone;
  const TagSelectionModal({Key? key, 
    required this.resource,
    this.onDone,
  }) : super(key: key);

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
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Container(
          child: Column(
            children: [
              _buildHeader(),
              _buildSearch(),
              _buildTags(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      child: Padding(
        padding: const EdgeInsets.only(left: 15.0, right: 15,  top: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(width: 30,),
            Text('${model.resource.tags.isNotEmpty ? (model.resource.tags.length.toString() + 'tag') : 'Tags'} ${model.resource.tags.length > 1 ? "s" : ""}',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 20,
              ),
            ),
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Text('Done',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.amber,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildSearch() {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: SearchField(
        hintText: 'Search or create',
        onChanged: (value) => model.updateVisibleTags(value),
        onSubmitted: (value) => model.updateVisibleTags(value),
      ),
    );
  }

  Widget _buildTags() {
    return Container(
      child: Wrap(
        children: model.visibleTags.map((tag) {
          return TagChip(tag: tag);
        }).toList(),
      ),
    );
  }
}