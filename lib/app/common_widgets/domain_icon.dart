import 'package:flutter/material.dart';
import 'package:stashmobile/extensions/color.dart';
import 'package:stashmobile/models/domain.dart';

class DomainIcon extends StatelessWidget {
  final Function() onTap;
  final Function()? onLongPress;
  final Domain domain;
  final double size;
  const DomainIcon({Key? key,
    required this.domain, 
    required this.onTap, 
    this.onLongPress,
    this.size = 30,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
        child: Container(
          //color: HexColor.fromHex('333333'),
          height: size,
          width: size,
          child: domain.favIconUrl != null 
            ? Image.network(domain.favIconUrl!,
              //loadingBuilder: (context, child, loadingProgress) => Icon(Icons.language, size: 30,),
              errorBuilder: (context, child, loadingProgress) => Icon(Icons.public, size: size,),
            )
            : Icon(Icons.public, size: size,)
          ),
      );
            
  }
  
}