import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_theme.dart';
import '../widgets/main_shell.dart';

// ══════════════════════════════════════════════════════════════════════════════
// Contact Screen — Interactive support hub
// ══════════════════════════════════════════════════════════════════════════════

class ContactScreen extends StatelessWidget {
  const ContactScreen({super.key});

  Future<void> _launchPhone(BuildContext ctx) async {
    final uri = Uri.parse('tel:+21671703700');
    if (!await launchUrl(uri) && ctx.mounted) {
      ScaffoldMessenger.of(ctx).showSnackBar(
        const SnackBar(content: Text('Impossible d\'ouvrir le téléphone.')),
      );
    }
  }

  Future<void> _launchEmail(BuildContext ctx) async {
    final uri = Uri.parse('mailto:contact@tuntrust.tn?subject=Demande%20d%27information');
    if (!await launchUrl(uri) && ctx.mounted) {
      ScaffoldMessenger.of(ctx).showSnackBar(
        const SnackBar(content: Text('Impossible d\'ouvrir le client email.')),
      );
    }
  }

  Future<void> _launchWebsite(BuildContext ctx) async {
    final uri = Uri.parse('https://www.tuntrust.tn');
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication) && ctx.mounted) {
      ScaffoldMessenger.of(ctx).showSnackBar(
        const SnackBar(content: Text('Impossible d\'ouvrir le navigateur.')),
      );
    }
  }

  Future<void> _launchMap(BuildContext ctx) async {
    final uri = Uri.parse(
        'https://maps.google.com/?q=Agence+Nationale+de+Certification+Electronique+Tunisie');
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication) && ctx.mounted) {
      ScaffoldMessenger.of(ctx).showSnackBar(
        const SnackBar(content: Text('Impossible d\'ouvrir la carte.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surfaceLight,
      body: CustomScrollView(
        slivers: [
          // ── App Bar ───────────────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 160,
            pinned: true,
            backgroundColor: AppTheme.tealAccent,
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF007A87), Color(0xFF005F6B)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -30, top: -30,
                      child: Container(
                        width: 160, height: 160,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.06),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    const Positioned(
                      bottom: 30, left: 20,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.support_agent_rounded,
                              color: Colors.white70, size: 26),
                          SizedBox(height: 8),
                          Text(
                            'Nous Contacter',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 26,
                                fontWeight: FontWeight.w800),
                          ),
                          Text(
                            'Notre équipe est à votre disposition',
                            style: TextStyle(
                                color: Colors.white70, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Content ───────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Contact Cards ────────────────────────────────────────
                  Text('Canaux de contact',
                      style: Theme.of(context).textTheme.headlineSmall)
                      .animate().fadeIn(duration: 350.ms),
                  const SizedBox(height: 4),
                  Text('Choisissez votre mode de communication',
                      style: Theme.of(context).textTheme.bodyMedium)
                      .animate().fadeIn(delay: 50.ms),
                  const SizedBox(height: 16),

                  // Phone
                  _ContactCard(
                    icon: Icons.phone_rounded,
                    color: AppTheme.primaryGreen,
                    title: 'Téléphone',
                    value: '+216 71 703 700',
                    subtitle: 'Lun–Ven, 08h–17h',
                    onTap: () => _launchPhone(context),
                    delay: 100,
                  ),
                  const SizedBox(height: 12),

                  // Email
                  _ContactCard(
                    icon: Icons.email_rounded,
                    color: AppTheme.tealAccent,
                    title: 'Email',
                    value: 'contact@tuntrust.tn',
                    subtitle: 'Réponse sous 24–48h',
                    onTap: () => _launchEmail(context),
                    delay: 160,
                  ),
                  const SizedBox(height: 12),

                  // Website
                  _ContactCard(
                    icon: Icons.language_rounded,
                    color: const Color(0xFF6366F1),
                    title: 'Site officiel',
                    value: 'www.tuntrust.tn',
                    subtitle: 'Informations, services et produits',
                    onTap: () => _launchWebsite(context),
                    delay: 220,
                  ),
                  const SizedBox(height: 12),

                  // Location
                  _ContactCard(
                    icon: Icons.location_on_rounded,
                    color: const Color(0xFFF59E0B),
                    title: 'Adresse',
                    value: 'Rue du Lac de Constance',
                    subtitle: 'Les Berges du Lac, 1053 Tunis',
                    onTap: () => _launchMap(context),
                    delay: 280,
                  ),
                  const SizedBox(height: 28),

                  // ── Info Section ─────────────────────────────────────────
                  Text('Informations institutionnelles',
                      style: Theme.of(context).textTheme.headlineSmall)
                      .animate(delay: 320.ms).fadeIn(),
                  const SizedBox(height: 12),
                  _InfoSection()
                      .animate(delay: 360.ms).fadeIn().slideY(begin: 0.1),
                  const SizedBox(height: 28),

                  // ── Assistant CTA ─────────────────────────────────────────
                  _AssistantCta(context: context)
                      .animate(delay: 420.ms).fadeIn().slideY(begin: 0.1),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Contact Card ──────────────────────────────────────────────────────────────

class _ContactCard extends StatefulWidget {
  const _ContactCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.onTap,
    required this.delay,
  });
  final IconData icon;
  final Color color;
  final String title;
  final String value;
  final String subtitle;
  final VoidCallback onTap;
  final int delay;

  @override
  State<_ContactCard> createState() => _ContactCardState();
}

class _ContactCardState extends State<_ContactCard> {
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
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppTheme.cardWhite,
            borderRadius: BorderRadius.circular(18),
            boxShadow: AppTheme.cardShadow,
            border: Border.all(
              color: _pressed
                  ? widget.color.withOpacity(0.4)
                  : Colors.transparent,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: widget.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(widget.icon, color: widget.color, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.title,
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: widget.color, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 2),
                    Text(widget.value,
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 2),
                    Text(widget.subtitle,
                        style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios_rounded,
                  size: 14, color: widget.color),
            ],
          ),
        ),
      ),
    )
        .animate(delay: Duration(milliseconds: widget.delay))
        .fadeIn(duration: 350.ms)
        .slideX(begin: 0.05, end: 0);
  }
}

