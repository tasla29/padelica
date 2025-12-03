import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
    }
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
                          style: Theme.of(context).textTheme.headlineSmall,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        
                        if (!_isLogin) ...[
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _firstNameController,
                                  decoration: const InputDecoration(
                                    labelText: 'Ime',
                                    prefixIcon: Icon(Icons.person_outline),
                                  ),
                                  validator: (value) =>
                                      value?.isEmpty ?? true ? 'Obavezno polje' : null,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: TextFormField(
                                  controller: _lastNameController,
                                  decoration: const InputDecoration(
                                    labelText: 'Prezime',
                                    prefixIcon: Icon(Icons.person_outline),
                                  ),
                                  validator: (value) =>
                                      value?.isEmpty ?? true ? 'Obavezno polje' : null,
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
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            prefixIcon: Icon(Icons.email_outlined),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) =>
                              value?.isEmpty ?? true ? 'Obavezno polje' : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _passwordController,
                          decoration: InputDecoration(
                            labelText: 'Lozinka',
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isPasswordVisible 
                                  ? Icons.visibility // Uncrossed when visible
                                  : Icons.visibility_off // Crossed when hidden
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
                            decoration: InputDecoration(
                              labelText: 'Potvrdi lozinku',
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _isConfirmPasswordVisible 
                                    ? Icons.visibility // Uncrossed when visible
                                    : Icons.visibility_off // Crossed when hidden
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                                  });
                                },
                              ),
                            ),
                            obscureText: !_isConfirmPasswordVisible,
                            validator: (value) {
                              if (value == null || value.isEmpty) return 'Obavezno polje';
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
