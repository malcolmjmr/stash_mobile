import 'package:flutter/material.dart';
import 'package:stashmobile/models/resource.dart';

class FavIcon extends StatefulWidget {
  const FavIcon({Key? key, required this.resource}) : super(key: key);
  final Resource resource;
  @override
  State<FavIcon> createState() => _FavIconState();
}

class _FavIconState extends State<FavIcon> {

  bool isLoaded = false;

  String? iconUrl;

  loadUrl() async {
    if (widget.resource.favIconUrl == null) {
      if (widget.resource.url != null) {
        //iconUrl = await 
      }
      
    } else {

    }
    setState(() {
      isLoaded = true;
    });
    
  }

  
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 35,
      width: 35,
      child: iconUrl != null 
        ? Image.network(iconUrl!,
          //loadingBuilder: (context, child, loadingProgress) => Icon(Icons.language, size: 30,),
          errorBuilder: (context, child, loadingProgress) => Icon(Icons.public, size: 35,),
        )
        : Icon(Icons.public, size: 35,)
      );
            
  }
}