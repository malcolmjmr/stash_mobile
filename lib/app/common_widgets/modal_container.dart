import 'package:flutter/material.dart';

class ModalContainer extends StatelessWidget {
  const ModalContainer({Key? key, required this.child}) : super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Container(
          // height: MediaQuery.of(context).size.height,
          // width: MediaQuery.of(context).size.width,
          child: Stack(
            children: [
              _buildBackground(context),
              Center(child:  child,)
            ],
          ),
        ),
      )
    );
  }

  Widget _buildBackground(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Opacity(
        opacity: 0.3,
        child: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}