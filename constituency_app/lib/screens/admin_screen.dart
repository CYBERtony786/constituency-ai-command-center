// File: lib/screens/admin_screen.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  bool _busy = false;
  String _status = '';

  final List<Map<String, dynamic>> _sampleData = [
    {
      'complaint_text':
          'Severe waterlogging on Main Road, Ward 13. Two-wheelers unable to pass since morning. Approximately 4,500 daily commuters affected.',
      'category': 'drainage',
      'location_text': 'Ward 13, Lucknow',
      'status': 'in_progress',
      'priority_score': 9,
      'ai_summary':
          'Drainage failure blocking major commuter route in Ward 13.',
      'ai_severity': 'high',
      'ai_department': 'Municipal Corporation - Drainage',
      'ai_actions': [
        'Deploy pump within 4 hours',
        'Notify traffic police for diversion',
        'Inspect underground drainage next 48h',
      ],
    },
    {
      'complaint_text':
          'Water shortage in Ward 12 for the past 3 days. Around 800 households affected. Tanker service not reaching interior lanes.',
      'category': 'water',
      'location_text': 'Ward 12, Bhopal',
      'status': 'assigned',
      'priority_score': 9,
      'ai_summary':
          'Persistent water shortage impacting 800 households; tanker logistics failing.',
      'ai_severity': 'high',
      'ai_department': 'Jal Board',
      'ai_actions': [
        'Deploy 3 additional water tankers today',
        'Repair main pipeline in next 24h',
        'Schedule alternate day supply notice',
      ],
    },
    {
      'complaint_text':
          'Large pothole near Government Girls School blocking safe passage. Two accidents reported last week.',
      'category': 'roads',
      'location_text': 'Sector 8, Ghaziabad',
      'status': 'submitted',
      'priority_score': 8,
      'ai_summary':
          'Safety hazard near school; accidents already reported.',
      'ai_severity': 'high',
      'ai_department': 'PWD',
      'ai_actions': [
        'Emergency patch within 24h',
        'Coordinate with school for temporary diversion',
      ],
    },
    {
      'complaint_text':
          'Power outage affecting 800 households in Rampur colony. Transformer damaged since last night.',
      'category': 'electricity',
      'location_text': 'Rampur Colony',
      'status': 'in_progress',
      'priority_score': 8,
      'ai_summary':
          'Transformer failure — 800 households without power.',
      'ai_severity': 'high',
      'ai_department': 'State Electricity Board',
      'ai_actions': [
        'Replace transformer within 12h',
        'Deploy mobile power backup to hospital',
      ],
    },
    {
      'complaint_text':
          'Street lights non-functional on NH-24 stretch (2.4 km). Night visibility critical for pedestrians.',
      'category': 'street_lights',
      'location_text': 'NH-24 Bypass',
      'status': 'assigned',
      'priority_score': 7,
      'ai_summary':
          'Highway lighting failure — pedestrian safety at risk.',
      'ai_severity': 'medium',
      'ai_department': 'NHAI Municipal Cell',
      'ai_actions': [
        'Replace 18 LED units by weekend',
      ],
    },
    {
      'complaint_text':
          'Uncollected garbage piling near community park entrance. Foul smell affecting 200+ residents.',
      'category': 'garbage',
      'location_text': 'Ward 5, Sector 22',
      'status': 'under_review',
      'priority_score': 6,
      'ai_summary':
          'Waste collection missed for 5+ days near park.',
      'ai_severity': 'medium',
      'ai_department': 'Solid Waste Management',
      'ai_actions': [
        'Deploy garbage truck same day',
        'Review route schedule',
      ],
    },
    {
      'complaint_text':
          'PHC has no doctor on weekends. Emergency cases being turned away.',
      'category': 'health',
      'location_text': 'Village Sundarpur',
      'status': 'under_review',
      'priority_score': 8,
      'ai_summary':
          'Weekend medical staffing gap — emergency referrals affected.',
      'ai_severity': 'high',
      'ai_department': 'Health Department',
      'ai_actions': [
        'Assign visiting doctor rotation',
        'Notify district CMO',
      ],
    },
    {
      'complaint_text':
          'School roof leaking during recent rains. 3 classrooms unusable.',
      'category': 'education',
      'location_text': 'Govt Primary School, Ward 9',
      'status': 'in_progress',
      'priority_score': 6,
      'ai_summary':
          'Infrastructure repair needed before monsoon peak.',
      'ai_severity': 'medium',
      'ai_department': 'Education Department',
      'ai_actions': [
        'Waterproofing tender to be raised',
        'Temporary tarpaulin arrangement',
      ],
    },
    {
      'complaint_text':
          'Blocked sewer line causing overflow near residential blocks in Sector 15.',
      'category': 'sanitation',
      'location_text': 'Sector 15',
      'status': 'assigned',
      'priority_score': 7,
      'ai_summary':
          'Sewer overflow health hazard in dense residential area.',
      'ai_severity': 'high',
      'ai_department': 'Municipal Sanitation',
      'ai_actions': [
        'Jetting machine deployment within 24h',
      ],
    },
    {
      'complaint_text':
          'Broken speed breaker near hospital entrance causing vehicle damage.',
      'category': 'roads',
      'location_text': 'Civil Hospital Road',
      'status': 'resolved',
      'priority_score': 4,
      'ai_summary':
          'Minor infrastructure repair completed.',
      'ai_severity': 'low',
      'ai_department': 'PWD',
      'ai_actions': ['Resurfaced on 12th of this month'],
    },
    {
      'complaint_text':
          'Community toilet non-functional for 2 weeks in market area.',
      'category': 'sanitation',
      'location_text': 'Central Market',
      'status': 'resolved',
      'priority_score': 5,
      'ai_summary': 'Toilet unit restored after plumbing repair.',
      'ai_severity': 'medium',
      'ai_department': 'Municipal Corporation',
      'ai_actions': ['Repair completed and inspection done'],
    },
    {
      'complaint_text':
          'Low voltage supply in Ward 7 causing appliance damage.',
      'category': 'electricity',
      'location_text': 'Ward 7',
      'status': 'in_progress',
      'priority_score': 6,
      'ai_summary':
          'Voltage stabilization required — capacitor bank upgrade.',
      'ai_severity': 'medium',
      'ai_department': 'Electricity Board',
      'ai_actions': ['Install voltage regulator'],
    },
  ];

  Future<void> _seed() async {
    setState(() {
      _busy = true;
      _status = 'Seeding realistic sample data...';
    });

    try {
      final col = FirebaseFirestore.instance.collection('grievances');
      final now = DateTime.now();

      for (int i = 0; i < _sampleData.length; i++) {
        final entry = _sampleData[i];
        await col.add({
          ...entry,
          'language': 'en',
          'timestamp': Timestamp.fromDate(
            now.subtract(Duration(hours: i * 3, minutes: i * 7)),
          ),
          'ai_sentiment': (entry['priority_score'] as int) >= 8
              ? 'frustrated'
              : 'neutral',
          'has_photo': false,
          'has_video': false,
          'media_mode': 'firestore_demo_no_storage',
        });
      }

      setState(() {
        _status = '✅ Added ${_sampleData.length} realistic grievances.';
        _busy = false;
      });
    } catch (e) {
      setState(() {
        _status = 'Error: $e';
        _busy = false;
      });
    }
  }

  Future<void> _clearAll() async {
    setState(() {
      _busy = true;
      _status = 'Clearing all grievances...';
    });

    try {
      final snap =
          await FirebaseFirestore.instance.collection('grievances').get();
      for (final doc in snap.docs) {
        await doc.reference.delete();
      }
      setState(() {
        _status = '🧹 Cleared ${snap.docs.length} documents.';
        _busy = false;
      });
    } catch (e) {
      setState(() {
        _status = 'Error: $e';
        _busy = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Panel'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.admin_panel_settings_rounded,
                    size: 64, color: Color(0xFF2563EB)),
                const SizedBox(height: 16),
                const Text(
                  'Data Management',
                  style: TextStyle(
                      fontSize: 22, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Seed realistic demo grievances or clear the database.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: _busy ? null : _seed,
                    icon: const Icon(Icons.dataset_rounded),
                    label: const Text('Add Realistic Sample Data'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E8E3E),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton.icon(
                    onPressed: _busy ? null : _clearAll,
                    icon: const Icon(Icons.delete_sweep_rounded,
                        color: Color(0xFFD93025)),
                    label: const Text(
                      'Clear All Grievances',
                      style: TextStyle(color: Color(0xFFD93025)),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFD93025)),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                if (_busy)
                  const CircularProgressIndicator()
                else if (_status.isNotEmpty)
                  Text(
                    _status,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 13),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}