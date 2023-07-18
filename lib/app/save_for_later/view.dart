import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:stashmobile/app/scent/view.dart';

import 'model.dart';

class SaveForLaterModal extends StatelessWidget {
  SaveForLaterModal();
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ViewModel(context),
      child: Consumer<ViewModel>(builder: (context, model, _) {
        return Column(
          children: [
            ScentSelectionView(
              height: 30,
              content: model.content,
            ),
            _buildTitle(model),
          ],
        );
      }),
    );
  }

  Widget _buildTitle(ViewModel model) => Container(
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.all(3.0),
              child: Icon(Icons.link),
            ),
            Expanded(
              child: model.loadingTitle
                  ? Center(child: CircularProgressIndicator())
                  : GestureDetector(
                      onTap: model.editTitle,
                      child: Container(
                        height: 18,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: [Text(model.content.title)],
                        ),
                      ),
                    ),
            ),
            GestureDetector(
              onTap: model.fetchTitle,
              child: Padding(
                padding: const EdgeInsets.only(left: 5.0, right: 5.0),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Theme.of(model.context).highlightColor,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(
                        left: 5, right: 8, top: 5, bottom: 5),
                    child: Text(
                      'Fetch title',
                      style: GoogleFonts.lato(fontSize: 10),
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      );
}
