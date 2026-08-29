import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/product.dart';
import '../theme/app_theme.dart';

class ProductDetailsScreen extends StatefulWidget {
  const ProductDetailsScreen({super.key, required this.product});
  final Product product;

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color get _cat => AppTheme.categoryColor(widget.product.category);

  Future<void> _launchUrl() async {
    final uri = Uri.parse(widget.product.url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication) && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Impossible d'ouvrir le navigateur.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    return Scaffold(
      backgroundColor: AppTheme.surfaceLight,
      body: CustomScrollView(
        slivers: [
          // ── Sliver App Bar ──────────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 260,
            pinned: true,
            backgroundColor: AppTheme.darkNavy,
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
                tag: 'product-header-${product.id}',
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Background
                    if (product.image.isNotEmpty)
                      CachedNetworkImage(
                        imageUrl: product.image,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => Container(
                            decoration: BoxDecoration(
                                gradient:
                                    AppTheme.categoryGradient(product.category))),
                        errorWidget: (_, __, ___) => Container(
                            decoration: BoxDecoration(
                                gradient:
                                    AppTheme.categoryGradient(product.category))),
                      )
                    else
                      Container(
                          decoration: BoxDecoration(
                              gradient:
                                  AppTheme.categoryGradient(product.category))),
                    // Scrim
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.black.withOpacity(0.55),
                            Colors.transparent,
                            Colors.black.withOpacity(0.3),
                          ],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                      ),
                    ),
                    // Icon + category
                    Positioned(
                      bottom: 24, left: 20,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                  color: Colors.white.withOpacity(0.3)),
                            ),
                            child: Text(
                              product.icon.isNotEmpty ? product.icon : '🔒',
                              style: const TextStyle(fontSize: 30),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: _cat.withOpacity(0.85),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Text(
                              product.category.isNotEmpty
                                  ? product.category
                                  : 'Certification',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Content ─────────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product name
                  Text(product.name,
                      style: Theme.of(context).textTheme.headlineLarge)
                      .animate().fadeIn(duration: 350.ms).slideY(begin: 0.15),

                  const SizedBox(height: 16),

                  // Description card
                  _InfoCard(
                    icon: Icons.description_rounded,
                    color: _cat,
                    title: 'Description',
                    child: Text(
                      product.description.isNotEmpty ? product.description : product.shortDescription,
                      softWrap: true,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(height: 1.6, color: AppTheme.textPrimary),
                    ),
                  ).animate(delay: 80.ms).fadeIn().slideY(begin: 0.1),

                  const SizedBox(height: 12),

                  // Benefits grid
                  if (product.benefits.isNotEmpty) ...[
                    _InfoCard(
                      icon: Icons.star_rounded,
                      color: const Color(0xFFF59E0B),
                      title: 'Avantages Clés',
                      child: _BenefitsGrid(
                          benefits: product.benefits, color: _cat),
                    ).animate(delay: 130.ms).fadeIn().slideY(begin: 0.1),
                    const SizedBox(height: 12),
                  ],

                  // Features
                  if (product.features.isNotEmpty) ...[
                    _InfoCard(
                      icon: Icons.checklist_rounded,
                      color: AppTheme.tealAccent,
                      title: 'Caractéristiques et Spécifications',
                      child: Column(
                        children: product.features
                            .asMap()
                            .entries
                            .map((e) => _FeatureItem(
                                  text: e.value,
                                  color: _cat,
                                  index: e.key,
                                ))
                            .toList(),
                      ),
                    ).animate(delay: 180.ms).fadeIn().slideY(begin: 0.1),
                    const SizedBox(height: 12),
                  ],

                  // Target users
                  if (product.targetUsers.isNotEmpty) ...[
                    _InfoCard(
                      icon: Icons.people_rounded,
                      color: const Color(0xFF6366F1),
                      title: 'Destinataires',
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: product.targetUsers
                            .map((u) => _UserChip(label: u, color: _cat))
                            .toList(),
                      ),
                    ).animate(delay: 230.ms).fadeIn().slideY(begin: 0.1),
                    const SizedBox(height: 24),
                  ],

                  // CTA
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _launchUrl,
                      style: FilledButton.styleFrom(
                        backgroundColor: _cat,
                        minimumSize: const Size(double.infinity, 56),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                      ),
                      icon: const Icon(Icons.open_in_new_rounded),
                      label: const Text('Visiter le site TunTrust',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                    ),
                  ).animate(delay: 280.ms).fadeIn().slideY(begin: 0.1),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Reusable sub-widgets ──────────────────────────────────────────────────────

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.child,
  });
  final IconData icon;
  final Color color;
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.cardWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 8),
            Text(title,
                style: Theme.of(context)
                    .textTheme
                    .titleSmall
                    ?.copyWith(color: color)),
          ]),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _BenefitsGrid extends StatelessWidget {
  const _BenefitsGrid({required this.benefits, required this.color});
  final List<String> benefits;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: benefits.map((b) {
        return ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 280),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.08),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: color.withOpacity(0.2)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.bolt_rounded, color: color, size: 13),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    b,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _FeatureItem extends StatelessWidget {
  const _FeatureItem({required this.text, required this.color, required this.index});
  final String text;
  final Color color;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 22, height: 22,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.check_rounded, color: color, size: 13),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textPrimary, height: 1.5)),
          ),
        ],
      ),
    );
  }
}

class _UserChip extends StatelessWidget {
  const _UserChip({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 260),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.person_rounded, color: color, size: 13),
            const SizedBox(width: 5),
            Expanded(
              child: Text(
                label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context)
                    .textTheme
                    .labelSmall
                    ?.copyWith(color: AppTheme.textPrimary, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
