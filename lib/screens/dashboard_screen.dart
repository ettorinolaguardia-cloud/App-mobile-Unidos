import 'dart:async';
import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import 'monitor_detail_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  MonitorStats? _stats;
  List<MonitorItem> _monitors = [];
  bool _isLoading = true;
  String _selectedFilter = 'ALL';
  String _searchQuery = '';
  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    _loadData();
    // Auto-refresh ogni 15 secondi
    _pollingTimer = Timer.periodic(const Duration(seconds: 15), (_) => _loadData(silent: true));
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadData({bool silent = false}) async {
    if (!silent) setState(() => _isLoading = true);

    final statsFuture = ApiService.getStats();
    final monitorsFuture = ApiService.getMonitors();

    final results = await Future.wait([statsFuture, monitorsFuture]);

    if (mounted) {
      setState(() {
        _stats = results[0] as MonitorStats;
        _monitors = results[1] as List<MonitorItem>;
        _isLoading = false;
      });
    }
  }

  List<MonitorItem> get _filteredMonitors {
    return _monitors.where((m) {
      final matchesSearch = m.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          m.targetDisplay.toLowerCase().contains(_searchQuery.toLowerCase());

      if (!matchesSearch) return false;

      if (_selectedFilter == 'UP') return m.status == 'UP';
      if (_selectedFilter == 'DOWN') return m.status == 'DOWN';
      if (_selectedFilter == 'DEGRADED') return m.status == 'DEGRADED';
      if (_selectedFilter == 'PAUSED') return m.status == 'PAUSED' || !m.isActive;

      return true;
    }).toList();
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Monitor', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _loadData(),
            tooltip: 'Ricarica Dati',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => _loadData(),
        child: _isLoading && _stats == null
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // KPI Overview Cards
                  if (_stats != null) _buildStatsSection(theme),

                  const SizedBox(height: 16),

                  // Search bar
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Cerca server, servizio o indirizzo IP...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    onChanged: (val) => setState(() => _searchQuery = val),
                  ),

                  const SizedBox(height: 12),

                  // Filtri
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterChip('Tutti (${_monitors.length})', 'ALL'),
                        const SizedBox(width: 8),
                        _buildFilterChip('🟢 Online (${_stats?.up ?? 0})', 'UP', color: Colors.green),
                        const SizedBox(width: 8),
                        _buildFilterChip('🔴 Offline (${_stats?.down ?? 0})', 'DOWN', color: Colors.red),
                        const SizedBox(width: 8),
                        _buildFilterChip('🟠 Degradati (${_stats?.degraded ?? 0})', 'DEGRADED', color: Colors.orange),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  Text(
                    'Servizi Monitorati (${_filteredMonitors.length})',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),

                  if (_filteredMonitors.isEmpty)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(Icons.search_off, size: 48, color: Colors.grey.shade400),
                              const SizedBox(height: 8),
                              Text(
                                'Nessun servizio corrispondente trovato.',
                                style: TextStyle(color: Colors.grey.shade600),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  else
                    ..._filteredMonitors.map((monitor) {
                      final color = _getStatusColor(monitor.status);
                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => MonitorDetailScreen(monitor: monitor),
                              ),
                            ).then((_) => _loadData(silent: true));
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Row(
                              children: [
                                Container(
                                  width: 12,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: color,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        monitor.name,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        monitor.targetDisplay,
                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                          fontSize: 12,
                                          fontFamily: 'monospace',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: color.withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        monitor.status,
                                        style: TextStyle(
                                          color: color,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${monitor.lastResponseTime ?? 0} ms',
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 6),
                                const Icon(Icons.chevron_right, color: Colors.grey),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                ],
              ),
      ),
    );
  }

  Widget _buildStatsSection(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [theme.colorScheme.primary, theme.colorScheme.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'UPTIME GLOBALE',
                    style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_stats!.uptimePercentage.toStringAsFixed(1)}%',
                    style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'LATENZA MEDIA',
                    style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_stats!.avgResponseTime} ms',
                    style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
          const Divider(color: Colors.white24, height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMiniMetric('Totali', '${_stats!.total}', Colors.white),
              _buildMiniMetric('Online', '${_stats!.up}', Colors.greenAccent),
              _buildMiniMetric('Offline', '${_stats!.down}', Colors.redAccent),
              _buildMiniMetric('Incidenti', '${_stats!.openIncidentsCount}', Colors.amberAccent),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniMetric(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 18)),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
      ],
    );
  }

  Widget _buildFilterChip(String label, String value, {Color? color}) {
    final isSelected = _selectedFilter == value;
    return FilterChip(
      selected: isSelected,
      label: Text(label),
      onSelected: (_) => setState(() => _selectedFilter = value),
      selectedColor: color?.withValues(alpha: 0.2) ?? Theme.of(context).colorScheme.primaryContainer,
      labelStyle: TextStyle(
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        color: isSelected ? (color ?? Theme.of(context).colorScheme.primary) : Colors.black87,
      ),
    );
  }
}
