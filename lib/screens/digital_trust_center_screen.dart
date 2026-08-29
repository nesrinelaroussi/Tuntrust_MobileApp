import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';

class DigitalTrustCenterScreen extends StatelessWidget {
  const DigitalTrustCenterScreen({super.key});

  static const List<_TrustTopic> _topics = [
    _TrustTopic(
      icon: Icons.verified_user_rounded,
      color: Color(0xFF05B257),
      title: 'Le Certificat Électronique',
      subtitle: 'Comprendre la certification numérique',
      body:
          'Un certificat électronique est un document numérique délivré par une Autorité de Certification (AC) reconnue. '
          'Il lie l\'identité d\'une personne physique ou morale à une clé publique cryptographique.\n\n'
          'TunTrust, en tant qu\'Agence Nationale de Certification Électronique de Tunisie, émet des certificats '
          'conformes aux standards internationaux X.509, garantissant l\'authenticité et l\'intégrité des échanges numériques.',
      keyPoints: [
        'Identifie de façon unique une entité numérique',
        'Contient une clé publique cryptographique',
        'Signé par une Autorité de Certification de confiance',
        'Possède une durée de validité définie',
        'Peut être révoqué en cas de compromission',
      ],
    ),
    _TrustTopic(
      icon: Icons.draw_rounded,
      color: Color(0xFF007A87),
      title: 'La Signature Électronique',
      subtitle: 'Valeur juridique et fonctionnement',
      body:
          'La signature électronique est un mécanisme cryptographique permettant d\'authentifier l\'auteur d\'un document '
          'numérique et d\'en garantir l\'intégrité.\n\n'
          'En Tunisie, la loi n°2000-83 du 9 août 2000 relative aux échanges et au commerce électroniques reconnaît '
          'la valeur juridique de la signature électronique. TunTrust fournit les certificats nécessaires '
          'pour signer des documents avec une force probante reconnue.',
      keyPoints: [
        'Valeur juridique équivalente à la signature manuscrite',
        'Garantit l\'intégrité du document signé',
        'Non-répudiation : l\'auteur ne peut nier sa signature',
        'Basée sur la cryptographie asymétrique (PKI)',
        'Reconnue par la loi tunisienne n°2000-83',
      ],
    ),
    _TrustTopic(
      icon: Icons.qr_code_2_rounded,
      color: Color(0xFF6366F1),
      title: 'TN CEV & Vérification 2D-DOC',
      subtitle: 'Vérification des documents officiels',
      body:
          'Le système TN CEV (Tunisian Certificate Electronic Verification) permet de vérifier l\'authenticité '
          'des documents officiels tunisiens intégrant un QR code ou un code 2D-DOC.\n\n'
          'Ces codes bidimensionnels contiennent des données signées cryptographiquement par l\'entité émettrice. '
          'TunTrust fournit l\'infrastructure PKI permettant la vérification de ces documents, '
          'garantissant leur authenticité et protégeant contre les falsifications.',
      keyPoints: [
        'Vérification instantanée par scan QR',
        'Données signées cryptographiquement',
        'Protection contre la fraude documentaire',
        'Compatible avec les documents officiels tunisiens',
        'Infrastructure PKI nationale TunTrust',
      ],
    ),
    _TrustTopic(
      icon: Icons.shield_rounded,
      color: Color(0xFFF59E0B),
      title: 'Identité Numérique & Sécurité',
      subtitle: 'Protéger votre présence numérique',
      body:
          'L\'identité numérique représente l\'ensemble des informations qui vous identifient dans le monde numérique. '
          'TunTrust joue un rôle central dans la mise en place d\'une infrastructure d\'identité numérique fiable en Tunisie.\n\n'
          'Grâce aux certificats qualifiés et aux services de confiance, TunTrust vous permet d\'accéder aux services '
          'administratifs en ligne, de signer des contrats électroniques et de sécuriser vos communications.',
      keyPoints: [
        'Infrastructure PKI nationale sécurisée',
        'Accès aux services e-gouvernement',
        'Protection des données personnelles',
        'Authentification forte multi-facteurs',
        'Conformité aux standards européens eIDAS',
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surfaceLight,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 160,
            pinned: true,
            backgroundColor: AppTheme.darkNavy,
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'Centre de Confiance Numérique',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white, fontSize: 14,
                ),
              ),
              background: Container(
                decoration: const BoxDecoration(gradient: AppTheme.darkHeroGradient),
                child: Stack(
                  children: [
                    Positioned(
                      right: -30, top: -30,
                      child: Container(
                        width: 180, height: 180,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    Positioned(
                      left: 24, bottom: 56,
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryGreen.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(Icons.school_rounded,
                                color: AppTheme.primaryGreen, size: 28),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Éducation numérique',
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(color: Colors.white70)),
                              Text('Comprendre la confiance numérique',
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(color: Colors.white, fontWeight: FontWeight.w600)),
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
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final topic = _topics[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _TopicCard(topic: topic, index: index),
                  );
                },
                childCount: _topics.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TrustTopic {
  const _TrustTopic({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.body,
    required this.keyPoints,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final String body;
  final List<String> keyPoints;
}

class _TopicCard extends StatefulWidget {
  const _TopicCard({required this.topic, required this.index});
  final _TrustTopic topic;
  final int index;

  @override
  State<_TopicCard> createState() => _TopicCardState();
}

class _TopicCardState extends State<_TopicCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final t = widget.topic;
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardWhite,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppTheme.cardShadow,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // Header
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: t.color.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(t.icon, color: t.color, size: 26),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(t.title,
                            style: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(height: 2),
                        Text(t.subtitle,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: t.color)),
                      ],
                    ),
                  ),
                  AnimatedRotation(
                    turns: _expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 300),
                    child: Icon(Icons.keyboard_arrow_down_rounded,
                        color: AppTheme.textSecondary),
                  ),
                ],
              ),
            ),
          ),
          // Expandable content
          AnimatedSize(
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeInOutCubic,
            child: _expanded
                ? Column(
                    children: [
                      Container(
                        height: 1,
                        color: AppTheme.borderColor,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(t.body,
                                style: Theme.of(context).textTheme.bodyMedium),
                            const SizedBox(height: 16),
                            Text('Points clés',
                                style: Theme.of(context).textTheme.titleSmall
                                    ?.copyWith(color: t.color)),
                            const SizedBox(height: 10),
                            ...t.keyPoints.map(
                              (point) => Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(Icons.check_circle_rounded,
                                        color: t.color, size: 16),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(point,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(
                                                  color: AppTheme.textPrimary,
                                                  height: 1.5)),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    )
        .animate(delay: Duration(milliseconds: 80 * widget.index))
        .fadeIn(duration: 400.ms)
        .slideY(begin: 0.2, end: 0, duration: 400.ms, curve: Curves.easeOut);
  }
}
