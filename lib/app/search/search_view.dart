import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stashmobile/app/common_widgets/search_field.dart';
import 'package:stashmobile/app/search/search_view_model.dart';
import 'package:stashmobile/extensions/color.dart';


class SearchView extends ConsumerWidget {
  const SearchView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final model = watch(searchViewProvider);
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Column(
            children: [
              _buildHeader(context, model),
              Expanded(child: _buildResults(context, model)),
            ]
          ),
        )
      ),
    );
  }

  Widget _buildHeader(BuildContext context, SearchViewModel model) {
    return Container(
      height: 50,
      width: MediaQuery.of(context).size.width,
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal:8.0,),
              child: SearchField(),
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Text('Cancel',
              style: TextStyle(
                color: Colors.amber
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildResults(BuildContext context, SearchViewModel model) {
    return Container();
  }
}