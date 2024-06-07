import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:stashmobile/app/common_widgets/tag.dart';
import 'package:stashmobile/app/profile/profile_view_model.dart';
import 'package:stashmobile/extensions/color.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({Key? key}) : super(key: key);

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {

  late ProfileViewModel model;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    model = ProfileViewModel(context, setState);

  }

  @override
  Widget build(BuildContext context) {
    print(model.summary);
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        body: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildHeader(),),
            
            SliverToBoxAdapter(child: _buildTerms()),
            SliverToBoxAdapter(child: _buildSummary(),),
            SliverToBoxAdapter(child: _buildFavorites()),
          ],
        ),
      )
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
      width: MediaQuery.of(context).size.width,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
        
          Text('Profile',
            style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
          
          ),
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(Icons.close_rounded),
            ),
          )

        ],
      ),
    );
  }

  Widget _buildSummary() {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Container(
          decoration: BoxDecoration(
            color: HexColor.fromHex('111111'),
            border: Border(top: BorderSide(color: HexColor.fromHex('222222')), bottom: BorderSide(color: HexColor.fromHex('222222')))
          ),
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Text(model.summary, 
              style: TextStyle(
                fontSize: 20,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTerms() {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: Wrap(
        children: model.favoriteTerms
          .sublist(0, 25)
          .map((tag) => Padding(
            padding: const EdgeInsets.all(6.0),
            child: TagChip(tag: tag),
          ))
          .toList(),
      ),
    );
  }

  Widget _buildFavorites() {
    return Container();
  }
}