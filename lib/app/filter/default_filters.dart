import 'package:stashmobile/models/content/content.dart';
import 'package:stashmobile/models/content/type_fields/filter.dart';

final defaultFilters = [
  Content(
    name: 'Newest',
    type: ContentType.filter,
    filter: FilterFields(
      fieldSpecs: [FieldSpec(fieldPath: 'created', sortAscending: false)],
    ),
  ),
  Content(
    name: 'Recent',
    type: ContentType.filter,
    filter: FilterFields(
      fieldSpecs: [FieldSpec(fieldPath: 'visits.last', sortAscending: false)],
    ),
  ),
  Content(
    name: 'Favorites',
    type: ContentType.filter,
    filter: FilterFields(
      fieldSpecs: [FieldSpec(fieldPath: 'visits.count', sortAscending: false)],
    ),
  ),
  Content(
    name: 'Top',
    type: ContentType.filter,
    filter: FilterFields(
      fieldSpecs: [FieldSpec(fieldPath: 'ratings.value', sortAscending: false)],
    ),
  ),
  Content(
    name: 'To Visit',
    type: ContentType.filter,
    filter: FilterFields(
      fieldSpecs: [
        FieldSpec(fieldPath: 'visits', operations: [
          Operation(
            operator: FilterOperator.doesNotExist,
            values: [],
          )
        ])
      ],
    ),
  ),
  Content(
    name: 'Tasks',
    type: ContentType.filter,
    filter: FilterFields(
      fieldSpecs: [
        FieldSpec(fieldPath: 'type', operations: [
          Operation(
            operator: FilterOperator.equals,
            values: [ContentType.task.index],
          )
        ]),
        FieldSpec(fieldPath: 'task.completed', operations: [
          Operation(
            operator: FilterOperator.doesNotExist,
            values: [],
          )
        ])
      ],
    ),
  ),
  Content(
    name: 'Highlights',
    type: ContentType.filter,
    filter: FilterFields(
      fieldSpecs: [
        FieldSpec(fieldPath: 'type', operations: [
          Operation(
            operator: FilterOperator.equals,
            values: [ContentType.annotation.index],
          )
        ]),
      ],
    ),
  ),
  Content(
    name: 'Daily Pages',
    type: ContentType.filter,
    filter: FilterFields(
      fieldSpecs: [
        FieldSpec(fieldPath: 'type', operations: [
          Operation(
            operator: FilterOperator.equals,
            values: [ContentType.dailyPage.index],
          )
        ]),
      ],
    ),
  ),
  Content(
    name: 'Topics',
    type: ContentType.filter,
    filter: FilterFields(
      fieldSpecs: [
        FieldSpec(fieldPath: 'type', operations: [
          Operation(
            operator: FilterOperator.equals,
            values: [ContentType.topic.index],
          )
        ]),
      ],
    ),
  ),
  Content(
    name: 'Searches',
    type: ContentType.filter,
    filter: FilterFields(
      fieldSpecs: [
        FieldSpec(fieldPath: 'type', operations: [
          Operation(
            operator: FilterOperator.equals,
            values: [ContentType.webSearch.index],
          )
        ]),
      ],
    ),
  ),
  Content(
    name: 'Oldest',
    type: ContentType.filter,
    filter: FilterFields(
      fieldSpecs: [FieldSpec(fieldPath: 'created', sortAscending: true)],
    ),
  ),
];
