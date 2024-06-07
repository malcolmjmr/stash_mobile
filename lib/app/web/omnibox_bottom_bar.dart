import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:stashmobile/app/workspace/workspace_view_model.dart';
import 'package:stashmobile/extensions/color.dart';

class OmniboxBottomBar extends StatelessWidget {
  const OmniboxBottomBar({Key? key, required this.workspaceModel,}) : super(key: key);
  final WorkspaceViewModel workspaceModel;
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildInputButtons(),
          _buildSpecialSymbols()
        ],
      ),
    );
  }

  Widget _buildInputButtons() {
    return Container(
      child: Row(
        children: [
          _buildInputButton(
            symbol: Symbols.mic_rounded, 
            onTap: () => null
          ),
          _buildInputButton(
            symbol: Symbols.photo_camera_rounded, 
            onTap: () => null
          ),

        ],
      ),
    );
  }

  Widget _buildInputButton({ required IconData symbol, Function()? onTap }) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(100),
            color: HexColor.fromHex('111111')
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(symbol,
                size: 25,
                fill: 1,
              ),
            ),
          ),
        ),
      ),
    );
  }


  Widget _buildSpecialSymbols() {
    return Container(
      child: Row(
        children: [
          _buildSpecialSymbol(':'),
          _buildSpecialSymbol('-'),
          _buildSpecialSymbol('/'),
          _buildSpecialSymbol('.com')
        ],
      ),
    );
  }

  Widget _buildSpecialSymbol(String symbol) {
    return GestureDetector(
      onTap: () => workspaceModel.addSpecialSymbolToOmniboxInput(symbol),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8),
        child: Container(
          child: Text(symbol,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500
            ),
          ),
        ),
      ),
    );
  }
}