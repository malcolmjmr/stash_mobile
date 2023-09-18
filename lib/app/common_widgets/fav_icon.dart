import 'package:flutter/material.dart';
import 'package:stashmobile/models/resource.dart';
import 'package:http/http.dart' as http;

class FavIcon extends StatefulWidget {
  const FavIcon({Key? key, required this.resource, this.size = 35}) : super(key: key);
  final double size;
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
        iconUrl = await http.read(Uri.parse(widget.resource.url!));
      }
    } else {
      iconUrl = widget.resource.favIconUrl;
    }
    setState(() {
      isLoaded = true;
    });
    
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadUrl();
  }

  
  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.size,
      width: widget.size,
      child: iconUrl != null 
        ? Image.network(iconUrl!,
          //loadingBuilder: (context, child, loadingProgress) => Icon(Icons.language, size: 30,),
          errorBuilder: (context, child, loadingProgress) => Icon(Icons.public, size: 35,),
        )
        : Icon(Icons.public, size: 35,)
      );
            
  }
}