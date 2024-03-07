

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:stashmobile/services/config.dart';

class LLM {

  static const termModel = 'babbage-002';


  mistralChatCompletion({
    String? prompt, 
    String? systemPrompt, 
    List<Map>? messages, 
    String? model = 'open-mistral-7b', 
    int? maxTokens = 500, 
    double? temp = 0.5
  }) async {
    const String apiUrl = 'https://api.mistral.ai/v1/chat/completions';

    if (messages == null && prompt == null) return;

    var response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${ServicesConfig.mistralApiKey}',
      },
      body: jsonEncode({
        'model': model, // You can choose a different model based on your needs
        'messages': prompt != null 
          ? [{
              "role": "system",
              "content": "You are a helpful assistant."
            },
            {
              "role": "user",
              "content": prompt
            }]
          : messages,
        'max_tokens': maxTokens, // Adjust based on how lengthy you expect the response to be
        'temperature': temp, // Adjust for creativity. Lower values mean more deterministic.
      }),
    );

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      print('got response from mistral');
      print(data);
      String generatedText = data['choices'][0]['message']['content'];
      // Further processing can be done here to clean and format the generated list

      return generatedText;
    } else {
      print(response.statusCode);
      print(response.body);

      throw Exception('Failed to load related terms');
      
    }
  }



  openAiChatCompletion({String? prompt, List<Map>? messages, String? model = 'gpt-3.5-turbo-0125', int? maxTokens = 500, double? temp = 0}) async {
    const String openAiUrl = 'https://api.openai.com/v1/chat/completions';

    if (messages == null && prompt == null) return;

    var response = await http.post(
      Uri.parse(openAiUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${ServicesConfig.openAiApiKey}',
      },
      body: jsonEncode({
        'model': model, // You can choose a different model based on your needs
        'messages': prompt != null 
          ? [{
              "role": "system",
              "content": "You are a helpful assistant."
            },
            {
              "role": "user",
              "content": prompt
            }]
          : messages,
        'max_tokens': maxTokens, // Adjust based on how lengthy you expect the response to be
        'temperature': temp, // Adjust for creativity. Lower values mean more deterministic.
      }),
    );

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      print('got response from OpenAI');
      print(data);
      String generatedText = data['choices'][0]['message']['content'];
      // Further processing can be done here to clean and format the generated list

      return generatedText;
    } else {
      print(response.statusCode);
      print(response.body);

      throw Exception('Failed to load related terms');
      
    }
  }

  searchExa(String prompt) {

  }
}