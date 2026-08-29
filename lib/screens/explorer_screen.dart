import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_theme.dart';

// ══════════════════════════════════════════════════════════════════════════════
// Explorer Screen — Solutions + Ressources hub
// ══════════════════════════════════════════════════════════════════════════════

class ExplorerScreen extends StatefulWidget {
  const ExplorerScreen({super.key});

  @override
  State<ExplorerScreen> createState() => _ExplorerScreenState();
}

class _ExplorerScreenState extends State<ExplorerScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surfaceLight,
      body: SafeArea(
        child: Column(
          children: [
            // ── Custom Header ────────────────────────────────────────────────
            Container(
              color: AppTheme.cardWhite,
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Explorer',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium),
                            Text('Solutions & Ressources TunTrust',
                                style: Theme.of(context).textTheme.bodySmall),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceLight,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.explore_rounded,
                            color: AppTheme.primaryGreen, size: 22),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  TabBar(
                    controller: _tabController,
                    indicatorColor: AppTheme.primaryGreen,
                    indicatorWeight: 2.5,
                    labelColor: AppTheme.primaryGreen,
                    unselectedLabelColor: AppTheme.textSecondary,
                    labelStyle: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 13),
                    unselectedLabelStyle: const TextStyle(
                        fontWeight: FontWeight.w400, fontSize: 13),
                    tabs: const [
                      Tab(text: 'Nos Solutions'),
                      Tab(text: 'Nos Ressources'),
                    ],
                  ),
                ],
              ),
            ),

            // ── Tab Content ──────────────────────────────────────────────────
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: const [
                  _SolutionsTab(),
                  _RessourcesTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// SOLUTIONS TAB
// ══════════════════════════════════════════════════════════════════════════════

class _SolutionData {
  const _SolutionData({
    required this.key,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.icon,
    required this.color,
    required this.url,
    required this.useCases,
    required this.features,
    required this.floatPhase,
  });
  final String key;
  final String title;
  final String subtitle;
  final String description;
  final IconData icon;
  final Color color;
  final String url;
  final List<String> useCases;
  final List<String> features;
  final double floatPhase;
}

const List<_SolutionData> _solutions = [
  _SolutionData(
    key: 'tunsign',
    title: 'TunSign',
    subtitle: 'Signature de documents',
    description:
        'Solution de signature électronique avancée pour signer vos documents numériques avec une valeur juridique reconnue, conforme à la loi tunisienne n°2000-83.',
    icon: Icons.draw_rounded,
    color: AppTheme.tunsignColor,
    url: 'https://www.tuntrust.tn/fr/solutions/tunsign',
    useCases: [
      'Signature de contrats en ligne',
      'Validation de documents officiels',
      'Authentification de factures',
      'Signature de formulaires administratifs',
    ],
    features: [
      'Signature électronique à valeur juridique',
      'Conforme à la loi tunisienne n°2000-83',
      'Compatible PDF, Word, et autres formats',
      'Interface simple et intuitive',
      'Traçabilité et archivage sécurisé',
    ],
    floatPhase: 0.0,
  ),
  _SolutionData(
    key: 'cev',
    title: 'CEV / 2D-DOC',
    subtitle: 'Sécurisation de documents',
    description:
        'Cachet Électronique Visible (TN CEV 2D-DOC) pour garantir l\'authenticité et l\'intégrité de vos documents officiels grâce à un QR code cryptographique.',
    icon: Icons.qr_code_2_rounded,
    color: AppTheme.cevColor,
    url: 'https://www.tuntrust.tn/fr/solutions/cev',
    useCases: [
      'Documents officiels et administratifs',
      'Diplômes et attestations',
      'Factures et devis vérifiables',
      'Lutte contre la fraude documentaire',
    ],
    features: [
      'QR code 2D-DOC signé cryptographiquement',
      'Vérification instantanée par scan',
      'Compatible avec les documents imprimés',
      'Infrastructure PKI nationale TunTrust',
      'Conforme aux standards internationaux',
    ],
    floatPhase: 0.5,
  ),
  _SolutionData(
    key: 'digigo',
    title: 'Digigo',
    subtitle: 'Signature à distance',
    description:
        'Solution de signature électronique à distance, entièrement mobile et sans support physique. Signez vos documents depuis n\'importe où, à tout moment.',
    icon: Icons.phone_android_rounded,
    color: AppTheme.digigoColor,
    url: 'https://www.tuntrust.tn/fr/solutions/digigo',
    useCases: [
      'Signature mobile sans token physique',
      'Processus de signature à distance',
      'Intégration dans les workflows entreprise',
      'Signature en masse de documents',
    ],
    features: [
      'Signature cloud sans token physique',
      'Application mobile Android/iOS',
      'Certificat de signature Digigo',
      'Intégration API pour entreprises',
      'Authentification forte multi-facteurs',
    ],
    floatPhase: 1.0,
  ),
  _SolutionData(
    key: 'tunstamp',
    title: 'TunStamp',
    subtitle: 'Contremarque de temps',
    description:
        'Service d\'horodatage électronique certifié pour attester l\'existence et l\'intégrité d\'un document à un instant précis, reconnu juridiquement.',
    icon: Icons.access_time_rounded,
    color: AppTheme.tunstampColor,
    url: 'https://www.tuntrust.tn/fr/solutions/tunstamp',
    useCases: [
      'Preuve d\'existence d\'un document',
      'Archivage légal horodaté',
      'Appels d\'offres et soumissions',
      'Transactions financières certifiées',
    ],
    features: [
      'Horodatage RFC 3161 certifié',
      'Valeur juridique reconnue',
      'Précision à la milliseconde',
      'Intégration API disponible',
      'Archivage à long terme sécurisé',
    ],
    floatPhase: 1.5,
  ),
];

class _SolutionsTab extends StatelessWidget {
  const _SolutionsTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      children: [
        // Header card
        _SolutionsHeroCard()
            .animate()
            .fadeIn(duration: 450.ms)
            .slideY(begin: 0.08, end: 0),
        const SizedBox(height: 20),
        Text('Nos Solutions',
            style: Theme.of(context).textTheme.headlineMedium)
            .animate(delay: 100.ms)
            .fadeIn(duration: 350.ms),
        const SizedBox(height: 4),
        Text(
          'Explorez l\'écosystème de confiance numérique TunTrust',
          style: Theme.of(context).textTheme.bodyMedium,
        ).animate(delay: 150.ms).fadeIn(duration: 350.ms),
        const SizedBox(height: 16),

        // Solution cards
        ..._solutions.asMap().entries.map((e) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: _SolutionCard(solution: e.value, index: e.key),
            )),
      ],
    );
  }
}

