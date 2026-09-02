// File: lib/screens/reports_screen.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/app_localizations.dart';

// ═════════════════════════════════════════════════════════════
// 11-LANGUAGE TRANSLATIONS SPECIFIC TO REPORTS SCREEN
// ═════════════════════════════════════════════════════════════
class _RepL10n {
  static String get(String key, String localeCode) {
    return _map[key]?[localeCode] ?? _map[key]?['en'] ?? key;
  }

  static const Map<String, Map<String, String>> _map = {
    'weekly_brief': {
      'en': 'Weekly Brief', 'hi': 'साप्ताहिक ब्रीफ', 'ta': 'வாராந்திர சுருக்கம்',
      'te': 'వారపు బ్రీఫ్', 'bn': 'সাপ্তাহিক ব্রিফ', 'mr': 'साप्ताहिक संक्षिप्त',
      'gu': 'સાપ્તાહિક સંક્ષિપ્ત', 'kn': 'ವಾರದ ಸಂಕ್ಷಿಪ್ತ', 'ml': 'വാരാന്ത്യ ബ്രീഫിംഗ്',
      'pa': 'ਹਫ਼ਤਾਵਾਰੀ ਬ੍ਰੀਫ', 'or': 'ସାପ୍ତାହିକ ବ୍ରିଫ୍',
    },
    'weekly_brief_sub': {
      'en': 'Auto-compiled grievance + project pulse',
      'hi': 'स्वचालित शिकायत और परियोजना स्थिति',
      'ta': 'தானியங்கி புகார் மற்றும் திட்ட நிலை',
      'te': 'ఆటో-కూర్చిన ఫిర్యాదు మరియు ప్రాజెక్ట్ స్థితి',
      'bn': 'স্বয়ংক্রিয় অভিযোগ এবং প্রকল্প পরিস্থিতি',
      'mr': 'स्वयंचलित तक्रार आणि प्रकल्प स्थिती',
      'gu': 'સ્વચાલિત ફરિયાદ અને પ્રોજેક્ટ સ્થિતિ',
      'kn': 'ಸ್ವಯಂಚಾಲಿತ ದೂರು ಮತ್ತು ಯೋಜನೆಯ ಸ್ಥಿತಿ',
      'ml': 'ഓട്ടോമാറ്റിക് പരാതിയും പ്രോജക്റ്റ് അവസ്ഥയും',
      'pa': 'ਸਵੈਚਲਿਤ ਸ਼ਿਕਾਇਤ ਅਤੇ ਪ੍ਰੋਜੈਕਟ ਸਥਿਤੀ',
      'or': 'ସ his ୍ଚାଳିତ ଅଭିଯୋଗ ଏବଂ ପ୍ରକଳ୍ପ ସ୍ଥିତି',
    },
    'cat_intel': {
      'en': 'Category Intelligence', 'hi': 'श्रेणी बुद्धिमत्ता', 'ta': 'வகை நுண்ணறிவு',
      'te': 'వర్గం ఇంటెలిజెన్స్', 'bn': 'বিভাগ বুদ্ধিমত্তা', 'mr': 'श्रेणी बुद्धिमत्ता',
      'gu': 'શ્રેણી બુદ્ધિમત્તા', 'kn': 'ವರ್ಗ ಬುದ್ಧಿವಂತಿಕೆ', 'ml': 'വിഭാഗ വിവരശേഖരണം',
      'pa': 'ਸ਼੍ਰੇਣੀ ਬੁੱਧੀਮਤਾ', 'or': 'ବିଭାଗ ବୁଦ୍ଧିମତ୍ତା',
    },
    'cat_intel_sub': {
      'en': 'Roads, water, power density snapshot', 'hi': 'सड़क, पानी, बिजली घनत्व का स्नैपशॉट',
      'ta': 'சாலைகள், நீர், மின்சார அடர்த்தி', 'te': 'రోడ్లు, నీరు, విద్యుత్ సాంద్రత',
      'bn': 'রাস্তা, পানি, বিদ্যুৎ ঘনত্বের চিত্র', 'mr': 'रस्ते, पाणी, वीज घनता चित्र',
      'gu': 'રસ્તાઓ, પાણી, વીજળી ઘનતા ચિત્ર', 'kn': 'ರಸ್ತೆಗಳು, ನೀರು, ವಿದ್ಯುತ್ ಸಾಂದ್ರತೆ',
      'ml': 'റോഡുകൾ, വെള്ളം, വൈദ്യുതി സാന്ദ്രത', 'pa': 'ਸੜਕਾਂ, ਪਾਣੀ, ਬਿਜਲੀ ਘਣਤਾ',
      'or': 'ରାସ୍ତା, ପାଣି, ବିଜୁଳି ଘନତ୍ୱ',
    },
    'action_tracker': {
      'en': 'Action Tracker', 'hi': 'कार्रवाई ट्रैकर', 'ta': 'நடவடிக்கை கண்காணிப்பு',
      'te': 'చర్యల ట్రాకర్', 'bn': 'পদক্ষেপ ট্র্যাকার', 'mr': 'कृती ट्रॅकर',
      'gu': 'ક્રિયા ટ્રેકર', 'kn': 'ಕ್ರಿಯಾ ಟ್ರ್ಯಾಕರ್', 'ml': 'നടപടി ട്രാക്കർ',
      'pa': 'ਕਾਰਵਾਈ ਟਰੈਕਰ', 'or': 'କାର୍ଯ୍ୟାନୁଷ୍ଠାନ ଟ୍ରାକର',
    },
    'action_tracker_sub': {
      'en': 'Delayed works and high-priority backlog', 'hi': 'विलंबित कार्य और उच्च प्राथमिकता मामले',
      'ta': 'தாமதமான பணிகள் மற்றும் முன்னுரிமைப் புகார்கள்', 'te': 'ఆలస్యమైన పనులు మరియు ప్రాధాన్యత ఫిర్యాదులు',
      'bn': 'বিলম্বিত কাজ এবং উচ্চ অগ্রাধিকার সমস্যা', 'mr': 'विलंबित कामे आणि उच्च प्राधान्य प्रकरणे',
      'gu': 'વિલંબિત કાર્યો और ઉચ્ચ પ્રાથમિકતા મુદ્દાઓ', 'kn': 'ವಿಳಂಬವಾದ ಕೆಲಸಗಳು మరియు ಹೆಚ್ಚಿನ ಆದ್ಯತೆಯ ಬಾಕಿ',
      'ml': 'വൈകിയ ജോലികളും ഉയർന്ന മുൻഗണനാ പരാതികളും', 'pa': 'ਦੇਰੀ ਵਾਲੇ ਕੰਮ ਅਤੇ ਉੱਚ ਤਰਜੀਹ ਵਾਲੇ ਮੁੱਦੇ',
      'or': 'ବିଳମ୍ବିତ କାର୍ଯ୍ୟ ଏବଂ ଉଚ୍ଚ ପ୍ରାଥମିକତା ସମସ୍ୟା',
    },
    'latest_report': {
      'en': 'Latest Auto Report', 'hi': 'नवीनतम ऑटो रिपोर्ट', 'ta': 'சமீபத்திய தானியங்கி அறிக்கை',
      'te': 'తాజా ఆటో నివేదిక', 'bn': 'সর্বশেষ স্বয়ংক্রিয় রিপোর্ট', 'mr': 'नवीनतम स्वयंचलित अहवाल',
      'gu': 'તાજેતરની ઓટો રિપોર્ટ', 'kn': 'ಇತ್ತೀಚಿನ ಸ್ವಯಂಚಾಲಿತ ವರದಿ', 'ml': 'ഏറ്റവും പുതിയ ഓട്ടോ റിപ്പോർട്ട്',
      'pa': 'ਤਾਜ਼ਾ ਸਵੈਚਲਿਤ ਰਿਪੋਰਟ', 'or': 'ସର୍ବଶେଷ ସ୍ୱୟଂଚାଳିତ ରିପୋର୍ଟ',
    },
    'toast_copied': {
      'en': 'Report copied to clipboard', 'hi': 'रिपोर्ट क्लिपबोर्ड पर कॉपी हो गई', 'ta': 'அறிக்கை நகலெடுக்கப்பட்டது',
      'te': 'నివేదిక క్లిప్‌బోర్డ్‌కి కాపీ చేయబడింది', 'bn': 'রিপোর্ট ক্লিপবোর্ডে কপি করা হয়েছে', 'mr': 'अहवाल क्लिपबोर्डवर कॉपी केला',
      'gu': 'રિપોર્ટ ક્લિપબોર્ડ પર કૉપિ થયો', 'kn': 'ವರದಿಯನ್ನು ಕ್ಲಿಪ್‌ಬೋರ್ಡ್‌ಗೆ ನಕಲಿಸಲಾಗಿದೆ', 'ml': 'റിപ്പോർട്ട് ക്ലിപ്ബോർഡിലേക്ക് പകർത്തി',
      'pa': 'ਰਿਪੋਰਟ ਕਲਿੱਪਬੋਰਡ ਤੇ ਕਾਪੀ ਕੀਤੀ ਗਈ', 'or': 'ରିପୋର୍ଟ କ୍ଲିପବୋର୍ଡରେ କପି ହେଲା',
    },

    // Report Header & Sections
    'rep_header': {
      'en': 'CONSTITUENCY AI — GOVERNANCE REPORT',
      'hi': 'जन सेवा AI — शासन समीक्षा रिपोर्ट',
      'ta': 'மக்கள் சேவை AI — ஆளுமை அறிக்கை',
      'te': 'ప్రజా సేవ AI — పాలన నివేదిక',
      'bn': 'জন সেবা AI — শাসন রিপোর্ট',
      'mr': 'जन सेवा AI — शासन अहवाल',
      'gu': 'જન સેવા AI — શાસન રિપોર્ટ',
      'kn': 'ಜನ ಸೇವೆ AI — ಆಡಳಿತ ವರದಿ',
      'ml': 'ജന സേവ AI — ഭരണ റിപ്പോർട്ട്',
      'pa': 'ਜਨ ਸੇਵਾ AI — ਸ਼ਾਸਨ ਰਿਪੋਰਟ',
      'or': 'ଜନ ସେବା AI — ଶାସନ ରିପୋର୍ଟ',
    },
    'rep_generated': {
      'en': 'Generated:', 'hi': 'दिनांक:', 'ta': 'உருவாக்கப்பட்டது:',
      'te': 'రూపొందించబడింది:', 'bn': 'তৈরির সময়:', 'mr': 'दिनांक:',
      'gu': 'તારીખ:', 'kn': 'ರಚಿಸಿದ ದಿನಾಂಕ:', 'ml': 'തയ്യാറാക്കിയത്:',
      'pa': 'ਮਿਤੀ:', 'or': 'ତାରିଖ:',
    },
    'rep_sec_grievance': {
      'en': 'GRIEVANCE SUMMARY', 'hi': 'शिकायत का संक्षिप्त विवरण', 'ta': 'புகார் சுருக்கம்',
      'te': 'ఫిర్యాదుల సారాంశం', 'bn': 'অভিযোগের সারসংক্ষেপ', 'mr': 'तक्रारींचा सारांश',
      'gu': 'ફરિયાદનો સારાંશ', 'kn': 'ದೂರುಗಳ ಸಾರಾಂಶ', 'ml': 'പരാതി സംഗ്രഹം',
      'pa': 'ਸ਼ਿਕਾਇਤ ਦਾ ਸਾਰਾਂਸ਼', 'or': 'ଅଭିଯୋଗର ସାରାଂଶ',
    },
    'rep_total_g': {
      'en': 'Total grievances', 'hi': 'कुल शिकायतें', 'ta': 'மொத்த புகார்கள்',
      'te': 'మొత్తం ఫిర్యాదులు', 'bn': 'মোট অভিযোগ', 'mr': 'एकूण तक्रारी',
      'gu': 'કુલ ફરિયાદો', 'kn': 'ಒಟ್ಟು ದೂರುಗಳು', 'ml': 'ആകെ പരാതികൾ',
      'pa': 'ਕੁੱਲ ਸ਼ਿਕਾਇਤਾਂ', 'or': 'ମୋଟ ଅଭିଯୋଗ',
    },
    'rep_high_p': {
      'en': 'High priority (≥8)', 'hi': 'उच्च प्राथमिकता (≥8)', 'ta': 'அதிக முன்னுரிமை (≥8)',
      'te': 'అధిక ప్రాధాన్యత (≥8)', 'bn': 'উচ্চ অগ্রাধিকার (≥8)', 'mr': 'उच्च प्राधान्य (≥8)',
      'gu': 'ઉચ્ચ પ્રાથમિકતા (≥8)', 'kn': 'ಹೆಚ್ಚಿನ ಆದ್ಯತೆ (≥8)', 'ml': 'ഉയർന്ന മുൻഗണന (≥8)',
      'pa': 'ਉੱਚ ਤਰਜੀਹ (≥8)', 'or': 'ଉଚ୍ଚ ପ୍ରାଥମିକତା (≥8)',
    },
    'rep_resolved_closed': {
      'en': 'Resolved/Closed', 'hi': 'निस्तारित/बंद', 'ta': 'தீர்க்கப்பட்டது/மூடப்பட்டது',
      'te': 'పరిష్కరించబడింది/మూసివేయబడింది', 'bn': 'মীমাংসিত/বন্ধ', 'mr': 'निकाली/बंद',
      'gu': 'ઉકેલાયેલ/બંધ', 'kn': 'ಪರಿಹರಿಸಲಾಗಿದೆ/ಮುಚ್ಚಲಾಗಿದೆ', 'ml': 'പരിഹരിച്ചു/അവസാനിപ്പിച്ചു',
      'pa': 'ਹੱਲ ਕੀਤਾ/ਬੰਦ', 'or': 'ସମାଧାନ/ବନ୍ଦ',
    },
    'rep_open_issues': {
      'en': 'Open issues', 'hi': 'लंबित मामले', 'ta': 'நிலுவையில் உள்ள பிரச்சனைகள்',
      'te': 'తెరిచి ఉన్న సమస్యలు', 'bn': 'খোলা সমস্যাসমূহ', 'mr': 'प्रलंबित समस्या',
      'gu': 'બાકી રહેલ મુદ્દાઓ', 'kn': 'ಬಾಕಿ ಇರುವ ಸಮಸ್ಯೆಗಳು', 'ml': 'തീർപ്പുകൽപ്പിക്കാത്ത വിഷയങ്ങൾ',
      'pa': 'ਖੁੱਲ੍ਹੇ ਮੁੱਦੇ', 'or': 'ବାକି ଥିବା ସମସ୍ୟା',
    },
    'rep_res_rate': {
      'en': 'Resolution rate', 'hi': 'समाधान दर', 'ta': 'தீர்வு விகிதம்',
      'te': 'పరిష్కార రేటు', 'bn': 'সমাধানের হার', 'mr': 'निराकरण दर',
      'gu': 'ઉકેલ દર', 'kn': 'ಪರಿಹಾರ ದರ', 'ml': 'പരിഹാര നിരക്ക്',
      'pa': 'ਹੱਲ ਦਰ', 'or': 'ସମାଧାନ ହାର',
    },
    'rep_by_cat': {
      'en': 'By category:', 'hi': 'श्रेणी अनुसार:', 'ta': 'வகை வாரியாக:',
      'te': 'వర్గం వారీగా:', 'bn': 'বিভাগ অনুযায়ী:', 'mr': 'प्रकारानुसार:',
      'gu': 'શ્રેણી મુજબ:', 'kn': 'ವರ್ಗವಾರು:', 'ml': 'വിഭാഗം അനുസരിച്ച്:',
      'pa': 'ਸ਼੍ਰੇਣੀ ਅਨੁਸਾਰ:', 'or': 'ଶ୍ରେଣୀ ଅନୁଯାୟୀ:',
    },
    'rep_sec_projects': {
      'en': 'PROJECTS SUMMARY', 'hi': 'परियोजनाओं का विवरण', 'ta': 'திட்டங்கள் சுருக்கம்',
      'te': 'ప్రాజెక్టుల సారాంశం', 'bn': 'প্রকল্পের সারসংক্ষেপ', 'mr': 'प्रकल्पांचा सारांश',
      'gu': 'પ્રોજેક્ટ્સનો સારાંશ', 'kn': 'ಯೋಜನೆಗಳ ಸಾರಾಂಶ', 'ml': 'പ്രോജക്ട് സംഗ്രഹം',
      'pa': 'ਪ੍ਰੋਜੈਕਟਾਂ ਦਾ ਸਾਰਾਂਸ਼', 'or': 'ପ୍ରକଳ୍ପର ସାରାଂଶ',
    },
    'rep_proj_tracked': {
      'en': 'Total projects tracked', 'hi': 'कुल ट्रैक की गई परियोजनाएं', 'ta': 'கண்காணிக்கப்படும் மொத்த திட்டங்கள்',
      'te': 'ట్రాక్ చేసిన మొత్తం ప్రాజెక్టులు', 'bn': 'মোট ট্র্যাকিং করা প্রকল্প', 'mr': 'एकूण ट्रॅक केलेले प्रकल्प',
      'gu': 'કુલ ટ્રેક કરેલ પ્રોજેક્ટ્સ', 'kn': 'ಒಟ್ಟು ಟ್ರ್ಯಾಕ್ ಮಾಡಲಾದ ಯೋಜನೆಗಳು', 'ml': 'ട്രാക്ക് ചെയ്ത ആകെ പ്രോജക്റ്റുകൾ',
      'pa': 'ਕੁੱਲ ਟਰੈਕ ਕੀਤੇ ਪ੍ਰੋਜੈਕਟ', 'or': 'ମୋଟ ଟ୍ରାକ୍ ହୋଇଥିବା ପ୍ରକଳ୍ପ',
    },
    'rep_proj_delayed': {
      'en': 'Delayed projects', 'hi': 'विलंबित परियोजनाएं', 'ta': 'தாமதமான திட்டங்கள்',
      'te': 'ఆలస్యమైన ప్రాజెక్టులు', 'bn': 'বিলম্বিত প্রকল্প', 'mr': 'विलंबित प्रकल्प',
      'gu': 'વિલંબિત પ્રોજેક્ટ્સ', 'kn': 'ವಿಳಂಬವಾದ ಯೋಜನೆಗಳು', 'ml': 'വൈകിയ പ്രോജക്റ്റുകൾ',
      'pa': 'ਦੇਰੀ ਵਾਲੇ ਪ੍ਰੋਜੈਕਟ', 'or': 'ବିଳମ୍ବିତ ପ୍ରକଳ୍ପ',
    },
    'rep_sec_actions': {
      'en': 'RECOMMENDED NEXT ACTIONS', 'hi': 'अनुशंसित आगामी कार्रवाई', 'ta': 'பரிந்துரைக்கப்பட்ட அடுத்த நடவடிக்கைகள்',
      'te': 'సిఫార్సు చేసిన తదుపరి చర్యలు', 'bn': 'প্রস্তাবিত পরবর্তী পদক্ষেপ', 'mr': 'शिफारस केलेल्या पुढील कृती',
      'gu': 'ભલામણ કરેલ આગામી પગલાં', 'kn': 'ಶಿಫಾರಸು ಮಾಡಿದ ಮುಂದಿನ ಕ್ರಮಗಳು', 'ml': 'ശുപാർശ ചെയ്യുന്ന അടുത്ത നടപടികൾ',
      'pa': 'ਸਿਫਾਰਸ਼ ਕੀਤੀਆਂ ਅਗਲੀਆਂ ਕਾਰਵਾਈਆਂ', 'or': 'ପରାମର୍ଶିତ ପରବର୍ତ୍ତୀ କାର୍ଯ୍ୟ',
    },
    'rep_act_1': {
      'en': '1. Prioritize high-priority open grievances this week',
      'hi': '1. इस सप्ताह उच्च प्राथमिकता वाले मामलों को प्राथमिकता दें',
      'ta': '1. இந்த வாரம் அதிக முன்னுரிமை புகார்களுக்கு முன்னுரிமை அளிக்கவும்',
      'te': '1. ఈ వారం అధిక ప్రాధాన్యత కలిగిన సమస్యలకు ప్రాధాన్యత ఇవ్వండి',
      'bn': '1. এই সপ্তাহে উচ্চ অগ্রাধিকার সমস্যাগুলোকে প্রাধান্য দিন',
      'mr': '1. या आठवड्यात उच्च प्राधान्य प्रकरणांना प्राधान्य द्या',
      'gu': '1. આ અઠવાડિયે ઉચ્ચ પ્રાથમિકતા ધરાવતા મુદ્દાઓને પ્રાથમિકતા આપો',
      'kn': '1. ಈ ವಾರ ಹೆಚ್ಚಿನ ಆದ್ಯತೆಯ ದೂರುಗಳಿಗೆ ಆದ್ಯತೆ ನೀಡಿ',
      'ml': '1. ഈ ആഴ്ച ഉയർന്ന മുൻഗണനാ പരാതികൾക്ക് മുൻഗണന നൽകുക',
      'pa': '1. ਇਸ ਹਫ਼ਤੇ ਉੱਚ ਤਰਜੀਹੀ ਮੁੱਦਿਆਂ ਨੂੰ ਪਹਿਲ ਦਿਓ',
      'or': '1. ଏହି ସପ୍ତାହରେ ଉଚ୍ଚ ପ୍ରାଥମିକତା ସମସ୍ୟାକୁ ପ୍ରାଥମିକତା ଦିଅନ୍ତୁ',
    },
    'rep_act_2': {
      'en': '2. Review delayed projects with contractors',
      'hi': '2. ठेकेदारों के साथ विलंबित परियोजनाओं की समीक्षा करें',
      'ta': '2. ஒப்பந்ததாரர்களுடன் தாமதமான திட்டங்களை மதிப்பாய்வு செய்யவும்',
      'te': '2. కాంట్రాక్టర్లతో ఆలస్యమైన ప్రాజెక్టులను సమీక్షించండి',
      'bn': '2. ঠিকাদারদের সাথে বিলম্বিত প্রকল্প পর্যালোচনা করুন',
      'mr': '2. कंत्राटदारांसह विलंबित प्रकल्पांचा आढावा घ्या',
      'gu': '2. કોન્ટ્રાક્ટરો સાથે વિલંબિત પ્રોજેક્ટ્સની સમીક્ષા કરો',
      'kn': '2. ಗುತ್ತಿಗೆದಾರರೊಂದಿಗೆ ವಿಳಂಬವಾದ ಯೋಜನೆಗಳನ್ನು ಪರಿಶೀಲಿಸಿ',
      'ml': '2. കരാറുകാരുമായി വൈകിയ പ്രോജക്റ്റുകൾ അവലോകനം ചെയ്യുക',
      'pa': '2. ਠੇਕੇਦਾਰਾਂ ਨਾਲ ਦੇਰੀ ਵਾਲੇ ਪ੍ਰੋਜੈਕਟਾਂ ਦੀ ਸਮੀਖਿਆ ਕਰੋ',
      'or': '2. ଠିକାଦାରଙ୍କ ସହ ବିଳମ୍ବିତ ପ୍ରକଳ୍ପର ସମୀକ୍ଷା କରନ୍ତୁ',
    },
    'rep_act_3': {
      'en': '3. Align MPLADS allocation with top complaint categories',
      'hi': '3. शीर्ष शिकायत श्रेणियों के साथ MPLADS आवंटन को संरेखित करें',
      'ta': '3. அதிக புகார்கள் உள்ள வகைகளுடன் MPLADS நிதியை ஒதுக்கவும்',
      'te': '3. ప్రధాన ఫిర్యాదు వర్గాలతో MPLADS కేటాయింపును సరిపోల్చండి',
      'bn': '3. প্রধান অভিযোগ বিভাগগুলোর সাথে MPLADS বরাদ্দ মেলান',
      'mr': '3. मुख्य तक्रार प्रकारांनुसार MPLADS निधीचे वाटप करा',
      'gu': '3. મુખ્ય ફરિયાદ શ્રેણીઓ સાથે MPLADS ફાળવણી સુમેળ કરો',
      'kn': '3. ಪ್ರಮುಖ ದೂರು ವರ್ಗಗಳೊಂದಿಗೆ MPLADS ಹಂಚಿಕೆಯನ್ನು ಹೊಂದಿಸಿ',
      'ml': '3. പ്രധാന പരാതി വിഭാഗങ്ങളുമായി MPLADS ഫണ്ട് വിനിയോഗം ക്രമീകരിക്കുക',
      'pa': '3. ਮੁੱਖ ਸ਼ਿਕਾਇਤ ਸ਼੍ਰੇਣੀਆਂ ਨਾਲ MPLADS ਵੰਡ ਨੂੰ ਮਿਲਾਓ',
      'or': '3. ମୁଖ୍ୟ ଅଭିଯୋଗ ଶ୍ରେଣୀ ସହ MPLADS ବଣ୍ଟନକୁ ସମାନ କରନ୍ତୁ',
    },
    'rep_act_4': {
      'en': '4. Publish public status update for transparency',
      'hi': '4. पारदर्शिता के लिए सार्वजनिक स्थिति अपडेट प्रकाशित करें',
      'ta': '4. வெளிப்படைத்தன்மைக்கு பொது நிலை புதுப்பிப்பை வெளியிடுங்கள்',
      'te': '4. పారదర్శకత కోసం ప్రజల స్థితి నవీకరణను ప్రచురించండి',
      'bn': '4. স্বচ্ছতার জন্য জনসমক্ষে অগ্রগতি আপডেট প্রকাশ করুন',
      'mr': '4. पारदर्शकतेसाठी सार्वजनिक प्रगती अहवाल प्रसिद्ध करा',
      'gu': '4. પારદર્શિતા માટે જાહેર સ્થિતિ અપડેટ પ્રકાશિત કરો',
      'kn': '4. ಪಾರದರ್ಶಕತೆಗಾಗಿ ಸಾರ್ವಜನಿಕ ಸ್ಥಿತಿ ನವೀಕರಣವನ್ನು ಪ್ರಕಟಿಸಿ',
      'ml': '4. സുതാര്യതയ്ക്കായി പൊതു നില വിവരങ്ങൾ പ്രസിദ്ധീകരിക്കുക',
      'pa': '4. ਪਾਰਦਰਸ਼ਤਾ ਲਈ ਜਨਤਕ ਸਥਿਤੀ ਅਪਡੇਟ ਪ੍ਰਕਾਸ਼ਿਤ ਕਰੋ',
      'or': '4. ସ୍ୱଚ୍ଛତା ପାଇଁ ସାର୍ବଜନୀନ ସ୍ଥିତି ଅପଡେଟ୍ ପ୍ରକାଶ କରନ୍ତୁ',
    },
    'rep_end': {
      'en': '— End of report —', 'hi': '— रिपोर्ट समाप्त —', 'ta': '— அறிக்கை முடிவு —',
      'te': '— నివేదిక ముగిసింది —', 'bn': '— রিপোর্ট সমাপ্ত —', 'mr': '— अहवाल समाप्त —',
      'gu': '— રિપોર્ટ સમાપ્ત —', 'kn': '— ವರದಿ ಮುಕ್ತಾಯ —', 'ml': '— റിപ്പോർട്ട് സമാപിച്ചു —',
      'pa': '— ਰਿਪੋਰਟ ਸਮਾਪਤ —', 'or': '— ରିପୋର୍ଟ ସମାପ୍ତ —',
    },
  };
}

