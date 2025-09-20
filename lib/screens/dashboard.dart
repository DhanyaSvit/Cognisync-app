import 'package:flutter/material.dart';
import 'profile_page_modal.dart';
import 'package:video_player/video_player.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'dart:ui';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  bool _showProfileModal = false;
  bool _showProfileEditModal = false;
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset('assets/video/brain-loop3.mp4')
      ..setLooping(true)
      ..setVolume(0.0)
      ..initialize().then((_) {
        setState(() {
          _controller.play();
        });
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: (!_showProfileModal && !_showProfileEditModal)
          ? AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              centerTitle: true,
              title: const Text(
                'Cognisync',
                style: TextStyle(
                  fontFamily: 'Zentry',
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              leading: Builder(
                builder: (context) => IconButton(
                  icon: const Icon(Icons.menu, color: Colors.white),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.account_circle, color: Colors.white),
                  onPressed: () {
                    setState(() {
                      _showProfileModal = true;
                    });
                  },
                ),
              ],
            )
          : null,
      extendBodyBehindAppBar: true,
      drawer: (!_showProfileModal && !_showProfileEditModal)
          ? Drawer(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  const DrawerHeader(
                    decoration: BoxDecoration(color: Colors.green),
                    child: Text(
                      'Menu',
                      style: TextStyle(color: Colors.white, fontSize: 24),
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.home),
                    title: const Text(
                      'Home',
                      style: TextStyle(fontFamily: 'Zentry'),
                    ),
                    onTap: () {
                      Navigator.of(context).pushNamed('/dashboard');
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.info),
                    title: const Text(
                      'About',
                      style: TextStyle(fontFamily: 'Zentry'),
                    ),
                    onTap: () {
                      Navigator.of(context).pushNamed('/about');
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.flag),
                    title: const Text(
                      'Goals',
                      style: TextStyle(fontFamily: 'Zentry'),
                    ),
                    onTap: () {
                      Navigator.of(context).pushNamed('/goals');
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.videogame_asset),
                    title: const Text(
                      'Games',
                      style: TextStyle(fontFamily: 'Zentry'),
                    ),
                    onTap: () {
                      Navigator.of(context).pushNamed('/games');
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.exit_to_app),
                    title: const Text(
                      'Sign Out',
                      style: TextStyle(fontFamily: 'Zentry'),
                    ),
                    onTap: () async {
                      await firebase_auth.FirebaseAuth.instance.signOut();
                      Navigator.of(context).pushReplacementNamed('/login');
                    },
                  ),
                ],
              ),
            )
          : null,
      body: Stack(
        children: [
          Positioned.fill(
            child: _controller.value.isInitialized
                ? Transform.scale(
                    scale: 0.49, // Zoom out by 51%
                    child: FittedBox(
                      fit: BoxFit.cover,
                      child: SizedBox(
                        width: _controller.value.size.width,
                        height: _controller.value.size.height,
                        child: VideoPlayer(_controller),
                      ),
                    ),
                  )
                : Container(color: Colors.black),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 80),
                const SizedBox(height: 24),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'REWIRING\n',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextSpan(
                        text: 'REALITY.',
                        style: TextStyle(
                          color: Color.fromRGBO(50, 242, 57, 1),
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'BE THE FUTURE.',
                  style: TextStyle(
                    color: Color.fromRGBO(50, 242, 57, 1),
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1.2,
                  ),
                ),
                const Spacer(),
                Row(
                  children: [
                    GlassButton(
                      text: 'Start Session',
                      onTap: () {
                        Navigator.of(context).pushNamed('/eeg');
                      },
                      key: const Key('startSessionButton'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                  'LATEST BRAIN HEALTH REPORT',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.1,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'No previous sessions found.',
                  style: TextStyle(color: Colors.white54, fontSize: 16),
                ),
              ],
            ),
          ),
          if (_showProfileModal)
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => setState(() => _showProfileModal = false),
              child: Center(
                child: GestureDetector(
                  onTap: () {},
                  child: FutureBuilder<firebase_auth.User?>(
                    future: Future.value(
                      firebase_auth.FirebaseAuth.instance.currentUser,
                    ),
                    builder: (context, snapshot) {
                      final user = snapshot.data;
                      final displayName = user?.displayName ?? 'User';
                      final email = user?.email ?? '';
                      return _ProfilePopup(
                        onClose: () =>
                            setState(() => _showProfileModal = false),
                        username: displayName,
                        email: email,
                        onEdit: () {
                          setState(() {
                            _showProfileModal = false;
                            _showProfileEditModal = true;
                          });
                        },
                      );
                    },
                  ),
                ),
              ),
            ),
          if (_showProfileEditModal)
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => setState(() => _showProfileEditModal = false),
              child: Center(
                child: GestureDetector(
                  onTap: () {},
                  child: ProfilePageModal(
                    onClose: () =>
                        setState(() => _showProfileEditModal = false),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class GlassButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  const GlassButton({required this.text, required this.onTap, super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 26,
          vertical: 11,
        ), // reduced by another 20%
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          gradient: const LinearGradient(
            colors: [
              Color.fromRGBO(76, 175, 80, 1), // light green
              Color.fromRGBO(255, 235, 59, 1), // yellow
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Color.fromRGBO(76, 175, 80, 0.15),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontFamily: 'GoodTimingBd',
            color: Colors.white,
            fontSize: 11, // reduced by another 20%
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
            shadows: [
              Shadow(
                color: Colors.black54,
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Profile Popup Modal Widget
class _ProfilePopup extends StatelessWidget {
  final VoidCallback onClose;
  final String username;
  final String email;
  final VoidCallback? onEdit;
  const _ProfilePopup({
    required this.onClose,
    required this.username,
    required this.email,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double popupWidth = (screenWidth * 0.85).clamp(
      0,
      340,
    ); // Increase width, max 340
    return GestureDetector(
      onTap: onClose,
      child: Stack(
        children: [
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(color: Colors.black.withOpacity(0.3)),
            ),
          ),
          Center(
            child: GestureDetector(
              onTap: () {}, // Prevent tap from closing modal
              child: SizedBox(
                width: popupWidth,
                height: 320,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF2323A7), // dark blue
                        Color(0xFFE040FB), // pink
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(2.0), // Thinner border
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: 24,
                        horizontal: 16,
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Stack(
                              alignment: Alignment.topRight,
                              children: [
                                CircleAvatar(
                                  radius: 38,
                                  backgroundColor: Colors.transparent,
                                  child: const Icon(
                                    Icons.account_circle,
                                    size: 60,
                                    color: Colors.white70,
                                  ),
                                ),
                                Positioned(
                                  right: 0,
                                  bottom: 0,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.green,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    padding: const EdgeInsets.all(4),
                                    child: const Icon(
                                      Icons.edit,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 18),
                            Text(
                              username,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.1,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.8),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.email,
                                    color: Colors.white70,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Flexible(
                                    child: Text(
                                      email,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 22),
                            SizedBox(
                              width: 120,
                              height: 42,
                              child: ElevatedButton(
                                onPressed: onEdit,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: const Text(
                                  'Edit',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
