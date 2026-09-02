// File: lib/screens/analytics_screen.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../services/app_localizations.dart';

class AnalyticsScreen extends StatelessWidget {
  final String localeCode;

  const AnalyticsScreen({
    super.key,
    this.localeCode = 'hi',
  });

  static const Color _primary = Color(0xFF2563EB);
  static const Color _border = Color(0xFFE5EAF1);
  static const Color _textDark = Color(0xFF0F1F3D);
  static const Color _textGrey = Color(0xFF5B6B84);

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations(localeCode);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FB),
      appBar: AppBar(
        title: Text(loc.t('nav_analytics')),
        backgroundColor: const Color(0xFF0A1F44),
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance.collection('grievances').snapshots(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snap.data?.docs ?? [];
          final Map<String, int> cats = {};
          final Map<String, int> status = {};
          int high = 0;
          int withMedia = 0;

          for (final d in docs) {
            final data = d.data() as Map<String, dynamic>;
            final c = data['category']?.toString() ?? 'other';
            final s = data['status']?.toString() ?? 'submitted';
            cats[c] = (cats[c] ?? 0) + 1;
            status[s] = (status[s] ?? 0) + 1;

            final p = data['priority_score'] is int
                ? data['priority_score'] as int
                : int.tryParse(data['priority_score']?.toString() ?? '5') ?? 5;
            if (p >= 8) high++;
            if (data['has_photo'] == true || data['has_video'] == true) {
              withMedia++;
            }
          }

          final total = docs.length;
          final resolved =
              (status['resolved'] ?? 0) + (status['closed'] ?? 0);
          final rate = total == 0 ? 0.0 : resolved / total;

          final catEntries = cats.entries.toList()
            ..sort((a, b) => b.value.compareTo(a.value));

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1000),
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  Text(
                    loc.t('analytics_title'),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: _textDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    loc.t('analytics_sub'),
                    style: const TextStyle(fontSize: 13, color: _textGrey),
                  ),
                  const SizedBox(height: 20),

                  // KPI row — fixed height to avoid overflow
                  LayoutBuilder(
                    builder: (context, c) {
                      final cols = c.maxWidth > 700 ? 4 : 2;
                      return GridView.count(
                        crossAxisCount: cols,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        mainAxisExtent: 128,
                        children: [
                          _kpi(
                            loc.t('total_cases'),
                            '$total',
                            Icons.dataset_rounded,
                            _primary,
                          ),
                          _kpi(
                            loc.t('high_priority'),
                            '$high',
                            Icons.priority_high_rounded,
                            const Color(0xFFD93025),
                          ),
                          _kpi(
                            loc.t('stat_resolved'),
                            '${(rate * 100).toStringAsFixed(0)}%',
                            Icons.verified_rounded,
                            const Color(0xFF1E8E3E),
                          ),
                          _kpi(
                            loc.t('with_media'),
                            '$withMedia',
                            Icons.photo_camera_rounded,
                            const Color(0xFF9334E6),
                          ),
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 24),

                  // Category share
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: _border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          loc.t('category_share'),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: _textDark,
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (catEntries.isEmpty)
                          const Text(
                            'No data yet',
                            style: TextStyle(color: _textGrey),
                          )
                        else
                          ...catEntries.map((e) {
                            final pct = total == 0 ? 0.0 : e.value / total;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 14),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          _localizedCategory(e.key, loc),
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w700,
                                            color: _textDark,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        '${e.value}  (${(pct * 100).toStringAsFixed(0)}%)',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: _textGrey,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(6),
                                    child: LinearProgressIndicator(
                                      value: pct,
                                      minHeight: 8,
                                      backgroundColor:
                                          const Color(0xFFEFF2F7),
                                      valueColor:
                                          const AlwaysStoppedAnimation<Color>(
                                        _primary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Status mix
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: _border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          loc.t('status_mix'),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: _textDark,
                          ),
                        ),
                        const SizedBox(height: 14),
                        if (status.isEmpty)
                          const Text(
                            'No status data yet',
                            style: TextStyle(color: _textGrey),
                          )
                        else
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: status.entries.map((e) {
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF8FAFF),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: _border),
                                ),
                                child: Text(
                                  '${_formatStatus(e.key)}: ${e.value}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: _textDark,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _kpi(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 17, color: color),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: color,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: _textGrey,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  String _localizedCategory(String category, AppLocalizations loc) {
    switch (category) {
      case 'roads':
        return loc.t('cat_roads');
      case 'water':
        return loc.t('cat_water');
      case 'electricity':
        return loc.t('cat_electricity');
      case 'health':
        return loc.t('cat_health');
      case 'education':
        return loc.t('cat_education');
      case 'sanitation':
        return loc.t('cat_sanitation');
      case 'street_lights':
        return loc.t('cat_lights');
      case 'drainage':
        return loc.t('cat_drainage');
      case 'garbage':
        return loc.t('cat_garbage');
      default:
        return loc.t('cat_other');
    }
  }

  String _formatStatus(String status) {
    return status.replaceAll('_', ' ').split(' ').map((w) {
      return w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}';
    }).join(' ');
  }
}