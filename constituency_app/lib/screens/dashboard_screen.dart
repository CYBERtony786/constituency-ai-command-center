// File: lib/screens/dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/gemini_service.dart';

class DashboardScreen extends StatefulWidget {
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String? aiBriefing;
  bool isLoadingBriefing = false;

  final GeminiService _gemini = GeminiService();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Dashboard title
          const Text(
            '📊 MP Dashboard',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            'Real-time constituency overview',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),

          const SizedBox(height: 20),

          // ============================================================
          // AI MORNING BRIEFING CARD
          // ============================================================
          Card(
            color: Colors.purple[50],
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.auto_awesome,
                        color: Colors.purple,
                      ),

                      const SizedBox(width: 8),

                      const Expanded(
                        child: Text(
                          'AI Morning Briefing',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      ElevatedButton(
                        onPressed:
                            isLoadingBriefing ? null : _generateBriefing,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple,
                          foregroundColor: Colors.white,
                        ),
                        child: Text(
                          isLoadingBriefing ? 'Loading...' : 'Generate',
                        ),
                      ),
                    ],
                  ),

                  if (isLoadingBriefing) ...[
                    const SizedBox(height: 14),
                    const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ],

                  if (aiBriefing != null && !isLoadingBriefing) ...[
                    const SizedBox(height: 12),
                    const Divider(),
                    const SizedBox(height: 6),
                    Text(
                      aiBriefing!,
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // ============================================================
          // LIVE STATS
          // ============================================================
          const Text(
            'Grievance Overview',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 12),

          _buildLiveStats(),

          const SizedBox(height: 24),

          // ============================================================
          // RECENT COMPLAINTS
          // ============================================================
          const Text(
            'Recent Complaints',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 12),

          _buildRecentComplaints(),

          const SizedBox(height: 24),

          // ============================================================
          // CATEGORY BREAKDOWN
          // ============================================================
          const Text(
            'Complaints by Category',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 12),

          _buildCategoryBreakdown(),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // ============================================================
  // AI BRIEFING FUNCTION
  // IMPORTANT: This function is OUTSIDE build(), but INSIDE class.
  // ============================================================
  Future<void> _generateBriefing() async {
    setState(() {
      isLoadingBriefing = true;
      aiBriefing = null;
    });

    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('grievances').get();

      int total = snapshot.docs.length;
      int pending = 0;
      int resolved = 0;

      Map<String, int> categoryCounts = {};

      for (var doc in snapshot.docs) {
        Map<String, dynamic> data =
            doc.data() as Map<String, dynamic>;

        String status = data['status'] ?? 'pending';

        if (status == 'resolved') {
          resolved++;
        } else {
          pending++;
        }

        String category = data['category'] ?? 'other';

        categoryCounts[category] =
            (categoryCounts[category] ?? 0) + 1;
      }

      String briefing = await _gemini.generateDailyBriefing(
        total,
        pending,
        resolved,
        categoryCounts,
      );

      if (!mounted) return;

      setState(() {
        aiBriefing = briefing;
        isLoadingBriefing = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        aiBriefing = 'Unable to generate briefing.\n\nError: $e';
        isLoadingBriefing = false;
      });
    }
  }

  // ============================================================
  // LIVE STATISTICS
  // ============================================================
  Widget _buildLiveStats() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('grievances')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Text('Error loading dashboard: ${snapshot.error}');
        }

        int total = snapshot.data?.docs.length ?? 0;
        int pending = 0;
        int resolved = 0;

        if (snapshot.hasData) {
          for (var doc in snapshot.data!.docs) {
            Map<String, dynamic> data =
                doc.data() as Map<String, dynamic>;

            if (data['status'] == 'resolved') {
              resolved++;
            } else {
              pending++;
            }
          }
        }

        return Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Total',
                '$total',
                Icons.list_alt,
                Colors.blue,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildStatCard(
                'Pending',
                '$pending',
                Icons.pending_actions,
                Colors.orange,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildStatCard(
                'Resolved',
                '$resolved',
                Icons.check_circle,
                Colors.green,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 14,
          horizontal: 8,
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 27),
            const SizedBox(height: 7),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // RECENT COMPLAINTS
  // ============================================================
  Widget _buildRecentComplaints() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('grievances')
          .orderBy('timestamp', descending: true)
          .limit(5)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          // If Firestore asks for an index, it may show here.
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Could not load recent complaints.\n${snapshot.error}',
              ),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Text(
                  'No complaints yet.\nSubmit a complaint to see data here.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
            ),
          );
        }

        return Column(
          children: snapshot.data!.docs.map((doc) {
            Map<String, dynamic> data =
                doc.data() as Map<String, dynamic>;

            String category = data['category'] ?? 'other';
            String status = data['status'] ?? 'pending';
            int priority = data['priority_score'] ?? 5;

            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: ExpansionTile(
                leading: CircleAvatar(
                  backgroundColor: _getCategoryColor(category),
                  child: Icon(
                    _getCategoryIcon(category),
                    color: Colors.white,
                    size: 20,
                  ),
                ),

                title: Text(
                  data['complaint_text'] ?? 'No complaint description',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),

                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          size: 14,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            data['location_text'] ?? 'Location not provided',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 5),

                    Row(
                      children: [
                        _statusChip(status),
                        const SizedBox(width: 7),
                        Text(
                          'Priority: $priority/10',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Divider(),

                        if (data['ai_summary'] != null)
                          _analysisRow(
                            '🤖 AI Summary',
                            data['ai_summary'].toString(),
                          ),

                        if (data['ai_severity'] != null)
                          _analysisRow(
                            '⚠️ Severity',
                            data['ai_severity'].toString(),
                          ),

                        if (data['ai_sentiment'] != null)
                          _analysisRow(
                            '😊 Sentiment',
                            data['ai_sentiment'].toString(),
                          ),

                        if (data['ai_department'] != null)
                          _analysisRow(
                            '🏢 Department',
                            data['ai_department'].toString(),
                          ),

                        if (data['ai_actions'] is List &&
                            (data['ai_actions'] as List).isNotEmpty) ...[
                          const SizedBox(height: 6),
                          const Text(
                            '📋 AI Suggested Actions',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 5),

                          ...(data['ai_actions'] as List).map(
                            (action) => Padding(
                              padding: const EdgeInsets.only(
                                left: 8,
                                bottom: 4,
                              ),
                              child: Text(
                                '• $action',
                                style: const TextStyle(fontSize: 13),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _analysisRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$title: ',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusChip(String status) {
    Color color;

    if (status == 'resolved') {
      color = Colors.green;
    } else if (status == 'processed') {
      color = Colors.blue;
    } else {
      color = Colors.orange;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.16),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  // ============================================================
  // CATEGORY BREAKDOWN
  // ============================================================
  Widget _buildCategoryBreakdown() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('grievances')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Text(
            'No category data available yet.',
            style: TextStyle(color: Colors.grey[600]),
          );
        }

        Map<String, int> counts = {};

        for (var doc in snapshot.data!.docs) {
          Map<String, dynamic> data =
              doc.data() as Map<String, dynamic>;

          String category = data['category'] ?? 'other';
          counts[category] = (counts[category] ?? 0) + 1;
        }

        List<MapEntry<String, int>> sortedCounts =
            counts.entries.toList()
              ..sort((a, b) => b.value.compareTo(a.value));

        int total = snapshot.data!.docs.length;

        return Column(
          children: sortedCounts.map((entry) {
            double percentage = entry.value / total;

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        _getCategoryIcon(entry.key),
                        size: 18,
                        color: _getCategoryColor(entry.key),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _formatCategory(entry.key),
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Text(
                        '${entry.value}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: percentage,
                      minHeight: 9,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _getCategoryColor(entry.key),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }

  // ============================================================
  // HELPERS
  // ============================================================
  Color _getCategoryColor(String category) {
    switch (category) {
      case 'roads':
        return Colors.brown;
      case 'water':
        return Colors.blue;
      case 'electricity':
        return Colors.amber[800]!;
      case 'health':
        return Colors.red;
      case 'education':
        return Colors.green;
      case 'sanitation':
        return Colors.teal;
      case 'street_lights':
        return Colors.orange;
      case 'drainage':
        return Colors.indigo;
      case 'garbage':
        return Colors.grey;
      default:
        return Colors.purple;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'roads':
        return Icons.add_road;
      case 'water':
        return Icons.water_drop;
      case 'electricity':
        return Icons.electrical_services;
      case 'health':
        return Icons.local_hospital;
      case 'education':
        return Icons.school;
      case 'sanitation':
        return Icons.cleaning_services;
      case 'street_lights':
        return Icons.lightbulb;
      case 'drainage':
        return Icons.water;
      case 'garbage':
        return Icons.delete_outline;
      default:
        return Icons.more_horiz;
    }
  }

  String _formatCategory(String category) {
    return category
        .replaceAll('_', ' ')
        .split(' ')
        .map(
          (word) => word.isEmpty
              ? word
              : '${word[0].toUpperCase()}${word.substring(1)}',
        )
        .join(' ');
  }
}