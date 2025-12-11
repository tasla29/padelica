import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/split_phone_input_widget.dart';
import 'auth_controller.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  bool _isLogin = true;
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();

  // Phone input state
  String _fullPhoneNumber = '';

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final controller = ref.read(authControllerProvider.notifier);

    if (_isLogin) {
      await controller.signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
    } else {
      await controller.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        phone: _fullPhoneNumber,
      );
      if (mounted) {
        _showEmailVerificationDialog(_emailController.text.trim());
      }
    }
  }

  Future<void> _signInWithGoogle() async {
    final controller = ref.read(authControllerProvider.notifier);
    await controller.signInWithGoogle();
  }

  Future<void> _signInWithFacebook() async {
    final controller = ref.read(authControllerProvider.notifier);
    await controller.signInWithFacebook();
  }

  void _toggleAuthMode() {
    setState(() {
      _isLogin = !_isLogin;
      _formKey.currentState?.reset();
      // Reset visibility on toggle
      _isPasswordVisible = false;
      _isConfirmPasswordVisible = false;
    });
  }

  void _showEmailVerificationDialog(String email) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.surface,
          title: Text(
            'Potvrdi email',
            style: GoogleFonts.montserrat(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          content: Text(
            'Poslali smo link za potvrdu na $email.\n\nOtvori mejl i klikni na link da završiš registraciju. '
            'Ako nisi dobio mejl, pošalji ponovo.',
            style: GoogleFonts.montserrat(fontSize: 13),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(
                'U redu',
                style: GoogleFonts.montserrat(fontSize: 13),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(ctx).pop();
                try {
                  await ref
                      .read(authControllerProvider.notifier)
                      .resendConfirmationEmail(email);
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Poslali smo novi email za potvrdu na $email',
                        style: GoogleFonts.montserrat(fontSize: 13),
                      ),
                    ),
                  );
                } catch (e) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Nije uspelo slanje potvrde: $e',
                        style: GoogleFonts.montserrat(fontSize: 13),
                      ),
                      backgroundColor: Theme.of(context).colorScheme.error,
                    ),
                  );
                }
              },
              child: Text(
                'Pošalji ponovo',
                style: GoogleFonts.montserrat(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue>(authControllerProvider, (_, state) {
      if (state.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(state.error.toString()),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    });

    final authState = ref.watch(authControllerProvider);
    final isLoading = authState.isLoading;

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                AppConstants.appName,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 32),
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          _isLogin ? 'Prijavi se' : 'Registruj se',
                          style: Theme.of(
                            context,
                          ).textTheme.headlineSmall?.copyWith(fontSize: 20),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),

                        if (!_isLogin) ...[
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _firstNameController,
                                  style: GoogleFonts.montserrat(fontSize: 12),
                                  decoration: InputDecoration(
                                    labelText: 'Ime',
                                    prefixIcon: const Icon(
                                      Icons.person_outline,
                                    ),
                                    labelStyle: GoogleFonts.montserrat(
                                      fontSize: 12,
                                    ),
                                    hintStyle: GoogleFonts.montserrat(
                                      fontSize: 12,
                                    ),
                                  ),
                                  validator: (value) => value?.isEmpty ?? true
                                      ? 'Obavezno polje'
                                      : null,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: TextFormField(
                                  controller: _lastNameController,
                                  style: GoogleFonts.montserrat(fontSize: 12),
                                  decoration: InputDecoration(
                                    labelText: 'Prezime',
                                    prefixIcon: const Icon(
                                      Icons.person_outline,
                                    ),
                                    labelStyle: GoogleFonts.montserrat(
                                      fontSize: 12,
                                    ),
                                    hintStyle: GoogleFonts.montserrat(
                                      fontSize: 12,
                                    ),
                                  ),
                                  validator: (value) => value?.isEmpty ?? true
                                      ? 'Obavezno polje'
                                      : null,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Split Phone Input
                          SplitPhoneInputWidget(
                            onChanged: (countryCode, phoneNumber) {
                              setState(() {
                                _fullPhoneNumber = '$countryCode$phoneNumber';
                              });
                            },
                            initialCountryCode: 'RS',
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Obavezno polje';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                        ],

                        TextFormField(
                          controller: _emailController,
                          style: GoogleFonts.montserrat(fontSize: 12),
                          decoration: InputDecoration(
                            labelText: 'Email',
                            prefixIcon: const Icon(Icons.email_outlined),
                            labelStyle: GoogleFonts.montserrat(fontSize: 12),
                            hintStyle: GoogleFonts.montserrat(fontSize: 12),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) =>
                              value?.isEmpty ?? true ? 'Obavezno polje' : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _passwordController,
                          style: GoogleFonts.montserrat(fontSize: 12),
                          decoration: InputDecoration(
                            labelText: 'Lozinka',
                            labelStyle: GoogleFonts.montserrat(fontSize: 12),
                            hintStyle: GoogleFonts.montserrat(fontSize: 12),
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isPasswordVisible
                                    ? Icons
                                          .visibility // Uncrossed when visible
                                    : Icons
                                          .visibility_off, // Crossed when hidden
                              ),
                              onPressed: () {
                                setState(() {
                                  _isPasswordVisible = !_isPasswordVisible;
                                });
                              },
                            ),
                          ),
                          obscureText: !_isPasswordVisible,
                          validator: (value) => (value?.length ?? 0) < 6
                              ? 'Min 6 karaktera'
                              : null,
                        ),

                        if (!_isLogin) ...[
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _confirmPasswordController,
                            style: GoogleFonts.montserrat(fontSize: 12),
                            decoration: InputDecoration(
                              labelText: 'Potvrdi lozinku',
                              labelStyle: GoogleFonts.montserrat(fontSize: 12),
                              hintStyle: GoogleFonts.montserrat(fontSize: 12),
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _isConfirmPasswordVisible
                                      ? Icons
                                            .visibility // Uncrossed when visible
                                      : Icons
                                            .visibility_off, // Crossed when hidden
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isConfirmPasswordVisible =
                                        !_isConfirmPasswordVisible;
                                  });
                                },
                              ),
                            ),
                            obscureText: !_isConfirmPasswordVisible,
                            validator: (value) {
                              if (value == null || value.isEmpty)
                                return 'Obavezno polje';
                              if (value != _passwordController.text) {
                                return 'Lozinke se ne poklapaju';
                              }
                              return null;
                            },
                          ),
                        ],

                        const SizedBox(height: 24),

                        ElevatedButton(
                          onPressed: isLoading ? null : _submit,
                          child: isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(_isLogin ? 'Prijavi se' : 'Registruj se'),
                        ),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: isLoading ? null : _toggleAuthMode,
                          child: Text(
                            _isLogin
                                ? 'Nemaš nalog? Registruj se'
                                : 'Imaš nalog? Prijavi se',
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Expanded(child: Divider()),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8.0,
                              ),
                              child: Text(
                                'ili',
                                style: GoogleFonts.montserrat(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const Expanded(child: Divider()),
                          ],
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                          onPressed: isLoading ? null : _signInWithGoogle,
                          icon: Icon(
                            Icons.g_mobiledata,
                            color: Theme.of(context).colorScheme.primary,
                            size: 28,
                          ),
                          label: isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  'Nastavi sa Google',
                                  style: GoogleFonts.montserrat(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                          onPressed: isLoading ? null : _signInWithFacebook,
                          icon: Icon(
                            Icons.facebook,
                            color: Theme.of(context).colorScheme.primary,
                            size: 24,
                          ),
                          label: isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  'Nastavi sa Facebook',
                                  style: GoogleFonts.montserrat(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