// ── Solutions Hero Card ───────────────────────────────────────────────────────

class _SolutionsHeroCard extends StatefulWidget {
  @override
  State<_SolutionsHeroCard> createState() => _SolutionsHeroCardState();
}

class _SolutionsHeroCardState extends State<_SolutionsHeroCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: AppTheme.darkHeroGradient,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: AppTheme.darkNavy.withOpacity(0.28),
            blurRadius: 28,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background decorative circles
          Positioned(
            right: -30, top: -30,
            child: Container(
              width: 130, height: 130,
              decoration: BoxDecoration(
                color: AppTheme.primaryGreen.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            right: 10, bottom: -40,
            child: Container(
              width: 90, height: 90,
              decoration: BoxDecoration(
                color: AppTheme.tealAccent.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),
          // Content
          Row(
            children: [
              // Animated central icon
              AnimatedBuilder(
                animation: _pulseAnim,
                builder: (_, __) => Transform.scale(
                  scale: _pulseAnim.value,
                  child: Container(
                    width: 68, height: 68,
                    decoration: BoxDecoration(
                      gradient: AppTheme.heroGradient,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryGreen.withOpacity(0.35),
                          blurRadius: 18,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: const Icon(Icons.hub_rounded,
                        color: Colors.white, size: 32),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Écosystème de Confiance',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '4 solutions pour sécuriser vos usages numériques',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.white70,
                          ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: const [
                        _MiniChip(label: '✍️ Signer'),
                        _MiniChip(label: '🔐 Sécuriser'),
                        _MiniChip(label: '🕒 Horodater'),
                        _MiniChip(label: '📱 Mobile'),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniChip extends StatelessWidget {
  const _MiniChip({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Text(label,
          style: const TextStyle(
              color: Colors.white, fontSize: 11, fontWeight: FontWeight.w500)),
    );
  }
}

// ── Solution Card ─────────────────────────────────────────────────────────────

class _SolutionCard extends StatefulWidget {
  const _SolutionCard({required this.solution, required this.index});
  final _SolutionData solution;
  final int index;

  @override
  State<_SolutionCard> createState() => _SolutionCardState();
}

class _SolutionCardState extends State<_SolutionCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _floatController;
  late Animation<double> _floatAnim;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat(reverse: true);

    // Stagger each card's float phase
    _floatAnim = Tween<double>(begin: -3.0, end: 3.0).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );

    // Apply phase offset by starting at a different value
    _floatController.value = (widget.solution.floatPhase % 1.0);
  }

  @override
  void dispose() {
    _floatController.dispose();
    super.dispose();
  }

  void _openDetail(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (_, anim, __) =>
            SolutionDetailScreen(solution: widget.solution),
        transitionsBuilder: (_, anim, __, child) => FadeTransition(
          opacity: CurvedAnimation(parent: anim, curve: Curves.easeOut),
          child: SlideTransition(
            position:
                Tween<Offset>(begin: const Offset(0, 0.04), end: Offset.zero)
                    .animate(CurvedAnimation(parent: anim, curve: Curves.easeOut)),
            child: child,
          ),
        ),
        transitionDuration: const Duration(milliseconds: 380),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.solution;
    return AnimatedBuilder(
      animation: _floatAnim,
      builder: (_, child) => Transform.translate(
        offset: Offset(0, _floatAnim.value),
        child: child,
      ),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) {
          setState(() => _pressed = false);
          _openDetail(context);
        },
        onTapCancel: () => setState(() => _pressed = false),
        child: AnimatedScale(
          scale: _pressed ? 0.97 : 1.0,
          duration: const Duration(milliseconds: 120),
          child: Container(
            decoration: BoxDecoration(
              color: AppTheme.cardWhite,
              borderRadius: BorderRadius.circular(20),
              boxShadow: AppTheme.solutionCardShadow(s.color),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Gradient header strip
                Container(
                  height: 6,
                  decoration: BoxDecoration(
                    gradient: AppTheme.solutionGradient(s.key),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(18),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: s.color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(s.icon, color: s.color, size: 28),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(s.title,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(color: AppTheme.textPrimary)),
                            const SizedBox(height: 2),
                            Text(s.subtitle,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                        color: s.color,
                                        fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                      Icon(Icons.arrow_forward_ios_rounded,
                          size: 14, color: s.color),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
                  child: Text(
                    s.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(height: 1.5),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    )
        .animate(delay: Duration(milliseconds: 120 + widget.index * 80))
        .fadeIn(duration: 400.ms)
        .slideY(begin: 0.12, end: 0);
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// SOLUTION DETAIL SCREEN
// ══════════════════════════════════════════════════════════════════════════════

class SolutionDetailScreen extends StatelessWidget {
  const SolutionDetailScreen({super.key, required this.solution});
  final _SolutionData solution;

  Future<void> _launch(BuildContext context) async {
    final uri = Uri.parse(solution.url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication) && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Impossible d'ouvrir le navigateur.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surfaceLight,
      body: CustomScrollView(
        slivers: [
          // ── Hero App Bar ─────────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: solution.color,
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: AppTheme.solutionGradient(solution.key),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -30, top: -30,
                      child: Container(
                        width: 180, height: 180,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.08),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    Positioned(
                      left: -20, bottom: -20,
                      child: Container(
                        width: 100, height: 100,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.06),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 28, left: 20,
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.18),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                  color: Colors.white.withOpacity(0.3)),
                            ),
                            child: Icon(solution.icon,
                                color: Colors.white, size: 28),
                          ),
                          const SizedBox(width: 14),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(solution.title,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 22,
                                      fontWeight: FontWeight.w800)),
                              Text(solution.subtitle,
                                  style: TextStyle(
                                      color: Colors.white.withOpacity(0.85),
                                      fontSize: 13)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Content ──────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Description
                  _DetailCard(
                    icon: Icons.info_outline_rounded,
                    color: solution.color,
                    title: 'Description',
                    child: Text(solution.description,
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(
                                color: AppTheme.textPrimary, height: 1.6)),
                  ).animate().fadeIn(duration: 350.ms).slideY(begin: 0.1),
                  const SizedBox(height: 14),

                  // Use Cases
                  _DetailCard(
                    icon: Icons.lightbulb_outline_rounded,
                    color: solution.color,
                    title: 'Cas d\'usage',
                    child: Column(
                      children: solution.useCases
                          .asMap()
                          .entries
                          .map((e) => _CheckRow(
                                text: e.value,
                                color: solution.color,
                                icon: Icons.circle,
                              ))
                          .toList(),
                    ),
                  ).animate(delay: 80.ms).fadeIn().slideY(begin: 0.1),
                  const SizedBox(height: 14),

                  // Features
                  _DetailCard(
                    icon: Icons.checklist_rounded,
                    color: solution.color,
                    title: 'Caractéristiques',
                    child: Column(
                      children: solution.features
                          .map((f) => _CheckRow(
                                text: f,
                                color: solution.color,
                                icon: Icons.check_circle_rounded,
                              ))
                          .toList(),
                    ),
                  ).animate(delay: 140.ms).fadeIn().slideY(begin: 0.1),
                  const SizedBox(height: 24),

                  // CTA
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: solution.color,
                        minimumSize: const Size(double.infinity, 56),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                      ),
                      onPressed: () => _launch(context),
                      icon: const Icon(Icons.open_in_new_rounded),
                      label: Text('Découvrir ${solution.title} sur tuntrust.tn',
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w600)),
                    ),
                  ).animate(delay: 200.ms).fadeIn().slideY(begin: 0.1),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailCard extends StatelessWidget {
  const _DetailCard(
      {required this.icon,
      required this.color,
      required this.title,
      required this.child});
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
        borderRadius: BorderRadius.circular(18),
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

class _CheckRow extends StatelessWidget {
  const _CheckRow({required this.text, required this.color, required this.icon});
  final String text;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 15),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: AppTheme.textPrimary, height: 1.45)),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// RESSOURCES TAB — Knowledge Hub
// ══════════════════════════════════════════════════════════════════════════════

class _ResourceCategory {
  const _ResourceCategory({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.resources,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final List<_Resource> resources;
}

class _Resource {
  const _Resource({
    required this.title,
    required this.url,
    required this.action,
  });
  final String title;
  final String url;
  final String action; // 'open', 'download', 'visit'
}

const List<_ResourceCategory> _resourceCategories = [
  _ResourceCategory(
    icon: Icons.policy_rounded,
    title: 'Politiques de Certification',
    subtitle: 'CP, CPS et déclarations',
    color: Color(0xFF05B257),
    resources: [
      _Resource(
        title: 'Politique de Certification Générale',
        url: 'https://www.tuntrust.tn/fr/documents-utiles?field_theme_target_id=53',
        action: 'visit',
      ),
      _Resource(
        title: 'Voir toutes les politiques',
        url: 'https://www.tuntrust.tn/fr/documents-utiles?field_theme_target_id=53',
        action: 'open',
      ),
    ],
  ),
  _ResourceCategory(
    icon: Icons.verified_rounded,
    title: 'Certificats Racines',
    subtitle: 'Certificats de confiance TunTrust',
    color: Color(0xFF007A87),
    resources: [
      _Resource(
        title: 'Certificat racine TunTrust',
        url: 'https://www.tuntrust.tn/fr/documents-utiles?field_theme_target_id=55',
        action: 'download',
      ),
      _Resource(
        title: 'Voir tous les certificats racines',
        url: 'https://www.tuntrust.tn/fr/documents-utiles?field_theme_target_id=55',
        action: 'open',
      ),
    ],
  ),
  _ResourceCategory(
    icon: Icons.description_rounded,
    title: 'Formulaires de Demande',
    subtitle: 'Demandes de certificats',
    color: Color(0xFF6366F1),
    resources: [
      _Resource(
        title: 'Formulaire ID-Trust',
        url: 'https://www.tuntrust.tn/fr/documents-utiles?field_theme_target_id=59',
        action: 'download',
      ),
      _Resource(
        title: 'Formulaire Enterprise-ID',
        url: 'https://www.tuntrust.tn/fr/documents-utiles?field_theme_target_id=59',
        action: 'download',
      ),
      _Resource(
        title: 'Voir tous les formulaires',
        url: 'https://www.tuntrust.tn/fr/documents-utiles?field_theme_target_id=59',
        action: 'open',
      ),
    ],
  ),
  _ResourceCategory(
    icon: Icons.computer_rounded,
    title: 'Pilotes & Guides',
    subtitle: 'Installation et configuration',
    color: Color(0xFFF59E0B),
    resources: [
      _Resource(
        title: 'Guide d\'installation Windows',
        url: 'https://www.tuntrust.tn/fr/documents-utiles?field_theme_target_id=58',
        action: 'download',
      ),
      _Resource(
        title: 'Guide d\'installation Linux',
        url: 'https://www.tuntrust.tn/fr/documents-utiles?field_theme_target_id=58',
        action: 'download',
      ),
      _Resource(
        title: 'Voir tous les guides',
        url: 'https://www.tuntrust.tn/fr/documents-utiles?field_theme_target_id=58',
        action: 'open',
      ),
    ],
  ),
  _ResourceCategory(
    icon: Icons.gavel_rounded,
    title: 'Conditions Générales',
    subtitle: 'CGU et cadre légal',
    color: Color(0xFFEF4444),
    resources: [
      _Resource(
        title: 'Conditions Générales d\'Utilisation',
        url: 'https://www.tuntrust.tn/fr/documents-utiles?field_theme_target_id=54',
        action: 'open',
      ),
    ],
  ),
  _ResourceCategory(
    icon: Icons.block_rounded,
    title: 'Listes de Révocation',
    subtitle: 'LCR et LAR',
    color: Color(0xFF8B5CF6),
    resources: [
      _Resource(
        title: 'Liste des Certificats Révoqués (LCR)',
        url: 'https://www.tuntrust.tn/fr/documents-utiles?field_theme_target_id=57',
        action: 'open',
      ),
      _Resource(
        title: 'Liste des Autorités Révoquées (LAR)',
        url: 'https://www.tuntrust.tn/fr/documents-utiles?field_theme_target_id=56',
        action: 'open',
      ),
    ],
  ),
  _ResourceCategory(
    icon: Icons.manage_search_rounded,
    title: 'Annuaire des Certificats',
    subtitle: 'Recherche LDAP',
    color: Color(0xFF0891B2),
    resources: [
      _Resource(
        title: 'Rechercher un certificat',
        url: 'https://www.tuntrust.tn/LdapSearch/',
        action: 'visit',
      ),
    ],
  ),
  _ResourceCategory(
    icon: Icons.workspace_premium_rounded,
    title: 'Nos Certifications',
    subtitle: 'Rapports d\'audit et qualifications',
    color: Color(0xFF059669),
    resources: [
      _Resource(
        title: 'Rapports d\'audit et certifications',
        url: 'https://www.tuntrust.tn/fr/content/rapports-d%E2%80%99audit',
        action: 'open',
      ),
    ],
  ),
];

class _RessourcesTab extends StatefulWidget {
  const _RessourcesTab();

  @override
  State<_RessourcesTab> createState() => _RessourcesTabState();
}

class _RessourcesTabState extends State<_RessourcesTab> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<_ResourceCategory> get _filtered => _query.isEmpty
      ? _resourceCategories
      : _resourceCategories
          .where((c) =>
              c.title.toLowerCase().contains(_query.toLowerCase()) ||
              c.subtitle.toLowerCase().contains(_query.toLowerCase()))
          .toList();

  void _showResources(BuildContext ctx, _ResourceCategory cat) {
    showModalBottomSheet(
      context: ctx,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _ResourceBottomSheet(category: cat),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cats = _filtered;
    return Column(
      children: [
        // Search bar
        Container(
          color: AppTheme.cardWhite,
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
          child: TextField(
            controller: _searchCtrl,
            onChanged: (v) => setState(() => _query = v),
            decoration: InputDecoration(
              hintText: 'Rechercher une ressource…',
              prefixIcon: const Icon(Icons.search_rounded,
                  color: AppTheme.textSecondary, size: 20),
              suffixIcon: _query.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.close_rounded,
                          color: AppTheme.textSecondary, size: 18),
                      onPressed: () {
                        _searchCtrl.clear();
                        setState(() => _query = '');
                      },
                    )
                  : null,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ),

        // Grid
        Expanded(
          child: cats.isEmpty
              ? Center(
                  child: Text('Aucune ressource trouvée',
                      style: Theme.of(context).textTheme.bodyMedium))
              : GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.95,
                  ),
                  itemCount: cats.length,
                  itemBuilder: (ctx, i) => _ResourceCategoryCard(
                    category: cats[i],
                    index: i,
                    onTap: () => _showResources(ctx, cats[i]),
                  ),
                ),
        ),
      ],
    );
  }
}

class _ResourceCategoryCard extends StatefulWidget {
  const _ResourceCategoryCard({
    required this.category,
    required this.index,
    required this.onTap,
  });
  final _ResourceCategory category;
  final int index;
  final VoidCallback onTap;

  @override
  State<_ResourceCategoryCard> createState() => _ResourceCategoryCardState();
}

class _ResourceCategoryCardState extends State<_ResourceCategoryCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final cat = widget.category;
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
          decoration: BoxDecoration(
            color: AppTheme.cardWhite,
            borderRadius: BorderRadius.circular(18),
            boxShadow: AppTheme.cardShadow,
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: cat.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(cat.icon, color: cat.color, size: 22),
              ),
              const Spacer(),
              Text(cat.title,
                  style: Theme.of(context).textTheme.titleSmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis),
              const SizedBox(height: 2),
              Text(cat.subtitle,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(fontSize: 10),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: cat.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${cat.resources.length} doc${cat.resources.length > 1 ? 's' : ''}',
                      style: TextStyle(
                          color: cat.color,
                          fontSize: 10,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                  const Spacer(),
                  Icon(Icons.arrow_forward_ios_rounded,
                      size: 11, color: cat.color),
                ],
              ),
            ],
          ),
        ),
      ),
    )
        .animate(delay: Duration(milliseconds: 60 * widget.index))
        .fadeIn(duration: 350.ms)
        .slideY(begin: 0.15, end: 0);
  }
}

// ── Resource Bottom Sheet ─────────────────────────────────────────────────────

class _ResourceBottomSheet extends StatelessWidget {
  const _ResourceBottomSheet({required this.category});
  final _ResourceCategory category;

  Future<void> _open(BuildContext ctx, _Resource r) async {
    final uri = Uri.parse(r.url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication) &&
        ctx.mounted) {
      ScaffoldMessenger.of(ctx).showSnackBar(
        const SnackBar(content: Text("Impossible d'ouvrir le lien.")),
      );
    }
  }

  IconData _actionIcon(String action) {
    switch (action) {
      case 'download':
        return Icons.download_rounded;
      case 'visit':
        return Icons.open_in_new_rounded;
      default:
        return Icons.open_in_browser_rounded;
    }
  }

  String _actionLabel(String action) {
    switch (action) {
      case 'download':
        return 'Télécharger';
      case 'visit':
        return 'Visiter';
      default:
        return 'Ouvrir';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.cardWhite,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 20),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.borderColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: category.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(category.icon, color: category.color, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(category.title,
                          style: Theme.of(context).textTheme.titleLarge),
                      Text(category.subtitle,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: category.color)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 8),

          // Resources list
          ...category.resources.map((r) => ListTile(
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 4),
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: category.color.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(_actionIcon(r.action),
                      color: category.color, size: 18),
                ),
                title: Text(r.title,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.w500,
                        )),
                subtitle: Text(_actionLabel(r.action),
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: category.color)),
                trailing: const Icon(Icons.chevron_right_rounded,
                    color: AppTheme.textSecondary),
                onTap: () => _open(context, r),
              )),

          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: OutlinedButton.icon(
              onPressed: () async {
                final uri = Uri.parse(
                    'https://www.tuntrust.tn/fr/repository');
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              },
              icon: const Icon(Icons.language_rounded, size: 16),
              label: const Text('Voir toutes les ressources sur tuntrust.tn'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Hex extension for convenience
extension _HexColor on Color {
  static Color fromHex(String hex) {
    final buffer = StringBuffer();
    if (hex.length == 6 || hex.length == 7) buffer.write('ff');
    buffer.write(hex.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }
}
