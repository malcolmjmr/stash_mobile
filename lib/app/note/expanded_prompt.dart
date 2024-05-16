import 'package:flutter/material.dart';
import 'package:stashmobile/models/resource.dart';

class ExpandedPrompt extends StatelessWidget {
  const ExpandedPrompt({Key? key, required this.resource, required this.highlightId, required this.color}) : super(key: key);

  final Resource resource;
  final String highlightId;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final highlight = resource.highlights.firstWhere((h) => h.id == highlightId);
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: GestureDetector(
          //onTap: () => Navigator.pop(context),
          child: Container(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 30),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: color,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SelectableText(highlight.text,
                    onSelectionChanged: (selection, change) => null,
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.black,
                    ),
                  ),
                )
              ),
            ),
          ),
        ),
      ),
    );
  }

  
}