import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'model.dart';

class ReminderView extends StatelessWidget {
  final Function()? goBack;
  ReminderView({this.goBack});
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ViewModel(context),
      child: Consumer<ViewModel>(builder: (context, model, _) {
        return Container(
          height: 45,
          child: CustomScrollView(
            scrollDirection: Axis.horizontal,
            slivers: [_buildBackButton(), _buildReminderOptions(model)],
          ),
        );
      }),
    );
  }

  Widget _buildBackButton() => SliverAppBar(
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        floating: true,
        title: GestureDetector(
          onTap: goBack,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(Icons.arrow_back_ios),
          ),
        ),
      );

  Widget _buildReminderOptions(ViewModel model) => SliverList(
        delegate: SliverChildListDelegate(model.reminderOptions
            .map(
              (option) => GestureDetector(
                onTap: () => model.setReminder(option),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      height: 20,
                      color: Theme.of(model.context).highlightColor,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                        child: Center(
                          child: Text(option.name),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            )
            .toList()),
      );
}
