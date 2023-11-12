import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:stashmobile/app/common_widgets/domain_icon.dart';
import 'package:stashmobile/app/common_widgets/freeze_container.dart';
import 'package:stashmobile/app/modals/create_new_tab/create_new_tab_modal.dart';
import 'package:stashmobile/app/web/tab_edit_model.dart';
import 'package:stashmobile/app/workspace/workspace_view_model.dart';
import 'package:stashmobile/extensions/color.dart';
import 'package:stashmobile/models/resource.dart';


/*
  search results 
  - resources that match 

  url field
    - type url
    - or search
*/


class TabEditModal extends StatefulWidget {
  final Resource tab;
  final WorkspaceViewModel workspaceModel;
  const TabEditModal({Key? key, required this.tab, required this.workspaceModel}) : super(key: key);

  @override
  State<TabEditModal> createState() => _TabEditModalState();
}

class _TabEditModalState extends State<TabEditModal> {


  late TabEditModel model;
  bool isLoaded = false;
  

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    model = TabEditModel(
      setState: setState, 
      workspaceModel: widget.workspaceModel,
      tab: widget.tab,

    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    model.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Container(
          width: screenSize.width,
          color: Colors.transparent,
          child: Column(
            children: [
              _buildBackground(),
             
              _buildUrlField(),
              if (model.visibleDomains.isNotEmpty)
              _buildCreateOptions(),
            ],
          ),
        )
      ),
    );
  }

  Widget _buildBackground() {
    return Expanded(
      child: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          color: Colors.transparent,
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    return Container();
  }

  Widget _buildCreateOptions() {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        //borderRadius: BorderRadius.circular(8),
        color: Colors.black,
      ),
      child: Container(
        
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    height: 35,
                    decoration: BoxDecoration(
                      //color: HexColor.fromHex('333333'),
                      //borderRadius: BorderRadius.circular(8)
                    ),
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      //controller: ScrollController().,
                      itemCount: model.visibleDomains.length,
                      itemBuilder: (context, index) {
                        final domain = model.visibleDomains[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5.0),
                          child: Center(child: DomainIcon(domain: domain, 
                            size: 26,
                            onTap: () => model.createNewTab(context, domain: domain), 
                            onLongPress: () => model.deleteDomain(domain),)),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                //color: HexColor.fromHex('333333'),
                borderRadius: BorderRadius.circular(8)
              ),
              child: Padding(
                padding: const EdgeInsets.only(right: 5.0, top: 1, bottom: 2, left: 3.0),
                child: Row(
                  children: [
                    CreateTabButton(
                      icon: Symbols.add_box_rounded, 
                      onTap: () => model.createNewTab(context)
                    ),
                    CreateTabButton(
                      icon: Symbols.visibility_off,
                      onTap: () => model.createNewTab(context, incognito: true),
                      size: 18,
                    ),
                    CreateTabButton(
                      icon: Symbols.new_window, 
                      onTap: () => model.createNewSpace(context),
                    ),

                  ],
                ),
              ),
            ),
            
          ],
        ),
      ),
    );
  }

  Widget _buildUrlField() {
    return Hero(
      tag: 'activetab' + model.tab.url!,
      child: Container(
        color: Colors.black,
        height: 50,
        width: MediaQuery.of(context).size.width,
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                child: Container(
                  decoration: BoxDecoration(
                    color: HexColor.fromHex('333333'),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: model.inputController,
                            autocorrect: false,
                            maxLines: 1,
                            keyboardType: TextInputType.visiblePassword,
                            textInputAction: TextInputAction.go,
                            onChanged: (value) => model.onInputChanged(),
                            onSubmitted: (value) {
                              model.updateTab(context);
                            },
                            autofocus: true,
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.only(bottom: 8),
                              border: InputBorder.none,
                              hintStyle: TextStyle(
                                color: Colors.white.withOpacity(0.8)
                              )
                            ),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16
                            ),
                          ),
                        ),
                        if (model.input.isNotEmpty)
                        GestureDetector(
                          onTap: () => model.clearInput(),
                          child: Padding(
                            padding: const EdgeInsets.all(5),
                            child: Container(
                              height: 20, 
                              width: 20,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(100),
                                color: HexColor.fromHex('555555'),
                              ),
                              child: Center(child: Icon(Icons.close_outlined, size: 18,))),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class CreateTabButton extends StatelessWidget {
  final Function() onTap;
  final Function()? onLongPress;
  final IconData icon;
  final Color? color;
  final double? size;

  const CreateTabButton({
    Key? key,
    required this.icon,
    required this.onTap,
    this.onLongPress,
    this.color,
    this.size = 25,
    }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Padding(
        padding: const EdgeInsets.only(left: 3.0, right: 3, bottom: 3),
        child: Container(
          height: 35,
          width: 35,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: HexColor.fromHex('333333')
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5.0),
            child: Container(
              child: Icon(icon,
               color: color,
               size: size,
              )
            ),
          ),
        ),
      ),
    );
  }
}