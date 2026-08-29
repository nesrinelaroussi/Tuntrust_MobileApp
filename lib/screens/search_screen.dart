import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../providers/products_provider.dart';
import '../screens/product_details_screen.dart';
import '../screens/explorer_screen.dart';
import '../theme/app_theme.dart';

// ══════════════════════════════════════════════════════════════════════════════
// Global Search Screen
// ══════════════════════════════════════════════════════════════════════════════

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _ctrl = TextEditingController();
  String _query = '';
  final FocusNode _focusNode = FocusNode();

  // ── Static searchable data ─────────────────────────────────────────────────
  static const List<_SolutionResult> _solutionPool = [
    _SolutionResult(
      title: 'TunSign',
      subtitle: 'Signature de documents électroniques',
      icon: Icons.draw_rounded,
      color: AppTheme.tunsignColor,
      key: 'tunsign',
    ),
    _SolutionResult(
      title: 'CEV / 2D-DOC',
      subtitle: 'Sécurisation de documents officiels',
      icon: Icons.qr_code_2_rounded,
      color: AppTheme.cevColor,
      key: 'cev',
    ),
    _SolutionResult(
      title: 'Digigo',
      subtitle: 'Signature à distance et mobile',
      icon: Icons.phone_android_rounded,
      color: AppTheme.digigoColor,
      key: 'digigo',
    ),
    _SolutionResult(
      title: 'TunStamp',
      subtitle: 'Contremarque de temps certifiée',
      icon: Icons.access_time_rounded,
      color: AppTheme.tunstampColor,
      key: 'tunstamp',
    ),
  ];

  static const List<_ResourceResult> _resourcePool = [
    _ResourceResult(title: 'Politiques de Certification', icon: Icons.policy_rounded, color: Color(0xFF05B257)),
    _ResourceResult(title: 'Certificats Racines', icon: Icons.verified_rounded, color: Color(0xFF007A87)),
    _ResourceResult(title: 'Formulaires de Demande', icon: Icons.description_rounded, color: Color(0xFF6366F1)),
    _ResourceResult(title: 'Pilotes et Guides d\'installation', icon: Icons.computer_rounded, color: Color(0xFFF59E0B)),
    _ResourceResult(title: 'Conditions Générales d\'Utilisation', icon: Icons.gavel_rounded, color: Color(0xFFEF4444)),
    _ResourceResult(title: 'Liste des Certificats Révoqués', icon: Icons.block_rounded, color: Color(0xFF8B5CF6)),
    _ResourceResult(title: 'Annuaire des Certificats', icon: Icons.manage_search_rounded, color: Color(0xFF0891B2)),
    _ResourceResult(title: 'Nos Certifications & Audits', icon: Icons.workspace_premium_rounded, color: Color(0xFF059669)),
  ];

  // ── Suggestions ────────────────────────────────────────────────────────────
  static const List<String> _suggestions = [
    'signature',
    'certificat',
    'SSL',
    'ID-Trust',
    'Enterprise-ID',
    'horodatage',
    'Digigo',
    'politiques',
    'formulaires',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _focusNode.requestFocus());
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  // ── Filtering ─────────────────────────────────────────────────────────────

  List<Product> _filteredProducts(List<Product> all) {
    if (_query.isEmpty) return [];
    final q = _query.toLowerCase();
    return all.where((p) =>
        p.name.toLowerCase().contains(q) ||
        p.category.toLowerCase().contains(q) ||
        p.shortDescription.toLowerCase().contains(q)).toList();
  }

  List<_SolutionResult> get _filteredSolutions {
    if (_query.isEmpty) return [];
    final q = _query.toLowerCase();
    return _solutionPool.where((s) =>
        s.title.toLowerCase().contains(q) ||
        s.subtitle.toLowerCase().contains(q)).toList();
  }

  List<_ResourceResult> get _filteredResources {
    if (_query.isEmpty) return [];
    final q = _query.toLowerCase();
    return _resourcePool.where((r) =>
        r.title.toLowerCase().contains(q)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProductsProvider>();
    final products = _filteredProducts(provider.products);
    final solutions = _filteredSolutions;
    final resources = _filteredResources;
    final hasResults = products.isNotEmpty || solutions.isNotEmpty || resources.isNotEmpty;
    final hasQuery = _query.isNotEmpty;

    return Scaffold(
      backgroundColor: AppTheme.surfaceLight,
      appBar: AppBar(
        title: TextField(
          controller: _ctrl,
          focusNode: _focusNode,
          onChanged: (v) => setState(() => _query = v),
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppTheme.textPrimary,
              ),
          decoration: InputDecoration(
            hintText: 'Produits, solutions, ressources…',
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            filled: false,
            hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppTheme.textSecondary,
                ),
          ),
          textInputAction: TextInputAction.search,
        ),
        actions: [
          if (_query.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.close_rounded),
              onPressed: () {
                _ctrl.clear();
                setState(() => _query = '');
              },
            ),
        ],
      ),
      body: hasQuery
          ? hasResults
              ? _buildResults(context, products, solutions, resources)
              : _buildEmpty(context)
          : _buildSuggestions(context),
    );
  }

  Widget _buildSuggestions(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Recherches suggérées',
              style: Theme.of(context).textTheme.headlineSmall)
              .animate().fadeIn(duration: 300.ms),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _suggestions.asMap().entries.map((e) => GestureDetector(
              onTap: () {
                _ctrl.text = e.value;
                setState(() => _query = e.value);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: AppTheme.cardWhite,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: AppTheme.cardShadow,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.search_rounded,
                        color: AppTheme.textSecondary, size: 14),
                    const SizedBox(width: 6),
                    Text(e.value,
                        style: Theme.of(context).textTheme.labelMedium),
                  ],
                ),
              ),
            ).animate(delay: Duration(milliseconds: 40 * e.key)).fadeIn().slideY(begin: 0.1))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.search_off_rounded,
              color: AppTheme.textSecondary, size: 56),
          const SizedBox(height: 16),
          Text('Aucun résultat pour "$_query"',
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text('Essayez d\'autres termes comme "certificat" ou "signature"',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center),
        ],
      ).animate().fadeIn(),
    );
  }

  Widget _buildResults(
    BuildContext context,
    List<Product> products,
    List<_SolutionResult> solutions,
    List<_ResourceResult> resources,
  ) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // Products section
        if (products.isNotEmpty) ...[
          _SectionHeader(
              icon: Icons.inventory_2_rounded,
              color: AppTheme.primaryGreen,
              title: 'Produits',
              count: products.length),
          const SizedBox(height: 8),
          ...products.asMap().entries.map((e) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _ProductResult(
                  product: e.value,
                  delay: e.key * 40,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (_) =>
                            ProductDetailsScreen(product: e.value)),
                  ),
                ),
              )),
          const SizedBox(height: 20),
        ],

        // Solutions section
        if (solutions.isNotEmpty) ...[
          _SectionHeader(
              icon: Icons.hub_rounded,
              color: AppTheme.tealAccent,
              title: 'Solutions',
              count: solutions.length),
          const SizedBox(height: 8),
          ...solutions.asMap().entries.map((e) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _SolutionSearchResult(
                  result: e.value,
                  delay: e.key * 40,
                  onTap: () {
                    // Find matching solution data and navigate to detail
                    // Navigate back to Explorer tab and open solution
                    Navigator.pop(context);
                  },
                ),
              )),
          const SizedBox(height: 20),
        ],

        // Resources section
        if (resources.isNotEmpty) ...[
          _SectionHeader(
              icon: Icons.library_books_rounded,
              color: const Color(0xFF6366F1),
              title: 'Ressources',
              count: resources.length),
          const SizedBox(height: 8),
          ...resources.asMap().entries.map((e) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _ResourceSearchResult(result: e.value, delay: e.key * 40),
              )),
        ],
      ],
    );
  }
}

