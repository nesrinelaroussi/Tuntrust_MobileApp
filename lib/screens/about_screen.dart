import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';

// ══════════════════════════════════════════════════════════════════════════════
// About Screen — Visual storytelling for TunTrust
// ══════════════════════════════════════════════════════════════════════════════

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _statsController;
  bool _statsVisible = false;

  @override
  void initState() {
    super.initState();
    _statsController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200));
    // Trigger stats animation after a short delay
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) {
        _statsController.forward();
        setState(() => _statsVisible = true);
      }
    });
  }

  @override
  void dispose() {
    _statsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surfaceLight,
      body: CustomScrollView(
        slivers: [
          // ── Hero App Bar ─────────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: AppTheme.darkNavy,
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(gradient: AppTheme.darkHeroGradient),
                child: Stack(
                  children: [
                    // Background rings
                    Positioned(
                      right: -40, top: -40,
                      child: Container(
                        width: 200, height: 200,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryGreen.withOpacity(0.08),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    Positioned(
                      left: -20, bottom: -60,
                      child: Container(
                        width: 150, height: 150,
                        decoration: BoxDecoration(
                          color: AppTheme.tealAccent.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    // Content
                    Positioned(
                      bottom: 32, left: 20,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryGreen.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color:
                                      AppTheme.primaryGreen.withOpacity(0.35)),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.verified_rounded,
                                    color: AppTheme.primaryGreen, size: 13),
                                SizedBox(width: 5),
                                Text(
                                  'Autorité Nationale de Certification',
                                  style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'À Propos de\nTunTrust',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              height: 1.2,
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

          // ── Body ─────────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Stats Row ──────────────────────────────────────────
                  _StatsRow(controller: _statsController)
                      .animate()
                      .fadeIn(duration: 500.ms),
                  const SizedBox(height: 28),

                  // ── Qui Sommes-Nous ───────────────────────────────────
                  _SectionTitle(title: 'Qui Sommes-Nous ?', icon: Icons.apartment_rounded, color: AppTheme.primaryGreen)
                      .animate(delay: 100.ms).fadeIn().slideX(begin: -0.08),
                  const SizedBox(height: 12),
                  _StoryCard(
                    child: Text(
                      'TunTrust (Agence Nationale de Certification Électronique — ANCE) est l\'autorité de certification racine de Tunisie, créée par le Décret n°2000-2354. '
                      'Elle œuvre pour la sécurisation de l\'économie numérique tunisienne en délivrant des certificats électroniques qualifiés et en fournissant des services de confiance reconnus juridiquement.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.textPrimary,
                            height: 1.7,
                          ),
                    ),
                  ).animate(delay: 150.ms).fadeIn().slideY(begin: 0.1),
                  const SizedBox(height: 24),

                  // ── Notre Mission ─────────────────────────────────────
                  _SectionTitle(title: 'Notre Mission', icon: Icons.track_changes_rounded, color: AppTheme.tealAccent)
                      .animate(delay: 200.ms).fadeIn().slideX(begin: -0.08),
                  const SizedBox(height: 12),
                  ..._missions.asMap().entries.map((e) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _MissionCard(mission: e.value, index: e.key),
                      )),
                  const SizedBox(height: 24),

                  // ── Notre Rôle ────────────────────────────────────────
                  _SectionTitle(title: 'Notre Rôle', icon: Icons.hub_rounded, color: Color(0xFF6366F1))
                      .animate(delay: 300.ms).fadeIn().slideX(begin: -0.08),
                  const SizedBox(height: 12),
                  _RoleCard().animate(delay: 360.ms).fadeIn().slideY(begin: 0.1),
                  const SizedBox(height: 24),

                  // ── Digital Trust Journey ─────────────────────────────
                  _SectionTitle(title: 'Le Parcours de Confiance Numérique', icon: Icons.timeline_rounded, color: AppTheme.primaryGreen)
                      .animate(delay: 420.ms).fadeIn().slideX(begin: -0.08),
                  const SizedBox(height: 12),
                  const _TrustJourney()
                      .animate(delay: 480.ms)
                      .fadeIn(duration: 500.ms),
                  const SizedBox(height: 24),

                  // ── Cadre Légal ───────────────────────────────────────
                  _SectionTitle(title: 'Cadre Légal', icon: Icons.gavel_rounded, color: Color(0xFFF59E0B))
                      .animate(delay: 540.ms).fadeIn().slideX(begin: -0.08),
                  const SizedBox(height: 12),
                  _LegalCard()
                      .animate(delay: 580.ms).fadeIn().slideY(begin: 0.1),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Data ──────────────────────────────────────────────────────────────────────

class _MissionItem {
  const _MissionItem({required this.icon, required this.color, required this.title, required this.body});
  final IconData icon;
  final Color color;
  final String title;
  final String body;
}

const List<_MissionItem> _missions = [
  _MissionItem(
    icon: Icons.verified_user_rounded,
    color: AppTheme.primaryGreen,
    title: 'Certification Électronique',
    body: 'Émettre et gérer les certificats électroniques qualifiés pour personnes physiques et morales, conformes aux standards X.509.',
  ),
  _MissionItem(
    icon: Icons.shield_rounded,
    color: AppTheme.tealAccent,
    title: 'Infrastructure de Confiance',
    body: 'Mettre en place et maintenir une infrastructure PKI nationale sécurisée et fiable pour l\'économie numérique tunisienne.',
  ),
  _MissionItem(
    icon: Icons.school_rounded,
    color: Color(0xFF6366F1),
    title: 'Sensibilisation & Formation',
    body: 'Promouvoir la culture de la sécurité numérique et former les acteurs économiques aux enjeux de la certification électronique.',
  ),
];

// ── Sub-widgets ───────────────────────────────────────────────────────────────

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.controller});
  final AnimationController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppTheme.heroGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppTheme.heroBannerShadow,
      ),
      child: Row(
        children: [
          _StatItem(
            controller: controller,
            end: 25,
            label: 'Ans\nd\'expérience',
            suffix: '+',
          ),
          _VerticalDivider(),
          _StatItem(
            controller: controller,
            end: 100,
            label: 'Partenaires\nde confiance',
            suffix: '+',
          ),
          _VerticalDivider(),
          _StatItem(
            controller: controller,
            end: 4,
            label: 'Solutions\nnumériques',
            suffix: '',
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.controller,
    required this.end,
    required this.label,
    required this.suffix,
  });
  final AnimationController controller;
  final int end;
  final String label;
  final String suffix;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: AnimatedBuilder(
        animation: controller,
        builder: (_, __) {
          final value = (controller.value * end).round();
          return Column(
            children: [
              Text(
                '$value$suffix',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 11,
                    height: 1.3),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 48,
      color: Colors.white.withOpacity(0.25),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.icon, required this.color});
  final String title;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 17),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(title, style: Theme.of(context).textTheme.headlineSmall),
        ),
      ],
    );
  }
}

class _StoryCard extends StatelessWidget {
  const _StoryCard({required this.child});
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
      child: child,
    );
  }
}

