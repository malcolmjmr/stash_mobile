import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:stashmobile/app/common_widgets/list_item/view.dart';
import 'package:stashmobile/models/content/content.dart';
import 'package:stashmobile/models/user/model.dart';
import 'model.dart';

class NotificationsView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => NotificationsViewModel(context),
      child: Consumer<NotificationsViewModel>(builder: (context, model, _) {
        return Container(
          child: Column(
            children: [
              _buildHeader(model),
              _buildNotifications(model),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildHeader(NotificationsViewModel model) => Container(
        decoration: BoxDecoration(border: Border(bottom: BorderSide())),
        width: MediaQuery.of(model.context).size.width * .9,
        height: 40,
        child: Stack(
          children: [
            Center(
              child: Text(
                'Notifications',
                style: GoogleFonts.lato(
                  fontSize: 24,
                ),
              ),
            ),
            Positioned(
                right: 0,
                bottom: 0,
                child: GestureDetector(
                  onTap: model.clearNotifications,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(Icons.clear_all),
                  ),
                )),
          ],
        ),
      );

  Widget _buildNotifications(NotificationsViewModel model) => model.isLoading
      ? Container()
      : Container(
          child: ListView(
            shrinkWrap: true,
            children: model.notifications
                .map((notification) => _buildNotification(notification,
                    onConfirm: () => model.confirm(notification),
                    onReject: () => model.reject(notification)))
                .toList(),
          ),
        );

  Widget _buildNotification(NotificationModel model,
          {Function()? onConfirm, Function()? onReject}) =>
      Column(
        children: [
          _buildUserInfo(model.user),
          _buildContentInfo(model.content),
          Row(
            children: [
              GestureDetector(
                onTap: onConfirm,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('Confirm'),
                ),
              ),
              GestureDetector(
                onTap: onReject,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('Reject'),
                ),
              )
            ],
          )
        ],
      );

  Widget _buildUserInfo(User user) => Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 5.0),
            child: ClipRRect(
              child: Image.network(user.imageUrl!),
            ),
          ),
          Expanded(child: Text(user.name!)),
        ],
      );

  Widget _buildContentInfo(Content content) => ListItem(content);
}
