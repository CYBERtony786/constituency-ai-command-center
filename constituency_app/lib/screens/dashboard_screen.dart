// File: lib/screens/dashboard_screen.dart

import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../services/app_localizations.dart';
import '../services/gemini_service.dart';
import '../services/status_helper.dart';

class DashboardScreen extends StatefulWidget {
  final String localeCode;

  const DashboardScreen({
    super.key,
    this.localeCode = 'hi',
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String? aiBriefing;
  bool isLoadingBriefing = false;
  final GeminiService _gemini = GeminiService();

  AppLocalizations get loc => AppLocalizations(widget.localeCode);

  static const Color _primary = Color(0xFF2563EB);
  static const Color _border = Color(0xFFE5EAF1);
  static const Color _textDark = Color(0xFF0F1F3D);
  static const Color _textGrey = Color(0xFF5B6B84);
  static const Color _purple = Color(0xFF9334E6);
  static const Color _red = Color(0xFFD93025);
  static const Color _green = Color(0xFF1E8E3E);

  // ═══════════════════════════════════════════════════════════
  // DASHBOARD-SPECIFIC TRANSLATIONS (all 11 languages)
  // These are keys NOT present in app_localizations.dart,
  // so they live here to keep everything in one file.
  // ═══════════════════════════════════════════════════════════
  String _dt(String key) {
    const Map<String, Map<String, String>> m = {
      'legend_low': {
        'en': 'Low', 'hi': 'कम', 'ta': 'குறைவு', 'te': 'తక్కువ',
        'bn': 'কম', 'mr': 'कमी', 'gu': 'ઓછું', 'kn': 'ಕಡಿಮೆ',
        'ml': 'കുറവ്', 'pa': 'ਘੱਟ', 'or': 'କମ୍',
      },
      'legend_medium': {
        'en': 'Medium', 'hi': 'मध्यम', 'ta': 'நடுத்தர', 'te': 'మధ్యస్థ',
        'bn': 'মাঝারি', 'mr': 'मध्यम', 'gu': 'મધ્યમ', 'kn': 'ಮಧ್ಯಮ',
        'ml': 'ഇടത്തരം', 'pa': 'ਮੱਧਮ', 'or': 'ମଧ୍ୟମ',
      },
      'legend_high': {
        'en': 'High', 'hi': 'उच्च', 'ta': 'அதிக', 'te': 'అధిక',
        'bn': 'উচ্চ', 'mr': 'जास्त', 'gu': 'વધુ', 'kn': 'ಹೆಚ್ಚು',
        'ml': 'കൂടുതൽ', 'pa': 'ਵੱਧ', 'or': 'ଅଧିକ',
      },
      'issues_word': {
        'en': 'issues', 'hi': 'मामले', 'ta': 'சிக்கல்கள்', 'te': 'సమస్యలు',
        'bn': 'সমস্যা', 'mr': 'समस्या', 'gu': 'મુદ્દા', 'kn': 'ಸಮಸ್ಯೆಗಳು',
        'ml': 'പ്രശ്നങ്ങൾ', 'pa': 'ਮੁੱਦੇ', 'or': 'ସମସ୍ୟା',
      },
      'map_empty_title': {
        'en': 'Map will populate as complaints arrive',
        'hi': 'शिकायतें आने पर नक्शा भर जाएगा',
        'ta': 'புகார்கள் வரும்போது வரைபடம் நிரம்பும்',
        'te': 'ఫిర్యాదులు వచ్చినప్పుడు మ్యాప్ నిండుతుంది',
        'bn': 'অভিযোগ আসলে মানচিত্র পূর্ণ হবে',
        'mr': 'तक्रारी आल्यावर नकाशा भरेल',
        'gu': 'ફરિયાદો આવશે ત્યારે નકશો ભરાશે',
        'kn': 'ದೂರುಗಳು ಬಂದಾಗ ನಕ್ಷೆ ತುಂಬುತ್ತದೆ',
        'ml': 'പരാതികൾ വരുമ്പോൾ ഭൂപടം നിറയും',
        'pa': 'ਸ਼ਿਕਾਇਤਾਂ ਆਉਣ ਨਾਲ ਨਕਸ਼ਾ ਭਰ ਜਾਵੇਗਾ',
        'or': 'ଅଭିଯୋଗ ଆସିଲେ ମାନଚିତ୍ର ଭରିଯିବ',
      },
      'map_empty_sub': {
        'en': 'Ward hotspots update in real time',
        'hi': 'वार्ड हॉटस्पॉट रियल टाइम में अपडेट होते हैं',
        'ta': 'வார்டு ஹாட்ஸ்பாட்கள் நேரடியாக புதுப்பிக்கப்படும்',
        'te': 'వార్డ్ హాట్‌స్పాట్‌లు రియల్ టైమ్‌లో అప్‌డేట్ అవుతాయి',
        'bn': 'ওয়ার্ড হটস্পট রিয়েল টাইমে আপডেট হয়',
        'mr': 'वॉर्ड हॉटस्पॉट रिअल टाइममध्ये अपडेट होतात',
        'gu': 'વોર્ડ હોટસ્પોટ રિયલ ટાઇમમાં અપડેટ થાય છે',
        'kn': 'ವಾರ್ಡ್ ಹಾಟ್‌ಸ್ಪಾಟ್‌ಗಳು ನೈಜ ಸಮಯದಲ್ಲಿ ನವೀಕರಿಸಲಾಗುತ್ತವೆ',
        'ml': 'വാർഡ് ഹോട്ട്‌സ്പോട്ടുകൾ തത്സമയം അപ്ഡേറ്റ് ചെയ്യപ്പെടും',
        'pa': 'ਵਾਰਡ ਹਾਟਸਪੌਟ ਰੀਅਲ ਟਾਈਮ ਵਿੱਚ ਅਪਡੇਟ ਹੁੰਦੇ ਹਨ',
        'or': 'ୱାର୍ଡ ହଟସ୍ପଟ ରିୟଲ ଟାଇମରେ ଅପଡେଟ ହୁଏ',
      },
      'map_info': {
        'en': 'Color intensity reflects complaint density in each ward.',
        'hi': 'रंग की तीव्रता प्रत्येक वार्ड में शिकायत घनत्व दर्शाती है।',
        'ta': 'நிற தீவிரம் ஒவ்வொரு வார்டிலும் புகார் அடர்த்தியைக் காட்டுகிறது.',
        'te': 'రంగు తీవ్రత ప్రతి వార్డులో ఫిర్యాదు సాంద్రతను చూపిస్తుంది.',
        'bn': 'রঙের তীব্রতা প্রতিটি ওয়ার্ডে অভিযোগের ঘনত্ব দেখায়।',
        'mr': 'रंगाची तीव्रता प्रत्येक प्रभागातील तक्रार घनता दर्शवते.',
        'gu': 'રંગની તીવ્રતા દરેક વોર્ડમાં ફરિયાદની ઘનતા દર્શાવે છે.',
        'kn': 'ಬಣ್ಣದ ತೀವ್ರತೆ ಪ್ರತಿ ವಾರ್ಡ್‌ನಲ್ಲಿ ದೂರು ಸಾಂದ್ರತೆಯನ್ನು ತೋರಿಸುತ್ತದೆ.',
        'ml': 'നിറത്തിന്റെ തീവ്രത ഓരോ വാർഡിലെയും പരാതി സാന്ദ്രത കാണിക്കുന്നു.',
        'pa': 'ਰੰਗ ਦੀ ਤੀਬ੍ਰਤਾ ਹਰ ਵਾਰਡ ਵਿੱਚ ਸ਼ਿਕਾਇਤ ਘਣਤਾ ਦਰਸਾਉਂਦੀ ਹੈ।',
        'or': 'ରଙ୍ଗର ତୀବ୍ରତା ପ୍ରତ୍ୟେକ ୱାର୍ଡରେ ଅଭିଯୋଗ ଘନତ୍ୱ ଦର୍ଶାଏ।',
      },
      'urgent_title': {
        'en': 'Urgent Issues Require Attention',
        'hi': 'अत्यावश्यक मामलों पर ध्यान आवश्यक',
        'ta': 'அவசர சிக்கல்களுக்கு கவனம் தேவை',
        'te': 'అత్యవసర సమస్యలకు శ్రద్ధ అవసరం',
        'bn': 'জরুরি সমস্যাগুলোর দিকে মনোযোগ প্রয়োজন',
        'mr': 'तातडीच्या समस्यांकडे लक्ष देणे आवश्यक',
        'gu': 'તાત્કાલિક મુદ્દાઓ પર ધ્યાન જરૂરી',
        'kn': 'ತುರ್ತು ಸಮಸ್ಯೆಗಳಿಗೆ ಗಮನ ಅಗತ್ಯ',
        'ml': 'അടിയന്തര പ്രശ്നങ്ങൾക്ക് ശ്രദ്ധ ആവശ്യമാണ്',
        'pa': 'ਤੁਰੰਤ ਮੁੱਦਿਆਂ ਵੱਲ ਧਿਆਨ ਚਾਹੀਦਾ ਹੈ',
        'or': 'ଜରୁରୀ ସମସ୍ୟା ଉପରେ ଧ୍ୟାନ ଆବଶ୍ୟକ',
      },
      'urgent_sub': {
        'en': 'High-priority grievances flagged by AI',
        'hi': 'AI द्वारा चिह्नित उच्च प्राथमिकता शिकायतें',
        'ta': 'AI கொடி பொருத்தப்பட்ட அதிக முன்னுரிமை புகார்கள்',
        'te': 'AI ద్వారా గుర్తించబడిన అధిక ప్రాధాన్యత ఫిర్యాదులు',
        'bn': 'AI দ্বারা চিহ্নিত উচ্চ অগ্রাধিকার অভিযোগ',
        'mr': 'AI द्वारे चिन्हांकित उच्च प्राधान्य तक्रारी',
        'gu': 'AI દ્વારા ફ્લેગ કરેલી ઉચ્ચ પ્રાથમિકતા ફરિયાદો',
        'kn': 'AI ಯಿಂದ ಗುರುತಿಸಲಾದ ಹೆಚ್ಚಿನ ಆದ್ಯತೆಯ ದೂರುಗಳು',
        'ml': 'AI ഫ്ലാഗ് ചെയ്ത ഉയർന്ന മുൻഗണനാ പരാതികൾ',
        'pa': 'AI ਦੁਆਰਾ ਫਲੈਗ ਕੀਤੀਆਂ ਉੱਚ ਤਰਜੀਹੀ ਸ਼ਿਕਾਇਤਾਂ',
        'or': 'AI ଦ୍ୱାରା ଚିହ୍ନିତ ଉଚ୍ଚ ପ୍ରାଥମିକତା ଅଭିଯୋଗ',
      },
      'no_unresolved': {
        'en': 'No unresolved complaints',
        'hi': 'कोई अनसुलझी शिकायत नहीं',
        'ta': 'தீர்க்கப்படாத புகார்கள் இல்லை',
        'te': 'పరిష్కరించని ఫిర్యాదులు లేవు',
        'bn': 'কোনো অমীমাংসিত অভিযোগ নেই',
        'mr': 'निकाली नसलेल्या तक्रारी नाहीत',
        'gu': 'કોઈ અનસુલઝી ફરિયાદ નથી',
        'kn': 'ಪರಿಹರಿಸದ ದೂರುಗಳಿಲ್ಲ',
        'ml': 'പരിഹരിക്കാത്ത പരാതികളില്ല',
        'pa': 'ਕੋਈ ਨਾ ਸੁਲਝੀ ਸ਼ਿਕਾਇਤ ਨਹੀਂ',
        'or': 'କୌଣସି ଅସୁଲଝା ଅଭିଯୋଗ ନାହିଁ',
      },
      'all_processing': {
        'en': 'All grievances are currently being processed.',
        'hi': 'सभी शिकायतों पर कार्य चल रहा है।',
        'ta': 'அனைத்து புகார்களும் தற்போது செயலாக்கப்படுகின்றன.',
        'te': 'అన్ని ఫిర్యాదులు ప్రస్తుతం ప్రాసెస్ చేయబడుతున్నాయి.',
        'bn': 'সকল অভিযোগ বর্তমানে প্রক্রিয়াধীন।',
        'mr': 'सर्व तक्रारींवर प्रक्रिया सुरू आहे.',
        'gu': 'તમામ ફરિયાદો પર પ્રક્રિયા ચાલી રહી છે.',
        'kn': 'ಎಲ್ಲಾ ದೂರುಗಳು ಪ್ರಸ್ತುತ ಪ್ರಕ್ರಿಯೆಯಲ್ಲಿವೆ.',
        'ml': 'എല്ലാ പരാതികളും പ്രോസസ്സ് ചെയ്യപ്പെടുകയാണ്.',
        'pa': 'ਸਾਰੀਆਂ ਸ਼ਿਕਾਇਤਾਂ ਦਾ ਇਲਾਜ ਹੋ ਰਿਹਾ ਹੈ।',
        'or': 'ସମସ୍ତ ଅଭିଯୋଗ ପ୍ରକ୍ରିୟାଧୀନ ଅଛି।',
      },
      'table_category': {
        'en': 'CATEGORY', 'hi': 'श्रेणी', 'ta': 'வகை', 'te': 'వర్గం',
        'bn': 'বিভাগ', 'mr': 'श्रेणी', 'gu': 'શ્રેણી', 'kn': 'ವರ್ಗ',
        'ml': 'വിഭാഗം', 'pa': 'ਸ਼੍ਰੇਣੀ', 'or': 'ଶ୍ରେଣୀ',
      },
      'table_share': {
        'en': 'SHARE', 'hi': 'हिस्सा', 'ta': 'பங்கு', 'te': 'వాటా',
        'bn': 'অংশ', 'mr': 'वाटा', 'gu': 'હિસ્સો', 'kn': 'ಪಾಲು',
        'ml': 'ഷെയർ', 'pa': 'ਹਿੱਸਾ', 'or': 'ଅଂଶ',
      },
      'table_count': {
        'en': 'COUNT', 'hi': 'संख्या', 'ta': 'எண்ணிக்கை', 'te': 'సంఖ్య',
        'bn': 'সংখ্যা', 'mr': 'संख्या', 'gu': 'સંખ્યા', 'kn': 'ಸಂಖ್ಯೆ',
        'ml': 'എണ്ണം', 'pa': 'ਗਿਣਤੀ', 'or': 'ସଂଖ୍ୟା',
      },
      'no_category_data': {
        'en': 'No category data yet',
        'hi': 'अभी कोई श्रेणी डेटा नहीं',
        'ta': 'இன்னும் வகை தரவு இல்லை',
        'te': 'ఇంకా వర్గం డేటా లేదు',
        'bn': 'এখনও কোনো বিভাগ ডেটা নেই',
        'mr': 'अद्याप श्रेणी डेटा नाही',
        'gu': 'હજુ કોઈ શ્રેણી ડેટા નથી',
        'kn': 'ಇನ್ನೂ ವರ್ಗ ಡೇಟಾ ಇಲ್ಲ',
        'ml': 'ഇതുവരെ വിഭാഗ ഡാറ്റയില്ല',
        'pa': 'ਅਜੇ ਕੋਈ ਸ਼੍ਰੇਣੀ ਡਾਟਾ ਨਹੀਂ',
        'or': 'ଏପର୍ଯ୍ୟନ୍ତ କୌଣସି ଶ୍ରେଣୀ ଡାଟା ନାହିଁ',
      },
      'submit_to_see': {
        'en': 'Submit complaints to see breakdown.',
        'hi': 'विवरण देखने के लिए शिकायत दर्ज करें।',
        'ta': 'பிரிவைக் காண புகார்களைச் சமர்ப்பிக்கவும்.',
        'te': 'విభజన చూడటానికి ఫిర్యాదులు సమర్పించండి.',
        'bn': 'বিভাজন দেখতে অভিযোগ জমা দিন।',
        'mr': 'ब्रेकडाउन पाहण्यासाठी तक्रारी नोंदवा.',
        'gu': 'વિભાજન જોવા માટે ફરિયાદો નોંધો.',
        'kn': 'ವಿಭಜನೆಯನ್ನು ನೋಡಲು ದೂರುಗಳನ್ನು ಸಲ್ಲಿಸಿ.',
        'ml': 'വിശദാംശങ്ങൾ കാണാൻ പരാതികൾ സമർപ്പിക്കുക.',
        'pa': 'ਵੰਡ ਵੇਖਣ ਲਈ ਸ਼ਿਕਾਇਤਾਂ ਦਰਜ ਕਰੋ।',
        'or': 'ବିଭାଜନ ଦେଖିବା ପାଇଁ ଅଭିଯୋଗ ଦାଖଲ କରନ୍ତୁ।',
      },
      'stat_new': {
        'en': 'New', 'hi': 'नई', 'ta': 'புதிய', 'te': 'కొత్త',
        'bn': 'নতুন', 'mr': 'नवीन', 'gu': 'નવી', 'kn': 'ಹೊಸ',
        'ml': 'പുതിയ', 'pa': 'ਨਵੀਂ', 'or': 'ନୂଆ',
      },
    };
    return m[key]?[widget.localeCode] ?? m[key]?['en'] ?? key;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            loc.t('dashboard_title'),
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: _textDark,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            loc.t('dashboard_sub'),
            style: const TextStyle(fontSize: 13, color: _textGrey),
          ),

          const SizedBox(height: 24),

          _buildPriorityAlerts(),

          const SizedBox(height: 24),

          _buildBriefingCard(),

          const SizedBox(height: 24),

          Text(
            loc.t('grievance_overview'),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: _textDark,
            ),
          ),
          const SizedBox(height: 14),
          _buildLiveStats(),

          const SizedBox(height: 28),

          // ═══ CONSTITUENCY MAP ═══
          Text(
            loc.t('constituency_map'),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: _textDark,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            loc.t('map_subtitle'),
            style: const TextStyle(fontSize: 12, color: _textGrey),
          ),
          const SizedBox(height: 14),
          _buildConstituencyMap(),

          const SizedBox(height: 28),

          LayoutBuilder(
            builder: (context, c) {
              final bool wide = c.maxWidth > 780;

              if (wide) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: _sectionColumn(
                        title: loc.t('recent_complaints'),
                        child: _buildRecentComplaints(),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      flex: 2,
                      child: _sectionColumn(
                        title: loc.t('category_breakdown'),
                        child: _buildCategoryTable(),
                      ),
                    ),
                  ],
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionColumn(
                    title: loc.t('recent_complaints'),
                    child: _buildRecentComplaints(),
                  ),
                  const SizedBox(height: 28),
                  _sectionColumn(
                    title: loc.t('category_breakdown'),
                    child: _buildCategoryTable(),
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _sectionColumn({required String title, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: _textDark,
          ),
        ),
        const SizedBox(height: 14),
        child,
      ],
    );
  }

