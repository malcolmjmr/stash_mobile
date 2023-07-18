class Category {
  String name;

  List<String> parents = [];
  List<String> children = [];
  List<String> collections = [];

  Category({required this.name});

  Category.fromDatabase(this.name, Map<String, dynamic> json) {
    parents = List<String>.from(json['parents']);
    children = List<String>.from(json['children']);
    collections = List<String>.from(json['collections']);
  }

  Map<String, dynamic> toJson() {
    return {
      'parents': parents,
      'children': children,
      'collections': collections,
    };
  }

  @override
  String toString() {
    // TODO: implement toString
    return '<Category[$name]${toJson().toString()}>';
  }
}
