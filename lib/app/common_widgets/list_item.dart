

import 'package:flutter/material.dart';

class ListItem extends StatelessWidget {
  const ListItem({Key? key, 
    required this.icon, 
    required this.title,
    this.showSubItems = false,
    this.textColor = Colors.white,
  }) : super(key: key);

  final Icon icon;
  final String title;
  final Color textColor;
  final bool showSubItems;

  @override
  Widget build(BuildContext context) {
    return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: icon,
              ),
              Expanded(
                child: Container(
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Expanded(
                        child: Text(title, 
                          style: TextStyle(
                            fontSize: 20,
                            overflow: TextOverflow.ellipsis,
                            color: textColor,
                            fontWeight: FontWeight.w400,
                          ),
                        )
                      ),
                      if (showSubItems)
                      const Icon(Icons.arrow_forward_ios, 
                        size: 16.0, 
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ),
              
            ],
          ),
        );
  }
}