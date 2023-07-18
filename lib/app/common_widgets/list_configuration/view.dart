import 'package:flutter/material.dart';

// class FilterSettingsButtons extends ConsumerWidget {
//   @override
//   Widget build(BuildContext context, ScopedReader watch) {
//     final model = watch(filterSettingsProvider);
//     return Padding(
//       padding: const EdgeInsets.only(top: 5, right: 10, left: 10, bottom: 5),
//       child: Container(
//         height: 30,
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceAround,
//           children: [
//             FilterSettingsButton(
//               name: 'View',
//               icon: Icons.view_quilt,
//               iconSize: 20,
//               count: model.viewSettingsCount,
//               onTap: () =>
//                   model.openView(context, queryPage: QueryViewPage.view),
//             ),
//             FilterSettingsButton(
//               name: 'Filter',
//               icon: Icons.filter_alt,
//               iconSize: 20,
//               count: model.filterCount,
//               onTap: () =>
//                   model.openView(context, queryPage: QueryViewPage.filter),
//             ),
//             FilterSettingsButton(
//               name: 'Sort',
//               icon: FontAwesomeIcons.sort,
//               iconSize: 18,
//               count: model.sortCount,
//               onTap: () =>
//                   model.openView(context, queryPage: QueryViewPage.sort),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

class FilterSettingsButton extends StatelessWidget {
  final String name;
  final IconData icon;
  final double iconSize;
  final Function() onTap;
  final int count;
  final Color? color;
  final double fontSize;
  FilterSettingsButton({
    required this.name,
    required this.icon,
    this.iconSize = 17,
    required this.onTap,
    this.count = 0,
    this.color,
    this.fontSize = 16,
  });
  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 5.0),
              child: Icon(
                icon,
                size: iconSize,
                color: color,
              ),
            ),
            Text(
              name,
              style: TextStyle(
                fontSize: fontSize,
                color: color,
              ),
            ),
            count > 0
                ? Padding(
                    padding: const EdgeInsets.only(left: 3.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(5.0),
                      child: Container(
                          color: color != null
                              ? color
                              : Theme.of(context).highlightColor,
                          child: Padding(
                            padding:
                                const EdgeInsets.only(right: 3.0, left: 3.0),
                            child: Text(count.toString()),
                          )),
                    ),
                  )
                : Container(),
          ],
        ),
      );
}