class ReportsScreen extends StatelessWidget {
  final String localeCode;

  const ReportsScreen({
    super.key,
    this.localeCode = 'hi',
  });

  static const Color _primary = Color(0xFF2563EB);
  static const Color _border = Color(0xFFE5EAF1);
  static const Color _textDark = Color(0xFF0F1F3D);
  static const Color _textGrey = Color(0xFF5B6B84);

  String _rt(String key) => _RepL10n.get(key, localeCode);

  Future<String> _buildReportText(AppLocalizations loc) async {
    final snap =
        await FirebaseFirestore.instance.collection('grievances').get();
    final proj =
        await FirebaseFirestore.instance.collection('projects').get();

    int total = snap.docs.length;
    int high = 0;
    int resolved = 0;
    final Map<String, int> cats = {};

    for (final d in snap.docs) {
      final data = d.data();
      final p = data['priority_score'] is int
          ? data['priority_score'] as int
          : int.tryParse(data['priority_score']?.toString() ?? '5') ?? 5;
      final s = data['status']?.toString() ?? 'submitted';
      if (p >= 8) high++;
      if (s == 'resolved' || s == 'closed') resolved++;
      final c = data['category']?.toString() ?? 'other';
      cats[c] = (cats[c] ?? 0) + 1;
    }

    final catLines = cats.entries
        .map((e) => '  - ${_localizedCategory(e.key, loc)}: ${e.value}')
        .join('\n');

    int delayed = 0;
    for (final d in proj.docs) {
      final s = (d.data())['status']?.toString() ?? '';
      if (s == 'delayed') delayed++;
    }

    final now = DateTime.now();
    return '''
${_rt('rep_header')}
${_rt('rep_generated')} ${now.day}/${now.month}/${now.year} ${now.hour}:${now.minute.toString().padLeft(2, '0')}

════════════════════════════════════
${_rt('rep_sec_grievance')}
════════════════════════════════════
${_rt('rep_total_g')}: $total
${_rt('rep_high_p')}: $high
${_rt('rep_resolved_closed')}: $resolved
${_rt('rep_open_issues')}: ${total - resolved}
${_rt('rep_res_rate')}: ${total == 0 ? 0 : ((resolved / total) * 100).toStringAsFixed(1)}%

${_rt('rep_by_cat')}
$catLines

════════════════════════════════════
${_rt('rep_sec_projects')}
════════════════════════════════════
${_rt('rep_proj_tracked')}: ${proj.docs.length}
${_rt('rep_proj_delayed')}: $delayed

════════════════════════════════════
${_rt('rep_sec_actions')}
════════════════════════════════════
${_rt('rep_act_1')}
${_rt('rep_act_2')}
${_rt('rep_act_3')}
${_rt('rep_act_4')}

${_rt('rep_end')}
''';
  }

