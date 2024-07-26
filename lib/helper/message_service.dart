import 'package:http/http.dart' as http;

class MessageService {
  Future<void> sendMessage(String token, String message) async {
    final uri = Uri.https('us-central1-chatting-app-2-8e7d4.cloudfunctions.net', '/sendMessage', {
      'token': token,
      'message': message,
    });

    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        print('Message sent successfully');
      } else {
        print('Failed to send message: ${response.body}');
      }
    } catch (e) {
      print('Error sending message: $e');
    }
  }
}
