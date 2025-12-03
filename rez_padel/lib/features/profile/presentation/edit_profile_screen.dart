import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/split_phone_input_widget.dart';

/// Edit Profile screen - User profile editing form
class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isEditing = false;
  
  // Form controllers
  final TextEditingController _nameController = TextEditingController(text: 'Marko Latas');
  final TextEditingController _emailController = TextEditingController(text: 'marko.latas@example.com');
  final TextEditingController _passwordController = TextEditingController();
  
  // Phone input state
  String _fullPhoneNumber = '+381641234567';
  String _countryCode = '+381';
  String _phoneNumber = '641234567';
  
  // Password visibility
  bool _isPasswordVisible = false;
  
  // Original values for cancel functionality
  String _originalName = 'Marko Latas';
  String _originalEmail = 'marko.latas@example.com';
  String _originalPhone = '+381641234567';
  
  String _userInitials = 'ML';

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String _getCountryCodeFromDialCode(String dialCode) {
    // Map dial codes to country codes
    final dialCodeToCountryCode = {
      '+381': 'RS',
      '+39': 'IT',
      '+1': 'US',
      '+44': 'GB',
      '+49': 'DE',
      '+33': 'FR',
      '+34': 'ES',
      '+385': 'HR',
      '+387': 'BA',
      '+382': 'ME',
      '+389': 'MK',
      '+386': 'SI',
      '+43': 'AT',
      '+41': 'CH',
      '+31': 'NL',
      '+32': 'BE',
      '+351': 'PT',
      '+30': 'GR',
      '+90': 'TR',
      '+7': 'RU',
    };
    return dialCodeToCountryCode[dialCode] ?? 'RS';
  }

  void _parsePhoneNumber(String phoneNumber) {
    // Parse phone number to extract country code and number
    // Format: +381641234567 -> country: +381, number: 641234567
    if (phoneNumber.startsWith('+')) {
      // Try to match known country codes
      final dialCodes = ['+381', '+39', '+1', '+44', '+49', '+33', '+34', '+385', '+387', '+382', '+389', '+386', '+43', '+41', '+31', '+32', '+351', '+30', '+90', '+7'];
      for (final dialCode in dialCodes) {
        if (phoneNumber.startsWith(dialCode)) {
          _countryCode = dialCode;
          _phoneNumber = phoneNumber.substring(dialCode.length);
          return;
        }
      }
      // Default to Serbia if no match
      _countryCode = '+381';
      _phoneNumber = phoneNumber.substring(4);
    } else {
      _countryCode = '+381';
      _phoneNumber = phoneNumber;
    }
  }

  @override
  void initState() {
    super.initState();
    _parsePhoneNumber(_fullPhoneNumber);
  }

  void _startEditing() {
    setState(() {
      _isEditing = true;
      // Save original values
      _originalName = _nameController.text;
      _originalEmail = _emailController.text;
      _originalPhone = _fullPhoneNumber;
    });
  }

  void _cancelEditing() {
    setState(() {
      _isEditing = false;
      // Restore original values
      _nameController.text = _originalName;
      _emailController.text = _originalEmail;
      _fullPhoneNumber = _originalPhone;
      _parsePhoneNumber(_originalPhone);
      _passwordController.clear();
    });
  }

  void _saveChanges() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isEditing = false;
        // Update original values
        _originalName = _nameController.text;
        _originalEmail = _emailController.text;
        _originalPhone = _fullPhoneNumber;
        _passwordController.clear();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profil je uspešno sačuvan!'),
          backgroundColor: AppColors.hotPink,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.deepNavy,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Picture Section
              _buildProfilePictureSection(),

              const SizedBox(height: 32),

              // Name Section
              _isEditing
                  ? _buildTextField(
                      label: 'Ime',
                      controller: _nameController,
                      icon: Icons.person,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Molimo unesite ime';
                        }
                        return null;
                      },
                    )
                  : _buildInfoCard(
                      label: 'Ime',
                      value: _nameController.text,
                      icon: Icons.person,
                    ),

              const SizedBox(height: 20),

              // Email Section
              _isEditing
                  ? _buildTextField(
                      label: 'Email',
                      controller: _emailController,
                      icon: Icons.email,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Molimo unesite email';
                        }
                        if (!value.contains('@')) {
                          return 'Molimo unesite validan email';
                        }
                        return null;
                      },
                    )
                  : _buildInfoCard(
                      label: 'Email',
                      value: _emailController.text,
                      icon: Icons.email,
                    ),

              const SizedBox(height: 20),

              // Phone Section
              _isEditing
                  ? _buildPhoneInput()
                  : _buildInfoCard(
                      label: 'Telefon',
                      value: _formatPhoneNumber(_fullPhoneNumber),
                      icon: Icons.phone,
                    ),

              const SizedBox(height: 20),

              // Password Section
              _isEditing
                  ? _buildPasswordField()
                  : _buildInfoCard(
                      label: 'Lozinka',
                      value: '••••••••',
                      icon: Icons.lock,
                    ),

              const SizedBox(height: 40),

              // Action Buttons
              _isEditing ? _buildEditModeButtons() : _buildEditButton(),
            ],
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
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () {
          if (_isEditing) {
            _cancelEditing();
          } else {
            Navigator.pop(context);
          }
        },
      ),
      title: Text(
        'Moj profil',
        style: GoogleFonts.montserrat(
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: Colors.white,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildProfilePictureSection() {
    return Center(
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppColors.cardNavy,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _isEditing ? AppColors.hotPink : Colors.transparent,
                    width: 3,
                  ),
                ),
                child: Center(
                  child: Text(
                    _userInitials,
                    style: GoogleFonts.montserrat(
                      fontSize: 36,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              if (_isEditing)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.hotPink,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.deepNavy,
                        width: 2,
                      ),
                    ),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      icon: const Icon(Icons.camera_alt, size: 16, color: Colors.white),
                      onPressed: () {
                        // TODO: Open image picker
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Funkcionalnost za promenu slike - uskoro!'),
                            backgroundColor: AppColors.hotPink,
                          ),
                        );
                      },
                    ),
                  ),
                ),
            ],
          ),
          if (_isEditing) ...[
            const SizedBox(height: 12),
            TextButton(
              onPressed: () {
                // TODO: Open image picker
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Funkcionalnost za promenu slike - uskoro!'),
                    backgroundColor: AppColors.hotPink,
                  ),
                );
              },
              child: Text(
                'Promeni sliku profila',
                style: GoogleFonts.montserrat(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.hotPink,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.montserrat(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.white70,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          enabled: _isEditing,
          style: GoogleFonts.montserrat(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: Colors.white60),
            filled: true,
            fillColor: AppColors.cardNavyLight,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppColors.hotPink,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Colors.red,
                width: 1,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Colors.red,
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            errorStyle: GoogleFonts.montserrat(
              fontSize: 12,
              color: Colors.red.shade300,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPhoneInput() {
    return SplitPhoneInputWidget(
      label: 'Telefon',
      onChanged: (countryCode, phoneNumber) {
        setState(() {
          _countryCode = countryCode;
          _phoneNumber = phoneNumber;
          _fullPhoneNumber = '$countryCode$phoneNumber';
        });
      },
      initialCountryCode: _getCountryCodeFromDialCode(_countryCode),
      initialPhoneNumber: _phoneNumber,
      validator: (value) {
        if (_isEditing && (value == null || value.isEmpty)) {
          return 'Molimo unesite telefon';
        }
        return null;
      },
    );
  }

  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Lozinka',
          style: GoogleFonts.montserrat(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.white70,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _passwordController,
          obscureText: !_isPasswordVisible,
          validator: (value) {
            if (value != null && value.isNotEmpty && value.length < 6) {
              return 'Min 6 karaktera';
            }
            return null;
          },
          style: GoogleFonts.montserrat(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.lock, color: Colors.white60),
            suffixIcon: IconButton(
              icon: Icon(
                _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                color: Colors.white60,
              ),
              onPressed: () {
                setState(() {
                  _isPasswordVisible = !_isPasswordVisible;
                });
              },
            ),
            filled: true,
            fillColor: AppColors.cardNavyLight,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppColors.hotPink,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Colors.red,
                width: 1,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Colors.red,
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            hintText: 'Ostavite prazno da zadržite trenutnu lozinku',
            hintStyle: GoogleFonts.montserrat(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Colors.white54,
            ),
            errorStyle: GoogleFonts.montserrat(
              fontSize: 12,
              color: Colors.red.shade300,
            ),
          ),
        ),
      ],
    );
  }

  String _formatPhoneNumber(String phoneNumber) {
    if (phoneNumber.isEmpty) return '';
    // Format: +381 64 123 4567
    if (phoneNumber.startsWith('+381')) {
      final cleaned = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
      if (cleaned.length >= 9) {
        final countryCode = cleaned.substring(0, 3);
        final areaCode = cleaned.substring(3, 5);
        final part1 = cleaned.substring(5, 8);
        final part2 = cleaned.substring(8);
        return '+$countryCode $areaCode $part1 $part2';
      }
    }
    return phoneNumber;
  }

  Widget _buildInfoCard({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardNavyLight,
        borderRadius: BorderRadius.circular(12),
      ),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.montserrat(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.white60,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: GoogleFonts.montserrat(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _startEditing,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.hotPink,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.edit, size: 20, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              'IZMENI',
              style: GoogleFonts.montserrat(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditModeButtons() {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 56,
            child: OutlinedButton(
              onPressed: _cancelEditing,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white70,
                side: BorderSide(color: Colors.white24, width: 1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'OTKAŽI',
                style: GoogleFonts.montserrat(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.0,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: SizedBox(
            height: 56,
            child: ElevatedButton(
              onPressed: _saveChanges,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.hotPink,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
              ),
              child: Text(
                'SAČUVAJ',
                style: GoogleFonts.montserrat(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.0,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

