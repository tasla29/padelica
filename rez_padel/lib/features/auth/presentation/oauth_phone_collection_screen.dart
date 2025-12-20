import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/split_phone_input_widget.dart';
import '../domain/user_model.dart';
import 'auth_controller.dart';

class OAuthPhoneCollectionScreen extends ConsumerStatefulWidget {
  final UserModel user;

  const OAuthPhoneCollectionScreen({super.key, required this.user});

  @override
  ConsumerState<OAuthPhoneCollectionScreen> createState() =>
      _OAuthPhoneCollectionScreenState();
}

class _OAuthPhoneCollectionScreenState
    extends ConsumerState<OAuthPhoneCollectionScreen> {
  final _formKey = GlobalKey<FormState>();
  String _fullPhoneNumber = '';

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue>(authControllerProvider, (previous, next) {
      if (next.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error.toString()),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    });

    final authState = ref.watch(authControllerProvider);
    final isLoading = authState.isLoading;

    return Scaffold(
      backgroundColor: AppColors.deepNavy,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Dodaj broj telefona',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.montserrat(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Potreban nam je tvoj broj telefona za potvrde rezervacija i obaveštenja.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.montserrat(
                      fontSize: 14,
                      color: Colors.white70,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.cardNavy,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SplitPhoneInputWidget(
                          initialCountryCode: 'RS',
                          onChanged: (countryCode, phoneNumber) {
                            setState(() {
                              _fullPhoneNumber = '$countryCode$phoneNumber';
                            });
                          },
                          validator: (value) {
                            if (_fullPhoneNumber.isEmpty) {
                              return 'Unesi broj telefona';
                            }
                            if (_fullPhoneNumber.length < 8) {
                              return 'Broj je prekratak';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        FilledButton(
                          onPressed: isLoading ? null : _submit,
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.hotPink,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            textStyle: GoogleFonts.montserrat(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          child: isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text('Nastavi'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    await ref
        .read(authControllerProvider.notifier)
        .savePhone(
          phone: _fullPhoneNumber,
          firstName: widget.user.firstName,
          lastName: widget.user.lastName,
        );
  }
}
