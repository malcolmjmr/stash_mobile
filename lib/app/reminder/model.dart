import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stashmobile/app/providers/app.dart';
import 'package:stashmobile/models/content/content.dart';
import 'package:stashmobile/models/content/reminders.dart';

class ViewModel extends ChangeNotifier {
  BuildContext context;
  late AppController app;
  ViewModel(this.context) {
    app = context.read(appProvider);
    loadReminders();
  }

  List<Reminder> reminderOptions = [];

  loadReminders() {
    final today = DateTime.now();
    reminderOptions = [
      Reminder('Later Today', today.add(Duration(hours: 3))),
      Reminder('Tomorrow', today.add(Duration(days: 1))),
      Reminder('Next Week', today.add(Duration(days: 7))),
      Reminder('In a Month', today.add(Duration(days: 30))),
      Reminder('Someday', today.add(Duration(days: 90))),
    ];
  }

  setReminder(Reminder reminder) async {
    updateContent(Content content) async {
      if (content.reminders == null)
        content.reminders = ContentReminders(reminder.time);
      else
        content.reminders!.setNext(reminder.time);
      await app.content.saveContent(content);
    }

    if (app.treeView.selected.isNotEmpty) {
      app.treeView.selected.forEach((node) {
        updateContent(node.content);
      });
    } else {
      updateContent(app.treeView.rootNode.content);
    }
  }
}

class Reminder {
  String name;
  DateTime time;
  Reminder(this.name, this.time);
}
