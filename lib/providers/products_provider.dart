import 'package:flutter/foundation.dart';

import '../models/product.dart';
import '../services/product_service.dart';

/// Provider that owns the product list, loading state and search/filter state.
class ProductsProvider extends ChangeNotifier {
  ProductsProvider({ProductService? service}) : _service = service ?? ProductService();

  final ProductService _service;

  List<Product> _products = <Product>[];
  bool _isLoading = false;
  String? _errorMessage;
  String _searchQuery = '';
  String _selectedCategory = 'Tous';
  final List<String> _categories = <String>['Tous'];

  List<Product> get products => _products;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  String get selectedCategory => _selectedCategory;
  List<String> get categories => _categories;

  Future<void> loadProducts() async {
    if (_isLoading) {
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final fetchedProducts = await _service.fetchProducts();
      _products = fetchedProducts;
      _categories
        ..clear()
        ..add('Tous');
      _categories.addAll(
        fetchedProducts
            .map((product) => product.category)
            .toSet()
            .toList()
            .where((category) => category.trim().isNotEmpty)
            .toList()
            ..sort(),
      );
      if (!_categories.contains(_selectedCategory)) {
        _selectedCategory = 'Tous';
      }
    } catch (error) {
      _products = <Product>[];
      _errorMessage = error.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void updateSearch(String value) {
    _searchQuery = value;
    notifyListeners();
  }

  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  List<Product> get filteredProducts {
    final normalizedQuery = _searchQuery.trim().toLowerCase();

    return _products.where((product) {
      final matchesCategory = _selectedCategory == 'Tous' || product.category == _selectedCategory;
      if (!matchesCategory) {
        return false;
      }

      if (normalizedQuery.isEmpty) {
        return true;
      }

      final haystack = '${product.name} ${product.category} ${product.shortDescription}'.toLowerCase();
      return haystack.contains(normalizedQuery);
    }).toList();
  }
}
