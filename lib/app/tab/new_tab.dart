import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:stashmobile/app/common_widgets/domain_icon.dart';
import 'package:stashmobile/app/tab/new_tab_model.dart';
import 'package:stashmobile/app/tab/news_card.dart';
import 'package:stashmobile/app/web/tab_model.dart';
import 'package:stashmobile/app/workspace/resource_list_item.dart';
import 'package:stashmobile/extensions/color.dart';

class NewTab extends StatefulWidget {
  const NewTab({Key? key, required this.tabModel}) : super(key: key);

  final TabViewModel tabModel;

  @override
  State<NewTab> createState() => _NewTabState();
}

class _NewTabState extends State<NewTab> {

  late NewTabModel model;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    model = NewTabModel(context, setState, widget.tabModel);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        _buildBackground(),
        Container(
          //color: Colors.black,
          child: CustomScrollView(
            slivers: [
              
              // app bar
              // SliverToBoxAdapter(
              //   child: _buildTextField(),
              // ),
        

        
        
              SliverPadding(padding: EdgeInsets.only(top: 15)),
              SliverToBoxAdapter(
                child:_buildCreateOptions() ,
              ),
              
              SliverToBoxAdapter(
                child: _buildFavoritesSectionTitle()
              ),

              SliverGrid.count(
                crossAxisCount: 5,
              
                children: model.favoriteDomains.map((domain) {
                    return Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Container(
                        decoration: BoxDecoration(
                        color: HexColor.fromHex('888888'),
                          borderRadius: BorderRadius.circular(8)
                          // border: Border(
                          //   top: BorderSide(color: HexColor.fromHex('333333')),
                          //   bottom: BorderSide(color: HexColor.fromHex('333333'))
                          // )
                        ),
                        child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8),
                            child: DomainIcon(
                              domain: domain, 
                              size: 35,
                              onTap: () => model.onDomainTapped(context, domain), 
                            //onLongPress: () => model.deleteDomain(domain),)),
                            )
                          ),
                      ),
                    );
                  }).toList(),
              ),
              // app bar
              // SliverToBoxAdapter(
              //   child: _buildSectionOptions(),
              // ),
              // if (model.searchText.isNotEmpty)
              // SliverList.builder(
              //   itemCount: model.searchResults.length,
              //   itemBuilder: (context, index) {
              //     final resource = model.searchResults[index];
              //     return ResourceListItem(
              //       model: model.tabModel.workspaceModel, 
              //       resource: resource, 
              //       onTap: () => null,
              //     );
              //   }
              // )
              // else if (model.subSection == NewTabSection.history)
              // SliverList.builder(
              //   itemCount: model.searchResults.length,
              //   itemBuilder: (context, index) {
              //     final resource = model.searchResults[index];
              //     return ResourceListItem(
              //       model: model.tabModel.workspaceModel, 
              //       resource: resource, 
              //       onTap: () => null,
              //     );
              //   }
              // )
              // else if (model.subSection == NewTabSection.news)
              // SliverList.builder(
              //   itemCount: model.newsItems.length,
              //   itemBuilder: (context, index) {
              //     final newsItem = model.newsItems[index];
              //     return NewsCard(resource: newsItem);
              //   }
              // )
             
              
              
            ],
          ),
        ),
      ],
    );
  }

  _buildTextField() {
    return Padding(
      padding: const EdgeInsets.only(top:8.0),
      child: Container(
      
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: HexColor.fromHex('333333')))
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: TextField(
            controller: model.textController,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: 'Prompt, search or enter URL...'
            ),
            style: TextStyle(
              
            ),
          ),
        ),
      ),
    );
  }

  _buildCreateOptions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8.0),
      child: Container(
       
        child: Padding(
          padding: const EdgeInsets.only(bottom: 15.0, top: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: HexColor.fromHex(model.tabModel.workspaceModel.workspaceHexColor)))
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 0.0, left: 5),
                    child: Text('Create',
                                    
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 0.0,),
                child: Container(
                  decoration: BoxDecoration(
                  color: HexColor.fromHex('888888'),
                  borderRadius: BorderRadius.circular(8)
                ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildCreateOption(
                          title: 'Journey',
                          icon: Symbols.assistant_navigation_rounded,
                          onTap: model.createAssistedNavigation
                        ),
                        _buildCreateOption(
                          title: 'Private',
                          icon: Symbols.visibility_off_rounded,
                          onTap: model.createPrivateTab
                        ),
                        _buildCreateOption(
                          title: 'Note',
                          icon: Symbols.edit_document_rounded,
                          onTap: model.createNote
                        ),
                        _buildCreateOption(
                          title: 'Chat',
                          icon: Symbols.forum_rounded,
                          onTap: model.createChat
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _buildCreateOption({
    required String title,
    required IconData icon,
    Function()? onTap,

  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
    
          //width: 90,
          
          child: Padding(
            padding: const EdgeInsets.all(0.0),
            child: Column(
      
              children: [
                Container(
                  decoration: BoxDecoration(
                    //color: HexColor.fromHex('222222'),
                    borderRadius: BorderRadius.circular(8)
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical:  5),
                    child: Icon(
                      icon, 
                      size: 34,
                      fill: 1,
                      color: HexColor.fromHex('222222'),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 0.0),
                  child: Text(title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      
                      fontWeight: FontWeight.w600,
                      color: HexColor.fromHex('222222'),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }


  Widget _buildFavoritesSectionTitle() {
    return Padding(
      padding: const EdgeInsets.only(left: 15.0, top: 20),
      child: Container(
        child: Text('Favorites',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  _buildFavorites() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8.0),
      child: Container(

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Container(
                child: Text('Favorites',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: Container(
                width: MediaQuery.of(context).size.width - 20,
               
                child: Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  children: [...model.favoriteDomains.map((domain) {
                    return Container(
                      decoration: BoxDecoration(
                      color: HexColor.fromHex('555555'),
                        borderRadius: BorderRadius.circular(8)
                        // border: Border(
                        //   top: BorderSide(color: HexColor.fromHex('333333')),
                        //   bottom: BorderSide(color: HexColor.fromHex('333333'))
                        // )
                      ),
                      child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8),
                          child: DomainIcon(
                            domain: domain, 
                            size: 35,
                            onTap: () => model.onDomainTapped(context, domain), 
                          //onLongPress: () => model.deleteDomain(domain),)),
                          )
                        ),
                    );
                  }).toList(), Container()],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _buildSectionOptions() {
    return Container(
      decoration: BoxDecoration(
        color: HexColor.fromHex('222222')
      ),
      height: 50,
      width: 100,
      child: Row(
        
        mainAxisSize: MainAxisSize.min,
        children: model.visibleSections
          .map((sectionTitle) {
            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: model.selectedSection == sectionTitle ? HexColor.fromHex('444444') : null
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(sectionTitle,
                   style: TextStyle(
                    fontSize: 20,
                   ),
                ),
              ),
            );
          }).toList(),
      ),
    );
  }

  Widget _buildBackground() {
    return Container(
      decoration: BoxDecoration(
        color: HexColor.fromHex(model.tabModel.workspaceModel.workspaceHexColor)
      ),
      
    );
  }
}