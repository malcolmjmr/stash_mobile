import 'package:flutter/material.dart';

import '../../extensions/color.dart';

class SearchField extends StatelessWidget {
  const SearchField({Key? key, 
    this.backgroundColor, 
    this.onTap, 
    this.showPlaceholder = false,
    this.onChanged,
    this.onSubmitted,
    }) : super(key: key);

  final Function()? onTap;
  final Function(String value)? onChanged;
  final Function(String value)? onSubmitted;
  final bool showPlaceholder;

  final Color? backgroundColor;
  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'search',
      child: Material(
        type: MaterialType.transparency,
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: 40,
          decoration: BoxDecoration(
            color: backgroundColor != null ? backgroundColor : HexColor.fromHex('222222'),
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 5.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(Icons.search, size: 25.0,),
                Expanded(
                  child: showPlaceholder 
                    ? Text('Search',
                        style: TextStyle(
                          fontSize: 22, 
                          fontWeight: 
                          FontWeight.w400,
                          color: Colors.white
                        ),
                      )
                    : TextField( 
                        style: TextStyle(
                          fontSize: 22, 
                          fontWeight: 
                          FontWeight.w400,
                          color: Colors.white
                        ),
                        onChanged: onChanged,
                        onSubmitted: onSubmitted,
                        onTap: onTap,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.only(bottom: 8, left: 3),
                          border: InputBorder.none,
                          hintStyle: TextStyle(
                            fontSize: 22, 
                            fontWeight: FontWeight.w400,
                            color: Colors.white
                          ),
                          hintText: 'Search'
                        ),
                      ),
                ),
                
              ],
            ),
          ),
        ),
      ),
    );
  }

}