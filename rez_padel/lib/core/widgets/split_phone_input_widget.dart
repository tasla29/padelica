import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';

/// Country data model
class Country {
  final String code;
  final String name;
  final String dialCode;

  const Country({
    required this.code,
    required this.name,
    required this.dialCode,
  });

  String get displayText => '$name ($dialCode)';
}

/// Split phone input widget with separate country selector and phone number fields
class SplitPhoneInputWidget extends StatelessWidget {
  final Function(String countryCode, String phoneNumber) onChanged;
  final String? initialCountryCode;
  final String? initialPhoneNumber;
  final String? label;
  final String? hintText;
  final String? Function(String?)? validator;

  const SplitPhoneInputWidget({
    super.key,
    required this.onChanged,
    this.initialCountryCode,
    this.initialPhoneNumber,
    this.label,
    this.hintText,
    this.validator,
  });

  // Common countries list (can be expanded)
  static const List<Country> _countries = [
    Country(code: 'RS', name: 'RS', dialCode: '+381'),
    Country(code: 'IT', name: 'IT', dialCode: '+39'),
    Country(code: 'US', name: 'US', dialCode: '+1'),
    Country(code: 'GB', name: 'GB', dialCode: '+44'),
    Country(code: 'DE', name: 'DE', dialCode: '+49'),
    Country(code: 'FR', name: 'FR', dialCode: '+33'),
    Country(code: 'ES', name: 'ES', dialCode: '+34'),
    Country(code: 'HR', name: 'HR', dialCode: '+385'),
    Country(code: 'BA', name: 'BA', dialCode: '+387'),
    Country(code: 'ME', name: 'ME', dialCode: '+382'),
    Country(code: 'MK', name: 'MK', dialCode: '+389'),
    Country(code: 'SI', name: 'SI', dialCode: '+386'),
    Country(code: 'AT', name: 'AT', dialCode: '+43'),
    Country(code: 'CH', name: 'CH', dialCode: '+41'),
    Country(code: 'NL', name: 'NL', dialCode: '+31'),
    Country(code: 'BE', name: 'BE', dialCode: '+32'),
    Country(code: 'PT', name: 'PT', dialCode: '+351'),
    Country(code: 'GR', name: 'GR', dialCode: '+30'),
    Country(code: 'TR', name: 'TR', dialCode: '+90'),
    Country(code: 'RU', name: 'RU', dialCode: '+7'),
  ];

  @override
  Widget build(BuildContext context) {
    return _SplitPhoneInputStatefulWidget(
      onChanged: onChanged,
      initialCountryCode: initialCountryCode ?? 'RS',
      initialPhoneNumber: initialPhoneNumber,
      label: label,
      hintText: hintText,
      validator: validator,
    );
  }
}

class _SplitPhoneInputStatefulWidget extends StatefulWidget {
  final Function(String countryCode, String phoneNumber) onChanged;
  final String initialCountryCode;
  final String? initialPhoneNumber;
  final String? label;
  final String? hintText;
  final String? Function(String?)? validator;

  const _SplitPhoneInputStatefulWidget({
    required this.onChanged,
    required this.initialCountryCode,
    this.initialPhoneNumber,
    this.label,
    this.hintText,
    this.validator,
  });

  @override
  State<_SplitPhoneInputStatefulWidget> createState() =>
      _SplitPhoneInputStatefulWidgetState();
}

class _SplitPhoneInputStatefulWidgetState
    extends State<_SplitPhoneInputStatefulWidget> {
  late String _selectedCountryCode;
  final TextEditingController _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedCountryCode = widget.initialCountryCode;
    if (widget.initialPhoneNumber != null) {
      _phoneController.text = widget.initialPhoneNumber!;
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _notifyChange() {
    final country = SplitPhoneInputWidget._countries
        .firstWhere((c) => c.code == _selectedCountryCode);
    widget.onChanged(country.dialCode, _phoneController.text);
  }

  @override
  Widget build(BuildContext context) {
    final textStyle = GoogleFonts.montserrat(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: Colors.white,
    );


    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: GoogleFonts.montserrat(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 8),
        ],
        Row(
          children: [
            // Country Code Selector
            Expanded(
              flex: 2,
              child: Container(
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.cardNavyLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButtonFormField<String>(
                  initialValue: _selectedCountryCode,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
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
                    filled: true,
                    fillColor: Colors.transparent,
                  ),
                  dropdownColor: AppColors.cardNavy,
                  style: textStyle,
                  icon: Icon(
                    Icons.keyboard_arrow_down,
                    color: Colors.white60,
                    size: 20,
                  ),
                  items: SplitPhoneInputWidget._countries.map((country) {
                    return DropdownMenuItem<String>(
                      value: country.code,
                      child: Text(
                        country.displayText,
                        style: textStyle,
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedCountryCode = value;
                      });
                      _notifyChange();
                    }
                  },
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Phone Number Input
            Expanded(
              flex: 3,
              child: TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                validator: widget.validator,
                style: textStyle,
                onChanged: (_) => _notifyChange(),
                decoration: InputDecoration(
                  hintText: widget.hintText ?? 'Broj telefona',
                  hintStyle: GoogleFonts.montserrat(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: Colors.white54,
                  ),
                  filled: true,
                  fillColor: AppColors.cardNavyLight,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
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
                  errorStyle: GoogleFonts.montserrat(
                    fontSize: 12,
                    color: Colors.red.shade300,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

