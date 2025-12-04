import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';

/// Settings screen - Configure privacy, notifications, security, etc.
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  // Mock settings state
  bool _emailNotifications = true;
  bool _pushNotifications = true;
  bool _smsNotifications = false;
  bool _marketingEmails = false;
  bool _biometricAuth = false;
  bool _twoFactorAuth = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.deepNavy,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 32),
            // Notifications Section
            _buildSection(
              title: 'Obaveštenja',
              icon: Icons.notifications,
              children: [
                _buildSwitchSetting(
                  title: 'Email obaveštenja',
                  subtitle: 'Primaj obaveštenja putem email-a',
                  value: _emailNotifications,
                  onChanged: (value) {
                    setState(() {
                      _emailNotifications = value;
                    });
                  },
                ),
                _buildSwitchSetting(
                  title: 'Push obaveštenja',
                  subtitle: 'Primaj obaveštenja na telefon',
                  value: _pushNotifications,
                  onChanged: (value) {
                    setState(() {
                      _pushNotifications = value;
                    });
                  },
                ),
                _buildSwitchSetting(
                  title: 'SMS obaveštenja',
                  subtitle: 'Primaj obaveštenja putem SMS-a',
                  value: _smsNotifications,
                  onChanged: (value) {
                    setState(() {
                      _smsNotifications = value;
                    });
                  },
                ),
                _buildSwitchSetting(
                  title: 'Marketinški email-ovi',
                  subtitle: 'Primaj promotivne poruke i ponude',
                  value: _marketingEmails,
                  onChanged: (value) {
                    setState(() {
                      _marketingEmails = value;
                    });
                  },
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Security Section
            _buildSection(
              title: 'Bezbednost',
              icon: Icons.security,
              children: [
                _buildSwitchSetting(
                  title: 'Biometrijska autentifikacija',
                  subtitle: 'Koristi otisak prsta ili Face ID',
                  value: _biometricAuth,
                  onChanged: (value) {
                    setState(() {
                      _biometricAuth = value;
                    });
                  },
                ),
                _buildSwitchSetting(
                  title: 'Dvofaktorska autentifikacija',
                  subtitle: 'Dodatna zaštita vašeg naloga',
                  value: _twoFactorAuth,
                  onChanged: (value) {
                    setState(() {
                      _twoFactorAuth = value;
                    });
                  },
                ),
                _buildActionSetting(
                  title: 'Promeni lozinku',
                  subtitle: 'Ažuriraj svoju lozinku',
                  icon: Icons.lock,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Funkcionalnost za promenu lozinke - uskoro!'),
                        backgroundColor: AppColors.hotPink,
                      ),
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Privacy Section
            _buildSection(
              title: 'Privatnost',
              icon: Icons.privacy_tip,
              children: [
                _buildActionSetting(
                  title: 'Politika privatnosti',
                  subtitle: 'Pročitaj našu politiku privatnosti',
                  icon: Icons.description,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Politika privatnosti - uskoro!'),
                        backgroundColor: AppColors.hotPink,
                      ),
                    );
                  },
                ),
                _buildActionSetting(
                  title: 'Upravljaj podacima',
                  subtitle: 'Pregled i brisanje vaših podataka',
                  icon: Icons.data_usage,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Upravljanje podacima - uskoro!'),
                        backgroundColor: AppColors.hotPink,
                      ),
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 32),

            // App Settings Section
            _buildSection(
              title: 'Podešavanja aplikacije',
              icon: Icons.settings,
              children: [
                _buildActionSetting(
                  title: 'Jezik',
                  subtitle: 'Srpski (Latinica)',
                  icon: Icons.language,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Promena jezika - uskoro!'),
                        backgroundColor: AppColors.hotPink,
                      ),
                    );
                  },
                ),
                _buildActionSetting(
                  title: 'Tema',
                  subtitle: 'Tamna tema',
                  icon: Icons.dark_mode,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Promena teme - uskoro!'),
                        backgroundColor: AppColors.hotPink,
                      ),
                    );
                  },
                ),
                _buildActionSetting(
                  title: 'Keš memorija',
                  subtitle: 'Očisti keš aplikacije',
                  icon: Icons.storage,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Keš je očišćen'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 32),

            // About Section
            _buildSection(
              title: 'O aplikaciji',
              icon: Icons.info,
              children: [
                _buildInfoSetting(
                  title: 'Verzija',
                  value: '1.0.0',
                  icon: Icons.tag,
                ),
                _buildActionSetting(
                  title: 'Uslovi korišćenja',
                  subtitle: 'Pročitaj uslove korišćenja',
                  icon: Icons.description,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Uslovi korišćenja - uskoro!'),
                        backgroundColor: AppColors.hotPink,
                      ),
                    );
                  },
                ),
                _buildActionSetting(
                  title: 'Kontakt',
                  subtitle: 'Kontaktirajte nas',
                  icon: Icons.email,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Kontakt - uskoro!'),
                        backgroundColor: AppColors.hotPink,
                      ),
                    );
                  },
                ),
              ],
            ),
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
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        'Podešavanja',
        style: GoogleFonts.montserrat(
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: Colors.white,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: AppColors.hotPink,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.montserrat(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ...children,
      ],
    );
  }

  Widget _buildSwitchSetting({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 1),
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Row(
          children: [
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
                  if (subtitle.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: GoogleFonts.montserrat(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: Colors.white60,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Switch(
              value: value,
              onChanged: onChanged,
              activeColor: AppColors.hotPink,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionSetting({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 1),
      color: Colors.transparent,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Row(
            children: [
              Icon(
                icon,
                color: Colors.white70,
                size: 20,
              ),
              const SizedBox(width: 16),
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
                    if (subtitle.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: GoogleFonts.montserrat(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: Colors.white60,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: Colors.white60,
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoSetting({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 1),
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.cardNavy,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: Colors.white70,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.montserrat(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
            Text(
              value,
              style: GoogleFonts.montserrat(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


