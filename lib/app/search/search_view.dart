import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
              child: Hero(
                tag: 'search',
                child: Material(
                  type: MaterialType.transparency,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: HexColor.fromHex('222222'),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5.0),
                          child: Icon(Icons.search),
                        ),
                        Expanded(
                          child: TextField(
                            controller: model.controller,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintStyle: TextStyle(
                                color: Colors.white.withOpacity(0.8)
                              )
                            ),
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
              
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