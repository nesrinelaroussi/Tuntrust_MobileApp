import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';

import '../api_service.dart';
import '../login_screen.dart';
import '../theme/app_theme.dart';
import 'about_screen.dart';
import 'contact_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _userName = '';
  String _userEmail = '';

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = await ApiService.getUser();
    if (mounted) {
      setState(() {
        _userName  = (user?['name']  ?? '').toString();
        _userEmail = (user?['email'] ?? '').toString();
      });
    }
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Déconnexion'),
        content: const Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Annuler')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFEF4444)),
              child: const Text('Déconnecter')),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await ApiService.logout();
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (_) => false,
      );
    }
  }

  Future<void> _launchWebsite() async {
    final uri = Uri.parse('https://www.tuntrust.tn');
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Impossible d\'ouvrir le navigateur.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surfaceLight,
      appBar: AppBar(
        title: const Text('Profil'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // User avatar card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: AppTheme.heroGradient,
                borderRadius: BorderRadius.circular(20),
                boxShadow: AppTheme.heroBannerShadow,
              ),
              child: Column(
                children: [
                  Container(
                    width: 72, height: 72,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.person_rounded,
                        color: Colors.white, size: 40),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    _userName.isNotEmpty ? _userName : 'Utilisateur',
                    style: Theme.of(context).textTheme.headlineSmall
                        ?.copyWith(color: Colors.white),
                  ),
                  if (_userEmail.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(_userEmail,
                        style: Theme.of(context).textTheme.bodyMedium
                            ?.copyWith(color: Colors.white70)),
                  ],
                ],
              ),
            ).animate().fadeIn(duration: 400.ms),
            const SizedBox(height: 24),

            // Action Links
            _SectionCard(
              icon: Icons.link_rounded,
              iconColor: AppTheme.primaryGreen,
              title: 'Liens Utiles',
              child: Column(
                children: [
                  _LinkItem(
                    icon: Icons.info_outline_rounded,
                    label: 'À Propos de TunTrust',
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => const AboutScreen()));
                    },
                  ),
                  _LinkItem(
                    icon: Icons.contact_support_rounded,
                    label: 'Nous Contacter',
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => const ContactScreen()));
                    },
                  ),
                  _LinkItem(
                    icon: Icons.language_rounded,
                    label: 'Site web officiel',
                    onTap: _launchWebsite,
                  ),
                ],
              ),
            ).animate(delay: 150.ms).fadeIn().slideY(begin: 0.1, end: 0),
            const SizedBox(height: 12),

            // App info
            _SectionCard(
              icon: Icons.smartphone_rounded,
              iconColor: const Color(0xFFF59E0B),
              title: 'Application',
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Version', style: Theme.of(context).textTheme.bodyMedium),
                      Text('1.0.0', style: Theme.of(context).textTheme.bodyMedium
                          ?.copyWith(color: AppTheme.textPrimary, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ],
              ),
            ).animate(delay: 250.ms).fadeIn().slideY(begin: 0.1, end: 0),
            const SizedBox(height: 24),

            // Logout
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _logout,
                icon: const Icon(Icons.logout_rounded),
                label: const Text('Déconnexion'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFEF4444),
                  side: const BorderSide(color: Color(0xFFEF4444)),
                  minimumSize: const Size(double.infinity, 52),
                ),
              ),
            ).animate(delay: 300.ms).fadeIn(),
            const SizedBox(height: 20),

            Text(
              '© TunTrust — Agence Nationale de Certification Électronique',
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ).animate(delay: 350.ms).fadeIn(),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.child,
  });
  final IconData icon;
  final Color iconColor;
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 18),
              ),
              const SizedBox(width: 10),
              Text(title, style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _LegalItem extends StatelessWidget {
  const _LegalItem({
    required this.title,
    required this.description,
    this.last = false,
  });
  final String title;
  final String description;
  final bool last;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.labelMedium
            ?.copyWith(color: AppTheme.primaryGreen)),
        const SizedBox(height: 2),
        Text(description, style: Theme.of(context).textTheme.bodySmall),
        if (!last) ...[
          const SizedBox(height: 10),
          const Divider(height: 1),
          const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class _LinkItem extends StatelessWidget {
  const _LinkItem({required this.icon, required this.label, required this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Icon(icon, color: AppTheme.primaryGreen, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(label,
                  style: Theme.of(context).textTheme.bodyMedium
                      ?.copyWith(color: AppTheme.primaryGreen,
                          decoration: TextDecoration.underline,
                          decorationColor: AppTheme.primaryGreen)),
            ),
            const Icon(Icons.open_in_new_rounded,
                color: AppTheme.primaryGreen, size: 14),
          ],
        ),
      ),
    );
  }
}
