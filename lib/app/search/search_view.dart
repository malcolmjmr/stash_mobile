import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stashmobile/app/common_widgets/search_field.dart';
import 'package:stashmobile/app/home/workspace_listitem.dart';
import 'package:stashmobile/app/search/search_view_model.dart';
import 'package:stashmobile/app/workspace/folder_list_item.dart';
import 'package:stashmobile/app/workspace/workspace_view_params.dart';
import 'package:stashmobile/extensions/color.dart';
import 'package:stashmobile/routing/app_router.dart';


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
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                title: _buildHeader(context, model),
                backgroundColor: Colors.black,
                automaticallyImplyLeading: false,
                leadingWidth: 0,
                pinned: true,
                leading: null,
              ),

              SliverPadding(padding: EdgeInsets.only(top: 20)),
              SliverList.builder(
                itemCount: model.visibleWorkspaces.length,
                itemBuilder: (context, index) {
                  final workspace = model.visibleWorkspaces[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
                    child: FolderListItem(
                      isFirstListItem: index == 0,
                      isLastListItem: index == model.visibleWorkspaces.length - 1,
                      workspace: workspace, 
                      onTap: () {
                        Navigator.pushNamed(context, AppRoutes.workspace, 
                          arguments: WorkspaceViewParams(
                            workspaceId: workspace.id
                          )
                        );
                      }
                    ),
                  );
                },
              )
            ]
          ),
        )
      ),
    );
  }

  Widget _buildHeader(BuildContext context, SearchViewModel model) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 10),
      child: Container(
        height: 50,
        width: MediaQuery.of(context).size.width,
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right:8.0),
                child: SearchField(
                  autofocus: true,
                  onChanged: (value) => model.updateSearchResults(value),
                ),
              ),
            ),
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Text('Cancel',
                style: TextStyle(
                  color: Colors.amber,
                  fontSize: 16
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildResults(BuildContext context, SearchViewModel model) {
    return  Container();
  }

  // Widget _buildFolderSection() {
  //   return Container();
  // }

  // Widget _build
}