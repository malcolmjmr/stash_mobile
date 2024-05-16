import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:stashmobile/app/home/home_view.dart';
import 'package:stashmobile/app/home/home_view_model.dart';
import 'package:stashmobile/constants/color_map.dart';
import 'package:stashmobile/extensions/color.dart';
import 'package:stashmobile/models/resource.dart';

class ExpandedHighlight extends StatelessWidget {
  const ExpandedHighlight({Key? key, required this.resource, required this.highlightId}) : super(key: key);

  final String highlightId;
  final Resource resource;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            child: Column(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 30),
                    child: Container(
      
                      child: ResourceWithHighlights(resource: resource, isExpanded: true,)
                    ),
                  )
                ),
                _buildFooter(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
      height: 50,
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border(top: BorderSide(color: HexColor.fromHex('555555')))
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildFooterButton(
            //title: 'Explore',
            symbol: Symbols.join_left_rounded,
            onTap: () => context.read(homeViewProvider)
              .createJourneyFromHighlight(context, resource: resource, highlightId: highlightId)
          ),
          _buildFooterButton(
            //title: 'Write',
            symbol: Symbols.edit_note, 
            onTap: () => context.read(homeViewProvider)
              .createNoteFromHighlight(context, resource: resource, highlightId: highlightId)
          ),
          _buildFooterButton(
            //title: 'Chat',
            symbol: Symbols.forum_rounded, 
            onTap: () => context.read(homeViewProvider)
              .createChatFromHighlight(context, resource: resource, highlightId: highlightId)
          ),
          
        ],
      ),
    );
  }

  Widget _buildFooterButton({
    String? title,
    required IconData symbol,
    Function()? onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          child: Padding(
            padding: const EdgeInsets.all(5.0),
            child:  title != null
              ? Text(title, 
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                  ),
                ) 
              : Icon(symbol, size: 30, fill: 1, color: HexColor.fromHex(colorMap['grey']!),),
          ),
        ),
      ),
    );
  }
}