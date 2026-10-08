import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'store_offer.dart';

/// Implémentation Native (Android / iOS) de RevenueCat.
/// Gère les interactions avec le SDK `purchases_flutter`.
class RevenueCatBridge {
  static bool _configured = false;
  static bool _configFailed = false;
  static String _apiKey = '';

  static bool get isTestMode => _apiKey.isEmpty || _apiKey.startsWith('test_') || _configFailed;

  static Future<void> configure(String apiKey, {String? userId}) async {
    try {
      if (kDebugMode) {
        await Purchases.setLogLevel(LogLevel.debug);
      }
      _apiKey = apiKey;
      debugPrint('🔑 [RevenueCat IO] Configuration avec la clé: ${apiKey.length > 8 ? apiKey.substring(0, 8) : apiKey}...');
      debugPrint('🔑 [RevenueCat IO] UserId: $userId');
      
      final configuration = PurchasesConfiguration(apiKey);
      if (userId != null && userId.isNotEmpty) {
        configuration.appUserID = userId;
      }
      
      await Purchases.configure(configuration);
      _configured = true;
      _configFailed = false;
      debugPrint('✅ [RevenueCat IO] Configuration réussie !');
    } catch (e) {
      debugPrint('❌ [RevenueCat IO] Échec de configuration: $e');
      _configFailed = true;
    }
  }

  static Future<void> logIn(String userId) async {
    if (_configFailed) return;
    try {
      debugPrint('🔑 [RevenueCat IO] LogIn user: $userId');
      await Purchases.logIn(userId);
    } catch (e) {
      debugPrint('❌ [RevenueCat IO] LogIn error: $e');
    }
  }

  static Future<void> logOut() async {
    if (_configFailed) return;
    try {
      debugPrint('🔑 [RevenueCat IO] LogOut user');
      await Purchases.logOut();
    } catch (e) {
      debugPrint('❌ [RevenueCat IO] LogOut error: $e');
    }
  }

  static Future<bool> isEntitlementActive(String entitlementId) async {
    if (_configFailed || !_configured) return false;
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      debugPrint('📋 [RevenueCat IO] Active entitlements: ${customerInfo.entitlements.active.keys.toList()}');
      final entitlement = customerInfo.entitlements.all[entitlementId];
      return entitlement != null && entitlement.isActive;
    } catch (e) {
      debugPrint('❌ [RevenueCat IO] Erreur vérification entitlement "$entitlementId": $e');
      return false;
    }
  }

  static Future<List<StoreOffer>> getStoreOffers() async {
    debugPrint('📦 [RevenueCat IO] Récupération des offres... (configured=$_configured, failed=$_configFailed)');
    
    if (_configFailed || !_configured) {
      return _getTestFallbackOffers();
    }

    try {
      final offerings = await Purchases.getOfferings();
      if (offerings.current != null && offerings.current!.availablePackages.isNotEmpty) {
        return offerings.current!.availablePackages.map((pkg) {
          final storeProduct = pkg.storeProduct;
          return StoreOffer(
            id: pkg.identifier,
            title: storeProduct.title.isNotEmpty ? storeProduct.title : 'TunTrust Pro',
            description: storeProduct.description.isNotEmpty 
                ? storeProduct.description 
                : 'Accès illimité à l\'assistant IA TunTrust',
            priceString: storeProduct.priceString,
            rawPackage: pkg,
          );
        }).toList();
      } else {
        debugPrint('⚠️ [RevenueCat IO] Aucune offre trouvée dans offerings.current, utilisation des offres de fallback pour le dev.');
        return _getTestFallbackOffers();
      }
    } catch (e) {
      debugPrint('❌ [RevenueCat IO] Erreur récupération offres: $e. Utilisation fallback.');
      return _getTestFallbackOffers();
    }
  }

  static Future<bool> purchasePackage(StoreOffer offer) async {
    if (offer.rawPackage != null && offer.rawPackage is Package) {
      try {
        final package = offer.rawPackage as Package;
        final customerInfo = await Purchases.purchasePackage(package);
        return customerInfo.entitlements.active.isNotEmpty;
      } catch (e) {
        debugPrint('❌ [RevenueCat IO] Erreur achat package: $e');
        return false;
      }
    }
    // Simulation si offre de test
    debugPrint('⚠️ [RevenueCat IO] Package brut non présent (mode test), achat simulé comme réussi.');
    return true;
  }

  static Future<bool> restorePurchases(String entitlementId) async {
    if (_configFailed || !_configured) return false;
    try {
      final customerInfo = await Purchases.restorePurchases();
      final entitlement = customerInfo.entitlements.all[entitlementId];
      return entitlement != null && entitlement.isActive;
    } catch (e) {
      debugPrint('❌ [RevenueCat IO] Erreur restauration achats: $e');
      return false;
    }
  }

  static void addCustomerInfoListener(Function(CustomerInfo) listener) {
    if (_configFailed || !_configured) return;
    Purchases.addCustomerInfoUpdateListener(listener);
  }

  static List<StoreOffer> _getTestFallbackOffers() {
    return const [
      StoreOffer(
        id: 'tuntrust_pro_monthly',
        title: 'TunTrust Pro Mensuel',
        description: 'Accès illimité aux questions de l\'assistant IA TunTrust',
        priceString: '9.99 TND / mois',
      ),
    ];
  }
}