  String _localizedCategory(String category, AppLocalizations loc) {
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
    final loc = AppLocalizations(localeCode);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FB),
      appBar: AppBar(
        title: Text(loc.t('reports_title')),
        backgroundColor: const Color(0xFF0A1F44),
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<String>(
        future: _buildReportText(loc),
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final report = snap.data!;

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 900),
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  Text(
                    loc.t('reports_title'),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: _textDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    loc.t('reports_sub'),
                    style: const TextStyle(fontSize: 13, color: _textGrey),
                  ),
                  const SizedBox(height: 20),

                  // Quick cards
                  LayoutBuilder(
                    builder: (context, c) {
                      final cols = c.maxWidth > 700 ? 3 : 1;
                      return GridView.count(
                        crossAxisCount: cols,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        mainAxisExtent: 120,
                        children: [
                          _reportCard(
                            _rt('weekly_brief'),
                            _rt('weekly_brief_sub'),
                            Icons.calendar_view_week_rounded,
                            _primary,
                          ),
                          _reportCard(
                            _rt('cat_intel'),
                            _rt('cat_intel_sub'),
                            Icons.pie_chart_rounded,
                            const Color(0xFF9334E6),
                          ),
                          _reportCard(
                            _rt('action_tracker'),
                            _rt('action_tracker_sub'),
                            Icons.flag_rounded,
                            const Color(0xFFD93025),
                          ),
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 20),

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
                        Row(
                          children: [
                            Text(
                              _rt('latest_report'),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: _textDark,
                              ),
                            ),
                            const Spacer(),
                            ElevatedButton.icon(
                              onPressed: () async {
                                await Clipboard.setData(
                                    ClipboardData(text: report));
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(_rt('toast_copied')),
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                }
                              },
                              icon: const Icon(Icons.copy_rounded, size: 16),
                              label: Text(loc.t('copy_report')),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _primary,
                                foregroundColor: Colors.white,
                                elevation: 0,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFF),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: _border),
                          ),
                          child: SelectableText(
                            report,
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 12.5,
                              height: 1.55,
                              color: _textDark,
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
        },
      ),
    );
  }

  Widget _reportCard(
    String title,
    String subtitle,
    IconData icon,
    Color color,
  ) {
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
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: _textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12, color: _textGrey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}