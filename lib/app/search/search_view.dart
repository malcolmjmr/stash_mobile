import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stashmobile/app/common_widgets/resource_list_item.dart';
import 'package:stashmobile/app/common_widgets/search_field.dart';
import 'package:stashmobile/app/common_widgets/section_header.dart';
import 'package:stashmobile/app/home/home_view_model.dart';
import 'package:stashmobile/app/home/workspace_listitem.dart';
import 'package:stashmobile/app/providers/workspace.dart';
import 'package:stashmobile/app/search/search_view_model.dart';
import 'package:stashmobile/app/workspace/space_list_item.dart';
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
                floating: true,
                leading: null,
              ),

              if (model.searchString.isEmpty)
              SliverPadding(padding: EdgeInsets.only(top: 20)),

              if (model.searchString.isEmpty)
              SliverList.builder(
                itemCount: model.suggestedResources.length,
                itemBuilder: (context, index) {
                  final resource = model.suggestedResources[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
                    child: ResourceListItem(
                      isFirstListItem: index == 0,
                      isLastListItem: index == model.suggestedResources.length - 1,
                      workspace: resource.primaryWorkspace,
                      resource: resource, 
                      onTap: () => model.openResource(context, resource)
                    ),
                  );
                },
              ),

              if (model.searchString.isNotEmpty && model.visibleWorkspaces.isNotEmpty)
              SliverList.builder(
                itemCount: model.visibleWorkspaces.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return Padding(
                      padding: const EdgeInsets.only(left: 15, right: 15, top: 20),
                      child: SectionHeader(
                        title: 'Spaces', 
                        trailing: Text('${model.visibleWorkspaces.length} Found'),
                      ),
                    );
                  } else {
                    final workspace = model.visibleWorkspaces[index - 1];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15.0),
                      child: WorkspaceListItem(
                        isFirstListItem: index == 1,
                        isLastListItem: index == model.visibleWorkspaces.length,
                        workspace: workspace, 
                        togglePin: (context) => context.read(homeViewProvider).toggleWorkspacePinned(workspace),
                        onTap: () {
                          Navigator.pushReplacementNamed(context, AppRoutes.workspace, 
                            arguments: WorkspaceViewParams(
                              workspaceId: workspace.id,
                              parentId: context.read(workspaceProvider).state,
                            )
                          );
                        }
                      ),
                    );
                  }
                },
              ),
              if (model.searchString.isNotEmpty && model.visibleResources.isNotEmpty)
              SliverList.builder(
                itemCount: model.visibleResources.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return Padding(
                      padding: const EdgeInsets.only(left: 15, right: 15, top: 20),
                      child: SectionHeader(
                        title: 'Resources', 
                        trailing: Text('${model.visibleResources.length} Found'),
                      ),
                    );
                  } else {
                    final resource = model.visibleResources[index - 1];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15.0),
                      child: ResourceListItem(
                        isFirstListItem: index == 1,
                        isLastListItem: index == model.visibleResources.length,
                        workspace: resource.contexts.isEmpty ? null : model.workspaceMap[resource.contexts.first],
                        resource: resource, 
                        onTap: () {
                          
                        }
                      ),
                    );
                  }
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