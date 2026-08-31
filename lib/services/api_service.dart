import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/models.dart';

class ApiService {
  static String baseUrl = 'http://192.168.5.216:3000';

  static UserAccount? currentUser;

  static void setBaseUrl(String url) {
    baseUrl = url.endsWith('/') ? url.substring(0, url.length - 1) : url;
  }

  // 1. Statistiche Globali
  static Future<MonitorStats> getStats() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/monitors/stats')).timeout(const Duration(seconds: 8));
      if (response.statusCode == 200) {
        return MonitorStats.fromJson(jsonDecode(response.body));
      }
    } catch (e) {
      // ignore
    }
    return MonitorStats(
      total: 0,
      up: 0,
      down: 0,
      degraded: 0,
      paused: 0,
      pending: 0,
      uptimePercentage: 100.0,
      avgResponseTime: 0,
      openIncidentsCount: 0,
    );
  }

  // 2. Lista di tutti i Monitor
  static Future<List<MonitorItem>> getMonitors() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/monitors')).timeout(const Duration(seconds: 8));
      if (response.statusCode == 200) {
        final List list = jsonDecode(response.body);
        return list.map((e) => MonitorItem.fromJson(e)).toList();
      }
    } catch (e) {
      // ignore
    }
    return [];
  }

  // 3. Esegui controllo manuale immediato
  static Future<MonitorCheckRecord?> runCheck(int monitorId) async {
    try {
      final response = await http.post(Uri.parse('$baseUrl/monitors/$monitorId/check')).timeout(const Duration(seconds: 15));
      if (response.statusCode == 200 || response.statusCode == 201) {
        return MonitorCheckRecord.fromJson(jsonDecode(response.body));
      }
    } catch (e) {
      // ignore
    }
    return null;
  }

  // 4. Storico controlli del monitor
  static Future<List<MonitorCheckRecord>> getChecks(int monitorId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/monitors/$monitorId/checks')).timeout(const Duration(seconds: 8));
      if (response.statusCode == 200) {
        final List list = jsonDecode(response.body);
        return list.map((e) => MonitorCheckRecord.fromJson(e)).toList();
      }
    } catch (e) {
      // ignore
    }
    return [];
  }

  // 5. Lista Incidenti
  static Future<List<IncidentItem>> getIncidents() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/monitors/incidents/all')).timeout(const Duration(seconds: 8));
      if (response.statusCode == 200) {
        final List list = jsonDecode(response.body);
        return list.map((e) => IncidentItem.fromJson(e)).toList();
      }
    } catch (e) {
      // fallback a incidenti
    }
    return [];
  }

  // 6. Lista Utenti per Login/Gestione
  static Future<List<UserAccount>> getUsers() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/users')).timeout(const Duration(seconds: 8));
      if (response.statusCode == 200) {
        final List list = jsonDecode(response.body);
        return list.map((e) => UserAccount.fromJson(e)).toList();
      }
    } catch (e) {
      // ignore
    }
    return [];
  }

  // 7. Invio Notifica Telegram
  static Future<bool> sendTelegram(String message) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/notifications/telegram/send'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'message': message}),
      ).timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body);
      return data['status'] == 'success';
    } catch (e) {
      return false;
    }
  }

  // 8. Invio Notifica WhatsApp
  static Future<bool> sendWhatsApp(String phone, String name, String message) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/notifications/whatsapp/send'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'toPhone': phone,
          'recipientName': name,
          'message': message,
        }),
      ).timeout(const Duration(seconds: 10));

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  // 9. Verifica Diagnostica / Firma Autore con Password Segreta
  static Future<Map<String, dynamic>?> checkDiagnostics(String key) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/system/diagnostics?key=$key'),
      ).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      // ignore
    }
    return null;
  }
}
