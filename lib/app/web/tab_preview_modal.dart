import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:stashmobile/models/resource.dart';

class TabPreviewModal extends StatelessWidget {

  final Resource resource;
  const TabPreviewModal({Key? key, required this.resource}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Container(
        height: MediaQuery.of(context).size.height * .66,
        //width: MediaQuery.of(context).size.width * .9,
        child: InAppWebView(
          initialUrlRequest: URLRequest(url: Uri.parse(resource.url!)),
        ),
      ),
    );
  }
}