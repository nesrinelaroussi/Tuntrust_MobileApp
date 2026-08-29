import 'package:flutter_test/flutter_test.dart';
import 'package:tuntrust_flutter/models/product.dart';

void main() {
  group('Product', () {
    test('fromJson maps backend fields correctly', () {
      final product = Product.fromJson({
        '_id': 'abc123',
        'name': 'Organisation SSL',
        'shortDescription': 'Short summary',
        'category': 'Sécurité web',
        'benefits': ['Durée de validité : 1 an'],
        'targetUsers': ['Entreprises'],
        'icon': '🔐',
        'simplifiedFeatures': ['Certificat logiciel'],
        'image': 'https://example.com/image.png',
        'url': 'https://example.com',
      });

      expect(product.id, 'abc123');
      expect(product.name, 'Organisation SSL');
      expect(product.category, 'Sécurité web');
      expect(product.benefits, contains('Durée de validité : 1 an'));
      expect(product.simplifiedFeatures, isNotEmpty);
    });
  });
}
