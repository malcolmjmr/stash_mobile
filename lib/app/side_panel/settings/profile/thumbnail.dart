import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stashmobile/models/user/model.dart';

class ProfileThumbnail extends StatelessWidget {
  final User user;
  final double height;
  ProfileThumbnail({required this.user, required this.height});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [_buildProfileImage(), Expanded(child: _buildUserName())],
      ),
    );
  }

  Widget _buildProfileImage() => Padding(
        padding: const EdgeInsets.all(8.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Container(
            width: height,
            child: Center(
              child: user.imageUrl != null
                  ? Image.network(user.imageUrl!)
                  : Container(),
            ),
          ),
        ),
      );

  Widget _buildUserName() => Container(
        child: Text(user.name!.split(' ').first,
            style: GoogleFonts.lato(fontSize: 30)),
      );
}
