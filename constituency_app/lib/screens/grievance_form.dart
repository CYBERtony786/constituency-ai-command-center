// File: lib/screens/grievance_form.dart
// FINAL — Voice (continuous) + Photo + Video (No Storage, No AI Fix)

import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../services/app_localizations.dart';
import '../services/gemini_service.dart';

class GrievanceForm extends StatefulWidget {
  final String localeCode;

  const GrievanceForm({
    super.key,
    this.localeCode = 'hi',
  });

  @override
  State<GrievanceForm> createState() => _GrievanceFormState();
}

class _GrievanceFormState extends State<GrievanceForm> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _complaintController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  String _selectedCategory = 'roads';
  bool _isSubmitting = false;
  bool _isSubmitted = false;

  // Voice
  late stt.SpeechToText _speech;
  bool _isListening = false;
  bool _speechAvailable = false;
  bool _userWantsListening = false; // true until user presses Stop
  String _voiceBaseText = '';

  // Media (no Firebase Storage)
  final ImagePicker _picker = ImagePicker();
  Uint8List? _photoBytes;
  String? _photoName;
  String? _videoName;
  int? _videoSizeBytes;

  AppLocalizations get loc => AppLocalizations(widget.localeCode);

  static const Color _primary = Color(0xFF2563EB);
  static const Color _border = Color(0xFFE5EAF1);
  static const Color _textDark = Color(0xFF0F1F3D);
  static const Color _textGrey = Color(0xFF5B6B84);
  static const Color _green = Color(0xFF1E8E3E);
  static const Color _purple = Color(0xFF9334E6);
  static const Color _red = Color(0xFFD93025);

  static const int _maxPhotoBytes = 350 * 1024;

  String get _speechLocale {
    switch (widget.localeCode) {
      case 'hi':
        return 'hi-IN';
      case 'ta':
        return 'ta-IN';
      case 'te':
        return 'te-IN';
      case 'bn':
        return 'bn-IN';
      case 'mr':
        return 'mr-IN';
      case 'gu':
        return 'gu-IN';
      case 'kn':
        return 'kn-IN';
      case 'ml':
        return 'ml-IN';
      case 'pa':
        return 'pa-IN';
      case 'or':
        return 'hi-IN';
      case 'en':
      default:
        return 'en-IN';
    }
  }

  String _mt(String key) {
    const Map<String, Map<String, String>> m = {
      'voice': {'en': 'Voice', 'hi': 'बोलें', 'ml': 'സംസാരിക്കുക'},
      'stop': {'en': 'Stop', 'hi': 'रोकें', 'ml': 'നിർത്തുക'},
      'listening': {
        'en': 'Listening… pause is OK, keep speaking',
        'hi': 'सुन रहे हैं… रुक सकते हैं, बोलते रहें',
        'ml': 'കേൾക്കുന്നു… ഇടി ശരി, തുടർന്ന് പറയൂ',
      },
      'evidence': {
        'en': 'Photo / Video Evidence',
        'hi': 'फोटो / वीडियो साक्ष्य',
        'ml': 'ഫോട്ടോ / വീഡിയോ തെളിവ്',
      },
      'evidence_sub': {
        'en': 'Optional — attach proof (road damage, garbage, broken lights)',
        'hi': 'वैकल्पिक — टूटी सड़क / कचरे का प्रमाण जोड़ें',
        'ml': 'ഓപ്ഷണൽ — തകരാറിന്റെ തെളിവ് ചേർക്കുക',
      },
      'add_photo': {
        'en': 'Add Photo',
        'hi': 'फोटो जोड़ें',
        'ml': 'ഫോട്ടോ ചേർക്കുക',
      },
      'add_video': {
        'en': 'Add Video',
        'hi': 'वीडियो जोड़ें',
        'ml': 'വീഡിയോ ചേർക്കുക',
      },
      'tap_upload': {
        'en': 'Tap to select',
        'hi': 'चुनने के लिए टैप करें',
        'ml': 'തിരഞ്ഞെടുക്കാൻ ടാപ്പ് ചെയ്യുക',
      },
      'voice_unsupported': {
        'en': 'Voice needs Chrome + microphone permission',
        'hi': 'वॉइस के लिए Chrome और माइक अनुमति चाहिए',
        'ml': 'വോയ്‌സിന് Chrome-ഉം മൈക്ക് അനുമതിയും വേണം',
      },
      'photo_big': {
        'en': 'Photo too large. Choose a smaller image.',
        'hi': 'फोटो बहुत बड़ी है। छोटी फोटो चुनें।',
        'ml': 'ഫോട്ടോ വളരെ വലുതാണ്. ചെറിയ ചിത്രം തിരഞ്ഞെടുക്കുക.',
      },
      'video_note': {
        'en': 'Video attached (demo — metadata saved)',
        'hi': 'वीडियो जुड़ी (डेमो — विवरण सेव)',
        'ml': 'വീഡിയോ ചേർത്തു (ഡെമോ — വിവരം സേവ്)',
      },
      'remove': {'en': 'Remove', 'hi': 'हटाएँ', 'ml': 'നീക്കം ചെയ്യുക'},
    };
    return m[key]?[widget.localeCode] ?? m[key]?['en'] ?? key;
  }

  List<Map<String, dynamic>> get categories => [
        {
          'id': 'roads',
          'label': loc.t('cat_roads'),
          'icon': Icons.add_road_rounded,
          'color': const Color(0xFF795548),
        },
        {
          'id': 'water',
          'label': loc.t('cat_water'),
          'icon': Icons.water_drop_rounded,
          'color': const Color(0xFF2563EB),
        },
        {
          'id': 'electricity',
          'label': loc.t('cat_electricity'),
          'icon': Icons.electrical_services_rounded,
          'color': const Color(0xFFF29900),
        },
        {
          'id': 'health',
          'label': loc.t('cat_health'),
          'icon': Icons.local_hospital_rounded,
          'color': const Color(0xFFD93025),
        },
        {
          'id': 'education',
          'label': loc.t('cat_education'),
          'icon': Icons.school_rounded,
          'color': const Color(0xFF1E8E3E),
        },
        {
          'id': 'sanitation',
          'label': loc.t('cat_sanitation'),
          'icon': Icons.cleaning_services_rounded,
          'color': const Color(0xFF00897B),
        },
        {
          'id': 'street_lights',
          'label': loc.t('cat_lights'),
          'icon': Icons.lightbulb_rounded,
          'color': const Color(0xFFE65100),
        },
        {
          'id': 'drainage',
          'label': loc.t('cat_drainage'),
          'icon': Icons.water_rounded,
          'color': const Color(0xFF3949AB),
        },
        {
          'id': 'garbage',
          'label': loc.t('cat_garbage'),
          'icon': Icons.delete_outline_rounded,
          'color': const Color(0xFF5F6368),
        },
        {
          'id': 'other',
          'label': loc.t('cat_other'),
          'icon': Icons.more_horiz_rounded,
          'color': const Color(0xFF9334E6),
        },
      ];

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _initSpeech();
  }

  Future<void> _initSpeech() async {
    try {
      _speechAvailable = await _speech.initialize(
        onError: (error) {
          debugPrint('Speech error: $error');
          if (!mounted) return;

          final text = error.toString();

          // Don't kill whole session on minor errors if user still wants listening
          if (text.contains('not-allowed')) {
            _userWantsListening = false;
            setState(() => _isListening = false);
            _showSnack(
              'Microphone blocked. Chrome lock → Microphone → Allow → Reload.',
              _red,
            );
            return;
          }

          // For no-speech / network blips: try restart if user still wants mic on
          if (_userWantsListening) {
            _restartListeningSoon();
          } else {
            setState(() => _isListening = false);
          }
        },
        onStatus: (status) {
          debugPrint('Speech status: $status');
          if (!mounted) return;

          // Browser often ends session after pause — auto continue
          if (status == 'done' || status == 'notListening') {
            setState(() => _isListening = false);
            if (_userWantsListening) {
              _restartListeningSoon();
            }
          }
        },
      );
      if (mounted) setState(() {});
    } catch (_) {
      _speechAvailable = false;
    }
  }

  void _restartListeningSoon() {
    Future.delayed(const Duration(milliseconds: 400), () async {
      if (!mounted || !_userWantsListening) return;
      if (_isListening) return;
      await _startListeningInternal(preserveBase: true);
    });
  }

  @override
  void dispose() {
    _userWantsListening = false;
    _nameController.dispose();
    _phoneController.dispose();
    _complaintController.dispose();
    _locationController.dispose();
    _speech.stop();
    super.dispose();
  }

  // ═════════════════════════════════════════════════════════
  // VOICE — continuous until user stops
  // ═════════════════════════════════════════════════════════
  Future<void> _toggleListening() async {
    if (_isListening || _userWantsListening) {
      // User pressed Stop
      _userWantsListening = false;
      await _speech.stop();
      if (!mounted) return;
      setState(() => _isListening = false);
      return;
    }

    if (!_speechAvailable) {
      _showSnack(_mt('voice_unsupported'), _red);
      return;
    }

    _userWantsListening = true;
    // Freeze current text so new speech appends
    _voiceBaseText = _complaintController.text.trim();
    await _startListeningInternal(preserveBase: true);
  }

  Future<void> _startListeningInternal({required bool preserveBase}) async {
    if (!_userWantsListening || !_speechAvailable) return;

    if (!preserveBase) {
      _voiceBaseText = _complaintController.text.trim();
    }

    if (!mounted) return;
    setState(() => _isListening = true);

    try {
      await _speech.listen(
        onResult: (result) {
          final heard = result.recognizedWords.trim();
          if (heard.isEmpty) return;

          setState(() {
            if (_voiceBaseText.isEmpty) {
              _complaintController.text = heard;
            } else {
              // Keep old text + current live hypothesis
              _complaintController.text = '$_voiceBaseText $heard';
            }
            _complaintController.selection = TextSelection.fromPosition(
              TextPosition(offset: _complaintController.text.length),
            );
          });

          // When a final result lands, extend base so next chunk appends cleanly
          if (result.finalResult) {
            _voiceBaseText = _complaintController.text.trim();
          }
        },
        localeId: _speechLocale,
        listenFor: const Duration(minutes: 2),
        pauseFor: const Duration(seconds: 8), // <-- pause allowed
        partialResults: true,
        cancelOnError: false,
        listenMode: stt.ListenMode.dictation,
      );
    } catch (e) {
      debugPrint('listen() failed: $e');
      if (_userWantsListening) {
        _restartListeningSoon();
      } else if (mounted) {
        setState(() => _isListening = false);
      }
    }
  }

  // ═════════════════════════════════════════════════════════
  // PHOTO / VIDEO
  // ═════════════════════════════════════════════════════════
  Future<void> _pickPhoto() async {
    try {
      final XFile? picked = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 45,
      );
      if (picked == null) return;

      final bytes = await picked.readAsBytes();
      if (bytes.length > _maxPhotoBytes) {
        _showSnack(_mt('photo_big'), _red);
        return;
      }

      setState(() {
        _photoBytes = bytes;
        _photoName = picked.name;
      });
    } catch (e) {
      _showSnack('Could not pick photo: $e', _red);
    }
  }

  Future<void> _pickVideo() async {
    try {
      final XFile? picked =
          await _picker.pickVideo(source: ImageSource.gallery);
      if (picked == null) return;

      int? size;
      try {
        size = await picked.length();
      } catch (_) {}

      setState(() {
        _videoName = picked.name;
        _videoSizeBytes = size;
      });

      _showSnack(_mt('video_note'), _purple);
    } catch (e) {
      _showSnack('Could not pick video: $e', _red);
    }
  }

  void _showSnack(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ═════════════════════════════════════════════════════════
  // BUILD
  // ═════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    if (_isSubmitted) return _buildSuccessScreen();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            loc.t('grievance_title'),
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: _textDark,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            loc.t('grievance_subtitle'),
            style: const TextStyle(fontSize: 13, color: _textGrey),
          ),

          const SizedBox(height: 24),

          // 01 Category
          _sectionCard(
            number: '01',
            title: loc.t('choose_category'),
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: categories.map((c) {
                final bool selected = _selectedCategory == c['id'];
                final Color color = c['color'] as Color;

                return InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    setState(() => _selectedCategory = c['id'] as String);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: 118,
                    height: 92,
                    decoration: BoxDecoration(
                      color: selected
                          ? color.withOpacity(0.08)
                          : const Color(0xFFFAFBFD),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: selected ? color : _border,
                        width: selected ? 2 : 1,
                      ),
                    ),
                    child: Stack(
                      children: [
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                c['icon'] as IconData,
                                size: 26,
                                color:
                                    selected ? color : Colors.grey.shade500,
                              ),
                              const SizedBox(height: 8),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 4),
                                child: Text(
                                  c['label'] as String,
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: selected
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                    color: selected ? color : _textGrey,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (selected)
                          Positioned(
                            top: 6,
                            right: 6,
                            child: Container(
                              width: 18,
                              height: 18,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.check_rounded,
                                size: 12,
                                color: Colors.white,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 20),

          // 02 Details + Voice only (NO AI Fix)
          _sectionCard(
            number: '02',
            title: loc.t('describe_problem'),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _fieldLabel(loc.t('location')),
                const SizedBox(height: 8),
                TextField(
                  controller: _locationController,
                  decoration: _inputDecoration(
                    hint: loc.t('location'),
                    icon: Icons.location_on_outlined,
                  ),
                ),
                const SizedBox(height: 18),

                Row(
                  children: [
                    Expanded(child: _fieldLabel(loc.t('describe_problem'))),
                    InkWell(
                      onTap: _toggleListening,
                      borderRadius: BorderRadius.circular(20),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: _isListening
                              ? _red
                              : _primary.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: _isListening
                                ? _red
                                : _primary.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _isListening
                                  ? Icons.stop_rounded
                                  : Icons.mic_rounded,
                              size: 16,
                              color:
                                  _isListening ? Colors.white : _primary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _isListening ? _mt('stop') : _mt('voice'),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: _isListening
                                    ? Colors.white
                                    : _primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),
                TextField(
                  controller: _complaintController,
                  maxLines: 5,
                  decoration: _inputDecoration(
                    hint: loc.t('describe_problem'),
                  ),
                ),

                if (_isListening || _userWantsListening)
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Row(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                            color: _red,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _mt('listening'),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: _red,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // 03 Evidence
          _sectionCard(
            number: '03',
            title: _mt('evidence'),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _mt('evidence_sub'),
                  style: const TextStyle(fontSize: 12, color: _textGrey),
                ),
                const SizedBox(height: 16),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final bool wide = constraints.maxWidth > 560;
                    final photo = _buildPhotoPicker();
                    final video = _buildVideoPicker();

                    if (wide) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: photo),
                          const SizedBox(width: 14),
                          Expanded(child: video),
                        ],
                      );
                    }
                    return Column(
                      children: [
                        photo,
                        const SizedBox(height: 14),
                        video,
                      ],
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // 04 Contact
          _sectionCard(
            number: '04',
            title: loc.t('name_optional'),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final bool wide = constraints.maxWidth > 560;

                final nameField = Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _fieldLabel(loc.t('name_optional')),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _nameController,
                      decoration: _inputDecoration(
                        hint: loc.t('name_optional'),
                        icon: Icons.person_outline_rounded,
                      ),
                    ),
                  ],
                );

                final phoneField = Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _fieldLabel(loc.t('mobile')),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: _inputDecoration(
                        hint: loc.t('mobile'),
                        icon: Icons.phone_outlined,
                        prefixText: '+91 ',
                      ),
                    ),
                  ],
                );

                if (wide) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: nameField),
                      const SizedBox(width: 16),
                      Expanded(child: phoneField),
                    ],
                  );
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    nameField,
                    const SizedBox(height: 18),
                    phoneField,
                  ],
                );
              },
            ),
          ),

          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _submitComplaint,
              style: ElevatedButton.styleFrom(
                backgroundColor: _green,
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey.shade300,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: _isSubmitting
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          loc.t('submitting'),
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.send_rounded, size: 20),
                        const SizedBox(width: 10),
                        Text(
                          loc.t('submit_complaint'),
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
            ),
          ),

          const SizedBox(height: 16),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFEAF3FF),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _primary.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                const Icon(Icons.mic_rounded, color: _primary, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Voice • Photo • ${_mt('video_note')}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _primary,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildPhotoPicker() {
    if (_photoBytes != null) {
      return Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.memory(
              _photoBytes!,
              height: 150,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: InkWell(
              onTap: () {
                setState(() {
                  _photoBytes = null;
                  _photoName = null;
                });
              },
              child: Container(
                padding: const EdgeInsets.all(5),
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close_rounded,
                    size: 16, color: Colors.white),
              ),
            ),
          ),
        ],
      );
    }

    return InkWell(
      onTap: _pickPhoto,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 150,
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFFFAFBFD),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _primary.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: _primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add_a_photo_rounded,
                  color: _primary, size: 22),
            ),
            const SizedBox(height: 10),
            Text(
              _mt('add_photo'),
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: _primary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              _mt('tap_upload'),
              style: const TextStyle(fontSize: 11, color: _textGrey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoPicker() {
    if (_videoName != null) {
      final sizeMb = _videoSizeBytes == null
          ? ''
          : ' • ${(_videoSizeBytes! / (1024 * 1024)).toStringAsFixed(1)} MB';

      return Container(
        height: 150,
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _purple.withOpacity(0.06),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _purple.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.videocam_rounded, color: _purple, size: 36),
            const SizedBox(height: 8),
            Text(
              '$_videoName$sizeMb',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: _textDark,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _mt('video_note'),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 11, color: _textGrey),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: () {
                setState(() {
                  _videoName = null;
                  _videoSizeBytes = null;
                });
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _purple.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.close_rounded, size: 14, color: _purple),
                    const SizedBox(width: 4),
                    Text(
                      _mt('remove'),
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: _purple,
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

    return InkWell(
      onTap: _pickVideo,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 150,
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFFFAFBFD),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _purple.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: _purple.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.videocam_rounded,
                  color: _purple, size: 22),
            ),
            const SizedBox(height: 10),
            Text(
              _mt('add_video'),
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: _purple,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              _mt('tap_upload'),
              style: const TextStyle(fontSize: 11, color: _textGrey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionCard({
    required String number,
    required String title,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
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
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: _primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  number,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: _primary,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: _textDark,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          child,
        ],
      ),
    );
  }

  Widget _fieldLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: _textGrey,
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    IconData? icon,
    String? prefixText,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
      prefixIcon: icon != null
          ? Icon(icon, size: 20, color: Colors.grey.shade500)
          : null,
      prefixText: prefixText,
      prefixStyle: const TextStyle(
        color: _textDark,
        fontWeight: FontWeight.w600,
      ),
      filled: true,
      fillColor: const Color(0xFFFAFBFD),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _primary, width: 2),
      ),
    );
  }

  Future<void> _submitComplaint() async {
    // Stop mic if still on
    _userWantsListening = false;
    await _speech.stop();

    if (_complaintController.text.trim().isEmpty) {
      _showSnack(loc.t('describe_problem'), _red);
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final GeminiService gemini = GeminiService();
      final Map<String, dynamic> aiAnalysis = await gemini.analyzeGrievance(
        _complaintController.text.trim(),
        _selectedCategory,
        _locationController.text.trim(),
      );

      Map<String, dynamic>? parsedAnalysis;
      int priorityScore = 5;

      try {
        if (aiAnalysis['raw_analysis'] != null) {
          parsedAnalysis = jsonDecode(aiAnalysis['raw_analysis']);
          priorityScore = int.tryParse(
                parsedAnalysis?['priority_score']?.toString() ?? '5',
              ) ??
              5;
        }
      } catch (e) {
        debugPrint('AI parse warning: $e');
      }

      String? photoBase64;
      if (_photoBytes != null) {
        photoBase64 = base64Encode(_photoBytes!);
      }

      await FirebaseFirestore.instance.collection('grievances').add({
        'name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'complaint_text': _complaintController.text.trim(),
        'category': parsedAnalysis?['category'] ?? _selectedCategory,
        'language': widget.localeCode,
        'location_text': _locationController.text.trim(),
        'status': 'processed',
        'priority_score': priorityScore,
        'timestamp': FieldValue.serverTimestamp(),
        'ai_analysis': parsedAnalysis ?? aiAnalysis,
        'ai_summary': parsedAnalysis?['summary'] ?? 'Analysis pending',
        'ai_severity': parsedAnalysis?['severity'] ?? 'medium',
        'ai_sentiment': parsedAnalysis?['sentiment'] ?? 'neutral',
        'ai_actions': parsedAnalysis?['suggested_actions'] ?? [],
        'ai_department':
            parsedAnalysis?['responsible_department'] ?? 'General',
        'has_photo': photoBase64 != null,
        'photo_name': _photoName,
        'photo_base64': photoBase64,
        'has_video': _videoName != null,
        'video_name': _videoName,
        'video_size_bytes': _videoSizeBytes,
        'media_mode': 'firestore_demo_no_storage',
      });

      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _isSubmitted = true;
      });
    } catch (e) {
      try {
        await FirebaseFirestore.instance.collection('grievances').add({
          'name': _nameController.text.trim(),
          'phone': _phoneController.text.trim(),
          'complaint_text': _complaintController.text.trim(),
          'category': _selectedCategory,
          'language': widget.localeCode,
          'location_text': _locationController.text.trim(),
          'status': 'pending',
          'priority_score': 5,
          'timestamp': FieldValue.serverTimestamp(),
          'has_photo': _photoBytes != null,
          'photo_name': _photoName,
          'has_video': _videoName != null,
          'video_name': _videoName,
          'media_mode': 'firestore_demo_no_storage',
        });

        if (!mounted) return;
        setState(() {
          _isSubmitting = false;
          _isSubmitted = true;
        });
      } catch (fallbackError) {
        if (!mounted) return;
        setState(() => _isSubmitting = false);
        _showSnack('Error: $fallbackError', _red);
      }
    }
  }

  Widget _buildSuccessScreen() {
    final String complaintId =
        'CMP-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(36),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _border),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 84,
                  height: 84,
                  decoration: BoxDecoration(
                    color: _green.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.verified_rounded,
                    size: 48,
                    color: _green,
                  ),
                ),
                const SizedBox(height: 22),
                Text(
                  loc.t('success_title'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: _textDark,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF3FF),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'ID: $complaintId',
                    style: const TextStyle(
                      fontSize: 15,
                      color: _primary,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _isSubmitted = false;
                        _nameController.clear();
                        _phoneController.clear();
                        _complaintController.clear();
                        _locationController.clear();
                        _selectedCategory = 'roads';
                        _photoBytes = null;
                        _photoName = null;
                        _videoName = null;
                        _videoSizeBytes = null;
                      });
                    },
                    icon: const Icon(Icons.add_rounded),
                    label: Text(
                      loc.t('file_another'),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}