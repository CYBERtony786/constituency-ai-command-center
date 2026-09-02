// File: lib/screens/chat_screen.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../services/app_localizations.dart';
import '../services/gemini_service.dart';
import '../services/status_helper.dart';

// ═════════════════════════════════════════════════════════════
// CHAT-SPECIFIC TRANSLATIONS (Shared between Chat + Context Panel)
// ═════════════════════════════════════════════════════════════
class _ChatL10n {
  static String get(String key, String localeCode) {
    return _map[key]?[localeCode] ?? _map[key]?['en'] ?? key;
  }

  static const Map<String, Map<String, String>> _map = {
    'governance_briefing': {
      'en': 'Governance Briefing', 'hi': 'शासन ब्रीफिंग', 'ta': 'ஆளுமை சுருக்கம்',
      'te': 'పాలన బ్రీఫింగ్', 'bn': 'শাসন ব্রিফিং', 'mr': 'शासन माहिती',
      'gu': 'શાસન બ્રીફિંગ', 'kn': 'ಆಡಳಿತ ಬ್ರೀಫಿಂಗ್', 'ml': 'ഭരണ ബ്രീഫിംഗ്',
      'pa': 'ਸ਼ਾਸਨ ਬ੍ਰੀਫਿੰਗ', 'or': 'ଶାସନ ବ୍ରିଫିଂ',
    },
    'ai_generated': {
      'en': 'AI GENERATED', 'hi': 'AI द्वारा निर्मित', 'ta': 'AI உருவாக்கியது',
      'te': 'AI రూపొందించింది', 'bn': 'AI নির্মিত', 'mr': 'AI द्वारे तयार',
      'gu': 'AI જનરેટેડ', 'kn': 'AI ರಚಿಸಲಾಗಿದೆ', 'ml': 'AI ജനറേറ്റഡ്',
      'pa': 'AI ਦੁਆਰਾ ਬਣਾਇਆ', 'or': 'AI ଦ୍ୱାରା ପ୍ରସ୍ତୁତ',
    },
    'overview': {
      'en': 'Overview', 'hi': 'सारांश', 'ta': 'மேலோட்டம்',
      'te': 'అవలోకనం', 'bn': 'সারসংক্ষেপ', 'mr': 'आढावा',
      'gu': 'ઝલક', 'kn': 'ಅವಲೋಕನ', 'ml': 'അവലോകനം',
      'pa': 'ਸੰਖੇਪ', 'or': 'ସାରାଂଶ',
    },
    'critical_issues': {
      'en': 'Critical Issues', 'hi': 'गंभीर मुद्दे', 'ta': 'முக்கிய பிரச்சினைகள்',
      'te': 'క్లిష్టమైన సమస్యలు', 'bn': 'গুরুতর সমস্যা', 'mr': 'गंभीर समस्या',
      'gu': 'ગંભીર મુદ્દા', 'kn': 'ಗಂಭೀರ ಸಮಸ್ಯೆಗಳು', 'ml': 'ഗുരുതരമായ പ്രശ്നങ്ങൾ',
      'pa': 'ਗੰਭੀਰ ਮੁੱਦੇ', 'or': 'ଗୁରୁତର ସମସ୍ୟା',
    },
    'recommended_actions': {
      'en': 'Recommended Actions', 'hi': 'अनुशंसित कार्रवाई', 'ta': 'பரிந்துரைக்கப்பட்ட நடவடிக்கைகள்',
      'te': 'సిఫార్సు చేసిన చర్యలు', 'bn': 'প্রস্তাবিত পদক্ষেপ', 'mr': 'शिफारस केलेल्या कृती',
      'gu': 'ભલામણ કરેલી ક્રિયાઓ', 'kn': 'ಶಿಫಾರಸು ಮಾಡಿದ ಕ್ರಮಗಳು', 'ml': 'ശുപാർശ ചെയ്യുന്ന നടപടികൾ',
      'pa': 'ਸਿਫਾਰਸ਼ ਕੀਤੀਆਂ ਕਾਰਵਾਈਆਂ', 'or': 'ପରାମର୍ଶିତ କାର୍ଯ୍ୟ',
    },
    'budget_impact': {
      'en': 'Estimated Budget Impact', 'hi': 'अनुमानित बजट प्रभाव', 'ta': 'மதிப்பிடப்பட்ட பட்ஜெட் தாக்கம்',
      'te': 'అంచనా బడ్జెట్ ప్రభావం', 'bn': 'আনুমানিক বাজেট প্রভাব', 'mr': 'अंदाजित अर्थसंकल्प परिणाम',
      'gu': 'અંદાજિત બજેટ અસર', 'kn': 'ಅಂದಾಜು ಬಜೆಟ್ ಪರಿಣಾಮ', 'ml': 'ഏകദേശ ബഡ്ജറ്റ് പ്രഭാവം',
      'pa': 'ਅਨੁਮਾਨਿਤ ਬਜਟ ਪ੍ਰਭਾਵ', 'or': 'ଆନୁମାନିକ ବଜେଟ୍ ପ୍ରଭାବ',
    },
    'create_task': {
      'en': 'Create Task', 'hi': 'कार्य बनाएं', 'ta': 'பணியை உருவாக்கு',
      'te': 'పనిని సృష్టించండి', 'bn': 'কাজ তৈরি করুন', 'mr': 'कार्य तयार करा',
      'gu': 'કાર્ય બનાવો', 'kn': 'ಕಾರ್ಯ ರಚಿಸಿ', 'ml': 'ടാസ്ക് സൃഷ്ടിക്കുക',
      'pa': 'ਕੰਮ ਬਣਾਓ', 'or': 'କାର୍ଯ୍ୟ ସୃଷ୍ଟି କରନ୍ତୁ',
    },
    'assign_officer': {
      'en': 'Assign Officer', 'hi': 'अधिकारी नियुक्त करें', 'ta': 'அலுவலரை நியமிக்கவும்',
      'te': 'అధికారిని నియమించండి', 'bn': 'কর্মকর্তা নিযুক্ত করুন', 'mr': 'अधिकारी नियुक्त करा',
      'gu': 'અધિકારીને સોંપો', 'kn': 'ಅಧಿಕಾರಿಯನ್ನು ನಿಯೋಜಿಸಿ', 'ml': 'ഓഫീസറെ നിയോഗിക്കുക',
      'pa': 'ਅਧਿਕਾਰੀ ਨਿਯੁਕਤ ਕਰੋ', 'or': 'ଅଧିକାରୀ ନିଯୁକ୍ତ କରନ୍ତୁ',
    },
    'view_data': {
      'en': 'View Data', 'hi': 'डेटा देखें', 'ta': 'தரவைக் காண்க',
      'te': 'డేటాను చూడండి', 'bn': 'ডেটা দেখুন', 'mr': 'डेटा पहा',
      'gu': 'ડેટા જુઓ', 'kn': 'ಡೇಟಾ ವೀಕ್ಷಿಸಿ', 'ml': 'ഡാറ്റ കാണുക',
      'pa': 'ਡਾਟਾ ਵੇਖੋ', 'or': 'ଡାଟା ଦେଖନ୍ତୁ',
    },
    'generate_report': {
      'en': 'Generate Report', 'hi': 'रिपोर्ट बनाएं', 'ta': 'அறிக்கை உருவாக்கவும்',
      'te': 'నివేదిక రూపొందించండి', 'bn': 'রিপোর্ট তৈরি করুন', 'mr': 'अहवाल तयार करा',
      'gu': 'રિપોર્ટ બનાવો', 'kn': 'ವರದಿ ರಚಿಸಿ', 'ml': 'റിപ്പോർട്ട് സൃഷ്ടിക്കുക',
      'pa': 'ਰਿਪੋਰਟ ਬਣਾਓ', 'or': 'ରିପୋର୍ଟ ପ୍ରସ୍ତୁତ କରନ୍ତୁ',
    },
    'task_created': {
      'en': 'Task created', 'hi': 'कार्य बनाया गया', 'ta': 'பணி உருவாக்கப்பட்டது',
      'te': 'పని సృష్టించబడింది', 'bn': 'কাজ তৈরি হয়েছে', 'mr': 'कार्य तयार केले',
      'gu': 'કાર્ય બન્યું', 'kn': 'ಕಾರ್ಯ ರಚಿಸಲಾಗಿದೆ', 'ml': 'ടാസ്ക് സൃഷ്ടിച്ചു',
      'pa': 'ਕੰਮ ਬਣਾਇਆ ਗਿਆ', 'or': 'କାର୍ଯ୍ୟ ସୃଷ୍ଟି ହୋଇଛି',
    },
    'officer_assigned': {
      'en': 'Officer assignment opened', 'hi': 'अधिकारी नियुक्ति खुली', 'ta': 'அலுவலர் ஒதுக்கீடு திறக்கப்பட்டது',
      'te': 'అధికారి కేటాయింపు తెరవబడింది', 'bn': 'কর্মকর্তা নিয়োগ খুলেছে', 'mr': 'अधिकारी नियुक्ती उघडली',
      'gu': 'અધિકારી સોંપણી ખુલી', 'kn': 'ಅಧಿಕಾರಿ ನಿಯೋಜನೆ ತೆರೆಯಲಾಗಿದೆ', 'ml': 'ഓഫീസർ അസൈൻമെന്റ് തുറന്നു',
      'pa': 'ਅਧਿਕਾਰੀ ਨਿਯੁਕਤੀ ਖੁੱਲੀ', 'or': 'ଅଧିକାରୀ ନିଯୁକ୍ତି ଖୋଲାଗଲା',
    },
    'data_opened': {
      'en': 'Data drill-down opened', 'hi': 'डेटा विवरण खुला', 'ta': 'தரவு விவரம் திறக்கப்பட்டது',
      'te': 'డేటా వివరాలు తెరవబడ్డాయి', 'bn': 'ডেটা বিশ্লেষণ খুলেছে', 'mr': 'डेटा तपशील उघडला',
      'gu': 'ડેટા વિગત ખુલી', 'kn': 'ಡೇಟಾ ವಿವರ ತೆರೆಯಲಾಗಿದೆ', 'ml': 'ഡാറ്റ വിശദാംശം തുറന്നു',
      'pa': 'ਡਾਟਾ ਵੇਰਵਾ ਖੁੱਲਾ', 'or': 'ଡାଟା ବିବରଣୀ ଖୋଲାଗଲା',
    },
    'report_queued': {
      'en': 'Report queued', 'hi': 'रिपोर्ट कतार में', 'ta': 'அறிக்கை வரிசையில்',
      'te': 'నివేదిక క్యూలో ఉంది', 'bn': 'রিপোর্ট সারিবদ্ধ', 'mr': 'अहवाल रांगेत',
      'gu': 'રિપોર્ટ કતારમાં', 'kn': 'ವರದಿ ಕ್ಯೂನಲ್ಲಿದೆ', 'ml': 'റിപ്പോർട്ട് ക്യൂവിൽ',
      'pa': 'ਰਿਪੋਰਟ ਕਤਾਰ ਵਿੱਚ', 'or': 'ରିପୋର୍ଟ ଧାଡ଼ିରେ ଅଛି',
    },
    'active_grievances': {
      'en': 'Active grievances', 'hi': 'सक्रिय शिकायतें', 'ta': 'செயலில் உள்ள புகார்கள்',
      'te': 'క్రియాశీల ఫిర్యాదులు', 'bn': 'সক্রিয় অভিযোগ', 'mr': 'सक्रिय तक्रारी',
      'gu': 'સક્રિય ફરિયાદો', 'kn': 'ಸಕ್ರಿಯ ದೂರುಗಳು', 'ml': 'സജീവ പരാതികൾ',
      'pa': 'ਸਰਗਰਮ ਸ਼ਿਕਾਇਤਾਂ', 'or': 'ସକ୍ରିୟ ଅଭିଯୋଗ',
    },
    'high_priority': {
      'en': 'High priority', 'hi': 'उच्च प्राथमिकता', 'ta': 'அதிக முன்னுரிமை',
      'te': 'అధిక ప్రాధాన్యత', 'bn': 'উচ্চ অগ্রাধিকার', 'mr': 'उच्च प्राधान्य',
      'gu': 'ઉચ્ચ પ્રાથમિકતા', 'kn': 'ಹೆಚ್ಚಿನ ಆದ್ಯತೆ', 'ml': 'ഉയർന്ന മുൻഗണന',
      'pa': 'ਉੱਚ ਤਰਜੀਹ', 'or': 'ଉଚ୍ଚ ପ୍ରାଥମିକତା',
    },
    'in_progress': {
      'en': 'In progress', 'hi': 'प्रगति पर', 'ta': 'நடைபெறுகிறது',
      'te': 'పురోగతిలో', 'bn': 'প্রক্রিয়াধীন', 'mr': 'प्रगतीपथावर',
      'gu': 'પ્રગતિમાં', 'kn': 'ಪ್ರಗತಿಯಲ್ಲಿದೆ', 'ml': 'പുരോഗമിക്കുന്നു',
      'pa': 'ਪ੍ਰਗਤੀ ਵਿੱਚ', 'or': 'ଚାଲିଛି',
    },
    'resolved': {
      'en': 'Resolved', 'hi': 'निस्तारित', 'ta': 'தீர்க்கப்பட்டது',
      'te': 'పరిష్కరించబడింది', 'bn': 'সমাধান', 'mr': 'निराकरण',
      'gu': 'નિરાકરણ', 'kn': 'ಪರಿಹರಿಸಲಾಗಿದೆ', 'ml': 'പരിഹരിച്ചു',
      'pa': 'ਹੱਲ ਹੋਇਆ', 'or': 'ସମାଧାନ',
    },
    'constituency_context': {
      'en': 'CONSTITUENCY CONTEXT', 'hi': 'क्षेत्रीय संदर्भ', 'ta': 'தொகுதி சூழல்',
      'te': 'నియోజకవర్గం సందర్భం', 'bn': 'নির্বাচনী এলাকার প্রসঙ্গ', 'mr': 'मतदारसंघ संदर्भ',
      'gu': 'મતવિસ્તાર સંદર્ભ', 'kn': 'ಕ್ಷೇತ್ರದ ಸಂದರ್ಭ', 'ml': 'മണ്ഡല പശ്ചാത്തലം',
      'pa': 'ਹਲਕੇ ਦਾ ਸੰਦਰਭ', 'or': 'ନିର୍ବାଚନମଣ୍ଡଳୀ ପ୍ରସଙ୍ଗ',
    },
    'live_snapshot': {
      'en': 'Live snapshot', 'hi': 'लाइव स्नैपशॉट', 'ta': 'நேரடி சுருக்கம்',
      'te': 'ప్రత్యక్ష స్నాప్‌షాట్', 'bn': 'লাইভ স্ন্যাপশট', 'mr': 'थेट स्नॅपशॉट',
      'gu': 'લાઇવ સ્નેપશોટ', 'kn': 'ಲೈವ್ ಸ್ನ್ಯಾಪ್‌ಶಾಟ್', 'ml': 'തത്സമയ അവലോകനം',
      'pa': 'ਲਾਈਵ ਸਨੈਪਸ਼ਾਟ', 'or': 'ଲାଇଭ୍ ସ୍ନାପସଟ୍',
    },
    'resolution_rate': {
      'en': 'Resolution rate', 'hi': 'समाधान दर', 'ta': 'தீர்வு விகிதம்',
      'te': 'పరిష్కార రేటు', 'bn': 'সমাধানের হার', 'mr': 'निराकरण दर',
      'gu': 'ઉકેલ દર', 'kn': 'ಪರಿಹಾರ ದರ', 'ml': 'പരിഹാര നിരക്ക്',
      'pa': 'ਹੱਲ ਦਰ', 'or': 'ସମାଧାନ ହାର',
    },
    'recent_activity': {
      'en': 'RECENT ACTIVITY', 'hi': 'हाल की गतिविधि', 'ta': 'சமீபத்திய செயல்பாடு',
      'te': 'ఇటీవలి కార్యాచరణ', 'bn': 'সাম্প্রতিক কার্যক্রম', 'mr': 'अलीकडील क्रियाकलाप',
      'gu': 'તાજેતરની પ્રવૃત્તિ', 'kn': 'ಇತ್ತೀಚಿನ ಚಟುವಟಿಕೆ', 'ml': 'സമീപകാല പ്രവർത്തനം',
      'pa': 'ਹਾਲੀਆ ਗਤੀਵਿਧੀ', 'or': 'ସାମ୍ପ୍ରତିକ କାର୍ଯ୍ୟକଳାପ',
    },
    'no_recent_activity': {
      'en': 'No recent activity', 'hi': 'कोई हालिया गतिविधि नहीं', 'ta': 'சமீபத்திய செயல்பாடு இல்லை',
      'te': 'ఇటీవలి కార్యాచరణ లేదు', 'bn': 'কোনো সাম্প্রতিক কার্যক্রম নেই', 'mr': 'कोणतीही अलीकडील क्रियाकलाप नाही',
      'gu': 'કોઈ તાજેતરની પ્રવૃત્તિ નથી', 'kn': 'ಯಾವುದೇ ಇತ್ತೀಚಿನ ಚಟುವಟಿಕೆ ಇಲ್ಲ', 'ml': 'സമീപകാല പ്രവർത്തനങ്ങളില്ല',
      'pa': 'ਕੋਈ ਹਾਲੀਆ ਗਤੀਵਿਧੀ ਨਹੀਂ', 'or': 'କୌଣସି ସାମ୍ପ୍ରତିକ କାର୍ଯ୍ୟ ନାହିଁ',
    },
    'ai_tip': {
      'en': 'AI TIP', 'hi': 'AI सुझाव', 'ta': 'AI குறிப்பு',
      'te': 'AI చిట్కా', 'bn': 'AI টিপ', 'mr': 'AI टीप',
      'gu': 'AI ટિપ', 'kn': 'AI ಸಲಹೆ', 'ml': 'AI ടിപ്പ്',
      'pa': 'AI ਸੁਝਾਅ', 'or': 'AI ଟିପ୍',
    },
    'ai_tip_text': {
      'en': 'Ask "Give me a morning briefing" to get structured actions.',
      'hi': '"मुझे सुबह की ब्रीफिंग दें" पूछकर संरचित कार्रवाई प्राप्त करें।',
      'ta': '"காலை சுருக்கத்தை கொடு" என்று கேட்டு கட்டமைக்கப்பட்ட நடவடிக்கைகளைப் பெறுங்கள்.',
      'te': '"ఉదయ బ్రీఫింగ్ ఇవ్వండి" అని అడిగి నిర్మాణాత్మక చర్యలను పొందండి.',
      'bn': '"আমাকে সকালের ব্রিফিং দিন" জিজ্ঞাসা করে কাঠামোগত পদক্ষেপ পান।',
      'mr': '"मला सकाळची माहिती द्या" विचारून संरचित कृती मिळवा.',
      'gu': '"મને સવારની બ્રીફિંગ આપો" પૂછીને સંરચિત ક્રિયાઓ મેળવો.',
      'kn': '"ಬೆಳಗಿನ ಬ್ರೀಫಿಂಗ್ ನೀಡಿ" ಎಂದು ಕೇಳಿ ರಚನಾತ್ಮಕ ಕ್ರಿಯೆಗಳನ್ನು ಪಡೆಯಿರಿ.',
      'ml': '"രാവിലെ ബ്രീഫിംഗ് തരൂ" എന്ന് ചോദിച്ച് ഘടനാപരമായ നടപടികൾ നേടുക.',
      'pa': '"ਮੈਨੂੰ ਸਵੇਰ ਦੀ ਬ੍ਰੀਫਿੰਗ ਦਿਓ" ਪੁੱਛ ਕੇ ਢਾਂਚਾਗਤ ਕਾਰਵਾਈਆਂ ਪ੍ਰਾਪਤ ਕਰੋ।',
      'or': '"ମୋତେ ସକାଳ ବ୍ରିଫିଂ ଦିଅ" ପଚାରି ଗଠନମୂଳକ କାର୍ଯ୍ୟ ପାଆନ୍ତୁ।',
    },
    // Chat Suggestions
    'sug_briefing': {
      'en': 'Give me a morning briefing',
      'hi': 'मुझे सुबह की ब्रीफिंग दें',
      'ta': 'காலை சுருக்கத்தை கொடு',
      'te': 'ఉదయ బ్రీఫింగ్ ఇవ్వండి',
      'bn': 'আমাকে সকালের ব্রিফিং দিন',
      'mr': 'मला सकाळची माहिती द्या',
      'gu': 'મને સવારની બ્રીફિંગ આપો',
      'kn': 'ಬೆಳಗಿನ ಬ್ರೀಫಿಂಗ್ ನೀಡಿ',
      'ml': 'എനിക്ക് രാവിലെ ബ്രീഫിംഗ് തരൂ',
      'pa': 'ਮੈਨੂੰ ਸਵੇਰ ਦੀ ਬ੍ਰੀਫਿੰਗ ਦਿਓ',
      'or': 'ମୋତେ ସକାଳ ବ୍ରିଫିଂ ଦିଅ',
    },
    'sug_ward': {
      'en': 'Which ward needs urgent attention?',
      'hi': 'किस वार्ड को तत्काल ध्यान चाहिए?',
      'ta': 'எந்த வார்டுக்கு அவசர கவனம் தேவை?',
      'te': 'ఏ వార్డ్‌కు అత్యవసర దృష్టి అవసరం?',
      'bn': 'কোন ওয়ার্ডে জরুরি মনোযোগ প্রয়োজন?',
      'mr': 'कोणत्या प्रभागाला तातडीचे लक्ष हवे?',
      'gu': 'કયા વોર્ડને તાત્કાલિક ધ્યાનની જરૂર છે?',
      'kn': 'ಯಾವ ವಾರ್ಡ್‌ಗೆ ತುರ್ತು ಗಮನ ಬೇಕು?',
      'ml': 'ഏത് വാർഡിന് അടിയന്തര ശ്രദ്ധ ആവശ്യമാണ്?',
      'pa': 'ਕਿਹੜੇ ਵਾਰਡ ਨੂੰ ਤੁਰੰਤ ਧਿਆਨ ਦੀ ਲੋੜ ਹੈ?',
      'or': 'କେଉଁ ୱାର୍ଡକୁ ଜରୁରୀ ଧ୍ୟାନ ଆବଶ୍ୟକ?',
    },
    'sug_budget': {
      'en': 'Suggest budget allocation for ₹5 crore',
      'hi': '₹5 करोड़ के लिए बजट आवंटन सुझाएं',
      'ta': '₹5 கோடிக்கான பட்ஜெட் ஒதுக்கீட்டை பரிந்துரைக்கவும்',
      'te': '₹5 కోట్లకు బడ్జెట్ కేటాయింపు సూచించండి',
      'bn': '₹5 কোটির জন্য বাজেট বরাদ্দ প্রস্তাব করুন',
      'mr': '₹5 कोटींसाठी अर्थसंकल्प वाटप सुचवा',
      'gu': '₹5 કરોડ માટે બજેટ ફાળવણી સૂચવો',
      'kn': '₹5 ಕೋಟಿಗೆ ಬಜೆಟ್ ಹಂಚಿಕೆ ಸೂಚಿಸಿ',
      'ml': '₹5 കോടിക്ക് ബഡ്ജറ്റ് വിനിയോഗം നിർദ്ദേശിക്കുക',
      'pa': '₹5 ਕਰੋੜ ਲਈ ਬਜਟ ਵੰਡ ਸੁਝਾਓ',
      'or': '₹5 କୋଟି ପାଇଁ ବଜେଟ୍ ବଣ୍ଟନ ପରାମର୍ଶ ଦିଅନ୍ତୁ',
    },
    'sug_compare': {
      'en': 'Compare water vs road complaints',
      'hi': 'पानी बनाम सड़क शिकायतों की तुलना करें',
      'ta': 'நீர் மற்றும் சாலை புகார்களை ஒப்பிடுங்கள்',
      'te': 'నీరు మరియు రోడ్డు ఫిర్యాదులను పోల్చండి',
      'bn': 'পানি বনাম রাস্তার অভিযোগ তুলনা করুন',
      'mr': 'पाणी विरुद्ध रस्ता तक्रारींची तुलना करा',
      'gu': 'પાણી વિ. રસ્તા ફરિયાદોની તુલના કરો',
      'kn': 'ನೀರು ವಿರುದ್ಧ ರಸ್ತೆ ದೂರುಗಳನ್ನು ಹೋಲಿಸಿ',
      'ml': 'വെള്ളവും റോഡ് പരാതികളും താരതമ്യം ചെയ്യുക',
      'pa': 'ਪਾਣੀ ਬਨਾਮ ਸੜਕ ਸ਼ਿਕਾਇਤਾਂ ਦੀ ਤੁਲਨਾ ਕਰੋ',
      'or': 'ପାଣି ବନାମ ରାସ୍ତା ଅଭିଯୋଗ ତୁଳନା କରନ୍ତୁ',
    },
    'sug_priority': {
      'en': 'What should I prioritize today?',
      'hi': 'आज मुझे किसे प्राथमिकता देनी चाहिए?',
      'ta': 'இன்று நான் எதற்கு முன்னுரிமை கொடுக்க வேண்டும்?',
      'te': 'నేను ఈరోజు దేనికి ప్రాధాన్యత ఇవ్వాలి?',
      'bn': 'আজ আমার কীসের অগ্রাধিকার দেওয়া উচিত?',
      'mr': 'आज मी कशाला प्राधान्य द्यावे?',
      'gu': 'આજે મારે શેને પ્રાથમિકતા આપવી જોઈએ?',
      'kn': 'ಇಂದು ನಾನು ಯಾವುದಕ್ಕೆ ಆದ್ಯತೆ ನೀಡಬೇಕು?',
      'ml': 'ഇന്ന് ഞാൻ എന്തിന് മുൻഗണന നൽകണം?',
      'pa': 'ਅੱਜ ਮੈਨੂੰ ਕਿਸ ਨੂੰ ਤਰਜੀਹ ਦੇਣੀ ਚਾਹੀਦੀ ਹੈ?',
      'or': 'ଆଜି ମୁଁ କାହାକୁ ପ୍ରାଥମିକତା ଦେବି?',
    },
  };
}

