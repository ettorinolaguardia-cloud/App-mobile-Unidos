import 'package:flutter/material.dart';
import '../services/api_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final _telegramController = TextEditingController(
    text: '🚀 [TEST DA APP MOBILE UNIDOS]\nIl canale di monitoraggio è perfettamente attivo e collegato!',
  );

  final _whatsappPhoneController = TextEditingController(text: '+393209269241');
  final _whatsappNameController = TextEditingController(text: 'Guido (Capo)');
  final _whatsappMsgController = TextEditingController(
    text: '🚨 [UNIDOS ALERT] Test di notifica inviato dall\'app mobile Flutter!',
  );

  bool _isSendingTelegram = false;
  bool _isSendingWhatsApp = false;

  Future<void> _sendTelegram() async {
    final msg = _telegramController.text.trim();
    if (msg.isEmpty) return;

    setState(() => _isSendingTelegram = true);
    final success = await ApiService.sendTelegram(msg);

    if (mounted) {
      setState(() => _isSendingTelegram = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? '✅ Notifica Telegram inviata al gruppo!' : '❌ Errore durante l\'invio Telegram.'),
          backgroundColor: success ? Colors.green.shade700 : Colors.red,
        ),
      );
    }
  }

  Future<void> _sendWhatsApp() async {
    final phone = _whatsappPhoneController.text.trim();
    final name = _whatsappNameController.text.trim();
    final msg = _whatsappMsgController.text.trim();

    if (phone.isEmpty || msg.isEmpty) return;

    setState(() => _isSendingWhatsApp = true);
    final success = await ApiService.sendWhatsApp(phone, name, msg);

    if (mounted) {
      setState(() => _isSendingWhatsApp = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? '✅ Messaggio WhatsApp inviato con successo!' : '❌ Errore durante l\'invio WhatsApp.'),
          backgroundColor: success ? Colors.green.shade700 : Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Centro Notifiche & Allarmi', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Sezione Telegram
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
                      const CircleAvatar(
                        backgroundColor: Color(0xFF229ED9),
                        radius: 18,
                        child: Icon(Icons.send, color: Colors.white, size: 18),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Notifica Canale Telegram',
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _telegramController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Messaggio HTML / Testo',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 14),
                  FilledButton.icon(
                    onPressed: _isSendingTelegram ? null : _sendTelegram,
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF229ED9),
                      minimumSize: const Size.fromHeight(45),
                    ),
                    icon: _isSendingTelegram
                        ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Icon(Icons.send_rounded),
                    label: Text(_isSendingTelegram ? 'INVIO IN CORSO...' : 'INVIA AVVISO TELEGRAM'),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Sezione WhatsApp
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
                      const CircleAvatar(
                        backgroundColor: Color(0xFF25D366),
                        radius: 18,
                        child: Icon(Icons.chat, color: Colors.white, size: 18),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Notifica Diretta WhatsApp',
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _whatsappPhoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Numero Destinatario (+39...)',
                      prefixIcon: Icon(Icons.phone),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _whatsappNameController,
                    decoration: const InputDecoration(
                      labelText: 'Nome Destinatario',
                      prefixIcon: Icon(Icons.person),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _whatsappMsgController,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Testo Notifica WhatsApp',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 14),
                  FilledButton.icon(
                    onPressed: _isSendingWhatsApp ? null : _sendWhatsApp,
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF25D366),
                      minimumSize: const Size.fromHeight(45),
                    ),
                    icon: _isSendingWhatsApp
                        ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Icon(Icons.send),
                    label: Text(_isSendingWhatsApp ? 'INVIO IN CORSO...' : 'INVIA SU WHATSAPP'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
