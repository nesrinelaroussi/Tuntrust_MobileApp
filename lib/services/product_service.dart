import 'dart:convert';
import 'dart:developer' as developer;

import 'package:http/http.dart' as http;

import '../models/product.dart';

/// Fetches product catalog data from the NestJS backend.
class ProductService {
  ProductService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;
  static const List<String> _candidateBaseUrls = <String>[
    'http://192.168.100.10:3000',
    'http://10.0.2.2:3000',
    'http://127.0.0.1:3000',
  ];
  static const String _productsEndpoint = '/products';

  Future<List<Product>> fetchProducts({String? baseUrl}) async {
    final candidates = <String>[
      if (baseUrl != null && baseUrl.isNotEmpty) baseUrl,
      ..._candidateBaseUrls,
    ];

    for (final candidate in candidates) {
      final uri = Uri.parse('$candidate$_productsEndpoint');
      try {
        final response = await _client.get(
          uri,
          headers: {'Accept': 'application/json'},
        ).timeout(const Duration(seconds: 8));

        developer.log('Product API response from $uri => ${response.statusCode} ${response.body}', name: 'TunTrust');

        if (response.statusCode == 200) {
          final decoded = jsonDecode(response.body);
          if (decoded is! List) {
            throw const FormatException('Format de réponse inattendu depuis l’API.');
          }

          return decoded
              .whereType<Map>()
              .map((item) => Product.fromJson(Map<String, dynamic>.from(item)))
              .toList();
        }
      } catch (error) {
        developer.log('Product API error on $uri: $error', name: 'TunTrust');
        continue;
      }
    }

    throw Exception('Impossible de charger les produits depuis l’API. Vérifiez que le backend NestJS est lancé et accessible depuis l’émulateur.');
  }
}
