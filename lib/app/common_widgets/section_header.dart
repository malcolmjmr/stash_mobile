import 'package:flutter/material.dart';

class SectionHeader extends StatelessWidget {
  const SectionHeader({Key? key, this.onToggleCollapse, required this.title, this.isCollapsed = false}) : super(key: key);
  final String title;
  final VoidCallback? onToggleCollapse;
  final bool isCollapsed;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          GestureDetector(
            onTap: onToggleCollapse,
            child: Padding(
              padding: const EdgeInsets.all(3.0),
              child: Icon(isCollapsed 
                ? Icons.keyboard_arrow_down 
                : Icons.keyboard_arrow_right,
                //color: Colors.amber,
              ),
            ),
          )
        ],
      ),
      
    );
  }
}