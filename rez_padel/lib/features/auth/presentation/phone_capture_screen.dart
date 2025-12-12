import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/split_phone_input_widget.dart';
import '../domain/user_model.dart';
import 'auth_controller.dart';

class PhoneCaptureScreen extends ConsumerStatefulWidget {
  final UserModel user;

  const PhoneCaptureScreen({super.key, required this.user});

  @override
  ConsumerState<PhoneCaptureScreen> createState() => _PhoneCaptureScreenState();
}

class _PhoneCaptureScreenState extends ConsumerState<PhoneCaptureScreen> {
  final _formKey = GlobalKey<FormState>();
  String _fullPhoneNumber = '';

  @override
  void initState() {
    super.initState();
    _fullPhoneNumber = widget.user.phone;
  }

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

    if (authState.hasValue &&
        authState.valueOrNull != null &&
        authState.valueOrNull!.phone.isNotEmpty) {
      // Phone saved, rebuild will let AuthGate route to HomeScreen
    }

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
                    'Još jedan korak',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.montserrat(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Unesi broj telefona kako bismo završili prijavu.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.montserrat(
                      fontSize: 14,
                      color: Colors.white70,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 28),
                  Container(
                    padding: const EdgeInsets.all(20),
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
                        const SizedBox(height: 20),
                        FilledButton(
                          onPressed: isLoading ? null : _submit,
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.hotPink,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            textStyle: GoogleFonts.montserrat(
                              fontSize: 14,
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
                              : const Text('Sačuvaj i nastavi'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: isLoading
                        ? null
                        : () async {
                            await ref
                                .read(authControllerProvider.notifier)
                                .signOut();
                          },
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white70,
                      textStyle: GoogleFonts.montserrat(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    child: const Text('Izloguj se'),
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
