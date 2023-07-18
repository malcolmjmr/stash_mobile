import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'model.dart';

class SidePanelView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MenuViewModel(context),
      child: Consumer<MenuViewModel>(builder: (context, model, _) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildHeader(context, model),
            _buildBody(context, model),
          ],
        );
      }),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    MenuViewModel model,
  ) =>
      Container(
          height: 60,
          color: Theme.of(context).primaryColor,
          child: Row(
            children: model.pages.map((page) {
              final bool selected = model.page == page;
              final double size = selected ? 40 : 30;
              return Expanded(
                child: GestureDetector(
                  onTap: () => model.setPage(page),
                  child: Container(
                    height: 60,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      border: selected
                          ? Border(
                              bottom: BorderSide(
                                width: 3,
                                color: Theme.of(context).disabledColor,
                              ),
                            )
                          : null,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                      child: Icon(
                        page.icon,
                        size: size,
                        color:
                            selected ? null : Theme.of(context).disabledColor,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ));

  Widget _buildBody(BuildContext context, MenuViewModel model) => Expanded(
        child: Container(
          color: Theme.of(context).primaryColorDark,
          child: PageView(
            scrollDirection: Axis.horizontal,
            controller: model.pageController,
            physics: NeverScrollableScrollPhysics(),
            children: model.pages.map((page) => page.view()).toList(),
          ),
        ),
      );
}
