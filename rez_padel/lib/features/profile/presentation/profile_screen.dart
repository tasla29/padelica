import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';

/// Profile screen - User profile and account management
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  // Mock user data
  final String userName = 'Marko Latas';
  final String accountType = 'Igrač';
  final String userInitials = 'ML';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.hotPink,
      appBar: _buildAppBar(),
      body: Container(
        color: AppColors.hotPink, // Pink background for the curve effect
        child: Container(
          decoration: const BoxDecoration(
            color: AppColors.deepNavy,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Header Section
                _buildProfileHeader(),

                const SizedBox(height: 32),

                // Your Account Section
                _buildAccountSection(),

                const SizedBox(height: 32),

                // Support Section
                _buildSupportSection(),

                const SizedBox(height: 32),

                // Legal Information Section
                _buildLegalSection(),
              ],
            ),
          ),
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
      actions: [
        IconButton(
          onPressed: () {
            // TODO: Navigate to menu/settings
          },
          icon: const Icon(Icons.menu, color: Colors.white, size: 28),
        ),
      ],
    );
  }

  Widget _buildProfileHeader() {
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
                  userName,
                  style: GoogleFonts.montserrat(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  accountType,
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
                userInitials,
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
          description: 'Ime, email, telefon, lokacija, pol,...',
          onTap: () {
            // TODO: Navigate to edit profile
          },
        ),
        _buildProfileListItem(
          icon: Icons.history,
          title: 'Vaša aktivnost',
          description: 'Mečevi, časovi, takmičenja, grupe...',
          onTap: () {
            // TODO: Navigate to activity
          },
        ),
        _buildProfileListItem(
          icon: Icons.wallet,
          title: 'Vaša plaćanja',
          description: 'Načini plaćanja, transakcije, klub...',
          onTap: () {
            // TODO: Navigate to payments
          },
        ),
        _buildProfileListItem(
          icon: Icons.settings,
          title: 'Podešavanja',
          description: 'Konfiguriši privatnost, obaveštenja, bezbednost...',
          onTap: () {
            // TODO: Navigate to settings
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
        // Placeholder for legal items - can be added later
      ],
    );
  }

  Widget _buildProfileListItem({
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
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
                color: Colors.white70,
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
                      color: Colors.white,
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

