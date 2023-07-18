import 'dart:convert' as convert;
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:stashmobile/models/content/content.dart';
import 'package:stashmobile/models/user/model.dart';
import 'package:html/parser.dart';
import 'package:stashmobile/services/hypothesis.dart';

class RandomGenerator {
  static Future<User?> user() async {
    // Get random user data
    final url = Uri.https('randomuser.me', '/api/');
    final response = await http.get(url);
    if (response.statusCode != 200) {
      print('Request failed with status: ${response.statusCode}.');
      return null;
    }
    var data = convert.jsonDecode(response.body)['results'][0];
    final name = data['name']['first'] + ' ' + data['name']['last'];
    final imageUrl = data['picture']['medium'];
    return User(name: name, imageUrl: imageUrl);

    // Todo: Add friends through preferential attachment
  }

  static Future<List<User>> multipleUsers({int count = 10}) async {
    List<User> users = [];
    final url =
        Uri.https('randomuser.me', '/api/', {'results': count.toString()});
    final response = await http.get(url);
    if (response.statusCode != 200) {
      print('Request failed with status: ${response.statusCode}.');
      return users;
    }
    var jsonUsers = convert.jsonDecode(response.body)['results'];
    for (Map<String, dynamic> jsonUser in jsonUsers) {
      final name = jsonUser['name']['first'] + ' ' + jsonUser['name']['last'];
      final imageUrl = jsonUser['picture']['medium'];
      users.add(User(name: name, imageUrl: imageUrl));
    }
    return users;
  }

  Future<String> htmlText({
    String type = 'gibberish',
    int paragraphCount = 10,
    int paragraphLengthMin = 5,
    int paragraphLengthMax = 10,
  }) async {
    final url = Uri.https('randomtext.me',
        '/api/$type/p-$paragraphCount/$paragraphLengthMin-$paragraphLengthMax');

    final response = await http.get(url);
    if (response.statusCode != 200) {
      print('Request failed with status: ${response.statusCode}.');
      return '';
    }
    final json = utf8.decode(response.bodyBytes);
    return convert.jsonDecode(json)['text_out'];
  }

  Future<String> text({String type = 'lorem', int wordLength = 100}) async {
    final html = await htmlText(
        type: type,
        paragraphCount: 1,
        paragraphLengthMax: wordLength,
        paragraphLengthMin: wordLength);
    return parse(html).getElementsByTagName('p').first.text;
  }

  Future<List<String>> kanyeQuotes({int count = 10}) async {
    List<String> quotes = [];
    for (int i = 0; i < count; i++) {
      quotes.add(await kanyeQuote());
      sleep(const Duration(milliseconds: 100));
    }
    return quotes;
  }

  Future<String> kanyeQuote() async {
    final url = Uri.https('api.kanye.rest', '/', {'format': 'text'});

    final response = await http.get(url);
    if (response.statusCode != 200) {
      print('Request failed with status: ${response.statusCode}.');
      return '';
    }
    final json = utf8.decode(response.bodyBytes);
    return convert.jsonDecode(json)['quote'];
  }

  Future<List<String>> imageUrls({int count = 10}) async {
    List<String> results = [];
    final limitPerPage = 100;
    int pages = 1;
    if (count > 100) {
      pages = (count / 100).round();
    }

    for (int page = 0; page < pages; page++) {
      final totalResultCount = (page + 1) * limitPerPage;
      final lessThanMaxRequired = page > 0 && totalResultCount > count;
      if (lessThanMaxRequired) count = totalResultCount - count;

      final url = Uri.https(
        'picsum.photos',
        '/v2/list',
        {
          'page': 1.toString(),
          'limit': count.toString(),
        },
      );

      final response = await http.get(url);
      if (response.statusCode != 200) {
        print('Request failed with status: ${response.statusCode}.');
        return [];
      }
      final json = utf8.decode(response.bodyBytes);
      final List imageData = convert.jsonDecode(json);
      results.addAll(imageData
          .map((image) => 'https://picsum.photos/id/${image['id']}/300'));
    }
    return results;
  }

  Future<List<Content>> hypothesisAnnotations({int count = 10}) async {
    final limit = 200;
    final years = [2016, 2017, 2018, 2019, 2020];
    final searchAfter = DateTime(
      years[Random().nextInt(years.length)],
      Random().nextInt(12),
      Random().nextInt(27),
    ).microsecondsSinceEpoch;
    print(searchAfter);
    final h = Hypothesis();
    List annotations = await h.search(params: {
      'search_after': searchAfter.toString(),
      'limit': limit.toString(),
    });
    annotations.shuffle();
    annotations = annotations
        .where((a) => a['target'].first['selector'] != null)
        .toList()
        .sublist(0, count);

    return annotations
        .map(
            (annotation) => h.normalizeAnnotationFromHypothesisData(annotation))
        .toList();
  }
}
