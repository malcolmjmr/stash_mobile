import 'package:flutter/material.dart';
import 'package:stashmobile/app/common_widgets/modal_container.dart';
import 'package:stashmobile/app/web/tab_model.dart';
import 'package:stashmobile/extensions/color.dart';

class TabSummaryModal extends StatelessWidget {
  const TabSummaryModal({Key? key, required this.model }) : super(key: key);
  final TabViewModel model;
  @override
  Widget build(BuildContext context) {
    return ModalContainer(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: HexColor.fromHex('333333'), width: 2)
        ),
        height: (MediaQuery.of(context).size.height * .85) - 160,
        width: MediaQuery.of(context).size.width * .85,
        child: Column(
          children: [
            //_buildHeader(),
            _buildTopics(),
            Expanded(child: _buildSummary()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final resource = model.resource;
    return Container(
      child: Text(resource.title ?? resource.url!,
        style: TextStyle(
          fontSize: 20,
        ),
        maxLines: 3,
      ),
    );
  }

  Widget _buildTopics() {
    return Container();
  }

  Widget _buildSummary() {
    return FutureBuilder<void>(
      future: model.getSummary(),
      builder: (context, snapshot) {
        return Container(
          child: ListView(
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            children: [
              Text(model.resource.summary ?? '',
                style: TextStyle(
                  fontSize: 20
                ),
              ),
            ],
          ),
        );
      }
    );
  }
}