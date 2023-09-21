import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stashmobile/app/providers/data.dart';
import 'package:stashmobile/app/providers/workspace.dart';
import 'package:stashmobile/app/workspace/workspace_view_params.dart';
import 'package:stashmobile/extensions/dates.dart';
import 'package:stashmobile/models/workspace.dart';
import 'package:stashmobile/routing/app_router.dart';


final historyViewProvider = ChangeNotifierProvider((ref) {
  return ActivityHistoryViewModel(ref.read);
});

class ActivityHistoryViewModel extends ChangeNotifier {

  late DataManager data;
  Reader read;

  List<Workspace> spaces = [];
  ActivityHistoryViewModel(this.read) {
    data = read(dataProvider);
    getTimeSections();
  } 

  //Map<String, List<Workspace>> sections = {};

  List<Section> sections = [];

  getTimeSections() async {
    spaces = data.workspaces.where((s) => s.isIncognito != true && s.updated != null).toList();
    spaces.sort(sortSpaces);
    Map<String, Section> sectionMap = {};
    final now = DateTime.now();
    for (final space in spaces) {
      //if (space.updated == null) continue;
      final date = DateTime.fromMillisecondsSinceEpoch(space.updated!);
      final timeDelta = now.difference(date);
      if (timeDelta.inDays < 1 && date.day == now.day) {
        if (sectionMap[TimeDeltaStrings.today] == null) {
          sectionMap[TimeDeltaStrings.today] = Section(TimeDeltaStrings.today, date);
        }
        sectionMap[TimeDeltaStrings.today]!.spaces.add(space);
      } else if (timeDelta.inDays < 7) {
        if (sectionMap[TimeDeltaStrings.previous7Days] == null) {
          sectionMap[TimeDeltaStrings.previous7Days] = Section(TimeDeltaStrings.previous7Days, date);
        }
        sectionMap[TimeDeltaStrings.previous7Days]!.spaces.add(space);
      } else if (timeDelta.inDays < 30) {
        if (sectionMap[TimeDeltaStrings.previous30Days] == null) {
          sectionMap[TimeDeltaStrings.previous30Days] = Section(TimeDeltaStrings.previous30Days, date);
        }
        sectionMap[TimeDeltaStrings.previous30Days]!.spaces.add(space);
      } else if (timeDelta.inDays < 365) {
        if (sectionMap[date.monthString] == null) {
          sectionMap[date.monthString] = Section(date.monthString, date);
        }
        sectionMap[date.monthString]!.spaces.add(space);
      }
    }
    sections = sectionMap.values.toList();
    sections.sort((a, b) => b.firstDate.compareTo(a.firstDate));
    notifyListeners();
  }

  openWorkspace(BuildContext buildContext, Workspace workspace) {
    buildContext.read(workspaceProvider).state = workspace.id;
    Navigator.pushNamed(buildContext, AppRoutes.workspace, arguments: WorkspaceViewParams(workspaceId: workspace.id));
  }

}

int sortSpaces(Workspace a, Workspace b) {
    return (b.updated!).compareTo(a.updated!);
    //  if (comp == 0) {
    //   comp = (.updated ?? 0).compareTo(a.updated ?? 0);
    // }

    // if (comp == 0) {
    //   comp = (b.created ?? 0).compareTo(a.created ?? 0);
    // }

    // return comp;


  }

class Section {

  String title;
  List<Workspace> spaces = [];
  Section(this.title, this.firstDate);
  DateTime firstDate;
  
  
}





class TimeDeltaStrings {
  static const today = 'Today';
  static const previous7Days = 'Previous 7 Days';
  static const previous30Days = 'Previous 30 Days';
}

