import 'package:flutter/material.dart';

class FilterOperatorSelectionView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container();
  }

  // Widget _buildOperationSelectionHeader(FilterSettings model) => _buildHeader(
  //       backFunction: model.leaveOperatorView,
  //       title: Row(mainAxisSize: MainAxisSize.min, children: [
  //         Padding(
  //           padding: const EdgeInsets.all(8.0),
  //           child: Icon(model.field!.icon),
  //         ),
  //         Text(
  //           model.field!.name,
  //           style: GoogleFonts.lato(fontWeight: FontWeight.bold, fontSize: 20),
  //         )
  //       ]),
  //     );

  // Widget _buildOperations(BuildContext context, FilterSettings model) =>
  //     Expanded(
  //       child: ListView(
  //           children: model.relevantOperators
  //               .map(
  //                 (operator) => ListTile(
  //                   onTap: () => model.setOperator(operator),
  //                   title: Text(operator.name),
  //                   trailing: Row(
  //                     mainAxisSize: MainAxisSize.min,
  //                     children: [
  //                       operator.count > 0
  //                           ? ClipRRect(
  //                               borderRadius: BorderRadius.circular(10),
  //                               child: Container(
  //                                 color: Theme.of(context).primaryColor,
  //                                 child: Padding(
  //                                   padding: const EdgeInsets.all(5.0),
  //                                   child: Text(operator.count.toString()),
  //                                 ),
  //                               ),
  //                             )
  //                           : Container(),
  //                       Icon(Icons.arrow_forward_ios),
  //                     ],
  //                   ),
  //                 ),
  //               )
  //               .toList()),
  //     );
}
