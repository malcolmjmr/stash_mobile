import 'package:flutter/material.dart';
import 'package:stashmobile/app/web/tab.dart';
import 'package:stashmobile/extensions/color.dart';
import 'package:stashmobile/models/resource.dart';

class TabPreview extends StatelessWidget {
  final Resource tab;
  final showSelectionToggle;
  final isSelected;
  final Function() open;
  final Function() toggleSelection;
  final Function() close;
  const TabPreview({Key? key, 
    required this.tab, 
    required this.open, 
    required this.toggleSelection,
    required this.close,
    this.isSelected = false,
    this.showSelectionToggle = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(isSelected ? 5 : 8),
      child: Column(
        children: [
          Stack(
            children: [
              GestureDetector(
                onTap: showSelectionToggle ? toggleSelection : open,
                onLongPress: toggleSelection,
                child: Container(
                   decoration: isSelected ? BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.blueAccent,
                      width: 4,
                    )
                  ) : null,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      width: MediaQuery.of(context).size.width * .43 - (isSelected ? 8 : 0),
                      height: MediaQuery.of(context).size.width * .45 * 1.2,
                      child: tab.image == null 
                        ? Container(
                            width: MediaQuery.of(context).size.width * .43,
                            height: MediaQuery.of(context).size.width * .45 * 1.2,
                            decoration: BoxDecoration(
                              border: Border.all(color: HexColor.fromHex('222222'), width: 2)
                            ),
                            child: Column(
                              children: [
                                tab.favIconUrl != null ? Image.network(tab.favIconUrl!) :
                                Text(tab.title ?? ''),
                              ]
                            ),
                          )
                        : Image.memory(tab.image!, fit: BoxFit.cover,),
                    ),
                  ),
                ),
              ),
            
              if (showSelectionToggle)
              _buildSelectionToggle(context)
              else
              _buildCloseTabButton(context)

            ],
          ),
          _buildTabTitle(context)
        ],
      ),
    );
  }

  Widget _buildSelectionToggle(BuildContext context) {
      return  Positioned(
        top: 5,
        right: 5,
        child: GestureDetector(
          onTap: toggleSelection,
          child: Container(
            height: 25,
            width: 25,
            padding: EdgeInsets.zero,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Container(
                   decoration: BoxDecoration(
                    color: HexColor.fromHex('222222'),
                    borderRadius: BorderRadius.circular(100),
                    
                  ),
                ),
                Icon(isSelected ? Icons.check_circle_outlined : Icons.circle_outlined, 
                  size: 25, 
                  color: 
                  Colors.blueAccent,
                ),
              ],
            ),
          ),
        )
      );
  
  }

  Widget _buildCloseTabButton(BuildContext context) {
    return  Positioned(
      top: 5,
      right: 5,
      child: GestureDetector(
        onTap: close,
        child: Container(
          height: 20,
          width: 20,
          decoration: BoxDecoration(
            color: HexColor.fromHex('222222'),
            borderRadius: BorderRadius.circular(100),
            
          ),
          child: Center(child: Icon(Icons.close, size: 16,)),
        ),
      )
    );
  }

  Widget _buildTabTitle(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: Container(
        height: 20,
        width: MediaQuery.of(context).size.width * .42,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (tab.favIconUrl != null) Padding(
              padding: const EdgeInsets.only(right: 3.0),
              child: Image.network(tab.favIconUrl!),
            ),
            Expanded(
              child: Text(tab.title ?? '', 
                textAlign: TextAlign.start,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// class TabPreview extends StatelessWidget {
//   final TabView tab;
//   final Function() onTap;
//   const TabPreview({Key? key, required this.tab, required this.onTap}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Padding(
//         padding: const EdgeInsets.all(8.0),
//         child: ClipRRect(
//           borderRadius: BorderRadius.circular(8),
//           child: Container(
//             width: MediaQuery.of(context).size.width * .4,
//             height: MediaQuery.of(context).size.width * .4 * 1.2,
//             child: Stack(
//               fit: StackFit.expand,
//               children: [
//                 SizedBox.expand(),
//                 Container(
//                   width: MediaQuery.of(context).size.width * .4,
//                   height: MediaQuery.of(context).size.width * .4 * 1.2,
//                   child: FittedBox(
//                     fit: BoxFit.contain,
//                     child: tab,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }