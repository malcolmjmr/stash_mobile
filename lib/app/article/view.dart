import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:stashmobile/app/article/model.dart';
import 'package:stashmobile/models/content/type_fields/web_article.dart';

class ArticleView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ArticleViewModel(context),
      child: Consumer<ArticleViewModel>(builder: (context, model, _) {
        return Material(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              //maxHeight: MediaQuery.of(context).size.height * .45,
              minHeight: 100,
            ),
            child: Container(
              padding: EdgeInsets.only(top: 8, left: 10, right: 10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(model),
                  _buildTableOfContents(model),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildHeader(ArticleViewModel model) {
    final textStyle =
        GoogleFonts.lato(fontSize: 14, fontWeight: FontWeight.bold);
    return Container(
      width: MediaQuery.of(model.context).size.width,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 5.0),
        child: Text(
          model.app.viewModel.root.title,
          style: textStyle,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      decoration: BoxDecoration(
          border: Border(
              bottom: BorderSide(
                  width: 2, color: Theme.of(model.context).focusColor))),
    );
  }

  Widget _buildTableOfContents(ArticleViewModel model) => Expanded(
        child: ListView(
          shrinkWrap: true,
          children: model.article.headings
              .map((heading) => _buildHeading(model, heading))
              .toList(),
        ),
      );

  Widget _buildHeading(ArticleViewModel model, ArticleSection heading) =>
      Padding(
        padding: const EdgeInsets.only(top: 5.0),
        child: Container(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () => model.onSectionTap(heading),
                onDoubleTap: () => model.onSectionDoubleTap(heading),
                child: Opacity(
                  opacity: model.article.currentHeading == heading ? 1 : .8,
                  child: Text(
                    heading.text,
                    maxLines: null,
                    style: GoogleFonts.lato(),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 15.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: heading.subHeadings
                      .map((h) => _buildHeading(model, h))
                      .toList(),
                ),
              )
            ],
          ),
        ),
      );
}
