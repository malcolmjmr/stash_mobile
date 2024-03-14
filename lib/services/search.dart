
import 'dart:convert';

import 'package:stashmobile/services/config.dart';
import 'package:http/http.dart' as http;

class SearchServices {

  searchExa(String text) {

  }

  searchBrave(String query) async {

    var response = await http.post(
      Uri.parse('https://api.search.brave.com/res/v1/web/search?q=brave+search'),
      headers: {
        'Accept': 'application/json',
        'Accept-Encoding': 'gzip',
        'X-Subscription-Token': ServicesConfig.braveApiKey,
      },
      body: jsonEncode({
        'q': query,
      }),
    );

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      return data['search']['results'];
    } else {
      print(response.statusCode);
      print(response);
    }
  }
}