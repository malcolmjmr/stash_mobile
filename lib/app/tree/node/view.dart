import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stashmobile/app/common_widgets/content_icon/view.dart';
import 'package:stashmobile/app/scent/colors.dart';

import 'package:stashmobile/app/tree/model.dart';

import 'package:stashmobile/models/content/content.dart';

import 'model.dart';

class TreeNodeView extends StatefulWidget {
  final TreeNodeViewModel model;

  TreeNodeView({required this.model, required Key key}) : super(key: key);

  @override
  _TreeNodeViewState createState() => _TreeNodeViewState();
}

class _TreeNodeViewState extends State<TreeNodeView> {
  late TreeNodeViewModel model;
  late TreeViewModel screenModel;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    model = widget.model;
    screenModel = context.read(treeViewProvider);
    isFocus = screenModel.focus?.content.id == model.content.id;
    model.isSelected =
        screenModel.selected.any((node) => node.content.id == model.content.id);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        //_buildDividerDragTarget(),
        model.isDraggable ? _buildDraggableBody() : _buildObjectBody(),
        // model.isLastChild
        //     ? _buildDividerDragTarget(isBelow: true)
        //     : Container(),
      ],
    );
  }

  Widget _buildDividerDragTarget() => DragTarget<Content>(
        onWillAccept: (draggedContent) =>
            draggedContent?.id != model.content.id,
        onAccept: (draggedContent) => null,
        builder: (context, candidates, rejects) => Container(
          height: 5,
          decoration: BoxDecoration(
            border: Border(
                bottom: BorderSide(
                    width: 3,
                    color: candidates.isNotEmpty
                        ? Theme.of(context).highlightColor
                        : Theme.of(context).primaryColorDark)),
          ),
        ),
      );

  Widget _buildObjectBody() => Column(
        children: [
          _buildContentHeading(),
          model.showChildren ? _buildChildren(context) : Container(),
        ],
      );

  Widget _buildDraggableBody() => Draggable<Content>(
        data: model.content,
        child: _buildObjectBody(),
        feedback: Material(
          color: Colors.transparent,
          child: Container(
            width: MediaQuery.of(context).size.width,
            child: Opacity(opacity: .7, child: _buildContentHeading()),
          ),
        ),
        childWhenDragging: Container(),
      );

  Widget _buildContentHeading() => Container(
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildIcon(),
                Expanded(
                  child: IntrinsicHeight(
                    child: Row(
                      children: [
                        Expanded(child: _buildTitle()),
                        _buildPriority(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            _buildListItemBody(),
            _buildListItemAttributes(),
          ],
        ),
      );

  Widget _buildIcon() => model.isDraggable
      ? GestureDetector(
          onLongPress: () => setState(() => model.isDraggable = false),
          child: Row(
            children: [
              Icon(
                Icons.drag_indicator_sharp,
                size: 10,
              ),
              ContentIcon(model.content),
            ],
          ))
      : GestureDetector(
          onDoubleTap: () =>
              setState(() => model.content.isOpen = !model.isOpen),
          onLongPress: () => setState(() => model.isDraggable = true),
          child: Row(
            children: [
              Container(width: 10),
              Stack(
                children: [
                  ContentIcon(model.content),
                  !model.showChildren && model.children.length > 0
                      ? Positioned(
                          bottom: 1,
                          right: 5,
                          child: Container(
                            height: 5,
                            width: 5,
                            decoration: BoxDecoration(
                              color: Colors.orange,
                              shape: BoxShape.circle,
                            ),
                          ))
                      : Container()
                ],
              ),
            ],
          ),
        );

  bool isFocus = false;
  //final focusTextStyle;
  Widget _buildTitle() {
    final focusTextStyle = GoogleFonts.lato(fontSize: 14);
    final textStyle = focusTextStyle.copyWith(
        color: Theme.of(context).primaryTextTheme.displayLarge!.color);
    return screenModel.focus == model
        ? Stack(
            children: [
              model.searchResults.isNotEmpty
                  ? Text(model.searchResults.first.title, style: textStyle)
                  : Container(),
              TextField(
                autofocus: true,
                controller: model.textController,
                style: focusTextStyle,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintStyle:
                      GoogleFonts.lato(color: Theme.of(context).disabledColor),
                  hintText: model.hintText,
                  isCollapsed: true,
                ),
                keyboardType: TextInputType.text,
                maxLines: null,
                onChanged: (text) => model.content.type == ContentType.empty
                    ? setState(() {
                        model.onSearchChanged(context, text);
                      })
                    : null,
                onSubmitted: (text) => setState(() {
                  model.onSubmitText(context, text);
                }),
              ),
            ],
          )
        : GestureDetector(
            onTap: () => model.onTapTitle(context),
            onLongPress: () => model.onLongPressTitle(context),
            onDoubleTap: () => model.onDoubleTapTitle(context),
            onHorizontalDragEnd: (details) =>
                model.onHorizontalDragEnd(context, details),
            child: Text(
              model.content.title,
              maxLines: model.content.isOpen == true ? null : 3,
              overflow:
                  model.content.isOpen == true ? null : TextOverflow.ellipsis,
              style: model.isSelected ? focusTextStyle : textStyle,
            ),
          );
  }

  Widget _buildPriority() => model.showPriority
      ? Padding(
          padding: const EdgeInsets.only(right: 2.0),
          child: Container(
            width: 4,
            color: PriorityColors.getColorFromPriority(
              model.content.ratings?.value ?? 0,
            ),
          ),
        )
      : Container();

  Widget _buildListItemBody() => Container();

  Widget _buildListItemAttributes() => Container();

  Widget _buildChildren(BuildContext context) => Padding(
        padding: const EdgeInsets.only(left: 20),
        child: Column(
          children: model.children
              .map((child) => TreeNodeView(
                    key: ValueKey(child.content.id),
                    model: child,
                  ))
              .toList(),
        ),
      );
}
