import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stashmobile/app/common_widgets/freeze_container.dart';
import 'package:stashmobile/app/common_widgets/search_field.dart';
import 'package:stashmobile/app/common_widgets/section_header.dart';
import 'package:stashmobile/app/history/activity_history_view_model.dart';
import 'package:stashmobile/app/home/workspace_listitem.dart';
import 'package:stashmobile/app/search/search_view_model.dart';
import 'package:stashmobile/extensions/color.dart';
import 'package:stashmobile/routing/app_router.dart';

class ActivityHistoryView extends ConsumerWidget {
  const ActivityHistoryView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final model = watch(historyViewProvider);
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              title: _buildPinnedHeader(context),
              
              automaticallyImplyLeading: false,
              pinned: true,
              leadingWidth: 0,
              leading: null,
              backgroundColor: Colors.black,
            ),
            SliverToBoxAdapter(
              child: _buildTitle(),
            ),
            SliverAppBar(
              title: _buildSearch(context),
              automaticallyImplyLeading: false,
              floating: true,
              leadingWidth: 0,
              leading: null,
              backgroundColor: Colors.black,
            ),
            ...model.sections.map((section) {
              return SliverList.builder(
                itemCount: section.spaces.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      child: SectionHeader(title: section.title),
                    );
                  } else {
                    final space = section.spaces[index - 1];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: WorkspaceListItem(
                        isFirstListItem: index == 1,
                        isLastListItem: index == section.spaces.length,
                        workspace: space, 
                        onTap: () {
                          model.openWorkspace(context, space);
                          Navigator.pop(context);
                        }
                      ),
                    );
                  }
                }
              );
            })
          ],
        ),
      ),
    );
  }


  Widget _buildPinnedHeader(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Container(
        height: 40,
        width: MediaQuery.of(context).size.width,
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 8.0, ),
              child: Icon(Icons.arrow_back_ios),
            ),
            Text('Home'),
            Expanded(child: SizedBox(),)
          ],
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: Container(
        child: Text('History',
          style: TextStyle(
            fontSize: 50,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildSearch(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 5, right: 5, top: 10),
      child: SearchField(
        onTap: () {
          context.read(searchViewProvider).initBeforeNavigation();
          Navigator.pushNamed(context, AppRoutes.search);
        }, 
        showPlaceholder: true,
      ),
    );
  }
}