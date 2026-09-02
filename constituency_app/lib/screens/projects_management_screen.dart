// File: lib/screens/projects_management_screen.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../services/app_localizations.dart';

class ProjectsManagementScreen extends StatefulWidget {
  final String localeCode;

  const ProjectsManagementScreen({
    super.key,
    this.localeCode = 'hi',
  });

  @override
  State<ProjectsManagementScreen> createState() =>
      _ProjectsManagementScreenState();
}

class _ProjectsManagementScreenState extends State<ProjectsManagementScreen> {
  static const Color _primary = Color(0xFF2563EB);
  static const Color _border = Color(0xFFE5EAF1);
  static const Color _textDark = Color(0xFF0F1F3D);
  static const Color _textGrey = Color(0xFF5B6B84);

  bool _seeding = false;
  AppLocalizations get loc => AppLocalizations(widget.localeCode);

  // 11-Language Translations mapped correctly
  String _pt(String key) {
    const Map<String, Map<String, String>> translations = {
      'proj_title': {
        'en': 'Project Monitor', 'hi': 'परियोजना मॉनिटर', 'ta': 'திட்ட கண்காணிப்பு',
        'te': 'ప్రాజెక్ట్ మానిటర్', 'bn': 'প্রকল্প মনিটর', 'mr': 'प्रकल्प मॉनिटर',
        'gu': 'પ્રોજેક્ટ મોનિટર', 'kn': 'ಯೋಜನಾ ಮಾನಿಟರ್', 'ml': 'പ്രോജക്റ്റ് മോണിറ്റർ',
        'pa': 'ਪ੍ਰੋਜੈਕਟ ਮਾਨੀਟਰ', 'or': 'ପ୍ରକଳ୍ପ ମନିଟର',
      },
      'total': {
        'en': 'Total', 'hi': 'कुल', 'ta': 'மொத்தம்', 'te': 'మొత్తం',
        'bn': 'মোট', 'mr': 'एकूण', 'gu': 'કુલ', 'kn': 'ಒಟ್ಟು',
        'ml': 'മൊത്തം', 'pa': 'ਕੁੱਲ', 'or': 'ମୋଟ',
      },
      'active': {
        'en': 'Active', 'hi': 'सक्रिय', 'ta': 'செயலில்', 'te': 'క్రియాశీల',
        'bn': 'সক্রিয়', 'mr': 'सक्रिय', 'gu': 'સક્રિય', 'kn': 'ಸಕ್ರಿಯ',
        'ml': 'സജീവം', 'pa': 'ਸਰਗਰਮ', 'or': 'ସକ୍ରିୟ',
      },
      'done': {
        'en': 'Done', 'hi': 'पूरा हुआ', 'ta': 'முடிந்தது', 'te': 'పూర్తయింది',
        'bn': 'সম্পন্ন', 'mr': 'पूर्ण झाले', 'gu': 'પૂર્ણ થયું', 'kn': 'ಮುಗಿದಿದೆ',
        'ml': 'പൂർത്തിയായി', 'pa': 'ਹੋ ਗਿਆ', 'or': 'ସମ୍ପନ୍ନ',
      },
      'delayed': {
        'en': 'Delayed', 'hi': 'विलंबित', 'ta': 'தாமதம்', 'te': 'ఆలస్యం',
        'bn': 'বিলম্বিত', 'mr': 'विलंबित', 'gu': 'વિલંબિત', 'kn': 'ವಿಳಂಬವಾಗಿದೆ',
        'ml': 'വൈകി', 'pa': 'ਦੇਰੀ ਨਾਲ', 'or': 'ବିଳମ୍ବିତ',
      },
      'total_budget': {
        'en': 'Total Budget', 'hi': 'कुल बजट', 'ta': 'மொத்த பட்ஜெட்', 'te': 'మొత్తం బడ్జెట్',
        'bn': 'মোট বাজেট', 'mr': 'एकूण बजेट', 'gu': 'કુલ બજેટ', 'kn': 'ಒಟ್ಟು ಬಜೆಟ್',
        'ml': 'മൊത്തം ബഡ്ജറ്റ്', 'pa': 'ਕੁੱਲ ਬਜਟ', 'or': 'ମୋଟ ବଜେଟ୍',
      },
      'lakhs': {
        'en': 'L', 'hi': 'लाख', 'ta': 'லட்சம்', 'te': 'లక్షలు',
        'bn': 'লক্ষ', 'mr': 'लाख', 'gu': 'લાખ', 'kn': 'ಲಕ್ಷ',
        'ml': 'ലക്ഷം', 'pa': 'ਲੱਖ', 'or': 'ଲକ୍ଷ',
      },
      'no_projects': {
        'en': 'No projects yet', 'hi': 'अभी कोई परियोजना नहीं', 'ta': 'இன்னும் திட்டங்கள் இல்லை',
        'te': 'ఇంకా ప్రాజెక్టులు లేవు', 'bn': 'এখনও কোনো প্রকল্প নেই', 'mr': 'अद्याप कोणतेही प्रकल्प नाहीत',
        'gu': 'હજુ કોઈ પ્રોજેક્ટ નથી', 'kn': 'ಇನ್ನೂ ಯಾವುದೇ ಯೋಜನೆಗಳಿಲ್ಲ', 'ml': 'ഇതുവരെ പ്രോജക്റ്റുകളൊന്നുമില്ല',
        'pa': 'ਅਜੇ ਕੋਈ ਪ੍ਰੋਜੈਕਟ ਨਹੀਂ', 'or': 'ଏପର୍ଯ୍ୟନ୍ତ କୌଣସି ପ୍ରକଳ୍ପ ନାହିଁ',
      },
      'unnamed': {
        'en': 'Unnamed Project', 'hi': 'अनामित परियोजना', 'ta': 'பெயரிடப்படாத திட்டம்',
        'te': 'పేరులేని ప్రాజెక్ట్', 'bn': 'নামহীন প্রকল্প', 'mr': 'अनामित प्रकल्प',
        'gu': 'અનામી પ્રોજેક્ટ', 'kn': 'ಹೆಸರಿಲ್ಲದ ಯೋಜನೆ', 'ml': 'പേരിടാത്ത പ്രോജക്റ്റ്',
        'pa': 'ਬੇਨਾਮ ਪ੍ਰੋਜੈਕਟ', 'or': 'ନାମବିହୀନ ପ୍ରକଳ୍ପ',
      },
      'progress': {
        'en': 'Progress', 'hi': 'प्रगति', 'ta': 'முன்னேற்றம்', 'te': 'ప్రగతి',
        'bn': 'অগ্রগতি', 'mr': 'प्रगती', 'gu': 'પ્રગતિ', 'kn': 'ಪ್ರಗತಿ',
        'ml': 'പുരോഗതി', 'pa': 'ਪ੍ਰਗਤੀ', 'or': 'ପ୍ରଗତି',
      },
      'budget': {
        'en': 'Budget', 'hi': 'बजट', 'ta': 'பட்ஜெட்', 'te': 'బడ్జెట్',
        'bn': 'বাজেট', 'mr': 'बजेट', 'gu': 'બજેટ', 'kn': 'ಬಜೆಟ್',
        'ml': 'ബഡ്ജറ്റ്', 'pa': 'ਬਜਟ', 'or': 'ବଜେଟ୍',
      },
      'beneficiaries': {
        'en': 'Beneficiaries', 'hi': 'लाभार्थी', 'ta': 'பயனாளிகள்', 'te': 'లబ్ధిదారులు',
        'bn': 'উপকারভোগী', 'mr': 'लाभार्थी', 'gu': 'લાભાર્થીઓ', 'kn': 'ಫಲಾನುಭವಿಗಳು',
        'ml': 'ഗുണഭോക്താക്കൾ', 'pa': 'ਲਾਭਪਾਤਰੀ', 'or': 'ହିତାଧିକାରୀ',
      },
      'type': {
        'en': 'Type', 'hi': 'प्रकार', 'ta': 'வகை', 'te': 'రకం',
        'bn': 'প্রকার', 'mr': 'प्रकार', 'gu': 'પ્રકાર', 'kn': 'ಪ್ರಕಾರ',
        'ml': 'തരം', 'pa': 'ਕਿਸਮ', 'or': 'ପ୍ରକାର',
      },
      'people': {
        'en': 'people', 'hi': 'लोग', 'ta': 'மக்கள்', 'te': 'ప్రజలు',
        'bn': 'মানুষ', 'mr': 'लोक', 'gu': 'લોકો', 'kn': 'ಜನರು',
        'ml': 'ആളുകൾ', 'pa': 'ਲੋਕ', 'or': 'ଲୋକମାନେ',
      },
    };
    return translations[key]?[widget.localeCode] ?? translations[key]?['en'] ?? key;
  }

