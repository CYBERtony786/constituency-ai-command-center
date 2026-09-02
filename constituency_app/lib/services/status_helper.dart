// File: lib/services/status_helper.dart
// Status lifecycle: submitted → under_review → assigned → in_progress → resolved → closed

import 'package:flutter/material.dart';

class StatusHelper {
  static const Map<String, Map<String, dynamic>> _statuses = {
    'submitted': {
      'label': 'Submitted',
      'color': Color(0xFFF29900),
      'icon': Icons.inbox_rounded,
      'emoji': '🟡',
    },
    'pending': {
      'label': 'Submitted',
      'color': Color(0xFFF29900),
      'icon': Icons.inbox_rounded,
      'emoji': '🟡',
    },
    'under_review': {
      'label': 'Under Review',
      'color': Color(0xFF2563EB),
      'icon': Icons.search_rounded,
      'emoji': '🔵',
    },
    'processed': {
      'label': 'Under Review',
      'color': Color(0xFF2563EB),
      'icon': Icons.search_rounded,
      'emoji': '🔵',
    },
    'assigned': {
      'label': 'Assigned',
      'color': Color(0xFF9334E6),
      'icon': Icons.assignment_ind_rounded,
      'emoji': '🟣',
    },
    'in_progress': {
      'label': 'In Progress',
      'color': Color(0xFFE65100),
      'icon': Icons.autorenew_rounded,
      'emoji': '🟠',
    },
    'resolved': {
      'label': 'Resolved',
      'color': Color(0xFF1E8E3E),
      'icon': Icons.verified_rounded,
      'emoji': '🟢',
    },
    'closed': {
      'label': 'Closed',
      'color': Color(0xFF5F6368),
      'icon': Icons.lock_rounded,
      'emoji': '⚫',
    },
  };

  static String label(String status) =>
      _statuses[status]?['label'] ?? 'Unknown';

  static Color color(String status) =>
      _statuses[status]?['color'] ?? Colors.grey;

  static IconData icon(String status) =>
      _statuses[status]?['icon'] ?? Icons.help_outline;

  static Color priorityColor(int p) {
    if (p >= 8) return const Color(0xFFD93025);
    if (p >= 5) return const Color(0xFFF29900);
    return const Color(0xFF1E8E3E);
  }

  static String priorityLabel(int p) {
    if (p >= 8) return 'HIGH';
    if (p >= 5) return 'MEDIUM';
    return 'LOW';
  }

  /// Format complaint ID like GRV-2026-1042
  static String formatId(String docId) {
    final year = DateTime.now().year;
    final short = docId.length >= 4
        ? docId.substring(docId.length - 4).toUpperCase()
        : docId.toUpperCase();
    return 'GRV-$year-$short';
  }

  /// "2 hours ago" style
  static String timeAgo(DateTime? dt) {
    if (dt == null) return 'Just now';
    final diff = DateTime.now().difference(dt);
    if (diff.inSeconds < 60) return '${diff.inSeconds}s ago';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${(diff.inDays / 7).floor()}w ago';
  }
}