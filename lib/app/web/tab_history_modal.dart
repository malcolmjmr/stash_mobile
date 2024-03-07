import 'package:flutter/material.dart';
import 'package:stashmobile/app/common_widgets/fav_icon.dart';
import 'package:stashmobile/app/common_widgets/modal_container.dart';
import 'package:stashmobile/app/web/tab_model.dart';
import 'package:stashmobile/extensions/color.dart';
import 'package:stashmobile/models/resource.dart';

class TabForwardModal extends StatelessWidget {
  const TabForwardModal ({Key? key, required this.model}) : super(key: key);
  final TabViewModel model;
  @override
  Widget build(BuildContext context) {
    return TabHistoryModal(model: model, resources: model.forwardItems, title: 'Go Forward');
  }
}

class TabBackModal extends StatelessWidget {
  const TabBackModal({Key? key, required this.model}) : super(key: key);
  final TabViewModel model;
  @override
  Widget build(BuildContext context) {
    return TabHistoryModal(model: model, resources: model.backItems, title: 'Go Back');
  }
}

class TabHistoryModal extends StatelessWidget {
  const TabHistoryModal({Key? key, required this.model, required this.resources, required this.title}) : super(key: key);
  final TabViewModel model;

  final List<Resource> resources;
  final String title;

  @override
  Widget build(BuildContext context) {
    return ModalContainer(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 50.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black,
            border: Border.all(color: HexColor.fromHex('333333'), width: 2),
            borderRadius: BorderRadius.circular(8)
          ),
          height: (MediaQuery.of(context).size.height * .85)- 160,
          width: MediaQuery.of(context).size.width * .8,
          child: Column(
            children: [
              _buildHeader(),
              _buildItems(),
            ],
          ),
        ),
      )
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: HexColor.fromHex('222222')))
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(title,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text('Cancel',
              style: TextStyle(
                fontSize: 16,
                color: Colors.amber
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildItems() {
    return Container(

      child: ListView(
        shrinkWrap: true,
        scrollDirection: Axis.vertical,
        children: resources.map((resource) {
          return GestureDetector(
            onTap: () => model.goTo(resource),
            child: Container(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 3.0),
                      child: FavIcon(resource: resource),
                    ),
                    Text(resource.title ?? resource.url ?? 'Untitled',
                      style: TextStyle(
                        
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}