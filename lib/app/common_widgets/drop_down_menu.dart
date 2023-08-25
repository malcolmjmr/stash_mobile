import 'package:flutter/material.dart';
import 'package:stashmobile/extensions/color.dart';



class DropDownMenu extends StatelessWidget {

  final List<Widget> menuItems;
  const DropDownMenu({Key? key, required this.menuItems}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Stack(
        fit: StackFit.expand,
        children: [
          _buildBackground(context),
          _buildMenu(context),
        ],
      ),
    );
  }

  Widget _buildBackground(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
      ),
    );
  }

  Widget _buildMenu(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: HexColor.fromHex('222222'),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: menuItems,
      ),
    );
  }

}



class DropDownMenuItem extends StatelessWidget {

  final Function() onTap;
  final String label;
  final IconData icon;
  const DropDownMenuItem({Key? key, 
    required this.onTap, 
    required this.label, 
    required this.icon
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        child: Row(
          children: [
            Expanded(child: Text(label)),
            Padding(
              padding: const EdgeInsets.only(left: 5.0),
              child: Icon(icon),
            ),

          ],
        ),
      ),
    );
  }
}

class DropDownMenuDivider extends StatelessWidget {
  const DropDownMenuDivider({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 2,
      color: HexColor.fromHex('444444'),
    );
  }
}