// ── Result Models ──────────────────────────────────────────────────────────────

class _SolutionResult {
  const _SolutionResult({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.key,
  });
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final String key;
}

class _ResourceResult {
  const _ResourceResult({
    required this.title,
    required this.icon,
    required this.color,
  });
  final String title;
  final IconData icon;
  final Color color;
}

// ── Result Widgets ────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.icon,
    required this.color,
    required this.title,
    required this.count,
  });
  final IconData icon;
  final Color color;
  final String title;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 8),
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text('$count',
              style: TextStyle(
                  color: color, fontSize: 11, fontWeight: FontWeight.w700)),
        ),
      ],
    );
  }
}

class _ProductResult extends StatelessWidget {
  const _ProductResult({
    required this.product,
    required this.onTap,
    required this.delay,
  });
  final Product product;
  final VoidCallback onTap;
  final int delay;

  @override
  Widget build(BuildContext context) {
    final color = AppTheme.categoryColor(product.category);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.cardWhite,
          borderRadius: BorderRadius.circular(14),
          boxShadow: AppTheme.cardShadow,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                product.icon.isNotEmpty ? product.icon : '🔒',
                style: const TextStyle(fontSize: 18),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.name,
                      style: Theme.of(context).textTheme.titleSmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  Text(
                    product.category.isNotEmpty
                        ? product.category
                        : 'Certification',
                    style: Theme.of(context)
                        .textTheme
                        .labelSmall
                        ?.copyWith(color: color),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded,
                size: 12, color: AppTheme.textSecondary),
          ],
        ),
      ),
    )
        .animate(delay: Duration(milliseconds: delay))
        .fadeIn(duration: 300.ms)
        .slideX(begin: 0.04, end: 0);
  }
}

class _SolutionSearchResult extends StatelessWidget {
  const _SolutionSearchResult({
    required this.result,
    required this.onTap,
    required this.delay,
  });
  final _SolutionResult result;
  final VoidCallback onTap;
  final int delay;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.cardWhite,
          borderRadius: BorderRadius.circular(14),
          boxShadow: AppTheme.cardShadow,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: result.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(result.icon, color: result.color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(result.title,
                      style: Theme.of(context).textTheme.titleSmall),
                  Text(result.subtitle,
                      style: Theme.of(context)
                          .textTheme
                          .labelSmall
                          ?.copyWith(color: result.color),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: result.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text('Solution',
                  style: TextStyle(
                      color: result.color,
                      fontSize: 10,
                      fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    )
        .animate(delay: Duration(milliseconds: delay))
        .fadeIn(duration: 300.ms)
        .slideX(begin: 0.04, end: 0);
  }
}

class _ResourceSearchResult extends StatelessWidget {
  const _ResourceSearchResult({required this.result, required this.delay});
  final _ResourceResult result;
  final int delay;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.cardWhite,
        borderRadius: BorderRadius.circular(14),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: result.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(result.icon, color: result.color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(result.title,
                style: Theme.of(context).textTheme.titleSmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: result.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text('Ressource',
                style: TextStyle(
                    color: result.color,
                    fontSize: 10,
                    fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    )
        .animate(delay: Duration(milliseconds: delay))
        .fadeIn(duration: 300.ms)
        .slideX(begin: 0.04, end: 0);
  }
}
