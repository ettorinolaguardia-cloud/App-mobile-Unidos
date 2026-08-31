import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import 'main_navigation_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController(text: 'ettorino.laguardia@unidos.it');
  final _passwordController = TextEditingController(text: 'admin');
  final _serverUrlController = TextEditingController(text: ApiService.baseUrl);

  bool _isLoading = false;
  String? _errorMessage;

  void _login(UserAccount user) {
    setState(() => _isLoading = true);
    ApiService.currentUser = user;
    ApiService.setBaseUrl(_serverUrlController.text.trim());
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
    );
  }

  void _handleCustomLogin() {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      setState(() => _errorMessage = 'Inserisci un indirizzo email valido.');
      return;
    }

    final user = UserAccount(
      id: 1,
      name: email.split('@').first.replaceAll('.', ' ').toUpperCase(),
      email: email,
      role: email.contains('admin') || email.contains('ettorino') ? 'Developer' : 'Client',
    );
    _login(user);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Logo & Titolo
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.shield_outlined,
                      size: 54,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'UNIDOS MOBILE',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Piattaforma di Monitoraggio Server & Sessioni',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 28),

                // Form Login
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Accedi al tuo account',
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            prefixIcon: Icon(Icons.email_outlined),
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: const InputDecoration(
                            labelText: 'Password',
                            prefixIcon: Icon(Icons.lock_outline),
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _serverUrlController,
                          decoration: const InputDecoration(
                            labelText: 'Indirizzo Server Backend API',
                            prefixIcon: Icon(Icons.dns_outlined),
                            border: OutlineInputBorder(),
                            helperText: 'Default: http://192.168.5.216:3000',
                          ),
                        ),
                        if (_errorMessage != null) ...[
                          const SizedBox(height: 12),
                          Text(
                            _errorMessage!,
                            style: const TextStyle(color: Colors.red, fontSize: 13),
                          ),
                        ],
                        const SizedBox(height: 18),
                        FilledButton.icon(
                          onPressed: _isLoading ? null : _handleCustomLogin,
                          icon: const Icon(Icons.login),
                          label: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            child: Text('ACCEDI', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),
                Text(
                  'Oppure seleziona un account rapido:',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
                ),
                const SizedBox(height: 10),

                // Account veloci
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: [
                    ActionChip(
                      avatar: const Icon(Icons.star, size: 18, color: Colors.amber),
                      label: const Text('Ettorino (Lead Dev)'),
                      onPressed: () {
                        _emailController.text = 'ettorino.laguardia@unidos.it';
                        _passwordController.text = 'admin';
                        _handleCustomLogin();
                      },
                    ),
                    ActionChip(
                      avatar: const Icon(Icons.code, size: 18),
                      label: const Text('Andrea (Dev)'),
                      onPressed: () {
                        _emailController.text = 'andrea.salvatore@unidos.it';
                        _passwordController.text = 'andrea2026';
                        _handleCustomLogin();
                      },
                    ),
                    ActionChip(
                      avatar: const Icon(Icons.code, size: 18),
                      label: const Text('Flavio (Dev)'),
                      onPressed: () {
                        _emailController.text = 'flavio.mastrangelo@unidos.it';
                        _passwordController.text = 'flavio2026';
                        _handleCustomLogin();
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
