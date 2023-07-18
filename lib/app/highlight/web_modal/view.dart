import 'package:flutter/material.dart';

class WebAnnotationModal extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Material(
      child: ConstrainedBox(
        constraints: BoxConstraints(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildMenuItem(
              icon: Icons.edit,
              title: 'Add note',
            ),
            _buildMenuItem(
              icon: Icons.style_outlined,
              title: 'Add tags',
            ),
            _buildMenuItem(
              icon: Icons.priority_high,
              title: 'Add priority level',
            ),
            _buildMenuItem(
              icon: Icons.alarm,
              title: 'Add reminder',
            ),
            _buildMenuItem(
              icon: Icons.public,
              title: 'Share',
            ),
            _buildMenuItem(
              icon: Icons.delete,
              title: 'Delete',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    Function()? onTap,
    required IconData icon,
    required String title,
  }) =>
      GestureDetector(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Opacity(
                  child: Icon(icon),
                  opacity: 0.6,
                ),
              ),
              Text(title)
            ],
          ),
        ),
      );
}
