import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

/// Reusable phone input widget matching the auth screen style
class PhoneInputWidget extends StatelessWidget {
  final Function(PhoneNumber) onInputChanged;
  final PhoneNumber initialValue;
  final String? hintText;
  final String? errorMessage;

  const PhoneInputWidget({
    super.key,
    required this.onInputChanged,
    required this.initialValue,
    this.hintText,
    this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    // Consistent text style for both country code and phone number
    final textStyle = GoogleFonts.montserrat(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      color: Colors.white,
    );

    return InternationalPhoneNumberInput(
      onInputChanged: onInputChanged,
      selectorConfig: const SelectorConfig(
        selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
        showFlags: true,
        useEmoji: true,
        leadingPadding: 0,
        trailingSpace: false,
        setSelectorButtonAsPrefixIcon: true,
      ),
      ignoreBlank: false,
      autoValidateMode: AutovalidateMode.disabled,
      selectorTextStyle: textStyle,
      textStyle: textStyle,
      initialValue: initialValue,
      formatInput: true,
      keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: true),
      inputBorder: InputBorder.none,
      inputDecoration: InputDecoration(
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        errorBorder: InputBorder.none,
        disabledBorder: InputBorder.none,
        hintText: hintText ?? 'Broj telefona',
        hintStyle: GoogleFonts.montserrat(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: Colors.white54,
        ),
        contentPadding: EdgeInsets.zero,
      ),
      errorMessage: errorMessage ?? 'Neispravan format',
    );
  }
}

