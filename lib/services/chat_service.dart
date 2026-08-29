import 'dart:convert';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import '../api_service.dart';

class ChatService {
  ChatService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  // PC LAN IP for physical Android/iOS devices on same Wi-Fi.
  static const String baseUrl = 'http://192.168.100.10:3000';
  static const String _chatEndpoint = '/ai/chat';

  /// Sends a question to `/ai/chat` with optional conversationId and returns a map.
  Future<Map<String, dynamic>> askQuestion(String question, {String? conversationId}) async {
    final String fullUrl = '$baseUrl$_chatEndpoint';
    final Uri uri = Uri.parse(fullUrl);
    final token = await ApiService.getToken();

    final String payload = jsonEncode({
      'question': question,
      if (conversationId != null) 'conversationId': conversationId,
    });

    developer.log(
      '[CHAT REQUEST] POST $fullUrl\n'
      'Body: $payload',
      name: 'TunTrust',
    );

    try {
      final http.Response response = await _client
          .post(
        uri,
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: payload,
      )
          .timeout(
        const Duration(seconds: 90),
      );

      developer.log(
        '[CHAT RESPONSE]\n'
        'URL: $fullUrl\n'
        'Status: ${response.statusCode}\n'
        'Body: ${response.body}',
        name: 'TunTrust',
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final dynamic decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          return decoded;
        }
        throw const FormatException('Format de réponse invalide.');
      }

      throw Exception(
        'Le serveur a retourné une erreur HTTP ${response.statusCode}.\n'
        'Response: ${response.body}',
      );
    } catch (error) {
      developer.log(
        '[CHAT ERROR]\n'
        'URL: $fullUrl\n'
        'Error: $error',
        name: 'TunTrust',
      );

      throw Exception(
        'Impossible de se connecter à l\'assistant TunTrust: $error',
      );
    }
  }

  /// Lists all conversations of the authenticated user.
  Future<List<dynamic>> getConversations() async {
    final token = await ApiService.getToken();
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl/ai/conversations'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as List<dynamic>;
      }
      throw Exception('Erreur HTTP ${response.statusCode}: ${response.body}');
    } catch (error) {
      developer.log('[GET CONVERSATIONS ERROR] $error', name: 'TunTrust');
      throw Exception('Impossible de charger les conversations: $error');
    }
  }

  /// Retrieves a specific conversation details (including messages).
  Future<Map<String, dynamic>> getConversation(String id) async {
    final token = await ApiService.getToken();
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl/ai/conversations/$id'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      throw Exception('Erreur HTTP ${response.statusCode}: ${response.body}');
    } catch (error) {
      developer.log('[GET CONVERSATION ERROR] $error', name: 'TunTrust');
      throw Exception('Impossible de charger la conversation: $error');
    }
  }

  /// Creates a new conversation.
  Future<Map<String, dynamic>> createConversation() async {
    final token = await ApiService.getToken();
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl/ai/conversations'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      throw Exception('Erreur HTTP ${response.statusCode}: ${response.body}');
    } catch (error) {
      developer.log('[CREATE CONVERSATION ERROR] $error', name: 'TunTrust');
      throw Exception('Impossible de créer la conversation: $error');
    }
  }

  /// Deletes a conversation.
  Future<void> deleteConversation(String id) async {
    final token = await ApiService.getToken();
    try {
      final response = await _client.delete(
        Uri.parse('$baseUrl/ai/conversations/$id'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200 || response.statusCode == 201) {
        return;
      }
      throw Exception('Erreur HTTP ${response.statusCode}: ${response.body}');
    } catch (error) {
      developer.log('[DELETE CONVERSATION ERROR] $error', name: 'TunTrust');
      throw Exception('Impossible de supprimer la conversation: $error');
    }
  }

  void dispose() {
    _client.close();
  }
}