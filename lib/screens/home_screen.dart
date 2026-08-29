import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/product.dart';
import '../providers/products_provider.dart';
import '../screens/about_screen.dart';
import '../screens/contact_screen.dart';
import '../screens/digital_trust_center_screen.dart';
import '../screens/product_details_screen.dart';
import '../screens/search_screen.dart';
import '../theme/app_theme.dart';
import '../widgets/main_shell.dart';
import '../widgets/section_header.dart';
import '../widgets/skeleton_loader.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

// ── Local asset image pool ────────────────────────────────────────────────────
const List<String> _localAssets = [
  'assets/img.png',
  'assets/img_1.png',
  'assets/img_2.png',
  'assets/img_3.png',
  'assets/img_4.png',
  'assets/img_5.png',
  'assets/img_6.png',
  'assets/img_7.png',
  'assets/img_8.png',
];

String _assetFor(int seed) => _localAssets[seed.abs() % _localAssets.length];

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final p = context.read<ProductsProvider>();
      if (p.products.isEmpty && !p.isLoading) {
        p.loadProducts();
      }
    });
  }

  void _goToProducts() {
    MainShell.of(context)?.navigateTo(1);
  }

  void _goToExplorer() {
    MainShell.of(context)?.navigateTo(2);
  }

  void _goToAssistant() {
    MainShell.of(context)?.navigateTo(3);
  }

  void _goToSearch() {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (_, anim, __) => const SearchScreen(),
        transitionsBuilder: (_, anim, __, child) => FadeTransition(
          opacity: CurvedAnimation(parent: anim, curve: Curves.easeOut),
          child: child,
        ),
        transitionDuration: const Duration(milliseconds: 280),
      ),
    );
  }

  void _goToAbout() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const AboutScreen()),
    );
  }

  void _goToContact() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const ContactScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surfaceLight,
      body: CustomScrollView(
        slivers: [
          // ── App Bar ─────────────────────────────────────────────────────
          SliverAppBar(
            floating: true,
            snap: true,
            backgroundColor: AppTheme.cardWhite,
            surfaceTintColor: Colors.transparent,
            title: Row(
              children: [
                Image.asset('assets/logotuntrust.png', height: 28),
                const SizedBox(width: 10),
                Text('TunTrust',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppTheme.primaryGreen,
                          fontWeight: FontWeight.w800,
                        )),
              ],
            ),
            actions: [
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceLight,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.search_rounded,
                      color: AppTheme.textPrimary, size: 20),
                ),
                onPressed: _goToSearch,
                tooltip: 'Rechercher',
              ),
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceLight,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.notifications_none_rounded,
                      color: AppTheme.textPrimary, size: 20),
                ),
                onPressed: () {},
              ),
              const SizedBox(width: 8),
            ],
          ),

          // ── Body ────────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Welcome
                  Text('Bienvenue sur',
                      style: Theme.of(context).textTheme.bodyLarge
                          ?.copyWith(color: AppTheme.textSecondary))
                      .animate().fadeIn(duration: 400.ms),
                  Text('TunTrust Mobile',
                      style: Theme.of(context).textTheme.displayMedium)
                      .animate().fadeIn(delay: 100.ms, duration: 400.ms),

                  const SizedBox(height: 20),

                  // Hero banner
                  _HeroBanner().animate().fadeIn(delay: 150.ms).slideY(begin: 0.1),

                  const SizedBox(height: 28),

                  // Quick actions
                  SectionHeader(
                    title: 'Accès Rapide',
                    subtitle: 'Naviguez vers nos services',
                  ).animate().fadeIn(delay: 200.ms),
                  const SizedBox(height: 14),

                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    childAspectRatio: 1.3,
                    children: [
                      _QuickAction(
                        icon: Icons.inventory_2_rounded,
                        color: AppTheme.primaryGreen,
                        label: 'Nos Produits',
                        subtitle: 'Certificats & services',
                        onTap: _goToProducts,
                        delay: 250,
                      ),
                      _QuickAction(
                        icon: Icons.explore_rounded,
                        color: AppTheme.tealAccent,
                        label: 'Explorer',
                        subtitle: 'Solutions & Ressources',
                        onTap: _goToExplorer,
                        delay: 300,
                      ),
                      _QuickAction(
                        icon: Icons.info_outline_rounded,
                        color: const Color(0xFF6366F1),
                        label: 'À Propos',
                        subtitle: 'Notre mission',
                        onTap: _goToAbout,
                        delay: 350,
                      ),
                      _QuickAction(
                        icon: Icons.smart_toy_rounded,
                        color: const Color(0xFFF59E0B),
                        label: 'Assistant IA',
                        subtitle: 'Guide intelligent',
                        onTap: _goToAssistant,
                        delay: 400,
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),

                  // Featured products
                  SectionHeader(
                    title: 'Produits en Vedette',
                    subtitle: 'Nos certifications numériques',
                    actionLabel: 'Voir tout',
                    onAction: _goToProducts,
                  ).animate().fadeIn(delay: 420.ms),

                  const SizedBox(height: 14),
                  _FeaturedProducts(onViewAll: _goToProducts)
                      .animate().fadeIn(delay: 460.ms),

                  const SizedBox(height: 28),

                  // Actualités teaser
                  SectionHeader(
                    title: 'Actualités',
                    subtitle: 'Dernières nouvelles TunTrust',
                    actionLabel: 'Voir tout',
                    onAction: () async {
                      final uri = Uri.parse('https://www.tuntrust.tn/fr/nos-actualites');
                      // ignore: use_build_context_synchronously
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Ouverture des actualités TunTrust…'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  ).animate().fadeIn(delay: 490.ms),
                  const SizedBox(height: 14),
                  _NewsTeaser().animate().fadeIn(delay: 520.ms),

                  const SizedBox(height: 28),

                  // Contact + About teaser
                  Row(
                    children: [
                      Expanded(
                        child: _SmallActionCard(
                          icon: Icons.contact_support_rounded,
                          color: AppTheme.tealAccent,
                          label: 'Nous Contacter',
                          onTap: _goToContact,
                          delay: 550,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _SmallActionCard(
                          icon: Icons.info_outline_rounded,
                          color: const Color(0xFF6366F1),
                          label: 'À Propos',
                          onTap: _goToAbout,
                          delay: 590,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),

                  // About TunTrust
                  SectionHeader(title: 'À Propos de TunTrust')
                      .animate().fadeIn(delay: 630.ms),
                  const SizedBox(height: 14),
                  _AboutCard().animate().fadeIn(delay: 650.ms).slideY(begin: 0.1),

                  const SizedBox(height: 28),

                  // Pillars
                  Row(
                    children: [
                      _PillarCard(
                          icon: Icons.security_rounded,
                          color: AppTheme.primaryGreen,
                          label: 'Sécurité',
                          delay: 690),
                      const SizedBox(width: 12),
                      _PillarCard(
                          icon: Icons.verified_rounded,
                          color: AppTheme.tealAccent,
                          label: 'Confiance',
                          delay: 720),
                      const SizedBox(width: 12),
                      _PillarCard(
                          icon: Icons.hub_rounded,
                          color: const Color(0xFF6366F1),
                          label: 'Innovation',
                          delay: 750),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature — Bientôt disponible'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

// ── Hero Banner ──────────────────────────────────────────────────────────────

class _HeroBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppTheme.heroGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppTheme.heroBannerShadow,
      ),
      child: Stack(
        children: [
          // Background circles
          Positioned(
            right: -40, top: -40,
            child: Container(
              width: 180, height: 180,
              decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.07),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            left: -20, bottom: -20,
            child: Container(
              width: 100, height: 100,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 320),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.verified_rounded,
                          color: Colors.white, size: 14),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Agence Nationale de Certification Électronique',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(color: Colors.white, letterSpacing: 0.3),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'La Confiance\nNumérique Nationale',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  color: Colors.white,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'TunTrust œuvre pour sécuriser l\'économie numérique tunisienne '
                'à travers des services de certification électronique de confiance.',
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium
                    ?.copyWith(color: Colors.white.withValues(alpha: 0.9), height: 1.5),
              ),
              const SizedBox(height: 20),
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 6,
                runSpacing: 8,
                children: [
                  const Icon(Icons.language_rounded,
                      color: Colors.white, size: 15),
                  Text(
                    'tuntrust.tn',
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: Colors.white,
                      decoration: TextDecoration.underline,
                      decorationColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Quick Action ─────────────────────────────────────────────────────────────

class _QuickAction extends StatefulWidget {
  const _QuickAction({
    required this.icon,
    required this.color,
    required this.label,
    required this.subtitle,
    required this.onTap,
    required this.delay,
  });
  final IconData icon;
  final Color color;
  final String label;
  final String subtitle;
  final VoidCallback onTap;
  final int delay;

  @override
  State<_QuickAction> createState() => _QuickActionState();
}

class _QuickActionState extends State<_QuickAction> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.cardWhite,
            borderRadius: BorderRadius.circular(18),
            boxShadow: AppTheme.cardShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: widget.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(widget.icon, color: widget.color, size: 22),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.label,
                      style: Theme.of(context).textTheme.titleSmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Text(widget.subtitle,
                      style: Theme.of(context).textTheme.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ],
              ),
            ],
          ),
        ),
      ),
    ).animate(delay: Duration(milliseconds: widget.delay))
        .fadeIn(duration: 350.ms)
        .slideY(begin: 0.1, end: 0);
  }
}

// ── Featured Products ─────────────────────────────────────────────────────────

class _FeaturedProducts extends StatelessWidget {
  const _FeaturedProducts({required this.onViewAll});
  final VoidCallback onViewAll;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProductsProvider>();

    if (provider.isLoading) {
      return SizedBox(
        height: 170,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: 3,
          separatorBuilder: (_, __) => const SizedBox(width: 14),
          itemBuilder: (_, __) => const MiniCardSkeleton(),
        ),
      );
    }

    if (provider.products.isEmpty) {
      return Container(
        height: 100,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppTheme.cardWhite,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          provider.errorMessage != null
              ? 'Impossible de charger les produits'
              : 'Aucun produit disponible',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      );
    }

    final featured = provider.products.take(5).toList();
    return SizedBox(
      height: 175,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: featured.length + 1,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (context, index) {
          if (index == featured.length) {
            return _ViewAllCard(onTap: onViewAll);
          }
          return _MiniProductCard(
            product: featured[index],
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => ProductDetailsScreen(product: featured[index]),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _MiniProductCard extends StatelessWidget {
  const _MiniProductCard({required this.product, required this.onTap});
  final Product product;
  final VoidCallback onTap;

  int get _seed {
    final id = product.id;
    if (id is int) return id as int;
    return id.toString().hashCode.abs();
  }

  @override
  Widget build(BuildContext context) {
    final color = AppTheme.categoryColor(product.category);
    final localAsset = _assetFor(_seed);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 190,
        decoration: BoxDecoration(
          color: AppTheme.cardWhite,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppTheme.cardShadow,
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image header
            SizedBox(
              height: 80,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  product.image.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: product.image,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          placeholder: (_, __) =>
                              Image.asset(localAsset, fit: BoxFit.cover),
                          errorWidget: (_, __, ___) =>
                              Image.asset(localAsset, fit: BoxFit.cover),
                        )
                      : Image.asset(localAsset, fit: BoxFit.cover),
                  // subtle colour tint
                  Container(color: color.withOpacity(0.15)),
                  // scrim
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.black.withOpacity(0.35), Colors.transparent],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                    ),
                  ),
                  // emoji
                  Positioned(
                    top: 8, left: 8,
                    child: Text(
                      product.icon.isNotEmpty ? product.icon : '🔒',
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 4),
                  Text(
                    product.category.isNotEmpty
                        ? product.category
                        : 'Certification',
                    style: Theme.of(context).textTheme.labelSmall
                        ?.copyWith(color: color),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ViewAllCard extends StatelessWidget {
  const _ViewAllCard({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 120,
        decoration: BoxDecoration(
          color: AppTheme.primaryGreen.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: AppTheme.primaryGreen.withValues(alpha: 0.3), width: 1.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.primaryGreen.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_forward_rounded,
                  color: AppTheme.primaryGreen, size: 22),
            ),
            const SizedBox(height: 10),
            Text('Voir tout',
                style: Theme.of(context).textTheme.labelMedium
                    ?.copyWith(color: AppTheme.primaryGreen,
                        fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

// ── About Card ───────────────────────────────────────────────────────────────

class _AboutCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardWhite,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Image.asset('assets/logotuntrust.png', height: 36),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('TunTrust',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: AppTheme.primaryGreen,
                            )),
                    Text('Agence Nationale de Certification Électronique',
                        style: Theme.of(context).textTheme.bodySmall,
                        maxLines: 2),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            'TunTrust est l\'autorité nationale de certification électronique de Tunisie. '
            'Elle assure la délivrance de certificats numériques sécurisés, '
            'garants de l\'authenticité et de l\'intégrité des échanges électroniques '
            'au sein de l\'économie numérique tunisienne.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

// ── Pillar Card ──────────────────────────────────────────────────────────────

class _PillarCard extends StatelessWidget {
  const _PillarCard({
    required this.icon,
    required this.color,
    required this.label,
    required this.delay,
  });
  final IconData icon;
  final Color color;
  final String label;
  final int delay;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppTheme.cardWhite,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppTheme.cardShadow,
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 8),
            Text(label,
                style: Theme.of(context).textTheme.labelMedium,
                textAlign: TextAlign.center),
          ],
        ),
      ).animate(delay: Duration(milliseconds: delay))
          .fadeIn(duration: 350.ms)
          .slideY(begin: 0.1),
    );
  }
}

// ── Small Action Card ────────────────────────────────────────────────────────

class _SmallActionCard extends StatefulWidget {
  const _SmallActionCard({
    required this.icon,
    required this.color,
    required this.label,
    required this.onTap,
    required this.delay,
  });
  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback onTap;
  final int delay;

  @override
  State<_SmallActionCard> createState() => _SmallActionCardState();
}

class _SmallActionCardState extends State<_SmallActionCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
          decoration: BoxDecoration(
            color: AppTheme.cardWhite,
            borderRadius: BorderRadius.circular(16),
            boxShadow: AppTheme.cardShadow,
            border: Border.all(
              color: _pressed ? widget.color.withOpacity(0.4) : Colors.transparent,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(widget.icon, color: widget.color, size: 20),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  widget.label,
                  style: Theme.of(context).textTheme.labelMedium,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate(delay: Duration(milliseconds: widget.delay)).fadeIn().slideX(begin: 0.05);
  }
}

// ── News Teaser ──────────────────────────────────────────────────────────────

class _NewsTeaser extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _NewsItem(
          imageUrl: 'https://www.tuntrust.tn/sites/default/files/styles/image_thumbs2/public/mediatheque/webinaireCEV.jpg',
          title: 'Invitation Webinaire : Qu\'est-ce qu\'un Cachet Électronique Visible (CEV) ?',
          date: '29.05.2024',
          localAsset: 'assets/img_5.png',
          onTap: () async {
            final uri = Uri.parse('https://www.tuntrust.tn/fr/node/441');
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          },
        ),
        const SizedBox(height: 12),
        _NewsItem(
          imageUrl: 'https://www.tuntrust.tn/sites/default/files/styles/image_thumbs2/public/mediatheque/webinaireSSL_TLS.jpg',
          title: 'Invitation Webinaire : La gestion des certificats SSL avec le protocole ACME',
          date: '29.05.2024',
          localAsset: 'assets/img_6.png',
          onTap: () async {
            final uri = Uri.parse('https://www.tuntrust.tn/fr/node/442');
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          },
        ),
      ],
    );
  }
}

class _NewsItem extends StatelessWidget {
  const _NewsItem({
    required this.imageUrl,
    required this.title,
    required this.date,
    required this.onTap,
    this.localAsset,
  });
  final String imageUrl;
  final String title;
  final String date;
  final VoidCallback onTap;
  final String? localAsset;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          color: AppTheme.cardWhite,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppTheme.cardShadow,
        ),
        clipBehavior: Clip.antiAlias,
        child: Row(
          children: [
            SizedBox(
              width: 110,
              height: double.infinity,
              child: localAsset != null
                  ? CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) =>
                          Image.asset(localAsset!, fit: BoxFit.cover),
                      errorWidget: (context, url, error) =>
                          Image.asset(localAsset!, fit: BoxFit.cover),
                    )
                  : CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) =>
                          Container(color: AppTheme.surfaceLight),
                      errorWidget: (context, url, error) => Container(
                        color: AppTheme.surfaceLight,
                        child: const Icon(Icons.image_not_supported_rounded,
                            color: AppTheme.textSecondary),
                      ),
                    ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryGreen.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Actualités',
                        style: TextStyle(
                            color: AppTheme.primaryGreen,
                            fontSize: 9,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Expanded(
                      child: Text(
                        title,
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall
                            ?.copyWith(height: 1.3),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      date,
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(fontSize: 10),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
