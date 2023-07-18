import 'package:flutter/material.dart';
import 'package:stashmobile/models/user/model.dart';

class UserIcon extends StatelessWidget {
  final User user;
  final Function()? onTap;
  final Function()? onLongPress;
  final double opacity;
  final EdgeInsets padding;
  final Border? border;
  UserIcon(
    this.user, {
    this.onTap,
    this.onLongPress,
    this.opacity = 1,
    this.padding = const EdgeInsets.all(8.0),
    this.border,
  });
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: GestureDetector(
        onTap: onTap,
        onLongPress: onLongPress,
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: border,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(45),
            child: Opacity(
              opacity: opacity,
              child: user.imageUrl != null
                  ? Image.network(user.imageUrl!)
                  : Icon(Icons.person),
            ),
          ),
        ),
      ),
    );
  }
}