  final List<Map<String, dynamic>> _samples = [
    {
      'name': 'Ward 5 Main Road Resurfacing',
      'category': 'roads',
      'location': 'Ward 5',
      'budget_lakh': 65.0,
      'progress': 72,
      'status': 'in_progress',
      'beneficiaries': 12000,
      'contractor': 'Ravi Infra Pvt Ltd',
    },
    {
      'name': 'Village Rampur Water Pipeline',
      'category': 'water',
      'location': 'Village Rampur',
      'budget_lakh': 120.0,
      'progress': 38,
      'status': 'in_progress',
      'beneficiaries': 25000,
      'contractor': 'Jal Seva Contractors',
    },
    {
      'name': 'PHC Ward 2 Upgrade',
      'category': 'health',
      'location': 'Ward 2',
      'budget_lakh': 45.0,
      'progress': 90,
      'status': 'in_progress',
      'beneficiaries': 18000,
      'contractor': 'MedBuild India',
    },
    {
      'name': 'NH Stretch Street Lighting',
      'category': 'street_lights',
      'location': 'NH Bypass',
      'budget_lakh': 22.0,
      'progress': 100,
      'status': 'completed',
      'beneficiaries': 9000,
      'contractor': 'BrightWay Electricals',
    },
    {
      'name': 'Primary School Roof Repair',
      'category': 'education',
      'location': 'Ward 8',
      'budget_lakh': 15.0,
      'progress': 45,
      'status': 'delayed',
      'beneficiaries': 850,
      'contractor': 'Shiksha Builders',
    },
    {
      'name': 'Ward 9 Drainage Network',
      'category': 'drainage',
      'location': 'Ward 9',
      'budget_lakh': 80.0,
      'progress': 20,
      'status': 'delayed',
      'beneficiaries': 14000,
      'contractor': 'AquaDrain Co.',
    },
  ];

