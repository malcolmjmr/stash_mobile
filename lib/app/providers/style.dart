import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stashmobile/app/providers/users.dart';
import 'package:stashmobile/models/user/model.dart';

class StyleManager {
  UserManager userManager;
  late User user;
  StyleManager(this.userManager) {
    user = userManager.me;
    theme = user.theme == 'light' ? ThemeData.light() : ThemeData.dark();
    textStyle = GoogleFonts.lato(fontSize: 12);
  }
  late ThemeData theme;
  late TextStyle textStyle;
}
