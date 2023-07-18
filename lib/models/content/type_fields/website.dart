class WebsiteFields {
  late String url;
  int? scrollPosition;

  WebsiteFields({required this.url});

  WebsiteFields.fromJson(Map<String, dynamic> json) {
    url = json['url'];
    scrollPosition = json['scrollPosition'];
  }
  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'scrollPosition': scrollPosition,
    };
  }
}