  Future<void> _seedIfEmpty() async {
    setState(() => _seeding = true);
    try {
      final snap =
          await FirebaseFirestore.instance.collection('projects').limit(1).get();
      if (snap.docs.isEmpty) {
        final batch = FirebaseFirestore.instance.batch();
        final col = FirebaseFirestore.instance.collection('projects');
        for (final p in _samples) {
          final ref = col.doc();
          batch.set(ref, {
            ...p,
            'created_at': FieldValue.serverTimestamp(),
            'updated_at': FieldValue.serverTimestamp(),
          });
        }
        await batch.commit();
      }
    } catch (_) {
      // ignore
    }
    if (mounted) setState(() => _seeding = false);
  }

  @override
  void initState() {
    super.initState();
    _seedIfEmpty();
  }

  Color _statusColor(String s) {
    switch (s) {
      case 'completed':
        return const Color(0xFF1E8E3E);
      case 'delayed':
        return const Color(0xFFD93025);
      case 'in_progress':
        return const Color(0xFF2563EB);
      default:
        return const Color(0xFFF29900);
    }
  }

  String _statusLabel(String s) {
    switch (s) {
      case 'completed':
        return _pt('done').toUpperCase();
      case 'delayed':
        return _pt('delayed').toUpperCase();
      case 'in_progress':
        return _pt('active').toUpperCase();
      default:
        return s.toUpperCase();
    }
  }

