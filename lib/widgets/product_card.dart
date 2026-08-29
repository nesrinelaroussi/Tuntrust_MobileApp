import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../models/product.dart';
import '../theme/app_theme.dart';

// ── Local asset images pool for product cards ─────────────────────────────────
const List<String> _productAssetImages = [
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

String _randomAssetImage(int seed) =>
    _productAssetImages[seed % _productAssetImages.length];

/// Premium animated product card — compact vertical size.
class ProductCard extends StatefulWidget {
  const ProductCard({
    super.key,
    required this.product,
    required this.onTap,
    this.animationDelay = Duration.zero,
  });

  final Product product;
  final VoidCallback onTap;
  final Duration animationDelay;

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pressCtrl;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _pressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      reverseDuration: const Duration(milliseconds: 200),
      lowerBound: 0,
      upperBound: 1,
    );
    _scaleAnim = Tween<double>(begin: 1, end: 0.97).animate(
      CurvedAnimation(parent: _pressCtrl, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _pressCtrl.dispose();
    super.dispose();
  }

  Color get _categoryColor =>
      AppTheme.categoryColor(widget.product.category);

  /// Derive a stable per-product seed from its id or name hashcode.
  int get _imageSeed {
    final id = widget.product.id;
    if (id is int) return id as int;
    return id.toString().hashCode.abs();
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    return AnimatedBuilder(
      animation: _scaleAnim,
      builder: (context, child) => Transform.scale(
        scale: _scaleAnim.value,
        child: child,
      ),
      child: GestureDetector(
        onTapDown: (_) => _pressCtrl.forward(),
        onTapUp: (_) {
          _pressCtrl.reverse();
          widget.onTap();
        },
        onTapCancel: () => _pressCtrl.reverse(),
        child: Container(
          decoration: BoxDecoration(
            color: AppTheme.cardWhite,
            borderRadius: BorderRadius.circular(18),
            boxShadow: AppTheme.cardShadow,
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Image header (shorter) ─────────────────────────────────
              _CardHeader(
                product: product,
                categoryColor: _categoryColor,
                imageSeed: _imageSeed,
              ),

              // ── Content ───────────────────────────────────────────────
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: _categoryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Text(
                          product.category.isNotEmpty
                              ? product.category
                              : 'Certification',
                          style: Theme.of(context)
                              .textTheme
                              .labelSmall
                              ?.copyWith(
                                color: _categoryColor,
                                fontWeight: FontWeight.w600,
                                fontSize: 10,
                              ),
                        ),
                      ),
                      const SizedBox(height: 6),

                      // Product name
                      Text(
                        product.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 4),

                      // Short description
                      Expanded(
                        child: Text(
                          product.shortDescription,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(height: 1.4, fontSize: 11),
                        ),
                      ),

                      const SizedBox(height: 8),

                      // CTA button — slim
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: widget.onTap,
                          style: FilledButton.styleFrom(
                            backgroundColor: _categoryColor,
                            padding: const EdgeInsets.symmetric(vertical: 9),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            minimumSize: Size.zero,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Text('En savoir plus',
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600)),
                              SizedBox(width: 4),
                              Icon(Icons.arrow_forward_rounded, size: 12),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Card Header ───────────────────────────────────────────────────────────────

class _CardHeader extends StatelessWidget {
  const _CardHeader({
    required this.product,
    required this.categoryColor,
    required this.imageSeed,
  });
  final Product product;
  final Color categoryColor;
  final int imageSeed;

  @override
  Widget build(BuildContext context) {
    final localAsset = _randomAssetImage(imageSeed);

    return Hero(
      tag: 'product-header-${product.id}',
      child: SizedBox(
        height: 95,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background: network image → local asset fallback → gradient
            if (product.image.isNotEmpty)
              CachedNetworkImage(
                imageUrl: product.image,
                fit: BoxFit.cover,
                placeholder: (_, __) => Image.asset(localAsset, fit: BoxFit.cover),
                errorWidget: (_, __, ___) =>
                    Image.asset(localAsset, fit: BoxFit.cover),
              )
            else
              Image.asset(localAsset, fit: BoxFit.cover),

            // Dark scrim overlay for readability
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withOpacity(0.40),
                    Colors.transparent,
                  ],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),
            ),

            // Category-colour tint overlay (subtle)
            Container(
              color: categoryColor.withOpacity(0.18),
            ),

            // Emoji icon badge
            Positioned(
              top: 10,
              left: 10,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.22),
                  borderRadius: BorderRadius.circular(10),
                  border:
                      Border.all(color: Colors.white.withOpacity(0.3), width: 1),
                ),
                child: Text(
                  product.icon.isNotEmpty ? product.icon : '🔒',
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
