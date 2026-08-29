import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:tuntrust_flutter/services/chat_service.dart';

void main() {
  test('returns answer string when NestJS backend returns HTTP 201 JSON with answer', () async {
    final client = MockClient((request) async {
      expect(request.method, 'POST');
      expect(request.url.toString(), 'http://192.168.100.10:3000/ai/chat');
      expect(request.headers['Content-Type'], 'application/json');
      expect(jsonDecode(request.body), {'question': 'What is ID-Trust?'});

      return http.Response(
        jsonEncode({'answer': 'ID-Trust est un certificat...', 'responseTimeMs': 1234}),
        201,
        headers: {'content-type': 'application/json'},
      );
    });

    final service = ChatService(client: client);
    final answer = await service.askQuestion('What is ID-Trust?');
    expect(answer, 'ID-Trust est un certificat...');
  });

  test('returns answer string when NestJS backend returns HTTP 200 JSON with answer', () async {
    final client = MockClient((request) async {
      return http.Response(
        jsonEncode({'answer': 'ID-Trust OK'}),
        200,
        headers: {'content-type': 'application/json'},
      );
    });

    final service = ChatService(client: client);
    final answer = await service.askQuestion('What is ID-Trust?');
    expect(answer, 'ID-Trust OK');
  });
}