  // ═════════════════════════════════════════════════════════
  // CONSTITUENCY MAP (custom visual — no external API)
  // ═════════════════════════════════════════════════════════
  Widget _buildConstituencyMap() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('grievances').snapshots(),
      builder: (context, snapshot) {
        final Map<String, int> wardCounts = {};
        int high = 0;

        if (snapshot.hasData) {
          for (final doc in snapshot.data!.docs) {
            final data = doc.data() as Map<String, dynamic>;
            final loc = (data['location_text']?.toString() ?? 'Other').trim();
            wardCounts[loc] = (wardCounts[loc] ?? 0) + 1;

            final p = data['priority_score'] is int
                ? data['priority_score'] as int
                : int.tryParse(data['priority_score']?.toString() ?? '5') ?? 5;
            if (p >= 8) high++;
          }
        }

        final maxCount = wardCounts.values.isEmpty
            ? 1
            : wardCounts.values.reduce(math.max);

        final sorted = wardCounts.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));
        final wards = sorted.take(12).toList();

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _border),
          ),
          child: Column(
            children: [
              // Header + legend
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: _border)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: _primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.map_rounded,
                          size: 20, color: _primary),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${wardCounts.length} ${loc.t('active_zones')}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: _textDark,
                            ),
                          ),
                          Text(
                            '$high ${loc.t('issues_flagged')}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: _textGrey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Wrap(
                      spacing: 12,
                      children: [
                        _legendDot(_green, _dt('legend_low')),
                        _legendDot(
                            const Color(0xFFF29900), _dt('legend_medium')),
                        _legendDot(_red, _dt('legend_high')),
                      ],
                    ),
                  ],
                ),
              ),

              // Map grid
              Padding(
                padding: const EdgeInsets.all(20),
                child: wards.isEmpty
                    ? _emptyMap()
                    : LayoutBuilder(
                        builder: (context, c) {
                          final bool wide = c.maxWidth > 600;
                          final cols = wide ? 4 : 3;

                          return GridView.count(
                            crossAxisCount: cols,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            mainAxisExtent: 96,
                            children: wards.map((w) {
                              final intensity = w.value / maxCount;
                              final color = _heatColor(intensity);
                              return _mapCell(
                                name: w.key,
                                count: w.value,
                                color: color,
                                intensity: intensity,
                              );
                            }).toList(),
                          );
                        },
                      ),
              ),

              // Bottom summary
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: const BoxDecoration(
                  color: Color(0xFFF8FAFF),
                  border: Border(top: BorderSide(color: _border)),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline_rounded,
                        size: 15, color: _textGrey),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _dt('map_info'),
                        style:
                            const TextStyle(fontSize: 11.5, color: _textGrey),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: _purple.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'AI HEATMAP',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: _purple,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _legendDot(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: _textGrey,
          ),
        ),
      ],
    );
  }

  Widget _emptyMap() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Center(
        child: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: _primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child:
                  const Icon(Icons.map_rounded, size: 28, color: _primary),
            ),
            const SizedBox(height: 12),
            Text(
              _dt('map_empty_title'),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: _textDark,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _dt('map_empty_sub'),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 11, color: _textGrey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _mapCell({
    required String name,
    required int count,
    required Color color,
    required double intensity,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOut,
      builder: (context, v, _) {
        return Opacity(
          opacity: v,
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  color.withOpacity(0.15 + intensity * 0.35),
                  color.withOpacity(0.08 + intensity * 0.2),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: color.withOpacity(0.3 + intensity * 0.4),
                width: 1.2,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: _textDark,
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      '$count',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: color,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 3),
                      child: Text(
                        _dt('issues_word'),
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: _textGrey,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Color _heatColor(double intensity) {
    if (intensity >= 0.66) return _red;
    if (intensity >= 0.33) return const Color(0xFFF29900);
    return _green;
  }

  // ═════════════════════════════════════════════════════════
  // PRIORITY ALERTS
  // ═════════════════════════════════════════════════════════
  Widget _buildPriorityAlerts() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('grievances')
          .where('priority_score', isGreaterThanOrEqualTo: 8)
          .limit(3)
          .snapshots(),
      builder: (context, snapshot) {
        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) return const SizedBox.shrink();

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [_red.withOpacity(0.05), _red.withOpacity(0.02)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _red.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _red.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.warning_amber_rounded,
                        color: _red, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${docs.length} ${_dt('urgent_title')}',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: _textDark,
                          ),
                        ),
                        Text(
                          _dt('urgent_sub'),
                          style:
                              const TextStyle(fontSize: 12, color: _textGrey),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              ...docs.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final category = data['category']?.toString() ?? 'other';
                final location =
                    data['location_text']?.toString() ?? 'Unknown';
                final text =
                    data['complaint_text']?.toString() ?? 'No description';

                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      const Text('•  ',
                          style: TextStyle(
                              color: _red, fontWeight: FontWeight.w800)),
                      Expanded(
                        child: RichText(
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          text: TextSpan(
                            style: const TextStyle(
                              fontSize: 13,
                              color: _textDark,
                            ),
                            children: [
                              TextSpan(
                                text:
                                    '${_prettyCategory(category)} • $location — ',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w700),
                              ),
                              TextSpan(
                                text: text,
                                style: const TextStyle(color: _textGrey),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  // ═════════════════════════════════════════════════════════
  // BRIEFING
  // ═════════════════════════════════════════════════════════
  Widget _buildBriefingCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: aiBriefing != null ? _border : Colors.transparent,
                ),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF9334E6), Color(0xFFC084FC)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.auto_awesome_rounded,
                      color: Colors.white, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        loc.t('ai_briefing'),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: _textDark,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        loc.t('chat_powered'),
                        style: const TextStyle(fontSize: 12, color: _textGrey),
                      ),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: isLoadingBriefing ? null : _generateBriefing,
                  icon: isLoadingBriefing
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.bolt_rounded, size: 18),
                  label: Text(
                    isLoadingBriefing
                        ? loc.t('thinking')
                        : loc.t('generate'),
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _purple,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (aiBriefing != null && !isLoadingBriefing)
            Padding(
              padding: const EdgeInsets.all(18),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFAF5FF),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _purple.withOpacity(0.2)),
                ),
                child: Text(
                  aiBriefing!,
                  style: const TextStyle(
                    fontSize: 13.5,
                    height: 1.6,
                    color: _textDark,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _generateBriefing() async {
    setState(() {
      isLoadingBriefing = true;
      aiBriefing = null;
    });

    try {
      final QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('grievances').get();

      int total = snapshot.docs.length;
      int pending = 0;
      int resolved = 0;
      final Map<String, int> categoryCounts = {};

      for (final doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final status = data['status']?.toString() ?? 'submitted';
        if (status == 'resolved' || status == 'closed') {
          resolved++;
        } else {
          pending++;
        }
        final cat = data['category']?.toString() ?? 'other';
        categoryCounts[cat] = (categoryCounts[cat] ?? 0) + 1;
      }

      final briefing = await _gemini.generateDailyBriefing(
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
        aiBriefing = 'Error: $e';
        isLoadingBriefing = false;
      });
    }
  }

  // ═════════════════════════════════════════════════════════
  // LIVE STATS
  // ═════════════════════════════════════════════════════════
  Widget _buildLiveStats() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('grievances').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _skeletonStats();
        }
        if (snapshot.hasError) return Text('Error: ${snapshot.error}');

        int total = snapshot.data?.docs.length ?? 0;
        int submitted = 0;
        int inProgress = 0;
        int resolved = 0;

        if (snapshot.hasData) {
          for (final doc in snapshot.data!.docs) {
            final data = doc.data() as Map<String, dynamic>;
            final s = data['status']?.toString() ?? 'submitted';
            if (s == 'resolved' || s == 'closed') {
              resolved++;
            } else if (s == 'in_progress' ||
                s == 'assigned' ||
                s == 'processed') {
              inProgress++;
            } else {
              submitted++;
            }
          }
        }

        final cards = [
          _statCard(loc.t('stat_total'), '$total',
              Icons.inventory_2_rounded, _primary),
          _statCard(_dt('stat_new'), '$submitted', Icons.inbox_rounded,
              const Color(0xFFF29900)),
          _statCard(loc.t('in_progress_status'), '$inProgress',
              Icons.autorenew_rounded, const Color(0xFFE65100)),
          _statCard(loc.t('stat_resolved'), '$resolved',
              Icons.verified_rounded, const Color(0xFF1E8E3E)),
        ];

        return LayoutBuilder(
          builder: (context, c) {
            final bool twoCol = c.maxWidth < 620;
            return GridView.count(
              crossAxisCount: twoCol ? 2 : 4,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              mainAxisExtent: 96,
              children: cards,
            );
          },
        );
      },
    );
  }

  Widget _skeletonStats() {
    return SizedBox(
      height: 96,
      child: Row(
        children: List.generate(
          4,
          (i) => Expanded(
            child: Container(
              margin: EdgeInsets.only(right: i < 3 ? 12 : 0),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _statCard(
      String label, String value, IconData icon, Color color) {
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
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 22, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TweenAnimationBuilder<int>(
                  tween: IntTween(
                    begin: 0,
                    end: int.tryParse(value.replaceAll('%', '')) ?? 0,
                  ),
                  duration: const Duration(milliseconds: 900),
                  curve: Curves.easeOutCubic,
                  builder: (context, v, _) => Text(
                    value.endsWith('%') ? '$v%' : '$v',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: color,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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

  // ═════════════════════════════════════════════════════════
  // RECENT COMPLAINTS
  // ═════════════════════════════════════════════════════════
  Widget _buildRecentComplaints() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('grievances')
          .orderBy('timestamp', descending: true)
          .limit(6)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _skeletonList();
        }
        if (snapshot.hasError) {
          return _emptyCard('Error: ${snapshot.error}');
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _emptyState(
            icon: Icons.celebration_rounded,
            color: const Color(0xFF1E8E3E),
            title: _dt('no_unresolved'),
            subtitle: _dt('all_processing'),
          );
        }

        return Column(
          children: snapshot.data!.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;

            final category = data['category']?.toString() ?? 'other';
            final rawStatus = data['status']?.toString() ?? 'submitted';
            final int priority = data['priority_score'] is int
                ? data['priority_score'] as int
                : int.tryParse(
                        data['priority_score']?.toString() ?? '5') ??
                    5;
            final location = data['location_text']?.toString() ?? 'Unknown';
            final text = data['complaint_text']?.toString() ?? 'No description';

            final ts = data['timestamp'];
            final DateTime? dt = ts is Timestamp ? ts.toDate() : null;
            final id = StatusHelper.formatId(doc.id);
            final statusColor = StatusHelper.color(rawStatus);
            final statusLabel = StatusHelper.label(rawStatus);
            final statusIcon = StatusHelper.icon(rawStatus);
            final priorityColor = StatusHelper.priorityColor(priority);
            final priorityLabel = StatusHelper.priorityLabel(priority);

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Material(
                color: Colors.white,
                clipBehavior: Clip.antiAlias,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: const BorderSide(color: _border),
                ),
                child: Theme(
                  data: Theme.of(context)
                      .copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    tilePadding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    childrenPadding:
                        const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    leading: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: _categoryColor(category).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(11),
                      ),
                      child: Icon(
                        _categoryIcon(category),
                        color: _categoryColor(category),
                        size: 20,
                      ),
                    ),
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF0F4FA),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                id,
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: _textGrey,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: priorityColor.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '$priorityLabel • $priority/10',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: priorityColor,
                                  letterSpacing: 0.4,
                                ),
                              ),
                            ),
                            const Spacer(),
                            Text(
                              StatusHelper.timeAgo(dt),
                              style: const TextStyle(
                                  fontSize: 11, color: _textGrey),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          text,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                            color: _textDark,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          _pill(
                            icon: Icons.category_rounded,
                            text: _prettyCategory(category),
                            color: _categoryColor(category),
                          ),
                          _pill(
                            icon: Icons.location_on_rounded,
                            text: location,
                            color: _textGrey,
                          ),
                          _pill(
                            icon: statusIcon,
                            text: statusLabel,
                            color: statusColor,
                          ),
                        ],
                      ),
                    ),
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFF),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: _border),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (data['ai_summary'] != null)
                              _analysisRow(
                                  'AI', data['ai_summary'].toString()),
                            if (data['ai_severity'] != null)
                              _analysisRow('Severity',
                                  data['ai_severity'].toString()),
                            if (data['ai_department'] != null)
                              _analysisRow('Department',
                                  data['ai_department'].toString()),
                            if (data['ai_actions'] is List &&
                                (data['ai_actions'] as List).isNotEmpty) ...[
                              const SizedBox(height: 6),
                              ...(data['ai_actions'] as List).map(
                                (a) => Padding(
                                  padding: const EdgeInsets.only(
                                      bottom: 4, left: 4),
                                  child: Text(
                                    '• $a',
                                    style: const TextStyle(
                                      fontSize: 12.5,
                                      color: _textGrey,
                                      height: 1.4,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _pill({
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 5),
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _analysisRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
            decoration: BoxDecoration(
              color: _primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: _primary,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 12.5,
                color: _textDark,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyCard(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _border),
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(color: _textGrey, fontSize: 13),
      ),
    );
  }

  Widget _emptyState({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _border),
      ),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 28, color: color),
          ),
          const SizedBox(height: 14),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: _textDark,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, color: _textGrey),
          ),
        ],
      ),
    );
  }

  Widget _skeletonList() {
    return Column(
      children: List.generate(
        3,
        (i) => Container(
          margin: const EdgeInsets.only(bottom: 12),
          height: 92,
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }

  // ═════════════════════════════════════════════════════════
  // CATEGORY TABLE
  // ═════════════════════════════════════════════════════════
  Widget _buildCategoryTable() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('grievances').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _skeletonList();
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _emptyState(
            icon: Icons.bar_chart_rounded,
            color: _primary,
            title: _dt('no_category_data'),
            subtitle: _dt('submit_to_see'),
          );
        }

        final Map<String, int> counts = {};
        for (final doc in snapshot.data!.docs) {
          final data = doc.data() as Map<String, dynamic>;
          final c = data['category']?.toString() ?? 'other';
          counts[c] = (counts[c] ?? 0) + 1;
        }

        final entries = counts.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));
        final total = snapshot.data!.docs.length;

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _border),
          ),
          child: Column(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: const BoxDecoration(
                  color: Color(0xFFF8FAFF),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(14),
                    topRight: Radius.circular(14),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Text(
                        _dt('table_category'),
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: _textGrey,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        _dt('table_share'),
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: _textGrey,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 44,
                      child: Text(
                        _dt('table_count'),
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: _textGrey,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              ...entries.asMap().entries.map((e) {
                final row = e.value;
                final pct = row.value / total;
                final color = _categoryColor(row.key);
                final isLast = e.key == entries.length - 1;

                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    border: isLast
                        ? null
                        : const Border(
                            bottom: BorderSide(color: _border),
                          ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Row(
                          children: [
                            Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                color: color.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                _categoryIcon(row.key),
                                size: 16,
                                color: color,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                _prettyCategory(row.key),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: _textDark,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: pct,
                            minHeight: 6,
                            backgroundColor: const Color(0xFFEFF2F7),
                            valueColor: AlwaysStoppedAnimation<Color>(color),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 44,
                        child: Text(
                          '${row.value}',
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: color,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  // ═════════════════════════════════════════════════════════
  // HELPERS (categories use app_localizations 11-language keys)
  // ═════════════════════════════════════════════════════════
  String _prettyCategory(String c) {
    switch (c) {
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

  Color _categoryColor(String category) {
    switch (category) {
      case 'roads':
        return const Color(0xFF795548);
      case 'water':
        return const Color(0xFF2563EB);
      case 'electricity':
        return const Color(0xFFF29900);
      case 'health':
        return const Color(0xFFD93025);
      case 'education':
        return const Color(0xFF1E8E3E);
      case 'sanitation':
        return const Color(0xFF00897B);
      case 'street_lights':
        return const Color(0xFFE65100);
      case 'drainage':
        return const Color(0xFF3949AB);
      case 'garbage':
        return const Color(0xFF5F6368);
      default:
        return const Color(0xFF9334E6);
    }
  }

  IconData _categoryIcon(String category) {
    switch (category) {
      case 'roads':
        return Icons.add_road_rounded;
      case 'water':
        return Icons.water_drop_rounded;
      case 'electricity':
        return Icons.electrical_services_rounded;
      case 'health':
        return Icons.local_hospital_rounded;
      case 'education':
        return Icons.school_rounded;
      case 'sanitation':
        return Icons.cleaning_services_rounded;
      case 'street_lights':
        return Icons.lightbulb_rounded;
      case 'drainage':
        return Icons.water_rounded;
      case 'garbage':
        return Icons.delete_outline_rounded;
      default:
        return Icons.more_horiz_rounded;
    }
  }
}