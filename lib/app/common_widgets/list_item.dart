

import 'package:flutter/material.dart';

class ListItem extends StatelessWidget {
  const ListItem({Key? key, required this.icon, required this.title}) : super(key: key);

  final Icon icon;
  final String title;

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
                            color: Colors.white,
                            fontWeight: FontWeight.w400,
                          ),
                        )
                      ),
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