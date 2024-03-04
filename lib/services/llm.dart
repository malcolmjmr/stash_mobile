

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:stashmobile/services/config.dart';

class LLM {

  static const termModel = 'babbage-002';

  getCompletion(String prompt, {String? model = termModel, int? maxTokens = 500, double? temp = 0}) async {
    const String openAiUrl = 'https://api.openai.com/v1/completions';


    var response = await http.post(
      Uri.parse(openAiUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${ServicesConfig.openAiApiKey}',
      },
      body: jsonEncode({
        'model': model, // You can choose a different model based on your needs
        'prompt': prompt,
        'max_tokens': maxTokens, // Adjust based on how lengthy you expect the response to be
        'temperature': temp, // Adjust for creativity. Lower values mean more deterministic.
      }),
    );

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      String generatedText = data['choices'][0]['text'].trim();
      // Further processing can be done here to clean and format the generated list
      print('got response from OpenAI');
      print(data);
      return generatedText;
    } else {
      print(response.statusCode);
      print(response.body);

      throw Exception('Failed to load related terms');
      
    }
  }

  getChatCompletion() {

  }

  searchExa(String prompt) {
    
  }
}