import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';
import '../services/api_service.dart';

class MonitorDetailScreen extends StatefulWidget {
  final MonitorItem monitor;

  const MonitorDetailScreen({super.key, required this.monitor});

  @override
  State<MonitorDetailScreen> createState() => _MonitorDetailScreenState();
}

class _MonitorDetailScreenState extends State<MonitorDetailScreen> {
  late MonitorItem _monitor;
  List<MonitorCheckRecord> _checks = [];
  bool _isLoadingChecks = true;
  bool _isCheckingNow = false;

  @override
  void initState() {
    super.initState();
    _monitor = widget.monitor;
    _loadChecks();
  }

  Future<void> _loadChecks() async {
    setState(() => _isLoadingChecks = true);
    final list = await ApiService.getChecks(_monitor.id);
    if (mounted) {
      setState(() {
        _checks = list;
        _isLoadingChecks = false;
      });
    }
  }

  Future<void> _triggerCheck() async {
    setState(() => _isCheckingNow = true);
    final result = await ApiService.runCheck(_monitor.id);
    if (mounted) {
      setState(() => _isCheckingNow = false);
      if (result != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Risultato: ${result.status} (${result.responseTime} ms)${result.errorMessage != null ? " - ${result.errorMessage}" : ""}',
            ),
            backgroundColor: result.status == 'UP' ? Colors.green.shade700 : Colors.red.shade700,
          ),
        );
        _loadChecks();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Impossibile completare il controllo. Verifica la connessione.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'UP':
        return Colors.green;
      case 'DOWN':
        return Colors.red;
      case 'DEGRADED':
        return Colors.orange;
      case 'PAUSED':
        return Colors.grey;
      default:
        return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColor = _getStatusColor(_monitor.status);

    return Scaffold(
      appBar: AppBar(
        title: Text(_monitor.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadChecks,
            tooltip: 'Ricarica Storico',
          )
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Card Stato Principale
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _monitor.name,
                        style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: statusColor, width: 1.5),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircleAvatar(radius: 4, backgroundColor: statusColor),
                            const SizedBox(width: 6),
                            Text(
                              _monitor.status,
                              style: TextStyle(
                                color: statusColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Target: ${_monitor.targetDisplay}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade700,
                      fontFamily: 'monospace',
                    ),
                  ),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildInfoColumn('Tipo', _monitor.type.toUpperCase(), Icons.category),
                      _buildInfoColumn('Latenza', '${_monitor.lastResponseTime ?? 0} ms', Icons.speed),
                      _buildInfoColumn('Intervallo', '${_monitor.interval} min', Icons.timer),
                      _buildInfoColumn('Timeout', '${_monitor.timeout}s', Icons.hourglass_bottom),
                    ],
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: _isCheckingNow ? null : _triggerCheck,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(45),
                    ),
                    icon: _isCheckingNow
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.bolt),
                    label: Text(_isCheckingNow ? 'CONTROLLO IN CORSO...' : 'EFFETTUA TEST ORA'),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),
          Text(
            'Storico Controlli Recenti',
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),

          if (_isLoadingChecks)
            const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator()))
          else if (_checks.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Center(
                  child: Text(
                    'Nessun controllo registrato finora.',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ),
              ),
            )
          else
            ..._checks.map((check) {
              final checkColor = _getStatusColor(check.status);
              final formattedTime = DateFormat('dd/MM/yyyy HH:mm:ss').format(check.checkedAt);

              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: checkColor.withValues(alpha: 0.15),
                    child: Icon(
                      check.status == 'UP' ? Icons.check : Icons.close,
                      color: checkColor,
                    ),
                  ),
                  title: Text(
                    '${check.status} - ${check.responseTime} ms',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    check.errorMessage != null && check.errorMessage!.isNotEmpty
                        ? '$formattedTime\nErrore: ${check.errorMessage}'
                        : formattedTime,
                  ),
                  trailing: check.statusCode != null
                      ? Chip(
                          label: Text(
                            'HTTP ${check.statusCode}',
                            style: const TextStyle(fontSize: 11),
                          ),
                        )
                      : null,
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildInfoColumn(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 20, color: Colors.grey.shade600),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ),
        Text(
          label,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
        ),
      ],
    );
  }
}
