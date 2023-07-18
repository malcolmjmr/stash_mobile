import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:stashmobile/app/keyboard/model.dart';

class Keyboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ChangeNotifierProvider(
        create: (context) => KeyboardViewModel(context),
        child: Consumer<KeyboardViewModel>(builder: (context, model, _) {
          return model.isLoading
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : Container(
                  child: Column(
                    children: [
                      _buildOutput(model),
                      //_buildTwoThumbInput(model),
                      _buildTwoLineInput(model),
                    ],
                  ),
                );
        }),
      ),
    );
  }

  Widget _buildOutput(KeyboardViewModel model) => Expanded(
        child: Center(
          child: Text(model.text, style: GoogleFonts.lato(fontSize: 20)),
        ),
      );

  // Widget _buildTwoThumbInput(KeyboardViewModel model) => Row(children: [
  // Expanded(
  // child: ListView(
  // scrollDirection: Axis.horizontal,
  //   children: [
  //     ...model.sortedConsonants
  //         .map((char) => GestureDetector(
  //       onTap: () => model.onInput(char),
  //       child: Padding(
  //         padding: const EdgeInsets.all(5.0),
  //         child: char == ' '
  //             ? Container()
  //             : Text(char, style: GoogleFonts.lato(fontSize: 20)),
  //       ),
  //     ))
  //         .toList()
  //   ],
  // ),
  // );
  // ],)

  Widget _buildTwoLineInput(KeyboardViewModel model) => Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          height: 80,
          child: Column(
            children: [
              _buildTopRow(model),
              _buildBottomRow(model),
            ],
          ),
        ),
      );

  Widget _buildTopRow(KeyboardViewModel model) => Expanded(
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: [
            ...model.sortedConsonants
                .map((char) => GestureDetector(
                      onTap: () => model.onInput(char),
                      child: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: char == ' '
                            ? Container()
                            : Text(char, style: GoogleFonts.lato(fontSize: 20)),
                      ),
                    ))
                .toList()
          ],
        ),
      );

  Widget _buildBottomRow(KeyboardViewModel model) => Expanded(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            GestureDetector(
              onLongPress: model.onClear,
              onTap: model.onBackspace,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(Icons.clear),
              ),
            ),
            ...model.sortedVowels
                .map((char) => GestureDetector(
                      onTap: () => model.onInput(char),
                      child: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Text(char,
                            style: GoogleFonts.lato(
                              fontSize: 20,
                            )),
                      ),
                    ))
                .toList()
                  ..reversed.toList(),
            GestureDetector(
              onTap: () => model.onInput(' '),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(Icons.space_bar),
              ),
            ),
          ],
        ),
      );
}
