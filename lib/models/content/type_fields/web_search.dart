class WebSearchFields {
  late String query;
  late String url;
  WebSearchFields({required this.query, required this.url});

  WebSearchFields.fromJson(Map<String, dynamic> json) {
    url = json['url'];
    query = json['query'];
  }

  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'query': query,
    };
  }
}