class ChatScreen extends StatefulWidget {
  final String localeCode;

  const ChatScreen({
    super.key,
    this.localeCode = 'hi',
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final GeminiService _gemini = GeminiService();

  final List<_ChatMessage> messages = [];
  bool isTyping = false;

  AppLocalizations get loc => AppLocalizations(widget.localeCode);
  String _ct(String key) => _ChatL10n.get(key, widget.localeCode);

  static const Color _primary = Color(0xFF2563EB);
  static const Color _purple = Color(0xFF9334E6);
  static const Color _border = Color(0xFFE5EAF1);
  static const Color _textDark = Color(0xFF0F1F3D);
  static const Color _textGrey = Color(0xFF5B6B84);
  static const Color _red = Color(0xFFD93025);
  static const Color _orange = Color(0xFFE65100);
  static const Color _green = Color(0xFF1E8E3E);
  static const Color _amber = Color(0xFFF29900);

  List<String> get suggestions => [
        _ct('sug_briefing'),
        _ct('sug_ward'),
        _ct('sug_budget'),
        _ct('sug_compare'),
        _ct('sug_priority'),
      ];

  String get _languageName {
    switch (widget.localeCode) {
      case 'hi':
        return 'Hindi';
      case 'ta':
        return 'Tamil';
      case 'te':
        return 'Telugu';
      case 'bn':
        return 'Bengali';
      case 'mr':
        return 'Marathi';
      case 'gu':
        return 'Gujarati';
      case 'kn':
        return 'Kannada';
      case 'ml':
        return 'Malayalam';
      case 'pa':
        return 'Punjabi';
      case 'or':
        return 'Odia';
      case 'en':
      default:
        return 'English';
    }
  }

  @override
  void initState() {
    super.initState();
    messages.add(_ChatMessage(
      role: 'ai',
      text: loc.t('chat_welcome'),
      structured: false,
    ));
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final bool wide = c.maxWidth >= 900;

        if (wide) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: _buildChatArea()),
              Container(width: 1, color: _border),
              SizedBox(
                width: 320,
                child: _ContextPanel(localeCode: widget.localeCode),
              ),
            ],
          );
        }

        return _buildChatArea();
      },
    );
  }

  Widget _buildChatArea() {
    return Column(
      children: [
        _buildHeader(),
        if (messages.length <= 2) _buildSuggestions(),
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(20),
            itemCount: messages.length,
            itemBuilder: (context, i) => _buildBubble(messages[i]),
          ),
        ),
        _buildInput(),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: _border)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF9334E6), Color(0xFFC084FC)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.smart_toy_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  loc.t('chat_title'),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: _textDark,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        color: _green,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      loc.t('chat_powered'),
                      style: const TextStyle(fontSize: 12, color: _textGrey),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (isTyping)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: _purple.withOpacity(0.08),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(_purple),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    loc.t('thinking'),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _purple,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSuggestions() {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: suggestions.map((s) {
          return _HoverLift(
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () => _sendMessage(s, structured: true),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _purple.withOpacity(0.3)),
                ),
                child: Text(
                  s,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _purple,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: _border)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF6F8FB),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: _border),
              ),
              child: TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  hintText: loc.t('chat_hint'),
                  hintStyle: TextStyle(color: Colors.grey.shade500),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 14,
                  ),
                ),
                maxLines: null,
                textCapitalization: TextCapitalization.sentences,
                onSubmitted: (text) {
                  if (text.trim().isNotEmpty) {
                    _sendMessage(text.trim(), structured: true);
                  }
                },
              ),
            ),
          ),
          const SizedBox(width: 12),
          _HoverLift(
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2563EB), Color(0xFF60A5FA)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: _primary.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: IconButton(
                onPressed: () {
                  final text = _messageController.text.trim();
                  if (text.isNotEmpty) {
                    _sendMessage(text, structured: true);
                  }
                },
                icon: const Icon(
                  Icons.send_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBubble(_ChatMessage msg) {
    final bool isUser = msg.role == 'user';

    if (!isUser && msg.structured) {
      return _structuredResponse(msg.text);
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser)
            Container(
              width: 32,
              height: 32,
              margin: const EdgeInsets.only(right: 10),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF9334E6), Color(0xFFC084FC)],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.auto_awesome_rounded,
                color: Colors.white,
                size: 16,
              ),
            ),
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.55,
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                color: isUser ? _primary : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isUser ? 16 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 16),
                ),
                border: isUser ? null : Border.all(color: _border),
                boxShadow: isUser
                    ? [
                        BoxShadow(
                          color: _primary.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ]
                    : null,
              ),
              child: Text(
                msg.text,
                style: TextStyle(
                  fontSize: 13.5,
                  height: 1.5,
                  color: isUser ? Colors.white : _textDark,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _structuredResponse(String raw) {
    final parsed = _parseStructured(raw);

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            margin: const EdgeInsets.only(right: 10, top: 4),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF9334E6), Color(0xFFC084FC)],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.auto_awesome_rounded,
              color: Colors.white,
              size: 16,
            ),
          ),
          Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
                    decoration: const BoxDecoration(
                      border: Border(bottom: BorderSide(color: _border)),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.insights_rounded,
                          size: 18,
                          color: _purple,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _ct('governance_briefing'),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: _textDark,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: _purple.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            _ct('ai_generated'),
                            style: const TextStyle(
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

                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (parsed['overview']!.isNotEmpty) ...[
                          _sectionTitle(
                            _ct('overview'),
                            Icons.article_rounded,
                            _primary,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            parsed['overview']!.first,
                            style: const TextStyle(
                              fontSize: 13.5,
                              color: _textDark,
                              height: 1.55,
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                        if (parsed['critical']!.isNotEmpty) ...[
                          _sectionTitle(
                            _ct('critical_issues'),
                            Icons.warning_amber_rounded,
                            _red,
                          ),
                          const SizedBox(height: 8),
                          _bulletList(parsed['critical']!, _red),
                          const SizedBox(height: 16),
                        ],
                        if (parsed['actions']!.isNotEmpty) ...[
                          _sectionTitle(
                            _ct('recommended_actions'),
                            Icons.checklist_rounded,
                            _green,
                          ),
                          const SizedBox(height: 8),
                          _bulletList(parsed['actions']!, _green),
                          const SizedBox(height: 16),
                        ],
                        if (parsed['budget']!.isNotEmpty) ...[
                          _sectionTitle(
                            _ct('budget_impact'),
                            Icons.account_balance_wallet_rounded,
                            _amber,
                          ),
                          const SizedBox(height: 8),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: _amber.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(10),
                              border:
                                  Border.all(color: _amber.withOpacity(0.25)),
                            ),
                            child: Text(
                              parsed['budget']!.first,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: _textDark,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                        // Fallback if nothing parsed
                        if (parsed['overview']!.isEmpty &&
                            parsed['critical']!.isEmpty &&
                            parsed['actions']!.isEmpty &&
                            parsed['budget']!.isEmpty)
                          Text(
                            raw,
                            style: const TextStyle(
                              fontSize: 13.5,
                              color: _textDark,
                              height: 1.55,
                            ),
                          ),
                      ],
                    ),
                  ),

                  Container(
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFF),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(16),
                        bottomRight: Radius.circular(16),
                      ),
                      border: Border(top: BorderSide(color: _border)),
                    ),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _actionBtn(
                          Icons.add_task_rounded,
                          _ct('create_task'),
                          _primary,
                          () => _showActionToast(_ct('task_created')),
                        ),
                        _actionBtn(
                          Icons.person_add_alt_1_rounded,
                          _ct('assign_officer'),
                          _purple,
                          () => _showActionToast(_ct('officer_assigned')),
                        ),
                        _actionBtn(
                          Icons.insights_rounded,
                          _ct('view_data'),
                          _orange,
                          () => _showActionToast(_ct('data_opened')),
                        ),
                        _actionBtn(
                          Icons.description_rounded,
                          _ct('generate_report'),
                          _green,
                          () => _showActionToast(_ct('report_queued')),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String label, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(7),
          ),
          child: Icon(icon, size: 15, color: color),
        ),
        const SizedBox(width: 10),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: _textDark,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _bulletList(List<String> items, Color accent) {
    return Column(
      children: items.map((item) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 6, left: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Container(
                  width: 5,
                  height: 5,
                  decoration: BoxDecoration(
                    color: accent,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  item,
                  style: const TextStyle(
                    fontSize: 13,
                    color: _textDark,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _actionBtn(
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap,
  ) {
    return _HoverLift(
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showActionToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: _primary,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Map<String, List<String>> _parseStructured(String raw) {
    final Map<String, List<String>> map = {
      'overview': <String>[],
      'critical': <String>[],
      'actions': <String>[],
      'budget': <String>[],
    };

    String current = '';

    for (final rawLine in raw.split('\n')) {
      final line = rawLine.trim();
      if (line.isEmpty) continue;

      final lower = line.toLowerCase();
      if (lower.startsWith('## overview')) {
        current = 'overview';
        continue;
      } else if (lower.startsWith('## critical')) {
        current = 'critical';
        continue;
      } else if (lower.startsWith('## recommended')) {
        current = 'actions';
        continue;
      } else if (lower.startsWith('## estimated') ||
          lower.startsWith('## budget')) {
        current = 'budget';
        continue;
      }

      if (current.isEmpty) continue;

      if (line.startsWith('- ')) {
        map[current]!.add(line.substring(2).trim());
      } else {
        if (current == 'overview' || current == 'budget') {
          if (map[current]!.isEmpty) {
            map[current]!.add(line);
          } else {
            map[current]![0] = '${map[current]![0]} $line';
          }
        } else {
          map[current]!.add(line);
        }
      }
    }

    final overview = map['overview'] ?? <String>[];
    final budget = map['budget'] ?? <String>[];

    return <String, List<String>>{
      'overview': overview.isEmpty ? <String>[] : <String>[overview.first],
      'critical': List<String>.from(map['critical'] ?? const <String>[]),
      'actions': List<String>.from(map['actions'] ?? const <String>[]),
      'budget': budget.isEmpty ? <String>[] : <String>[budget.first],
    };
  }

  Future<void> _sendMessage(String text, {bool structured = false}) async {
    setState(() {
      messages.add(_ChatMessage(
        role: 'user',
        text: text,
        structured: false,
      ));
      isTyping = true;
    });

    _messageController.clear();
    _scrollToBottom();

    try {
      String response;

      if (structured) {
        final snap = await FirebaseFirestore.instance
            .collection('grievances')
            .get();

        int total = snap.docs.length;
        int high = 0;
        final Map<String, int> cats = {};

        for (final doc in snap.docs) {
          final d = doc.data();
          final p = d['priority_score'] is int
              ? d['priority_score'] as int
              : int.tryParse(d['priority_score']?.toString() ?? '5') ?? 5;
          if (p >= 8) high++;
          final c = d['category']?.toString() ?? 'other';
          cats[c] = (cats[c] ?? 0) + 1;
        }

        response = await _gemini.generateStructuredBriefing(
          text,
          totalGrievances: total,
          highPriority: high,
          categoryCounts: cats,
          languageName: _languageName,
        );
      } else {
        final prompt =
            'Please answer in $_languageName language only.\n\nUser question: $text';
        response = await _gemini.chat(prompt);
      }

      if (!mounted) return;

      setState(() {
        messages.add(_ChatMessage(
          role: 'ai',
          text: response,
          structured: structured,
        ));
        isTyping = false;
      });
      _scrollToBottom();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        messages.add(_ChatMessage(
          role: 'ai',
          text: 'Error: $e',
          structured: false,
        ));
        isTyping = false;
      });
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }
}

// ═════════════════════════════════════════════════════════════
// MODEL
// ═════════════════════════════════════════════════════════════
class _ChatMessage {
  final String role;
  final String text;
  final bool structured;

  _ChatMessage({
    required this.role,
    required this.text,
    required this.structured,
  });
}

// ═════════════════════════════════════════════════════════════
// HOVER LIFT (micro-interaction)
// ═════════════════════════════════════════════════════════════
class _HoverLift extends StatefulWidget {
  final Widget child;
  const _HoverLift({required this.child});

  @override
  State<_HoverLift> createState() => _HoverLiftState();
}

class _HoverLiftState extends State<_HoverLift> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        transform: Matrix4.identity()..translate(0.0, _hover ? -2.0 : 0.0),
        child: widget.child,
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════
// RIGHT CONTEXT PANEL (desktop only) - FULLY TRANSLATED
// ═════════════════════════════════════════════════════════════
class _ContextPanel extends StatelessWidget {
  final String localeCode;

  const _ContextPanel({required this.localeCode});

  AppLocalizations get loc => AppLocalizations(localeCode);
  String _ct(String key) => _ChatL10n.get(key, localeCode);

  static const Color _primary = Color(0xFF2563EB);
  static const Color _border = Color(0xFFE5EAF1);
  static const Color _textDark = Color(0xFF0F1F3D);
  static const Color _textGrey = Color(0xFF5B6B84);
  static const Color _red = Color(0xFFD93025);
  static const Color _orange = Color(0xFFE65100);
  static const Color _green = Color(0xFF1E8E3E);

  String _prettyCat(String c) {
    switch (c) {
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
    return Container(
      color: const Color(0xFFF8FAFF),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _ct('constituency_context'),
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: _textGrey,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _ct('live_snapshot'),
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: _textDark,
              ),
            ),
            const SizedBox(height: 16),
            _liveStats(),
            const SizedBox(height: 20),
            Text(
              _ct('recent_activity'),
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: _textGrey,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 10),
            _recentActivity(),
            const SizedBox(height: 20),
            Text(
              _ct('ai_tip'),
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: _textGrey,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _primary.withOpacity(0.06),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _primary.withOpacity(0.2)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.tips_and_updates_rounded,
                    size: 16,
                    color: _primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _ct('ai_tip_text'),
                      style: const TextStyle(
                        fontSize: 12,
                        color: _textDark,
                        height: 1.45,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _liveStats() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('grievances').snapshots(),
      builder: (context, snap) {
        int total = 0;
        int high = 0;
        int inProgress = 0;
        int resolved = 0;

        if (snap.hasData) {
          for (final doc in snap.data!.docs) {
            final d = doc.data() as Map<String, dynamic>;
            total++;
            final p = d['priority_score'] is int
                ? d['priority_score'] as int
                : int.tryParse(d['priority_score']?.toString() ?? '5') ?? 5;
            final s = d['status']?.toString() ?? 'submitted';
            if (p >= 8 && s != 'resolved' && s != 'closed') high++;
            if (s == 'in_progress' ||
                s == 'assigned' ||
                s == 'processed') {
              inProgress++;
            }
            if (s == 'resolved' || s == 'closed') resolved++;
          }
        }

        final pct = total == 0 ? 0.0 : (resolved / total).clamp(0.0, 1.0);
        final pctInt = (pct * 100).round();

        return Column(
          children: [
            _statRow(
              _ct('active_grievances'),
              total,
              _primary,
              Icons.assignment_rounded,
            ),
            const SizedBox(height: 10),
            _statRow(
              _ct('high_priority'),
              high,
              _red,
              Icons.priority_high_rounded,
            ),
            const SizedBox(height: 10),
            _statRow(
              _ct('in_progress'),
              inProgress,
              _orange,
              Icons.autorenew_rounded,
            ),
            const SizedBox(height: 10),
            _statRow(
              _ct('resolved'),
              resolved,
              _green,
              Icons.verified_rounded,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        _ct('resolution_rate'),
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: _textGrey,
                        ),
                      ),
                      const Spacer(),
                      TweenAnimationBuilder<int>(
                        tween: IntTween(begin: 0, end: pctInt),
                        duration: const Duration(milliseconds: 900),
                        curve: Curves.easeOutCubic,
                        builder: (context, v, _) => Text(
                          '$v%',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: _green,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: pct,
                      minHeight: 7,
                      backgroundColor: const Color(0xFFEFF2F7),
                      valueColor:
                          const AlwaysStoppedAnimation<Color>(_green),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _statRow(String label, int value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _border),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: _textDark,
              ),
            ),
          ),
          TweenAnimationBuilder<int>(
            tween: IntTween(begin: 0, end: value),
            duration: const Duration(milliseconds: 900),
            curve: Curves.easeOutCubic,
            builder: (context, v, _) => Text(
              '$v',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _recentActivity() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('grievances')
          .orderBy('timestamp', descending: true)
          .limit(4)
          .snapshots(),
      builder: (context, snap) {
        if (!snap.hasData || snap.data!.docs.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _border),
            ),
            child: Text(
              _ct('no_recent_activity'),
              style: const TextStyle(fontSize: 12, color: _textGrey),
            ),
          );
        }

        return Column(
          children: snap.data!.docs.map((doc) {
            final d = doc.data() as Map<String, dynamic>;
            final cat = d['category']?.toString() ?? 'other';
            final locText = d['location_text']?.toString() ?? '-';
            final status = d['status']?.toString() ?? 'submitted';
            final ts = d['timestamp'];
            final dt = ts is Timestamp ? ts.toDate() : null;

            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: _border),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: StatusHelper.color(status),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${_prettyCat(cat)} • $locText',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: _textDark,
                            ),
                          ),
                          Text(
                            StatusHelper.timeAgo(dt),
                            style: const TextStyle(
                              fontSize: 10,
                              color: _textGrey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}