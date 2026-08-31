class MonitorStats {
  final int total;
  final int up;
  final int down;
  final int degraded;
  final int paused;
  final int pending;
  final double uptimePercentage;
  final int avgResponseTime;
  final int openIncidentsCount;

  MonitorStats({
    required this.total,
    required this.up,
    required this.down,
    required this.degraded,
    required this.paused,
    required this.pending,
    required this.uptimePercentage,
    required this.avgResponseTime,
    required this.openIncidentsCount,
  });

  factory MonitorStats.fromJson(Map<String, dynamic> json) {
    return MonitorStats(
      total: json['total'] ?? 0,
      up: json['up'] ?? 0,
      down: json['down'] ?? 0,
      degraded: json['degraded'] ?? 0,
      paused: json['paused'] ?? 0,
      pending: json['pending'] ?? 0,
      uptimePercentage: (json['uptimePercentage'] as num?)?.toDouble() ?? 100.0,
      avgResponseTime: json['avgResponseTime'] ?? 0,
      openIncidentsCount: json['openIncidentsCount'] ?? 0,
    );
  }
}

class MonitorItem {
  final int id;
  final String name;
  final String type;
  final String? url;
  final String? hostname;
  final int? port;
  final int interval;
  final int timeout;
  final String status;
  final int? lastResponseTime;
  final DateTime? lastCheckAt;
  final int consecutiveFailures;
  final bool isActive;

  MonitorItem({
    required this.id,
    required this.name,
    required this.type,
    this.url,
    this.hostname,
    this.port,
    required this.interval,
    required this.timeout,
    required this.status,
    this.lastResponseTime,
    this.lastCheckAt,
    required this.consecutiveFailures,
    required this.isActive,
  });

  factory MonitorItem.fromJson(Map<String, dynamic> json) {
    return MonitorItem(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      type: json['type'] ?? 'http',
      url: json['url'],
      hostname: json['hostname'],
      port: json['port'],
      interval: json['interval'] ?? 2,
      timeout: json['timeout'] ?? 10,
      status: json['status'] ?? 'PENDING',
      lastResponseTime: json['lastResponseTime'],
      lastCheckAt: json['lastCheckAt'] != null ? DateTime.tryParse(json['lastCheckAt']) : null,
      consecutiveFailures: json['consecutiveFailures'] ?? 0,
      isActive: json['isActive'] ?? true,
    );
  }

  String get targetDisplay {
    if (url != null && url!.isNotEmpty) return url!;
    if (hostname != null && hostname!.isNotEmpty) {
      return '$hostname${port != null ? ':$port' : ''}';
    }
    return 'N/D';
  }
}

class MonitorCheckRecord {
  final int id;
  final int monitorId;
  final String status;
  final int responseTime;
  final int? statusCode;
  final String? errorMessage;
  final DateTime checkedAt;

  MonitorCheckRecord({
    required this.id,
    required this.monitorId,
    required this.status,
    required this.responseTime,
    this.statusCode,
    this.errorMessage,
    required this.checkedAt,
  });

  factory MonitorCheckRecord.fromJson(Map<String, dynamic> json) {
    return MonitorCheckRecord(
      id: json['id'] ?? 0,
      monitorId: json['monitorId'] ?? 0,
      status: json['status'] ?? 'UP',
      responseTime: json['responseTime'] ?? 0,
      statusCode: json['statusCode'],
      errorMessage: json['errorMessage'],
      checkedAt: json['checkedAt'] != null
          ? DateTime.parse(json['checkedAt'])
          : DateTime.now(),
    );
  }
}

class IncidentItem {
  final int id;
  final int monitorId;
  final String status;
  final String cause;
  final DateTime startedAt;
  final DateTime? resolvedAt;
  final int? durationSeconds;
  final MonitorItem? monitor;

  IncidentItem({
    required this.id,
    required this.monitorId,
    required this.status,
    required this.cause,
    required this.startedAt,
    this.resolvedAt,
    this.durationSeconds,
    this.monitor,
  });

  factory IncidentItem.fromJson(Map<String, dynamic> json) {
    return IncidentItem(
      id: json['id'] ?? 0,
      monitorId: json['monitorId'] ?? 0,
      status: json['status'] ?? 'OPEN',
      cause: json['cause'] ?? 'Disservizio rilevato',
      startedAt: json['startedAt'] != null ? DateTime.parse(json['startedAt']) : DateTime.now(),
      resolvedAt: json['resolvedAt'] != null ? DateTime.tryParse(json['resolvedAt']) : null,
      durationSeconds: json['durationSeconds'],
      monitor: json['monitor'] != null ? MonitorItem.fromJson(json['monitor']) : null,
    );
  }
}

class UserAccount {
  final int id;
  final String name;
  final String email;
  final String role;
  final String? avatarUrl;

  UserAccount({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.avatarUrl,
  });

  factory UserAccount.fromJson(Map<String, dynamic> json) {
    return UserAccount(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'Developer',
      avatarUrl: json['avatarUrl'],
    );
  }
}
