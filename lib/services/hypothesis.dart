import 'dart:convert' as convert;
import 'package:http/http.dart' as http;

class Hypothesis {
  static const apiAuthority = 'hypothes.is';
  static const apiPath = '/api/';
  static const apiToken = '6879-iJu2OMVyz_f56KJH-4WAglvqwtlvsPrh505dZ4rx-F8';
  static const userName = 'malcolmjmr';

  static const publicGroupName = '__world__';

  Hypothesis() {
    createRequestHeader();
  }

  late Map<String, String> requestHeader;

  createRequestHeader() {
    requestHeader = {
      'Authorization': 'Bearer $apiToken',
      'Accept': 'application/json'
    };
  }

  Future<List<dynamic>> getUserAnnotations(String user, {int? limit}) async {
    // Todo: Get all annotations using multiple requests
    final requestLimit = 200;
    final params = {
      'user': user,
      'limit': limit != null && limit < requestLimit
          ? limit.toString()
          : requestLimit.toString(),
      'sort': 'created',
    };

    List allAnnotations = [];
    int? annotationsLeft;
    bool moreToFetch(List annotations) =>
        annotations.length == 0 ||
        annotations.length % int.parse(params['limit']!) == 0 ||
        annotations.length == limit;

    print('Getting annotations for $user.');

    while (moreToFetch(allAnnotations)) {
      final List batch = await search(params: params);
      print('Got new batch of ${batch.length}');
      allAnnotations.addAll(batch);
      params['search_after'] = batch.last['created'];
      if (limit != null) {
        annotationsLeft = limit - allAnnotations.length;
        if (annotationsLeft == 0) {
          break;
        } else if (annotationsLeft < requestLimit) {
          params['limit'] = annotationsLeft.toString();
        }
      }
    }
    return allAnnotations;
  }

  Future<List<dynamic>> search({Map<String, dynamic>? params}) async {
    final path = apiPath + 'search';
    final url = Uri.https(apiAuthority, path, params);
    final response = await http.get(url, headers: requestHeader);
    if (response.statusCode != 200) {
      print('Request failed with status: ${response.statusCode}.');
      return [];
    }
    return convert.jsonDecode(response.body)['rows'];
  }


  Future<String?> createAnnotation(Map<String, dynamic> annotationData) async {
    final path = apiPath + 'annotations';
    final url = Uri.https(apiAuthority, path);
    final response = await http.post(
      url,
      headers: requestHeader,
      body: convert.jsonEncode(annotationData),
    );
    if (response.statusCode == 200) {
      return convert.jsonDecode(response.body)['id'];
    }
    return null;
  }
}
