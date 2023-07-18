import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:stashmobile/app/common_widgets/list_item/view.dart';
import 'package:stashmobile/app/share/model.dart';

class ShareModal extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ShareViewModel(context),
      child: Consumer<ShareViewModel>(builder: (context, model, _) {
        return Container(
          height: 200,
          child: {
            ShareState.sending: () =>
                Center(child: CircularProgressIndicator()),
            ShareState.configuring: () => _buildConfigView(model),
            ShareState.sent: () => _buildSentView(model),
          }[model.state]!(),
        );
      }),
    );
  }

  Widget _buildConfigView(ShareViewModel model) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(model),
          _buildUserSelection(model),
          _buildConfigSelection(model),
          _buildSendButton(model),
        ],
      );

  Widget _buildSentView(ShareViewModel model) => Center(
        child: Text(
          'Notification Sent!',
          textAlign: TextAlign.center,
          style: GoogleFonts.lato(fontSize: 20),
        ),
      );

  Widget _buildHeader(ShareViewModel model) => Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 3.0),
                child: Text(
                  'Share',
                  style: GoogleFonts.lato(fontSize: 20),
                ),
              ),
              Expanded(
                child: Center(
                  child: ListItem(
                    model.node.content,
                    fontSize: 16,
                    padding: EdgeInsets.only(top: 5, left: 10),
                    maxLines: 1,
                  ),
                ),
              ),
            ],
          ),
        ),
      );

  Widget _buildUserSelection(ShareViewModel model) => model.contactsAreLoading
      ? Container()
      : Container(
          height: 70,
          width: MediaQuery.of(model.context).size.width,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) {
              final user = model.contacts[index];
              final isSelected = model.selectedUsers.contains(user);
              return Padding(
                padding: const EdgeInsets.all(5.0),
                child: GestureDetector(
                  onTap: () => model.toggleUser(user),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected
                            ? Theme.of(model.context).highlightColor
                            : Theme.of(model.context).canvasColor,
                        width: 5,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(45),
                      child: Image.network(user.imageUrl!),
                    ),
                  ),
                ),
              );
            },
            itemCount: model.contacts.length,
          ),
        );

  Widget _buildConfigSelection(ShareViewModel model) => Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          height: 20,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: _buildTypeSelection(model),
              ),
              _buildPermissionSelection(model),
            ],
          ),
        ),
      );

  Widget _buildTypeSelection(ShareViewModel model) {
    final textStyle = GoogleFonts.lato(fontSize: 16);
    return model.showTypeSelection
        ? Container(
            width: 115,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'As: ',
                  style: GoogleFonts.lato(fontSize: 16),
                ),
                Expanded(
                  child: PageView(
                    scrollDirection: Axis.vertical,
                    children: [
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 3.0),
                            child: Icon(
                              Icons.circle,
                              size: 12,
                            ),
                          ),
                          Text(
                            'Element',
                            style: textStyle,
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 3.0),
                            child: Icon(Icons.account_tree_outlined),
                          ),
                          Text(
                            'Root',
                            style: textStyle,
                          ),
                        ],
                      )
                    ],
                  ),
                ),
                Icon(
                  Icons.unfold_more,
                  size: 16,
                )
              ],
            ),
          )
        : Container();
  }

  Widget _buildPermissionSelection(ShareViewModel model) {
    final textStyle = GoogleFonts.lato(fontSize: 16);
    return Container(
        width: 135,
        child: Row(
          children: [
            Text(
              'With: ',
              style: GoogleFonts.lato(fontSize: 16),
            ),
            Expanded(
              child: PageView(
                scrollDirection: Axis.vertical,
                children: [
                  Text(
                    'Full access',
                    style: textStyle,
                  ),
                  Text(
                    'Edit access',
                    style: textStyle,
                  ),
                  Text(
                    'View access',
                    style: textStyle,
                  ),
                ],
              ),
            ),
            Icon(
              Icons.unfold_more,
              size: 16,
            )
          ],
        ));
  }

  Widget _buildSendButton(ShareViewModel model) => Padding(
        padding: const EdgeInsets.all(8.0),
        child: GestureDetector(
          onTap: model.sendRequest,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Container(
              color: Theme.of(model.context).highlightColor,
              child: Padding(
                padding: const EdgeInsets.only(
                    top: 8.0, bottom: 8.0, left: 30, right: 30),
                child: Text('Send'),
              ),
            ),
          ),
        ),
      );
}
