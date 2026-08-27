// File: lib/screens/grievance_form.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/gemini_service.dart';
import 'dart:convert';

class GrievanceForm extends StatefulWidget {
  @override
  _GrievanceFormState createState() => _GrievanceFormState();
}

class _GrievanceFormState extends State<GrievanceForm> {
  // Controllers to get text from input fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _complaintController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  
  // Selected category
  String _selectedCategory = 'roads';
  
  // Selected language
  String _selectedLanguage = 'English';
  
  // Is the form being submitted?
  bool _isSubmitting = false;
  
  // Has the form been submitted?
  bool _isSubmitted = false;
  
  // Categories list with icons
  final List<Map<String, dynamic>> categories = [
    {'id': 'roads', 'label': 'Roads & Transport', 'icon': Icons.add_road, 'color': Colors.brown},
    {'id': 'water', 'label': 'Water Supply', 'icon': Icons.water_drop, 'color': Colors.blue},
    {'id': 'electricity', 'label': 'Electricity', 'icon': Icons.electrical_services, 'color': Colors.amber},
    {'id': 'health', 'label': 'Healthcare', 'icon': Icons.local_hospital, 'color': Colors.red},
    {'id': 'education', 'label': 'Education', 'icon': Icons.school, 'color': Colors.green},
    {'id': 'sanitation', 'label': 'Sanitation', 'icon': Icons.cleaning_services, 'color': Colors.teal},
    {'id': 'street_lights', 'label': 'Street Lights', 'icon': Icons.lightbulb, 'color': Colors.orange},
    {'id': 'drainage', 'label': 'Drainage', 'icon': Icons.water, 'color': Colors.indigo},
    {'id': 'garbage', 'label': 'Garbage', 'icon': Icons.delete_outline, 'color': Colors.grey},
    {'id': 'other', 'label': 'Other', 'icon': Icons.more_horiz, 'color': Colors.purple},
  ];
  
  // Languages
  final List<String> languages = [
    'English', 'Hindi', 'Tamil', 'Telugu', 'Bengali',
    'Marathi', 'Gujarati', 'Kannada', 'Malayalam', 'Punjabi',
  ];
  
