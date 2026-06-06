import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vmeet/core/theme/theme.dart';
import 'package:vmeet/core/widgets/avatar_widget.dart';
import 'package:vmeet/core/widgets/glass_container.dart';
import 'package:vmeet/core/widgets/glowing_button.dart';
import 'package:vmeet/data/services/permission_service.dart';
import 'package:vmeet/domain/providers/providers.dart';
import 'package:vmeet/presentation/home/home_screen.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final TextEditingController _nameController = TextEditingController();
  int _selectedAvatarIndex = 0;
  bool _cameraPermissionGranted = false;
  bool _micPermissionGranted = false;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    final granted = await PermissionService.hasCameraAndMicPermissions();
    if (mounted) {
      setState(() {
        _cameraPermissionGranted = granted;
        _micPermissionGranted = granted;
      });
    }
  }

  Future<void> _requestPermissions() async {
    final granted = await PermissionService.requestCameraAndMicPermissions();
    setState(() {
      _cameraPermissionGranted = granted;
      _micPermissionGranted = granted;
    });

    if (!granted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              "Camera and Microphone are required for video calls. Please enable them in settings.",
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: VMeetTheme.destructive.withAlpha(220),
            action: SnackBarAction(
              label: "SETTINGS",
              textColor: Colors.white,
              onPressed: () {
                PermissionService.openAppSettingsPage();
              },
            ),
          ),
        );
      }
    }
  }

  Widget _buildAvatar(int index, double size, {bool isSelected = false}) {
    return VMeetAvatar(
      avatarIndex: index,
      name: _nameController.text,
      size: size,
      isSelected: isSelected,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A090F), // Soft twilight dark base
      body: Stack(
        children: [
          // 1. Ambient Background Glowing Blobs (Create a luxurious glassmorphism canvas)
          // Top-Left Lavender Glow
          Positioned(
            top: -150,
            left: -150,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.transparent,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF818CF8).withAlpha(35),
                    blurRadius: 120,
                    spreadRadius: 80,
                  ),
                ],
              ),
            ),
          ),

          // Bottom-Right Dusty Rose Glow
          Positioned(
            bottom: -150,
            right: -150,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.transparent,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFCA5A5).withAlpha(25),
                    blurRadius: 120,
                    spreadRadius: 80,
                  ),
                ],
              ),
            ),
          ),

          // 2. Main Onboarding Content
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 30,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 450,
                  ), // Standard premium card width limit
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 10),

                      // Custom Vector Brand Header Logo (Replaces low quality asset image)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              gradient: VMeetTheme.primaryGradient,
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: VMeetTheme.glowShadow(
                                const Color(0xFF818CF8),
                                radius: 8,
                              ),
                            ),
                            child: const Icon(
                              Icons.videocam_rounded,
                              color: Colors.white,
                              size: 32,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ShaderMask(
                                shaderCallback: (bounds) => VMeetTheme
                                    .primaryGradient
                                    .createShader(bounds),
                                child: Text(
                                  "vMeet",
                                  style: GoogleFonts.outfit(
                                    fontSize: 34,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                    letterSpacing: -0.8,
                                  ),
                                ),
                              ),
                              Text(
                                "CONFERENCE PLATFORM",
                                style: GoogleFonts.outfit(
                                  fontSize: 8.5,
                                  fontWeight: FontWeight.bold,
                                  color: VMeetTheme.textSecondary,
                                  letterSpacing: 2.5,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 14),

                      Text(
                        "Ultra-smooth video conferences. Fully free.",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.outfit(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: VMeetTheme.textSecondary,
                        ),
                      ),

                      const SizedBox(height: 35),

                      // Glassmorphic Profile Form Container
                      GlassContainer(
                        opacity:
                            0.12, // Increased opacity for richer glassmorphism
                        padding: const EdgeInsets.all(28),
                        borderRadius: 30,
                        borderSide: BorderSide(
                          color: Colors.white.withAlpha(20),
                          width: 1.5,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              "Set Up Your Profile",
                              style: GoogleFonts.outfit(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 25),

                            // Preview Avatar
                            Center(
                              child: _buildAvatar(
                                _selectedAvatarIndex,
                                100,
                                isSelected: true,
                              ),
                            ),

                            const SizedBox(height: 30),

                            // Nickname input field
                            TextField(
                              controller: _nameController,
                              onChanged: (text) => setState(() {}),
                              textCapitalization: TextCapitalization.words,
                              maxLength: 18,
                              style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                              decoration: const InputDecoration(
                                labelText: "Meeting Nickname",
                                hintText: "Enter your name...",
                                prefixIcon: Icon(
                                  Icons.person_outline_rounded,
                                  color: VMeetTheme.primary,
                                ),
                                counterText: "",
                              ),
                            ),

                            const SizedBox(height: 25),

                            // Custom grid of avatar colors
                            Text(
                              "Select Avatar Theme",
                              style: GoogleFonts.outfit(
                                fontWeight: FontWeight.bold,
                                color: Colors.white.withAlpha(204),
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: List.generate(
                                VMeetAvatar.avatarGradients.length,
                                (index) => GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedAvatarIndex = index;
                                    });
                                  },
                                  child: _buildAvatar(
                                    index,
                                    44,
                                    isSelected: _selectedAvatarIndex == index,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Permissions Panel
                      GlassContainer(
                        opacity: 0.08,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                        borderRadius: 20,
                        borderSide: BorderSide(
                          color: Colors.white.withAlpha(15),
                          width: 1.2,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color:
                                        (_cameraPermissionGranted &&
                                                    _micPermissionGranted
                                                ? VMeetTheme.accent
                                                : VMeetTheme.textSecondary)
                                            .withAlpha(25),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    _cameraPermissionGranted &&
                                            _micPermissionGranted
                                        ? Icons.verified_user_rounded
                                        : Icons.security_rounded,
                                    color:
                                        _cameraPermissionGranted &&
                                            _micPermissionGranted
                                        ? VMeetTheme.accent
                                        : VMeetTheme.textSecondary,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Camera & Mic Access",
                                      style: GoogleFonts.outfit(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        color: Colors.white,
                                      ),
                                    ),
                                    Text(
                                      _cameraPermissionGranted &&
                                              _micPermissionGranted
                                          ? "Permissions granted!"
                                          : "Access required for calling",
                                      style: GoogleFonts.outfit(
                                        fontSize: 11,
                                        color:
                                            _cameraPermissionGranted &&
                                                _micPermissionGranted
                                            ? VMeetTheme.accent
                                            : VMeetTheme.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            if (!(_cameraPermissionGranted &&
                                _micPermissionGranted))
                              TextButton(
                                onPressed: _requestPermissions,
                                style: TextButton.styleFrom(
                                  foregroundColor: VMeetTheme.primary,
                                ),
                                child: Text(
                                  "GRANT",
                                  style: GoogleFonts.outfit(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              )
                            else
                              const Icon(
                                Icons.check_circle_rounded,
                                color: VMeetTheme.accent,
                                size: 22,
                              ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 35),

                      // Glowing Let's Go Button
                      GlowingButton(
                        onTap: () async {
                          final name = _nameController.text.trim();
                          if (name.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text(
                                  "Please enter a nickname first.",
                                ),
                                backgroundColor: VMeetTheme.destructive
                                    .withAlpha(200),
                              ),
                            );
                            return;
                          }

                          final navigator = Navigator.of(context);

                          // Save user profile state
                          await ref
                              .read(profileStateProvider.notifier)
                              .saveProfile(name, _selectedAvatarIndex);

                          navigator.pushReplacement(
                            MaterialPageRoute(
                              builder: (context) => const HomeScreen(),
                            ),
                          );
                        },
                        text: "Enter Dashboard",
                        icon: Icons.keyboard_double_arrow_right_rounded,
                      ),
                      const SizedBox(height: 10),
                    ],
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
