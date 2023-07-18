import 'package:flutter/material.dart' hide SearchBar;
import 'package:provider/provider.dart';
import 'package:stashmobile/app/common_widgets/search_bar/view.dart';
import 'package:stashmobile/app/tags/tag.dart';

import 'model.dart';

class SearchView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      lazy: false,
      create: (context) => SearchViewModel(context),
      child: Consumer<SearchViewModel>(builder: (context, model, _) {
        return SafeArea(
          child: Scaffold(
              body: Container(
            color: Theme.of(context).primaryColorDark,
            child: Column(
              children: [
                _buildSearchBar(model),
                model.selectedTags.isNotEmpty
                    ? _buildSelectedTags(model)
                    : Container(),
                Expanded(
                    child: model.showTags
                        ? _buildTags(model)
                        : _buildSearchResults(model))
              ],
            ),
          )),
        );
      }),
    );
  }

  Widget _buildSearchBar(SearchViewModel model) => Padding(
        padding: const EdgeInsets.only(top: 5.0),
        child: Container(
          height: 50,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () => Navigator.of(model.context).pop(),
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0, top: 5.0),
                  child: Icon(Icons.arrow_back_ios),
                ),
              ),
              Expanded(
                child: SearchBar(
                  padding: const EdgeInsets.only(left: 0, top: 5, right: 15),
                  leading: Padding(
                    padding: const EdgeInsets.only(left: 10.0, right: 5.0),
                    child: Icon(
                      Icons.search,
                      size: 24,
                    ),
                  ),
                  controller: model.textController,
                  hintText: 'Search ${model.showTags ? 'tags' : 'content'}',
                  fontSize: 20,
                  onChanged: (text) => model.updateSearch(text),
                  onSubmit: model.onSearchSubmit,
                  trailing: _buildToggleTagSearch(model),
                ),
              ),
            ],
          ),
        ),
      );

  Widget _buildSelectedTags(SearchViewModel model) => Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 15, bottom: 8.0),
            child: Container(
              height: 30,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: model.selectedTags.length,
                itemBuilder: (context, index) {
                  final tag = model.selectedTags[index];
                  return Padding(
                    padding: const EdgeInsets.only(left: 3.0, right: 3.0),
                    child: TagView(
                      tag,
                      color: Theme.of(context).highlightColor,
                    ),
                  );
                },
              ),
            ),
          ),
          Divider(
            thickness: 3,
            height: 3,
          )
        ],
      );
  Widget _buildToggleTagSearch(SearchViewModel model) => GestureDetector(
        onTap: () => model.setShowTags(!model.showTags),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: model.showTags ? Icon(Icons.list) : Icon(Icons.style_outlined),
        ),
      );

  Widget _buildTags(SearchViewModel model) => Padding(
        padding: const EdgeInsets.only(left: 5.0, right: 5.0),
        child: Container(
          child: ListView(
            children: [
              Wrap(
                spacing: 5,
                children: model.availableTags
                    .map(
                      (tag) => Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: TagView(
                          tag,
                          onTap: () => model.selectTag(tag),
                          color: Theme.of(model.context).canvasColor,
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        ),
      );

  Widget _buildSearchResults(SearchViewModel model) => Container();
}
