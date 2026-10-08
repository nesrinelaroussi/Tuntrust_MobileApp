import 'package:flutter/foundation.dart';
import 'store_offer.dart';

/// Implémentation Web / Fallback de RevenueCat.
/// Évite les crashs d'import sur Flutter Web tout en simulant le comportement pour les tests.
class RevenueCatBridge {
  static bool _configured = false;

  static bool get isTestMode => true;

  static Future<void> configure(String apiKey, {String? userId}) async {
    debugPrint('🌐 [RevenueCat Web Stub] Configuration simulée avec la clé : $apiKey (User: $userId)');
    _configured = true;
  }

  static Future<void> logIn(String userId) async {
    debugPrint('🌐 [RevenueCat Web Stub] LogIn simulé : $userId');
  }

  static Future<void> logOut() async {
    debugPrint('🌐 [RevenueCat Web Stub] LogOut simulé');
  }

  static Future<bool> isEntitlementActive(String entitlementId) async {
    debugPrint('🌐 [RevenueCat Web Stub] Entitlement active check for "$entitlementId" -> false');
    return false;
  }

  static Future<List<StoreOffer>> getStoreOffers() async {
    debugPrint('🌐 [RevenueCat Web Stub] Récupération d\'offres de test web');
    return const [
      StoreOffer(
        id: 'tuntrust_pro_monthly',
        title: 'TunTrust Pro Mensuel (Mode Test)',
        description: 'Accès illimité aux réponses de l\'assistant IA TunTrust',
        priceString: '9.99 TND / mois',
      ),
    ];
  }

  static Future<bool> purchasePackage(StoreOffer offer) async {
    debugPrint('🌐 [RevenueCat Web Stub] Achat simulé réussi pour ${offer.id}');
    return true;
  }

  static Future<bool> restorePurchases(String entitlementId) async {
    debugPrint('🌐 [RevenueCat Web Stub] Restauration simulée');
    return false;
  }

  static void addCustomerInfoListener(Function(dynamic) listener) {}
}