  @override
  Widget build(BuildContext context) {
    // If form is submitted, show success screen
    if (_isSubmitted) {
      return _buildSuccessScreen();
    }
    
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Card(
            color: Colors.red[50],
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.report_problem, color: Colors.red, size: 30),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'File a Complaint',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Your voice matters. Report issues in your area.',
                          style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          SizedBox(height: 20),
          
          // Language Selector
          Text('Select Language', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButton<String>(
              value: _selectedLanguage,
              isExpanded: true,
              underline: SizedBox(),
              items: languages.map((lang) {
                return DropdownMenuItem(
                  value: lang,
                  child: Text(lang),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedLanguage = value!;
                });
              },
            ),
          ),
          
          SizedBox(height: 20),
          
          // Name Field
          Text('Your Name (Optional)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              hintText: 'Enter your name',
              prefixIcon: Icon(Icons.person),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
          
          SizedBox(height: 16),
          
          // Phone Field
          Text('Mobile Number', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          TextField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              hintText: 'For SMS updates on your complaint',
              prefixIcon: Icon(Icons.phone),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              prefixText: '+91 ',
            ),
          ),
          
          SizedBox(height: 20),
          
          // Category Selection
          Text('Select Category', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          
          // Grid of category buttons
          GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 1.1,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              final isSelected = _selectedCategory == category['id'];
              
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedCategory = category['id'];
                  });
                },
                child: Card(
                  color: isSelected ? (category['color'] as Color).withOpacity(0.2) : Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: isSelected ? category['color'] : Colors.grey[300]!,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        category['icon'],
                        size: 28,
                        color: isSelected ? category['color'] : Colors.grey[600],
                      ),
                      SizedBox(height: 4),
                      Text(
                        category['label'],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? category['color'] : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          
          SizedBox(height: 20),
          
          // Location Field
          Text('Location', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          TextField(
            controller: _locationController,
            decoration: InputDecoration(
              hintText: 'Ward/Village/Area name',
              prefixIcon: Icon(Icons.location_on, color: Colors.red),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
          
          SizedBox(height: 20),
          
          // Complaint Description
          Text('Describe Your Problem *', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          TextField(
            controller: _complaintController,
            maxLines: 5,
            decoration: InputDecoration(
              hintText: 'Example: The road near my house has a big pothole. It has been there for 2 weeks. Many people have fallen.',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
          
          SizedBox(height: 30),
          
          // Submit Button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _submitComplaint,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isSubmitting
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        ),
                        SizedBox(width: 12),
                        Text('Submitting...', style: TextStyle(fontSize: 18)),
                      ],
                    )
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.send, size: 20),
                        SizedBox(width: 10),
                        Text(
                          'SUBMIT COMPLAINT',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
          SizedBox(height: 40),
        ],
      ),
    );
  }
  
  // Submit function with AI analysis
  void _submitComplaint() async {
    // Validate
    if (_complaintController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please describe your complaint'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    // Show loading
    setState(() {
      _isSubmitting = true;
    });
    
    try {
      // Step 1: Get AI Analysis from Gemini
      GeminiService gemini = GeminiService();
      Map<String, dynamic> aiAnalysis = await gemini.analyzeGrievance(
        _complaintController.text,
        _selectedCategory,
        _locationController.text,
      );
      
      // Step 2: Try to parse the AI response
      Map<String, dynamic>? parsedAnalysis;
      int priorityScore = 5;
      
      try {
        if (aiAnalysis['raw_analysis'] != null) {
          parsedAnalysis = jsonDecode(aiAnalysis['raw_analysis']);
          priorityScore = int.tryParse(parsedAnalysis?['priority_score']?.toString() ?? '5') ?? 5;
        }
      } catch (e) {
        print('Could not parse AI response: $e');
        // Not critical - we'll save the raw analysis
      }
      
      // Step 3: Save to Firebase with AI analysis
      DocumentReference docRef = await FirebaseFirestore.instance.collection('grievances').add({
        'name': _nameController.text,
        'phone': _phoneController.text,
        'complaint_text': _complaintController.text,
        'category': parsedAnalysis?['category'] ?? _selectedCategory,
        'language': _selectedLanguage,
        'location_text': _locationController.text,
        'status': 'processed',
        'priority_score': priorityScore,
        'timestamp': FieldValue.serverTimestamp(),
        'ai_analysis': parsedAnalysis ?? aiAnalysis,
        'ai_summary': parsedAnalysis?['summary'] ?? 'Analysis pending',
        'ai_severity': parsedAnalysis?['severity'] ?? 'medium',
        'ai_sentiment': parsedAnalysis?['sentiment'] ?? 'neutral',
        'ai_actions': parsedAnalysis?['suggested_actions'] ?? [],
        'ai_department': parsedAnalysis?['responsible_department'] ?? 'General',
      });
      
      setState(() {
        _isSubmitting = false;
        _isSubmitted = true;
      });
      
    } catch (e) {
      // If AI fails, still save complaint without analysis
      try {
        await FirebaseFirestore.instance.collection('grievances').add({
          'name': _nameController.text,
          'phone': _phoneController.text,
          'complaint_text': _complaintController.text,
          'category': _selectedCategory,
          'language': _selectedLanguage,
          'location_text': _locationController.text,
          'status': 'pending',
          'priority_score': 5,
          'timestamp': FieldValue.serverTimestamp(),
          'ai_analysis': null,
        });
        
        setState(() {
          _isSubmitting = false;
          _isSubmitted = true;
        });
      } catch (e2) {
        setState(() {
          _isSubmitting = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e2'), backgroundColor: Colors.red),
        );
      }
    }
  }
  
  // Success screen after submission
  Widget _buildSuccessScreen() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Green checkmark animation
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.green[50],
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.check_circle, size: 80, color: Colors.green),
            ),
            
            SizedBox(height: 24),
            
            Text(
              'Complaint Submitted! ✅',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            
            SizedBox(height: 12),
            
            Text(
              'Complaint ID: CMP-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
              style: TextStyle(fontSize: 16, color: Colors.blue, fontWeight: FontWeight.bold),
            ),
            
            SizedBox(height: 8),
            
            Text(
              'You will receive SMS updates on your phone.',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            
            SizedBox(height: 32),
            
            ElevatedButton(
              onPressed: () {
                // Reset form
                setState(() {
                  _isSubmitted = false;
                  _nameController.clear();
                  _phoneController.clear();
                  _complaintController.clear();
                  _locationController.clear();
                  _selectedCategory = 'roads';
                });
              },
              child: Text('File Another Complaint'),
            ),
          ],
        ),
      ),
    );
  }
}