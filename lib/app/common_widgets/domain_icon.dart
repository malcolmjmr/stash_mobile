import 'package:flutter/material.dart';
import 'package:stashmobile/extensions/color.dart';
import 'package:stashmobile/models/domain.dart';

class DomainIcon extends StatelessWidget {
  final Function() onTap;
  final Function()? onLongPress;
  final Domain domain;
  const DomainIcon({Key? key,
    required this.domain, 
    required this.onTap, 
    this.onLongPress
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Container(
            color: HexColor.fromHex('333333'),
            height: 30,
            width: 30,
            child: domain.favIconUrl != null 
              ? Image.network(domain.favIconUrl!,
                //loadingBuilder: (context, child, loadingProgress) => Icon(Icons.language, size: 30,),
                errorBuilder: (context, child, loadingProgress) => Icon(Icons.public, size: 30,),
              )
              : Icon(Icons.public, size: 30,)
            ),
        ),
      );
            
  }
  
}