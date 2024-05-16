import 'package:flutter/material.dart';
import 'package:stashmobile/models/resource.dart';

class NewsCard extends StatelessWidget {
  const NewsCard({Key? key, required this.resource }) : super(key: key);
  final Resource resource;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text(resource.title ?? ''),
    );
  }
}