class _MissionCard extends StatelessWidget {
  const _MissionCard({required this.mission, required this.index});
  final _MissionItem mission;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: mission.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(mission.icon, color: mission.color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(mission.title,
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(mission.body,
                    style: Theme.of(context).textTheme.bodySmall,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    )
        .animate(delay: Duration(milliseconds: 220 + index * 70))
        .fadeIn(duration: 400.ms)
        .slideX(begin: 0.06, end: 0);
  }
}

class _RoleCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0D1B2A), Color(0xFF1A3050)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.hub_rounded, color: AppTheme.primaryGreen, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Text('TunTrust dans l\'écosystème numérique',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                        )),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...[
            'Autorité de Certification Racine de Tunisie',
            'Garant de l\'authenticité des échanges électroniques',
            'Pilier de la confiance numérique nationale',
            'Interface entre la technologie PKI et l\'usage citoyen',
          ].map((role) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_rounded,
                        color: AppTheme.primaryGreen, size: 15),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(role,
                          style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                              height: 1.4)),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

// ── Digital Trust Journey Timeline ────────────────────────────────────────────

class _TrustJourney extends StatelessWidget {
  const _TrustJourney();

  static const List<_JourneyStep> _steps = [
    _JourneyStep(icon: Icons.person_rounded, label: 'Identité', color: Color(0xFF05B257)),
    _JourneyStep(icon: Icons.lock_rounded, label: 'Authentification', color: Color(0xFF007A87)),
    _JourneyStep(icon: Icons.draw_rounded, label: 'Signature', color: Color(0xFF6366F1)),
    _JourneyStep(icon: Icons.receipt_long_rounded, label: 'Transactions Sécurisées', color: Color(0xFFF59E0B)),
    _JourneyStep(icon: Icons.verified_rounded, label: 'Confiance Numérique', color: Color(0xFF059669)),
  ];

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
        children: _steps.asMap().entries.map((e) {
          final isLast = e.key == _steps.length - 1;
          return _JourneyRow(step: e.value, isLast: isLast, index: e.key);
        }).toList(),
      ),
    );
  }
}