  String _localizedCategory(String category) {
    switch (category) {
      case 'roads': return loc.t('cat_roads');
      case 'water': return loc.t('cat_water');
      case 'electricity': return loc.t('cat_electricity');
      case 'health': return loc.t('cat_health');
      case 'education': return loc.t('cat_education');
      case 'sanitation': return loc.t('cat_sanitation');
      case 'street_lights': return loc.t('cat_lights');
      case 'drainage': return loc.t('cat_drainage');
      case 'garbage': return loc.t('cat_garbage');
      default: return loc.t('cat_other');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FB),
      appBar: AppBar(
        title: Text(loc.t('projects_title')),
        backgroundColor: const Color(0xFF0A1F44),
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('projects').snapshots(),
        builder: (context, snapshot) {
          if (_seeding || snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data?.docs ?? [];

          int total = docs.length;
          int completed = 0;
          int delayed = 0;
          int active = 0;
          double budget = 0;

          for (final d in docs) {
            final data = d.data() as Map<String, dynamic>;
            final s = data['status']?.toString() ?? '';
            if (s == 'completed') {
              completed++;
            } else if (s == 'delayed') {
              delayed++;
            } else {
              active++;
            }
            budget += (data['budget_lakh'] is num)
                ? (data['budget_lakh'] as num).toDouble()
                : 0;
          }

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1100),
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  Text(
                    loc.t('projects_title'),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: _textDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    loc.t('projects_sub'),
                    style: const TextStyle(fontSize: 13, color: _textGrey),
                  ),
                  const SizedBox(height: 20),

                  // Summary cards
                  LayoutBuilder(
                    builder: (context, c) {
                      final cols = c.maxWidth > 700 ? 4 : 2;
                      return GridView.count(
                        crossAxisCount: cols,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        mainAxisExtent: 100,
                        children: [
                          _sumCard(_pt('total'), '$total', Icons.folder_rounded, _primary),
                          _sumCard(_pt('active'), '$active', Icons.play_circle_rounded, const Color(0xFF2563EB)),
                          _sumCard(_pt('delayed'), '$delayed', Icons.warning_rounded, const Color(0xFFD93025)),
                          _sumCard(_pt('budget'), '₹${budget.toStringAsFixed(0)} ${_pt('lakhs')}', Icons.currency_rupee_rounded, const Color(0xFF1E8E3E)),
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 24),

                  if (docs.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: _border),
                      ),
                      child: Center(
                        child: Text(
                          _pt('no_projects'),
                          style: const TextStyle(color: _textGrey),
                        ),
                      ),
                    )
                  else
                    ...docs.map((doc) {
                      final p = doc.data() as Map<String, dynamic>;
                      final status = p['status']?.toString() ?? 'in_progress';
                      final progress = p['progress'] is int
                          ? p['progress'] as int
                          : int.tryParse(p['progress']?.toString() ?? '0') ?? 0;
                      final budgetL = (p['budget_lakh'] is num)
                          ? (p['budget_lakh'] as num).toDouble()
                          : 0.0;
                      final color = _statusColor(status);

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: _border),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    p['name']?.toString() ?? _pt('unnamed'),
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800,
                                      color: _textDark,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: color.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    _statusLabel(status),
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      color: color,
                                      letterSpacing: 0.4,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${p['location'] ?? '-'}  •  ${p['contractor'] ?? '-'}  •  ₹${budgetL.toStringAsFixed(0)} ${_pt('lakhs')}  •  ${p['beneficiaries'] ?? 0} ${_pt('people')}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: _textGrey,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(6),
                                    child: LinearProgressIndicator(
                                      value: (progress / 100).clamp(0.0, 1.0),
                                      minHeight: 8,
                                      backgroundColor: const Color(0xFFEFF2F7),
                                      valueColor: AlwaysStoppedAnimation<Color>(color),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  '$progress%',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                    color: color,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildProjectDetailItem(Icons.currency_rupee, '₹${budgetL.toStringAsFixed(1)} ${_pt('lakhs')}', _pt('budget')),
                                _buildProjectDetailItem(Icons.people, '${p['beneficiaries'] ?? 0}', _pt('beneficiaries')),
                                _buildProjectDetailItem(Icons.category, _localizedCategory(p['category']?.toString() ?? ''), _pt('type')),
                              ],
                            ),
                          ],
                        ),
                      );
                    }),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProjectDetailItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, size: 18, color: Colors.grey[600]),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
      ],
    );
  }

  Widget _sumCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: _textGrey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}