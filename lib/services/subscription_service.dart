import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../api_service.dart';
import 'revenuecat_bridge.dart';
import 'store_offer.dart';

/// Service central d'abonnement et de gestion du quota gratuit pour TunTrust.
class SubscriptionService extends ChangeNotifier {
  static final SubscriptionService instance = SubscriptionService._();
  factory SubscriptionService() => instance;
  SubscriptionService._();

  /// Clé d'API publique RevenueCat TEST (identique à MedAIChain preprod4)
  static const String revenueCatApiKeyAndroid = 'test_mThrMrvmkejjQOaswkPPTrxmuLA';
  static const String revenueCatApiKeyIos = 'test_mThrMrvmkejjQOaswkPPTrxmuLA';

  /// Identifiant de l'entitlement configuré dans RevenueCat pour TunTrust Pro.
  static const String premiumEntitlementId = 'tuntrust_pro';

  /// Nombre maximum de questions gratuites autorisées par utilisateur.
  static const int maxFreeQuestions = 3;

  bool _isInitialized = false;
  bool _isSubscribed = false;
  int _questionCount = 0;
  String? _currentUserId;

  bool get isInitialized => _isInitialized;
  bool get isSubscribed => _isSubscribed;
  int get questionCount => _questionCount;
  String? get currentUserId => _currentUserId;

  /// Nombre de questions gratuites restantes.
  int get remainingFreeQuestions {
    if (_isSubscribed) return 999;
    final remaining = maxFreeQuestions - _questionCount;
    return remaining < 0 ? 0 : remaining;
  }

  /// Indique si l'utilisateur a le droit de poser une question à l'IA.
  bool get canAskQuestion => _isSubscribed || _questionCount < maxFreeQuestions;

  /// Initialise le service d'abonnement au démarrage de l'application.
  Future<void> initialize() async {
    if (_isInitialized) return;
    try {
      final user = await ApiService.getUser();
      final userId = user?['id']?.toString() ?? user?['_id']?.toString();
      _currentUserId = userId;

      final apiKey = defaultTargetPlatform == TargetPlatform.iOS
          ? revenueCatApiKeyIos
          : revenueCatApiKeyAndroid;

      await RevenueCatBridge.configure(apiKey, userId: userId);

      if (userId != null && userId.isNotEmpty) {
        await syncBackendSubscription();
      }

      await checkSubscriptionStatus();
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Erreur lors de l\'initialisation de SubscriptionService: $e');
      _isInitialized = true;
      notifyListeners();
    }
  }

  /// Identifie l'utilisateur connecté dans RevenueCat et charge son statut backend.
  Future<void> identifyUser(String userId) async {
    _currentUserId = userId;
    await RevenueCatBridge.logIn(userId);
    await syncBackendSubscription();
    await checkSubscriptionStatus();
    notifyListeners();
  }

  /// Réinitialise l'état lors de la déconnexion de l'utilisateur.
  Future<void> logOut() async {
    await RevenueCatBridge.logOut();
    _currentUserId = null;
    _questionCount = 0;
    _isSubscribed = false;
    notifyListeners();
  }

  /// Interroge le serveur backend NestJS (`GET /subscription/me`) pour récupérer le quota atomique MongoDB et l'état Pro.
  Future<void> syncBackendSubscription() async {
    try {
      final token = await ApiService.getToken();
      if (token == null) return;

      final response = await http.get(
        Uri.parse('${ApiService.baseUrl}/subscription/me'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        _isSubscribed = data['isPro'] ?? false;
        _questionCount = data['questionCount'] ?? 0;
        debugPrint('📊 Sync Backend réussi: isPro=$_isSubscribed, questionsUtilisées=$_questionCount/3');
        notifyListeners();
      }
    } catch (e) {
      debugPrint('⚠️ Impossible de synchroniser avec le backend NestJS: $e');
    }
  }

  /// Envoie une demande de vérification au serveur NestJS (`POST /subscription/sync`) après un achat RevenueCat.
  Future<bool> triggerBackendRevenueCatSync() async {
    try {
      final token = await ApiService.getToken();
      if (token == null) return false;

      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/subscription/sync'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        _isSubscribed = data['isPro'] ?? false;
        _questionCount = data['questionCount'] ?? 0;
        notifyListeners();
        return _isSubscribed;
      }
      return false;
    } catch (e) {
      debugPrint(' Erreur lors du déclenchement du sync backend RevenueCat: $e');
      return false;
    }
  }

  /// Vérifie le statut d'abonnement actif auprès de RevenueCat SDK.
  Future<bool> checkSubscriptionStatus() async {
    try {
      final active = await RevenueCatBridge.isEntitlementActive(premiumEntitlementId);
      if (active && !_isSubscribed) {
        _isSubscribed = true;
        await triggerBackendRevenueCatSync();
      }
      return _isSubscribed;
    } catch (e) {
      debugPrint('Erreur vérification statut abonnement RevenueCat SDK: $e');
      return _isSubscribed;
    }
  }

  /// Récupère la liste des offres d'abonnement disponibles depuis RevenueCat SDK.
  Future<List<StoreOffer>> getOffers() async {
    return await RevenueCatBridge.getStoreOffers();
  }

  /// Effectue l'achat d'un package RevenueCat et synchronise avec le serveur backend.
  Future<bool> purchasePackage(StoreOffer offer) async {
    final success = await RevenueCatBridge.purchasePackage(offer);
    if (success) {
      _isSubscribed = true;
      await triggerBackendRevenueCatSync();
      notifyListeners();
    }
    return success;
  }

  /// Restaure les achats de l'utilisateur.
  Future<bool> restorePurchases() async {
    final restored = await RevenueCatBridge.restorePurchases(premiumEntitlementId);
    if (restored) {
      _isSubscribed = true;
      await triggerBackendRevenueCatSync();
      notifyListeners();
    }
    return restored;
  }
}
