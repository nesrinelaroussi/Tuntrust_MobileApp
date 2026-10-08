import 'package:flutter/material.dart';
import '../services/store_offer.dart';
import '../services/subscription_service.dart';
import '../theme/app_theme.dart';

/// Écran de Paywall affiché lorsque l'utilisateur a épuisé ses 3 questions gratuites.
class PaywallScreen extends StatefulWidget {
  const PaywallScreen({super.key});

  @override
  State<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<PaywallScreen> {
  final SubscriptionService _subService = SubscriptionService.instance;
  List<StoreOffer> _offers = [];
  bool _isLoading = true;
  bool _isPurchasing = false;
  String? _selectedOfferId;

  @override
  void initState() {
    super.initState();
    _loadOffers();
  }

  Future<void> _loadOffers() async {
    setState(() => _isLoading = true);
    final offers = await _subService.getOffers();
    if (!mounted) return;
    setState(() {
      _offers = offers;
      if (offers.isNotEmpty) {
        _selectedOfferId = offers.first.id;
      }
      _isLoading = false;
    });
  }

  Future<void> _handlePurchase() async {
    if (_selectedOfferId == null || _isPurchasing) return;
    
    final offer = _offers.firstWhere(
      (o) => o.id == _selectedOfferId,
      orElse: () => _offers.first,
    );

    setState(() => _isPurchasing = true);

    final success = await _subService.purchasePackage(offer);

    if (!mounted) return;
    setState(() => _isPurchasing = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Félicitations ! Vous êtes désormais abonné à TunTrust Pro 🎉'),
          backgroundColor: AppTheme.primaryGreen,
        ),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('L\'achat n\'a pas pu être finalisé. Veuillez réessayer.'),
          backgroundColor: Colors.red.shade600,
        ),
      );
    }
  }

  Future<void> _handleRestore() async {
    if (_isPurchasing) return;
    setState(() => _isPurchasing = true);

    final restored = await _subService.restorePurchases();

    if (!mounted) return;
    setState(() => _isPurchasing = false);

    if (restored) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Achats restaurés avec succès !'),
          backgroundColor: AppTheme.primaryGreen,
        ),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Aucun abonnement actif trouvé à restaurer.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A), // Slate sombre élégant
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context, false),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Badge Pro Top
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryGreen.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppTheme.primaryGreen.withOpacity(0.5)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.workspace_premium_rounded, color: AppTheme.primaryGreen, size: 18),
                      SizedBox(width: 6),
                      Text(
                        'PASS TUNTRUST PRO',
                        style: TextStyle(
                          color: AppTheme.primaryGreen,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          letterSpacing: 1.1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Title
              const Text(
                'Débloquez l\'accès illimité à l\'Assistant IA',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                ),
              ),

              const SizedBox(height: 12),

              Text(
                'Vous avez consommé vos 3 questions gratuites.\nPassez à TunTrust Pro pour continuer de poser vos questions sans restriction.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey.shade400,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 28),

              // Benefits list
              _buildFeatureRow(
                icon: Icons.all_inclusive_rounded,
                title: 'Questions IA illimitées',
                subtitle: 'Posez toutes vos questions sur les services et certificats TunTrust',
              ),
              const SizedBox(height: 16),
              _buildFeatureRow(
                icon: Icons.bolt_rounded,
                title: 'Réponses instantanées',
                subtitle: 'Temps de réponse prioritaire via nos modèles optimisés',
              ),
              const SizedBox(height: 16),
              _buildFeatureRow(
                icon: Icons.shield_rounded,
                title: 'Assistance Confiance Numérique',
                subtitle: 'Guide complet pour ID-Trust, DigiGO, E-Sign et certificats SSL',
              ),

              const SizedBox(height: 32),

              // Offer Options
              const Text(
                'Choix de l\'offre',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 12),

              if (_isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24.0),
                    child: CircularProgressIndicator(color: AppTheme.primaryGreen),
                  ),
                )
              else if (_offers.isEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Aucune offre disponible pour le moment. Veuillez réessayer plus tard.',
                    style: TextStyle(color: Colors.white70),
                    textAlign: TextAlign.center,
                  ),
                )
              else
                Column(
                  children: _offers.map((offer) {
                    final isSelected = offer.id == _selectedOfferId;
                    return InkWell(
                      onTap: () => setState(() => _selectedOfferId = offer.id),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppTheme.primaryGreen.withOpacity(0.15)
                              : Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected ? AppTheme.primaryGreen : Colors.white12,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Radio<String>(
                              value: offer.id,
                              groupValue: _selectedOfferId,
                              activeColor: AppTheme.primaryGreen,
                              onChanged: (val) => setState(() => _selectedOfferId = val),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    offer.title,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    offer.description,
                                    style: TextStyle(
                                      color: Colors.grey.shade400,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              offer.priceString,
                              style: const TextStyle(
                                color: AppTheme.primaryGreen,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),

              const SizedBox(height: 24),

              // Action button
              ElevatedButton(
                onPressed: _isPurchasing || _isLoading ? null : _handlePurchase,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 4,
                ),
                child: _isPurchasing
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Text(
                        'S\'abonner maintenant',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),

              const SizedBox(height: 12),

              // Restore purchases button
              TextButton(
                onPressed: _isPurchasing ? null : _handleRestore,
                child: Text(
                  'Restaurer mes achats',
                  style: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 14,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),

              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureRow({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppTheme.primaryGreen.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppTheme.primaryGreen, size: 22),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.grey.shade400,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