class _JourneyStep {
  const _JourneyStep({required this.icon, required this.label, required this.color});
  final IconData icon;
  final String label;
  final Color color;
}

class _JourneyRow extends StatelessWidget {
  const _JourneyRow({required this.step, required this.isLast, required this.index});
  final _JourneyStep step;
  final bool isLast;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Left: icon + connector line
        Column(
          children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: step.color.withOpacity(0.12),
                shape: BoxShape.circle,
                border: Border.all(color: step.color.withOpacity(0.35), width: 1.5),
              ),
              child: Icon(step.icon, color: step.color, size: 18),
            ),
            if (!isLast)
              Container(
                width: 2, height: 28,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [step.color.withOpacity(0.4), Colors.transparent],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    step.label,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: step.color,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
                if (!isLast)
                  Icon(Icons.south_rounded,
                      size: 14, color: AppTheme.textSecondary),
              ],
            ),
          ),
        ),
      ],
    )
        .animate(delay: Duration(milliseconds: 80 * index))
        .fadeIn(duration: 350.ms)
        .slideX(begin: 0.06, end: 0);
  }
}

// ── Legal Card ────────────────────────────────────────────────────────────────

class _LegalCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.cardWhite,
        borderRadius: BorderRadius.circular(18),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        children: [
          _LegalRow(
            title: 'Loi n°2000-83',
            desc: 'Échanges et commerce électroniques — valeur juridique de la signature électronique',
            color: const Color(0xFFF59E0B),
          ),
          const Divider(height: 20),
          _LegalRow(
            title: 'Décret n°2000-2354',
            desc: 'Création de l\'ANCE (TunTrust) — Agence Nationale de Certification Électronique',
            color: const Color(0xFF6366F1),
          ),
          const Divider(height: 20),
          _LegalRow(
            title: 'Arrêté du 9 octobre 2002',
            desc: 'Normes et procédures techniques de certification électronique en Tunisie',
            color: AppTheme.tealAccent,
            last: true,
          ),
        ],
      ),
    );
  }
}

class _LegalRow extends StatelessWidget {
  const _LegalRow({required this.title, required this.desc, required this.color, this.last = false});
  final String title;
  final String desc;
  final Color color;
  final bool last;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(title,
              style: TextStyle(
                  color: color,
                  fontSize: 11,
                  fontWeight: FontWeight.w700)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(desc,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textPrimary,
                    height: 1.45,
                  )),
        ),
      ],
    );
  }
}
