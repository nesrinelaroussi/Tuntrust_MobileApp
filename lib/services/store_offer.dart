/// Représente une offre d'abonnement affichable dans le Paywall.
class StoreOffer {
  final String id;
  final String title;
  final String description;
  final String priceString;
  final dynamic rawPackage; // Instance de Package (purchases_flutter) si disponible

  const StoreOffer({
    required this.id,
    required this.title,
    required this.description,
    required this.priceString,
    this.rawPackage,
  });
}