// ── Info Section ──────────────────────────────────────────────────────────────

class _InfoSection extends StatelessWidget {
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
          _InfoRow(label: 'Organisme', value: 'Agence Nationale de Certification Électronique'),
          const Divider(height: 20),
          _InfoRow(label: 'Sigle', value: 'TunTrust / ANCE'),
          const Divider(height: 20),
          _InfoRow(label: 'Tutelle', value: 'Ministère des Technologies de la Communication'),
          const Divider(height: 20),
          _InfoRow(label: 'Création', value: 'Décret n°2000-2354 du 24 octobre 2000'),
          const Divider(height: 20),
          _InfoRow(label: 'Horaires', value: 'Lundi au Vendredi, 08h00 – 17h00', last: true),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value, this.last = false});
  final String label;
  final String value;
  final bool last;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 90,
          child: Text(label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textSecondary,
                  )),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(value,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: AppTheme.textPrimary, height: 1.4)),
        ),
      ],
    );
  }
}

// ── Assistant CTA ─────────────────────────────────────────────────────────────

class _AssistantCta extends StatelessWidget {
  const _AssistantCta({required this.context});
  final BuildContext context;

  @override
  Widget build(BuildContext outerCtx) {
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
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.smart_toy_rounded,
                color: AppTheme.primaryGreen, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Besoin d\'aide ?',
                    style: Theme.of(outerCtx)
                        .textTheme
                        .titleMedium
                        ?.copyWith(color: Colors.white)),
                const SizedBox(height: 4),
                Text(
                  'Notre Assistant IA répond à vos questions 24h/7j.',
                  style: Theme.of(outerCtx)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: Colors.white60),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.primaryGreen,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              // Navigate to assistant tab (index 3)
              MainShell.of(context)?.navigateTo(3);
            },
            child: const Text('Ouvrir', style: TextStyle(fontSize: 13)),
          ),
        ],
      ),
    );
  }
}
