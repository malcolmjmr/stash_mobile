class Article {
  int place = 0;
  String? imageUrl;
  List<ArticleSection> sections = [];

  ArticleSection? get currentSection =>
      sections.isEmpty || place == sections.length ? null : sections[place];
  ArticleSection? get previousSection =>
      sections.isEmpty || place - 1 < 0 ? null : sections[place - 1];
  ArticleSection? get nextSection =>
      sections.isEmpty || place + 1 == sections.length
          ? null
          : sections[place + 1];

  ArticleSection? get currentHeading {
    if (currentSection == null) return null;
    if (currentSection!.isHeading)
      return currentSection;
    else if (currentSection!.parentId >= 0)
      return sections[currentSection!.parentId];
    else
      return null;
  }

  Article.fromWebView(List json) {
    sections = json.map((section) {
      final index = json.indexOf(section);
      return ArticleSection.fromWebView(index, section);
    }).toList();
  }

  Article.fromJson(Map<String, dynamic> json) {
    sections = List<ArticleSection>.from(
      json['sections'].map(
        (s) => ArticleSection.fromJson(s),
      ),
    );
    place = json['place'];
    imageUrl = json['imageUrl'];
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {
      'sections': sections.map((s) => s.toJson()).toList(),
      'place': place,
      'imageUrl': imageUrl,
    };
    json.removeWhere((key, value) => value == null);
    return json;
  }

  List<ArticleSection> get headings => getSubHeadings(sections[0]);

  List<ArticleSection> getSubHeadings(ArticleSection section) {
    return section.childrenIds
        .where((id) => sections[id].tag.contains('h'))
        .map(
      (id) {
        ArticleSection s = sections[id];
        s.subHeadings = getSubHeadings(s);
        return s;
      },
    ).toList();
  }
}

class ArticleSection {
  late int index;
  late String tag;
  late String text;
  late int parentId;
  ArticleSection? parent;
  late List<int> childrenIds;
  List<ArticleSection> subHeadings = [];
  bool get isHeading => tag.contains('h');

  ArticleSection.fromWebView(this.index, Map<String, dynamic> section) {
    tag = section['tag'];
    text = section['text'] ?? '';
    parentId = section['parent'] ?? -1;
    childrenIds =
        section['sections'] != null ? List<int>.from(section['sections']) : [];
  }

  ArticleSection.fromJson(Map<String, dynamic> json) {
    index = json['index'];
    tag = json['tag'];
    text = json['text'];
    parentId = json['parentId'];
    childrenIds = List<int>.from(json['childrenIds']);
  }

  Map<String, dynamic> toJson() => {
        'index': index,
        'tag': tag,
        'text': text,
        'parentId': parentId,
        'childrenIds': childrenIds,
      };

  @override
  String toString() {
    // TODO: implement toString
    return '<$tag:$text>';
  }
}
