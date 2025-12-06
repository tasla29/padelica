import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import 'edit_profile_screen.dart';
import 'activity_screen.dart';
import 'payments_screen.dart';
import 'settings_screen.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../auth/presentation/auth_gate.dart';
import 'privacy_policy_screen.dart';
import 'terms_of_service_screen.dart';

/// Profile screen - User profile and account management
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);

    String displayName = 'Gost';
    String displayRole = 'Igrač';
    String displayInitials = 'G';

    authState.whenData((user) {
      if (user != null) {
        displayName = user.fullName.trim().isEmpty ? user.email : user.fullName;
        displayRole = _mapRole(user.role);
        displayInitials = _initials(user.firstName, user.lastName);
      }
    });

    return Scaffold(
      backgroundColor: AppColors.deepNavy,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Header Section
            _buildProfileHeader(
              displayName: displayName,
              displayRole: displayRole,
              displayInitials: displayInitials,
            ),

            const SizedBox(height: 32),

            // Your Account Section
            _buildAccountSection(),

            const SizedBox(height: 32),

            // Support Section
            _buildSupportSection(),

            const SizedBox(height: 32),

            // Legal Information Section
            _buildLegalSection(),

            const SizedBox(height: 32),

            // Logout Section
            _buildLogoutSection(),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.hotPink,
      elevation: 0,
      centerTitle: false,
      title: Text(
        'Profil',
        style: GoogleFonts.montserrat(
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: Colors.white,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildProfileHeader({
    required String displayName,
    required String displayRole,
    required String displayInitials,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left side: Name and account type
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  style: GoogleFonts.montserrat(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  displayRole,
                  style: GoogleFonts.montserrat(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          // Right side: Profile picture
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.cardNavy,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                displayInitials,
                style: GoogleFonts.montserrat(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _initials(String first, String last) {
    final f = first.trim();
    final l = last.trim();
    if (f.isEmpty && l.isEmpty) return '?';
    if (f.isNotEmpty && l.isNotEmpty) {
      return '${f[0]}${l[0]}'.toUpperCase();
    }
    final combined = f.isNotEmpty ? f : l;
    return combined.substring(0, 1).toUpperCase();
  }

  String _mapRole(String role) {
    switch (role) {
      case 'admin':
        return 'Admin';
      case 'staff':
        return 'Osoblje';
      default:
        return 'Igrač';
    }
  }

  Widget _buildAccountSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            'Vaš nalog',
            style: GoogleFonts.montserrat(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
        ),
        const SizedBox(height: 16),
        _buildProfileListItem(
          icon: Icons.person,
          title: 'Izmeni profil',
          description: 'Ime, email, telefon, lozinka...',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const EditProfileScreen(),
              ),
            );
          },
        ),
        _buildProfileListItem(
          icon: Icons.history,
          title: 'Aktivnost',
          description: 'Mečevi, časovi, takmičenja, grupe...',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ActivityScreen(),
              ),
            );
          },
        ),
        _buildProfileListItem(
          icon: Icons.wallet,
          title: 'Metode plaćanja',
          description: 'Sačuvana kartica, transakcije...',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const PaymentsScreen(),
              ),
            );
          },
        ),
        _buildProfileListItem(
          icon: Icons.settings,
          title: 'Podešavanja',
          description: 'Konfiguriši privatnost, obaveštenja...',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SettingsScreen(),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSupportSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            'Podrška',
            style: GoogleFonts.montserrat(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
        ),
        const SizedBox(height: 16),
        _buildProfileListItem(
          icon: Icons.help_center,
          title: 'Pomoć',
          description: '',
          onTap: () {
            // TODO: Navigate to help
          },
        ),
        _buildProfileListItem(
          icon: Icons.article,
          title: 'Kako Rez Padel radi',
          description: '',
          onTap: () {
            // TODO: Navigate to how it works
          },
        ),
      ],
    );
  }

  Widget _buildLegalSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            'Pravne informacije',
            style: GoogleFonts.montserrat(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
        ),
        const SizedBox(height: 16),
        _buildProfileListItem(
          icon: Icons.description,
          title: 'Uslovi korišćenja',
          description: '',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const TermsOfServiceScreen(),
              ),
            );
          },
        ),
        _buildProfileListItem(
          icon: Icons.privacy_tip,
          title: 'Politika privatnosti',
          description: '',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const PrivacyPolicyScreen(),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildLogoutSection() {
    return _buildProfileListItem(
      icon: Icons.logout,
      title: 'Odjavi se',
      description: '',
      onTap: () async {
        final shouldLogout = await _confirmLogout();
        if (shouldLogout != true) return;
        try {
          await ref.read(authControllerProvider.notifier).signOut();
          if (!mounted) return;
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const AuthGate()),
            (route) => false,
          );
        } catch (_) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Odjava neuspešna. Pokušaj ponovo.'),
              backgroundColor: AppColors.hotPink,
            ),
          );
        }
      },
      // force red styling
      iconColor: Colors.red,
      titleColor: Colors.red,
    );
  }

  Future<bool?> _confirmLogout() {
    return showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: AppColors.cardNavy,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Odjava',
                  style: GoogleFonts.montserrat(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Da li ste sigurni da želite da se odjavite?',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.montserrat(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.red.shade300, width: 1.4),
                          foregroundColor: Colors.red.shade300,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () => Navigator.of(dialogContext).pop(true),
                        child: Text(
                          'Odjavi se',
                          style: GoogleFonts.montserrat(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.cardNavyLight,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        onPressed: () => Navigator.of(dialogContext).pop(false),
                        child: Text(
                          'Otkaži',
                          style: GoogleFonts.montserrat(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileListItem({
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
    Color iconColor = Colors.white70,
    Color titleColor = Colors.white,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Row(
          children: [
            // Icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.cardNavyLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            // Title and description
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.montserrat(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: titleColor,
                    ),
                  ),
                  if (description.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      description,
                      style: GoogleFonts.montserrat(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: Colors.white60,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            // Arrow icon
            Icon(
              Icons.chevron_right,
              color: Colors.white60,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}

