import 'package:flutter/material.dart';

import '../../extensions/color.dart';

class SearchField extends StatelessWidget {
  const SearchField({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'search',
      child: Material(
        type: MaterialType.transparency,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 20.0),
          child: Container(
            decoration: BoxDecoration(
              color: HexColor.fromHex('222222'),
              borderRadius: BorderRadius.circular(10.0),
              
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 5.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(Icons.search, size: 25.0,),
                  Text('Search', 
                    style: TextStyle(
                      fontSize: 22, 
                      fontWeight: 
                      FontWeight.w400
                    ),
                  ),
                  
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

}