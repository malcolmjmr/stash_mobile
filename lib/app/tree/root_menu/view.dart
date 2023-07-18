import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stashmobile/app/common_widgets/item_count.dart';
import 'package:stashmobile/app/tree/model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RootMenu extends ConsumerWidget {
  final TreeViewModel model;
  RootMenu(this.model);
  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final model = watch(treeViewProvider);
    final textStyle = GoogleFonts.lato(fontSize: 16);
    return Material(
        child: Container(
      height: 200,
      child: Column(
        children: [
          _buildLinkDirectionToggle(context, textStyle, model),
          _buildExpandAll(context, textStyle, model),
          _buildCollapseAll(context, textStyle, model),
          _buildSelectAll(context, textStyle, model),
          _buildUnSelectAll(context, textStyle, model),
          _buildCopyAll(context, textStyle, model),
        ],
      ),
    ));
  }

  Widget _buildLinkDirectionToggle(
    BuildContext context,
    TextStyle textStyle,
    TreeViewModel model,
  ) =>
      model.linkDirection == LinkDirection.forward
          ? GestureDetector(
              onTap: () => model.setLinkDirection(context, LinkDirection.back),
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Icon(Icons.north_west, size: 20),
                  ),
                  Text(
                    'Back links',
                    style: textStyle,
                  ),
                  Padding(
                      padding: const EdgeInsets.all(5.0), child: ItemCount(2)),
                ],
              ),
            )
          : GestureDetector(
              onTap: () =>
                  model.setLinkDirection(context, LinkDirection.forward),
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Icon(
                      Icons.south_east,
                      size: 20,
                    ),
                  ),
                  Text(
                    'Forward links',
                    style: textStyle,
                  )
                ],
              ),
            );

  Widget _buildExpandAll(
    BuildContext context,
    TextStyle textStyle,
    TreeViewModel model,
  ) =>
      GestureDetector(
        onTap: () => model.setExpandAll(true),
        child: Container(
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(5.0),
                child: Icon(Icons.unfold_more, size: 20),
              ),
              Text(
                'Expand all',
                style: textStyle,
              )
            ],
          ),
        ),
      );

  Widget _buildCollapseAll(
    BuildContext context,
    TextStyle textStyle,
    TreeViewModel model,
  ) =>
      GestureDetector(
        onTap: () => model.setExpandAll(false),
        child: Container(
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(5.0),
                child: Icon(Icons.unfold_less, size: 20),
              ),
              Text(
                'Collapse all',
                style: textStyle,
              )
            ],
          ),
        ),
      );

  Widget _buildSelectAll(
    BuildContext context,
    TextStyle textStyle,
    TreeViewModel model,
  ) =>
      Container();

  Widget _buildUnSelectAll(
    BuildContext context,
    TextStyle textStyle,
    TreeViewModel model,
  ) =>
      Container();

  Widget _buildCopyAll(
    BuildContext context,
    TextStyle textStyle,
    TreeViewModel model,
  ) =>
      Container();
}
