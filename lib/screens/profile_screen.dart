import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _keyController = TextEditingController();
  Map<String, dynamic>? _verifiedData;
  bool _isCheckingKey = false;
  String? _keyError;

  Future<void> _verifySecretKey() async {
    final key = _keyController.text.trim();
    if (key.isEmpty) return;

    setState(() {
      _isCheckingKey = true;
      _keyError = null;
    });

    final res = await ApiService.checkDiagnostics(key);

    if (mounted) {
      setState(() {
        _isCheckingKey = false;
        if (res != null && res['authStatus'] == 'VERIFIED_ORIGINAL_CREATOR') {
          _verifiedData = res;
        } else {
          _keyError = 'Password errata o non riconosciuta dal server.';
        }
      });
    }
  }

  void _logout() {
    ApiService.currentUser = null;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = ApiService.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profilo & Diagnostica', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Scheda Utente
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: theme.colorScheme.primaryContainer,
                    child: Text(
                      user?.name.isNotEmpty == true ? user!.name[0] : 'U',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.name ?? 'Utente Unidos',
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          user?.email ?? 'nessuna email',
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                        ),
                        const SizedBox(height: 6),
                        Chip(
                          label: Text(
                            user?.role ?? 'Developer',
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                          padding: EdgeInsets.zero,
                          visualDensity: VisualDensity.compact,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Sezione Sblocco Certificato Autore & Diagnostica
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.verified_user_outlined, color: theme.colorScheme.primary),
                      const SizedBox(width: 8),
                      Text(
                        'Verifica Autorialità Progetto',
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Inserisci la chiave di sicurezza dell\'autore per verificare l\'integrità crittografica e la paternità del software.',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _keyController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Chiave Segreta Autore',
                      hintText: 'Inserisci password (es. 09061997)',
                      prefixIcon: const Icon(Icons.key),
                      border: const OutlineInputBorder(),
                      errorText: _keyError,
                    ),
                  ),
                  const SizedBox(height: 10),
                  FilledButton.icon(
                    onPressed: _isCheckingKey ? null : _verifySecretKey,
                    icon: _isCheckingKey
                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.check_circle_outline),
                    label: const Text('VERIFICA IDENTITÀ SUL BACKEND'),
                  ),

                  if (_verifiedData != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        border: Border.all(color: Colors.green.shade600, width: 1.5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.verified, color: Colors.green, size: 20),
                              SizedBox(width: 8),
                              Text(
                                'PATERNITÀ ORIGINALE CONFERMATA',
                                style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                            ],
                          ),
                          const Divider(height: 16, color: Colors.green),
                          _buildDetailRow('Autore:', _verifiedData!['author'] ?? 'Ettorino La Guardia'),
                          _buildDetailRow('Ruolo:', _verifiedData!['role'] ?? 'Full Stack Creator'),
                          _buildDetailRow('Progetto:', _verifiedData!['project'] ?? 'Unidos'),
                          _buildDetailRow('Stage:', _verifiedData!['createdFor'] ?? '2026'),
                          _buildDetailRow('Validazione:', _verifiedData!['validationCode'] ?? 'VERIFIED'),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Informazioni Server
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: ListTile(
              leading: const Icon(Icons.dns),
              title: const Text('Backend API'),
              subtitle: Text(ApiService.baseUrl),
            ),
          ),

          const SizedBox(height: 24),

          // Bottone Logout
          OutlinedButton.icon(
            onPressed: _logout,
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red),
              minimumSize: const Size.fromHeight(48),
            ),
            icon: const Icon(Icons.logout),
            label: const Text('DISCONNETTI ACCOUNT', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 90, child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 12))),
        ],
      ),
    );
  }
}
