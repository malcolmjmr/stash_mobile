import 'package:flutter/material.dart';
import 'package:stashmobile/models/field/field.dart';

final List<Field> defaultFields = [
  Field(
    name: 'Type',
    path: 'type',
    type: FieldType.contentType,
    isCustomField: false,
    iconIndex: Icons.category.codePoint,
  ),
  Field(
    name: 'Back Links',
    path: 'links.back',
    type: FieldType.link,
    isCustomField: false,
    iconIndex: Icons.north_west.codePoint,
  ),
  Field(
    name: 'Forward Links',
    path: 'links.forward',
    type: FieldType.link,
    isCustomField: false,
    iconIndex: Icons.south_east.codePoint,
  ),
  Field(
    name: 'Tags',
    path: 'tags.values',
    type: FieldType.tag,
    isCustomField: false,
    iconIndex: Icons.style.codePoint,
  ),
  Field(
    name: 'Ratings',
    path: 'ratings.value',
    type: FieldType.rating,
    isCustomField: false,
    iconIndex: Icons.star.codePoint,
  ),
  Field(
    name: 'Created',
    path: 'created',
    type: FieldType.date,
    isCustomField: false,
    iconIndex: Icons.more_time.codePoint,
  ),
  Field(
    name: 'Last Visited',
    path: 'visits.last',
    type: FieldType.date,
    isCustomField: false,
    iconIndex: Icons.update.codePoint,
  ),
  Field(
    name: 'Visits',
    path: 'visits.count',
    type: FieldType.number,
    isCustomField: false,
    iconIndex: Icons.update.codePoint,
  ),
  Field(
    name: 'Last Updated',
    path: 'updates.last',
    type: FieldType.date,
    isCustomField: false,
    iconIndex: Icons.touch_app.codePoint,
  ),
  Field(
    name: 'Reminder',
    path: 'reminder.next',
    type: FieldType.date,
    isCustomField: false,
    iconIndex: Icons.schedule.codePoint,
  ),
  Field(
    name: 'Read Aloud',
    path: 'webArticle.readAloud',
    type: FieldType.date,
    isCustomField: false,
    iconIndex: Icons.schedule.codePoint,
  ),
  Field(
    name: 'Listen Count',
    path: 'webArticle.readAloud',
    type: FieldType.date,
    isCustomField: false,
    iconIndex: Icons.schedule.codePoint,
  ),
];
