import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:stashmobile/app/common_widgets/user_icon.dart';

import 'model.dart';

class CollectionCreateView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Material(
        child: ChangeNotifierProvider(
          create: (_) => CollectionCreateViewModel(context),
          child: Consumer<CollectionCreateViewModel>(
            builder: (context, model, _) => Container(
              child: Column(
                children: [
                  _buildHeader(model),
                  Divider(thickness: 3),
                  _buildNameInput(model),
                  Divider(),
                  _buildIconSelection(model),
                  _buildPinnedItemSelection(model),
                  Divider(),
                  _buildMemberSelection(model),
                  _buildCategorySelection(model),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(CollectionCreateViewModel model) => Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            GestureDetector(
              onTap: model.cancel,
              child: Padding(
                padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 8.0),
                child: Text('Cancel'),
              ),
            ),
            Expanded(
              child: Text(
                'Create Collection',
                textAlign: TextAlign.center,
                style: GoogleFonts.lato(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
            ),
            GestureDetector(
              onTap: model.done,
              child: Padding(
                padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 8.0),
                child: Text('Done'),
              ),
            ),
          ],
        ),
      );

  Widget _buildNameInput(CollectionCreateViewModel model) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Text(
              'Name',
              style: GoogleFonts.lato(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: model.onNameChanged,
              onSubmitted: model.onNameChanged,
              decoration: InputDecoration(
                border: InputBorder.none,
                isCollapsed: true,
                hintText: 'Enter collection name',
                hintStyle: GoogleFonts.lato(fontSize: 18),
              ),
            ),
          ),
        ],
      );

  Widget _buildIconSelection(CollectionCreateViewModel model) => Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
              child: Text(
                'Icon',
                style: GoogleFonts.lato(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            model.imageUrlsAreLoading
                ? Container()
                : Container(
                    height: 60,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: model.imageUrls.length,
                      itemBuilder: (context, index) {
                        final imageUrl = model.imageUrls[index];
                        return GestureDetector(
                          onTap: () => model.updateIconUrl(imageUrl),
                          child: Padding(
                            padding: EdgeInsets.only(left: 3, right: 3),
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  width: 5,
                                  color: model.collection.iconUrl == imageUrl
                                      ? Theme.of(model.context).highlightColor
                                      : Theme.of(model.context).canvasColor,
                                ),
                              ),
                              child: Image.network(imageUrl),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
          ],
        ),
      );
  Widget _buildPinnedItemSelection(CollectionCreateViewModel model) =>
      Container();

  Widget _buildMemberSelection(CollectionCreateViewModel model) =>
      model.contactsAreLoading
          ? Container()
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
                  child: Text(
                    'Members',
                    style: GoogleFonts.lato(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  height: 60,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: model.contacts.length,
                    itemBuilder: (context, index) {
                      final user = model.contacts[index];
                      return UserIcon(
                        user,
                        onTap: () => model.toggleMember(user),
                        padding: EdgeInsets.only(left: 3, right: 3),
                        border: Border.all(
                          width: 5,
                          color: (model.collection.contributors
                                      ?.contains(user.id) ??
                                  false)
                              ? Theme.of(model.context).highlightColor
                              : Theme.of(model.context).canvasColor,
                        ),
                      );
                    },
                  ),
                ),
              ],
            );

  Widget _buildCategorySelection(CollectionCreateViewModel model) =>
      Container();
}
