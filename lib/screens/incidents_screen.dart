import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';
import '../services/api_service.dart';

class IncidentsScreen extends StatefulWidget {
  const IncidentsScreen({super.key});

  @override
  State<IncidentsScreen> createState() => _IncidentsScreenState();
}

class _IncidentsScreenState extends State<IncidentsScreen> {
  List<IncidentItem> _incidents = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadIncidents();
  }

  Future<void> _loadIncidents() async {
    setState(() => _isLoading = true);
    final list = await ApiService.getIncidents();
    if (mounted) {
      setState(() {
        _incidents = list;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final openIncidents = _incidents.where((i) => i.status == 'OPEN').toList();
    final resolvedIncidents = _incidents.where((i) => i.status == 'RESOLVED').toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Registro Incidenti & Allarmi', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadIncidents,
            tooltip: 'Ricarica',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadIncidents,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Sezione Incidenti Aperti
                  Row(
                    children: [
                      Icon(Icons.warning_amber_rounded, color: Colors.red.shade700),
                      const SizedBox(width: 8),
                      Text(
                        'Incidenti Aperti (${openIncidents.length})',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.red.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  if (openIncidents.isEmpty)
                    Card(
                      color: Colors.green.shade50,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: const Padding(
                        padding: EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Icon(Icons.check_circle, color: Colors.green),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Nessun incidente attivo. Tutti i sistemi sono operativi!',
                                style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    ...openIncidents.map((incident) => _buildIncidentCard(incident, isOpen: true)),

                  const SizedBox(height: 24),

                  // Sezione Incidenti Risolti
                  Row(
                    children: [
                      const Icon(Icons.history, color: Colors.grey),
                      const SizedBox(width: 8),
                      Text(
                        'Storico Incidenti Risolti (${resolvedIncidents.length})',
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  if (resolvedIncidents.isEmpty)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Center(
                          child: Text('Nessun incidente nello storico.', style: TextStyle(color: Colors.grey.shade600)),
                        ),
                      ),
                    )
                  else
                    ...resolvedIncidents.map((incident) => _buildIncidentCard(incident, isOpen: false)),
                ],
              ),
      ),
    );
  }

  Widget _buildIncidentCard(IncidentItem incident, {required bool isOpen}) {
    final startTimeFormatted = DateFormat('dd/MM/yyyy HH:mm:ss').format(incident.startedAt);
    final resolveTimeFormatted = incident.resolvedAt != null
        ? DateFormat('dd/MM/yyyy HH:mm:ss').format(incident.resolvedAt!)
        : null;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: isOpen ? BorderSide(color: Colors.red.shade400, width: 1.5) : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    incident.monitor?.name ?? 'Server #${incident.monitorId}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isOpen ? Colors.red.shade100 : Colors.green.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    isOpen ? 'ATTIVO (DOWN)' : 'RISOLTO',
                    style: TextStyle(
                      color: isOpen ? Colors.red.shade800 : Colors.green.shade800,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Causa: ${incident.cause}',
              style: TextStyle(color: Colors.grey.shade800, fontSize: 13),
            ),
            const SizedBox(height: 6),
            Text(
              'Inizio disservizio: $startTimeFormatted',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
            ),
            if (resolveTimeFormatted != null) ...[
              Text(
                'Risolto il: $resolveTimeFormatted (Durata: ${incident.durationSeconds ?? 0}s)',
                style: TextStyle(color: Colors.green.shade700, fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
