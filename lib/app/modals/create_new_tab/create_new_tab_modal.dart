import 'package:flutter/material.dart';
import 'package:stashmobile/app/common_widgets/fav_icon.dart';
import 'package:stashmobile/app/modals/create_new_tab/create_new_tab_model.dart';
import 'package:stashmobile/app/workspace/workspace_view_model.dart';
import 'package:stashmobile/models/domain.dart';

class CreateNewTab extends StatefulWidget {

  final WorkspaceViewModel? workspaceModel;
  const CreateNewTab({Key? key, this.workspaceModel}) : super(key: key);

  @override
  State<CreateNewTab> createState() => _CreateNewTabState();
}

class _CreateNewTabState extends State<CreateNewTab> {

  late CreateNewTabModel model;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    model = CreateNewTabModel(
      context, 
      setState,
      workspaceModel: widget.workspaceModel,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Container(
        height: 200,
        child: Column(
          children: [
            _buildInputField(),
            _buildCreateOptions(),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField() {
    return Container(
      child: TextField(
        onSubmitted: (value) => null,//model.createTab,
      ),
    );
  }

  Widget _buildCreateOptions() {
    return Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            ...model.favoriteDomains
              .map((domain) => DomainIcon(
                domain: domain, 
                onTap: () => model.onDomainTap(domain),
                onLongPress: () => model.onDomainLongPress(domain),
                )
              ),
            if (model.textInput.isNotEmpty)
            ...model.favoirteSearchDomains.map((domain) => DomainIcon(
                domain: domain, 
                onTap: () => model.onDomainTap(domain),
                onLongPress: () => model.onDomainLongPress(domain),
                )
              ),
            if (model.workspaceModel != null)
            GestureDetector(
              child: Icon(Icons.create_new_folder_outlined),
            ),
            GestureDetector(
              child: Icon(Icons.visibility_off_outlined),
            ),

              
          ],
        ),
    );
  }
}

class DomainIcon extends StatelessWidget {
  final Function() onTap;
  final Function()? onLongPress;
  final Domain domain;
  const DomainIcon({Key? key,
    required this.domain, 
    required this.onTap, 
    this.onLongPress
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        height: 20,
        width: 20,
        child: domain.favIconUrl != null 
          ? Image.network(domain.favIconUrl!,
            //loadingBuilder: (context, child, loadingProgress) => Icon(Icons.language, size: 30,),
            errorBuilder: (context, child, loadingProgress) => Icon(Icons.public, size: 35,),
          )
          : Icon(Icons.public, size: 35,)
        ),
    );
            
  }
  
}