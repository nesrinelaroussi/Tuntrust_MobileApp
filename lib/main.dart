import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'api_service.dart';
import 'login_screen.dart';
import 'providers/products_provider.dart';
import 'theme/app_theme.dart';
import 'widgets/main_shell.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProductsProvider()),
      ],
      child: MaterialApp(
        title: 'TunTrust',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: const SplashScreen(),
      ),
    );
  }
}

// ==========================================
// 1. SPLASH SCREEN WIDGET
// ==========================================
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  // Staggered Animations
  late Animation<double> _fadeInAnimation;
  late Animation<double> _logoMoveAnimation;
  late Animation<double> _fadeOutAnimation;
  late Animation<double> _paintSlideAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 5000), // 5.0 seconds total duration
    );

    // Phase 1 — Logo + Name fade in: 0.0s → 0.9s (0% → 18%)
    // Smooth entrance with slight scale.
    _fadeInAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.18, curve: Curves.easeOut),
      ),
    );

    // Phase 2 — HOLD (18% → 38%): 0.9s → 1.9s
    // Both logo & name are fully visible — no animation during this interval.
    // Nothing to animate here; the controller simply advances.

    // Phase 3 — Logo moves right + name erases: 1.9s → 3.1s (38% → 62%)
    // Slow, cinematic movement so the user can follow it.
    _logoMoveAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.38, 0.62, curve: Curves.easeInOutCubic),
      ),
    );

    // Phase 4 — Fade out logo + name: 3.1s → 3.5s (62% → 70%)
    _fadeOutAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.62, 0.70, curve: Curves.easeOut),
      ),
    );

    // Phase 5 — Green wave slides down: 3.5s → 5.0s (70% → 100%)
    // 1.5 seconds — slow enough to be clearly visible and cinematic.
    _paintSlideAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.70, 1.0, curve: Curves.easeInOutQuad),
      ),
    );

    // Start the animation
    _controller.forward();

    // Transition to LoginScreen or the new Home Screen depending on session
    _controller.addStatusListener((status) async {
      if (status == AnimationStatus.completed) {
        final isLoggedIn = await ApiService.isLoggedIn();
        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                isLoggedIn
                    ? const MainShell()
                    : const LoginScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 700),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    // Scaled dimensions: original logo is 126x100, name is 371x66
    const double logoHeight = 50.0;
    const double logoWidth = logoHeight * 1.26; // 63.0
    const double nameHeight = 33.0;
    const double nameWidth = nameHeight * 5.62; // 185.5
    const double spacing = 15.0;
    const double totalContentWidth = logoWidth + spacing + nameWidth; // 263.5

    return Scaffold(
      backgroundColor: Colors.white,
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final double paintHeight = screenWidth * (320 / 541);
          final double paintY = -paintHeight + _paintSlideAnimation.value * (screenHeight + paintHeight);

          return Stack(
            clipBehavior: Clip.none,
            children: [
              // Permanent background to prevent Stack collapse and provide white canvas
              const SizedBox.expand(
                child: ColoredBox(
                  color: Colors.white,
                ),
              ),
              // --- Phase 1, 2 & 3: Logo and Name ---
              if (_controller.value < 0.70)
                Center(
                  child: Opacity(
                    opacity: _controller.value < 0.62
                        ? _fadeInAnimation.value
                        : _fadeOutAnimation.value,
                    child: SizedBox(
                      width: totalContentWidth,
                      height: logoHeight,
                      child: Stack(
                        alignment: Alignment.centerLeft,
                        clipBehavior: Clip.none,
                        children: [
                          // Erasing Name Widget (Clipped)
                          Positioned(
                            left: logoWidth + spacing,
                            top: (logoHeight - nameHeight) / 2,
                            child: ClipRect(
                              clipper: EraseClipper(
                                logoX: _logoMoveAnimation.value * totalContentWidth,
                                logoWidth: logoWidth,
                                nameStartX: logoWidth + spacing,
                                nameWidth: nameWidth,
                              ),
                              child: Image.asset(
                                'assets/tuntrust.png',
                                width: nameWidth,
                                height: nameHeight,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                          // Moving Logo Widget
                          Positioned(
                            left: _logoMoveAnimation.value * totalContentWidth,
                            top: 0,
                            child: Image.asset(
                              'assets/logotuntrust.png',
                              width: logoWidth,
                              height: logoHeight,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              // --- Phase 5: Paint Slide Down ---
              if (_controller.value >= 0.70) ...[
                // Solid green background above the sliding paint image
                if (paintY > 0)
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: paintY + 1.5, // 1.5px overlap eliminates rendering gaps
                    child: Container(
                      color: const Color(0xFF05B257),
                    ),
                  ),
                // Sliding Paint Image
                Positioned(
                  top: paintY,
                  left: 0,
                  right: 0,
                  height: paintHeight,
                  child: Image.asset(
                    'assets/paint.png',
                    width: screenWidth,
                    height: paintHeight,
                    fit: BoxFit.fill,
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

// Custom clipper for the erasing text effect
class EraseClipper extends CustomClipper<Rect> {
  final double logoX;
  final double logoWidth;
  final double nameStartX;
  final double nameWidth;

  EraseClipper({
    required this.logoX,
    required this.logoWidth,
    required this.nameStartX,
    required this.nameWidth,
  });

  @override
  Rect getClip(Size size) {
    // We use the center/slightly left of center of the logo as the erase boundary.
    // This allows the logo to start overlapping letters before they disappear.
    final double erasePoint = logoX + (logoWidth * 0.4);
    final double clipLeft = (erasePoint - nameStartX).clamp(0.0, nameWidth);
    return Rect.fromLTRB(clipLeft, 0, size.width, size.height);
  }

  @override
  bool shouldReclip(covariant EraseClipper oldClipper) {
    return oldClipper.logoX != logoX ||
        oldClipper.logoWidth != logoWidth ||
        oldClipper.nameStartX != nameStartX ||
        oldClipper.nameWidth != nameWidth;
  }
}

// ==========================================
// 2. PREMIUM BRANDED HOMEPAGE WIDGET
// ==========================================
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F5),
      body: SafeArea(
        child: Column(
          children: [
            // Custom Premium Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(24.0),
                  bottomRight: Radius.circular(24.0),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x08000000),
                    blurRadius: 16.0,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: const Color(0xFF05B257).withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Image.asset(
                          'assets/logotuntrust.png',
                          width: 32.0,
                          height: 32.0,
                        ),
                      ),
                      const SizedBox(width: 12.0),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'TunTrust Mobile ID',
                            style: TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800],
                            ),
                          ),
                          const Text(
                            'Identité Numérique Nationale',
                            style: TextStyle(
                              fontSize: 12.0,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.notifications_none_outlined, color: Colors.black87),
                      onPressed: () {},
                    ),
                  ),
                ],
              ),
            ),

            // Main Content Area
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Welcome user
                    const Text(
                      'Bonjour, Mohamed',
                      style: TextStyle(
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      'Votre identité numérique est active et sécurisée.',
                      style: TextStyle(
                        fontSize: 14.0,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 24.0),

                    // Premium TunTrust Mobile ID Card
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF05B257), Color(0xFF007A87)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(24.0),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF05B257).withOpacity(0.3),
                            blurRadius: 20.0,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          // Background design circles
                          Positioned(
                            right: -50,
                            top: -50,
                            child: Container(
                              width: 200,
                              height: 200,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.08),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                          Positioned(
                            left: -30,
                            bottom: -30,
                            child: Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.05),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(30.0),
                                      ),
                                      child: const Row(
                                        children: [
                                          Icon(Icons.verified, color: Colors.white, size: 14.0),
                                          SizedBox(width: 4.0),
                                          Text(
                                            'VÉRIFIÉ & ACTIF',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 10.0,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 1.0,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Icon(
                                      Icons.nfc_outlined,
                                      color: Colors.white,
                                      size: 28.0,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 30.0),
                                const Text(
                                  'M. Mohamed Ben Ali',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 22.0,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(height: 4.0),
                                Text(
                                  'ID National: 09876543',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.85),
                                    fontSize: 14.0,
                                    fontFamily: 'Courier',
                                  ),
                                ),
                                const SizedBox(height: 24.0),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'EXPIRE LE',
                                          style: TextStyle(
                                            color: Colors.white.withOpacity(0.6),
                                            fontSize: 10.0,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const Text(
                                          '31/12/2028',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 14.0,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(12.0),
                                      ),
                                      padding: const EdgeInsets.all(8.0),
                                      child: const Icon(
                                        Icons.qr_code_2,
                                        color: Color(0xFF007A87),
                                        size: 32.0,
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28.0),

                    // Quick Actions Section Title
                    const Text(
                      'Actions Rapides',
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16.0),

                    // Actions Grid (2x2)
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 16.0,
                      mainAxisSpacing: 16.0,
                      childAspectRatio: 1.35,
                      children: [
                        _buildActionCard(
                          icon: Icons.draw_rounded,
                          title: 'Signer Document',
                          subtitle: 'Signature e-ID',
                          color: const Color(0xFF05B257),
                        ),
                        _buildActionCard(
                          icon: Icons.qr_code_scanner_rounded,
                          title: 'Scanner QR',
                          subtitle: 'Vérification',
                          color: const Color(0xFF007A87),
                        ),
                        _buildActionCard(
                          icon: Icons.badge_outlined,
                          title: 'Certificats',
                          subtitle: 'Gérer vos clés',
                          color: const Color(0xFFE8963E),
                        ),
                        _buildActionCard(
                          icon: Icons.history_rounded,
                          title: 'Historique',
                          subtitle: 'Vos signatures',
                          color: const Color(0xFF4A4A4A),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(24.0),
            topLeft: Radius.circular(24.0),
          ),
          boxShadow: [
            BoxShadow(color: Colors.black12, spreadRadius: 0, blurRadius: 10),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24.0),
            topRight: Radius.circular(24.0),
          ),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            selectedItemColor: const Color(0xFF05B257),
            unselectedItemColor: Colors.grey[400],
            showSelectedLabels: true,
            showUnselectedLabels: true,
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home_rounded),
                label: 'Accueil',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.verified_user_outlined),
                activeIcon: Icon(Icons.verified_user_rounded),
                label: 'Certificats',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.receipt_long_outlined),
                activeIcon: Icon(Icons.receipt_long_rounded),
                label: 'Historique',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.settings_outlined),
                activeIcon: Icon(Icons.settings_rounded),
                label: 'Paramètres',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.0),
        boxShadow: const [
          BoxShadow(
            color: Color(0x05000000),
            blurRadius: 12.0,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(20.0),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 24.0,
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14.0,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 11.0,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
