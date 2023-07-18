import 'package:flutter/material.dart';
import 'package:stashmobile/models/content/content.dart';

class ContentIcon extends StatelessWidget {
  final Content content;
  final Color? color;
  final double? size;
  ContentIcon(this.content, {this.color, this.size = 20});

  IconData get icon {
    Map<ContentType, IconData Function()> icons = {
      ContentType.annotation: () => Icons.format_quote_rounded,
      ContentType.filter: () => Icons.filter_list,
      ContentType.webSearch: () => Icons.travel_explore,
      ContentType.webSite: () => Icons.language,
      ContentType.webArticle: () => Icons.article,
      ContentType.topic: () => Icons.topic,
      ContentType.tag: () => Icons.local_offer,
      ContentType.note: () => Icons.short_text,
      ContentType.root: () => Icons.account_tree_outlined,
      ContentType.dailyPage: () => Icons.today,
      ContentType.task: () =>
          content.task != null && content.task!.completed != null
              ? Icons.check_box
              : Icons.check_box_outline_blank,
    };

    if (icons.containsKey(content.type))
      return icons[content.type]!();
    else
      return Icons.circle;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 5.0),
      child: content.iconUrl != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Container(
                height: size,
                width: size,
                child: Image.network(
                  content.iconUrl!,
                  cacheHeight: 25,
                  cacheWidth: 25,
                ),
              ),
            )
          : Icon(
              icon,
              color: color,
              size: size,
            ),
    );
  }
}
