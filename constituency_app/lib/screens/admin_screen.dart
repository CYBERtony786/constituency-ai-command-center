import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

class AdminScreen extends StatefulWidget {
  @override
  _AdminScreenState createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  bool _isLoading = false;
  String _statusMessage = '';
  
  final Random random = Random();
  
  // Sample complaint texts
  final List<Map<String, String>> sampleComplaints = [
    {'category': 'roads', 'text': 'The main road near Government School has developed a large pothole causing accidents', 'location': 'Ward 5, Main Road'},
    {'category': 'roads', 'text': 'Road construction has been abandoned for 3 months, debris blocking path', 'location': 'Ward 12, Market Area'},
    {'category': 'water', 'text': 'No water supply for the last 4 days in our area', 'location': 'Village Rampur'},
    {'category': 'water', 'text': 'Water pipeline is leaking, wasting water for 2 weeks', 'location': 'Ward 3, Temple Road'},
    {'category': 'water', 'text': 'Borwell not working, 500 families affected', 'location': 'Village Sundarpur'},
    {'category': 'electricity', 'text': 'Power cuts of 8 hours daily, children cannot study', 'location': 'Ward 7'},
    {'category': 'electricity', 'text': 'Transformer burnt 5 days ago, no replacement', 'location': 'Village Laxmipur'},
    {'category': 'health', 'text': 'Primary Health Centre has no medicines in stock', 'location': 'Ward 2, PHC Area'},
    {'category': 'health', 'text': 'No doctor available at government hospital on weekends', 'location': 'Ward 1, Civil Hospital'},
    {'category': 'education', 'text': 'School roof is leaking, dangerous for children during rain', 'location': 'Ward 8, Govt School'},
    {'category': 'education', 'text': 'Only 1 teacher for 200 students in primary school', 'location': 'Village Chandanpur'},
    {'category': 'sanitation', 'text': 'Open drain overflowing near residential area', 'location': 'Ward 4'},
    {'category': 'sanitation', 'text': 'Public toilet in market area is non-functional for 6 months', 'location': 'Ward 6, Market'},
    {'category': 'street_lights', 'text': '15 street lights broken on highway stretch, very unsafe at night', 'location': 'Ward 10, NH Road'},
    {'category': 'street_lights', 'text': 'New colony has zero street lights installed', 'location': 'Ward 15, New Colony'},
    {'category': 'drainage', 'text': 'Drainage blocked causing waterlogging during every rain', 'location': 'Ward 9'},
    {'category': 'drainage', 'text': 'Sewage water entering houses, health hazard', 'location': 'Ward 11, Low Area'},
    {'category': 'garbage', 'text': 'Garbage not collected for 10 days, terrible smell', 'location': 'Ward 3, Block B'},
    {'category': 'garbage', 'text': 'Illegal garbage dump near school, children falling sick', 'location': 'Ward 13'},
    {'category': 'roads', 'text': 'Speed breaker too high, causing vehicle damage', 'location': 'Ward 6, College Road'},
    {'category': 'water', 'text': 'Contaminated water supply causing diarrhea outbreak', 'location': 'Village Haridwar Nagar'},
    {'category': 'electricity', 'text': 'Exposed electrical wires near playground, very dangerous', 'location': 'Ward 14, Park Area'},
    {'category': 'health', 'text': 'Ambulance service not responding to emergencies', 'location': 'Ward 2'},
    {'category': 'education', 'text': 'Mid-day meal quality very poor, children refusing to eat', 'location': 'Ward 5, Primary School'},
    {'category': 'roads', 'text': 'No footpath for pedestrians on busy road', 'location': 'Ward 1, Station Road'},
  ];
  
  // Sample names
  final List<String> sampleNames = [
    'Rajesh Kumar', 'Priya Sharma', 'Amit Singh', 'Sunita Devi',
    'Mohammad Ali', 'Lakshmi Bai', 'Vikram Patel', 'Anita Gupta',
    'Ravi Verma', 'Meena Kumari', 'Sanjay Yadav', 'Pooja Mishra',
  ];
  
  Future<void> _addSampleData() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Adding sample complaints...';
    });
    
    try {
      // Add 25 sample grievances
      for (int i = 0; i < sampleComplaints.length; i++) {
        var complaint = sampleComplaints[i];
        
        // Random date within last 30 days
        DateTime randomDate = DateTime.now().subtract(
          Duration(days: random.nextInt(30), hours: random.nextInt(24)),
        );
        
        await FirebaseFirestore.instance.collection('grievances').add({
          'name': sampleNames[random.nextInt(sampleNames.length)],
          'phone': '9${random.nextInt(900000000) + 100000000}',
          'complaint_text': complaint['text'],
          'category': complaint['category'],
          'language': ['Hindi', 'English', 'Tamil'][random.nextInt(3)],
          'location_text': complaint['location'],
          'status': ['pending', 'pending', 'pending', 'resolved'][random.nextInt(4)],
          'priority_score': random.nextInt(10) + 1,
          'timestamp': Timestamp.fromDate(randomDate),
          'ai_analysis': null,
        });
        
        setState(() {
          _statusMessage = 'Added ${i + 1}/${sampleComplaints.length} complaints...';
        });
      }
      
      // Add 10 sample projects
      setState(() {
        _statusMessage = 'Adding sample projects...';
      });
      
      List<Map<String, dynamic>> sampleProjects = [
        {'name': 'Ward 5 Road Repair', 'category': 'roads', 'budget': 6500000, 'progress': 65, 'status': 'in_progress'},
        {'name': 'Village Rampur Water Pipeline', 'category': 'water', 'budget': 12000000, 'progress': 30, 'status': 'in_progress'},
        {'name': 'PHC Ward 2 Upgrade', 'category': 'health', 'budget': 4500000, 'progress': 90, 'status': 'in_progress'},
        {'name': 'Street Light Installation NH Road', 'category': 'street_lights', 'budget': 2000000, 'progress': 100, 'status': 'completed'},
        {'name': 'Primary School Roof Repair', 'category': 'education', 'budget': 1500000, 'progress': 45, 'status': 'delayed'},
        {'name': 'Ward 9 Drainage System', 'category': 'drainage', 'budget': 8000000, 'progress': 20, 'status': 'in_progress'},
        {'name': 'Community Toilet Construction', 'category': 'sanitation', 'budget': 3000000, 'progress': 80, 'status': 'in_progress'},
        {'name': 'Village Borwell Installation', 'category': 'water', 'budget': 500000, 'progress': 100, 'status': 'completed'},
        {'name': 'Ward 14 Park Development', 'category': 'other', 'budget': 7500000, 'progress': 55, 'status': 'in_progress'},
        {'name': 'Market Road Widening', 'category': 'roads', 'budget': 15000000, 'progress': 10, 'status': 'delayed'},
      ];
      
      for (int i = 0; i < sampleProjects.length; i++) {
        var project = sampleProjects[i];
        
        await FirebaseFirestore.instance.collection('projects').add({
          'project_name': project['name'],
          'category': project['category'],
          'budget_sanctioned': project['budget'],
          'budget_spent': (project['budget'] as int) * (project['progress'] as int) ~/ 100,
          'progress_percentage': project['progress'],
          'status': project['status'],
          'beneficiaries_count': random.nextInt(20000) + 1000,
          'location': project['name'].split(' ').first,
          'start_date': Timestamp.fromDate(DateTime.now().subtract(Duration(days: random.nextInt(180) + 30))),
          'expected_completion': Timestamp.fromDate(DateTime.now().add(Duration(days: random.nextInt(180) + 30))),
          'created_at': FieldValue.serverTimestamp(),
        });
        
        setState(() {
          _statusMessage = 'Added ${i + 1}/${sampleProjects.length} projects...';
        });
      }
      
      // Add constituency profile
      await FirebaseFirestore.instance.collection('constituency_profile').doc('demo').set({
        'name': 'Mumbai North',
        'mp_name': 'Demo MP',
        'total_population': 1500000,
        'literacy_rate': 82.5,
        'total_wards': 20,
        'total_villages': 15,
        'mplads_budget': 50000000, // 5 crores
        'budget_used': 31000000,
      });
      
      setState(() {
        _isLoading = false;
        _statusMessage = '✅ All sample data added successfully!';
      });
      
    } catch (e) {
      setState(() {
        _isLoading = false;
        _statusMessage = '❌ Error: $e';
      });
    }
  }
  
  Future<void> _clearAllData() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Clearing data...';
    });
    
    try {
      // Delete all grievances
      var grievances = await FirebaseFirestore.instance.collection('grievances').get();
      for (var doc in grievances.docs) {
        await doc.reference.delete();
      }
      
      // Delete all projects
      var projects = await FirebaseFirestore.instance.collection('projects').get();
      for (var doc in projects.docs) {
        await doc.reference.delete();
      }
      
      setState(() {
        _isLoading = false;
        _statusMessage = '✅ All data cleared!';
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _statusMessage = '❌ Error: $e';
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Panel'),
        backgroundColor: Colors.red[700],
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.admin_panel_settings, size: 64, color: Colors.red),
              SizedBox(height: 24),
              Text('Sample Data Manager', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('Add or remove test data for demo', style: TextStyle(color: Colors.grey)),
              SizedBox(height: 32),
              
              if (_isLoading)
                Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text(_statusMessage),
                  ],
                )
              else
                Column(
                  children: [
                    SizedBox(
                      width: 250,
                      child: ElevatedButton.icon(
                        onPressed: _addSampleData,
                        icon: Icon(Icons.add_circle),
                        label: Text('Add Sample Data'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    SizedBox(
                      width: 250,
                      child: OutlinedButton.icon(
                        onPressed: _clearAllData,
                        icon: Icon(Icons.delete_forever, color: Colors.red),
                        label: Text('Clear All Data', style: TextStyle(color: Colors.red)),
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          side: BorderSide(color: Colors.red),
                        ),
                      ),
                    ),
                    SizedBox(height: 24),
                    Text(
                      _statusMessage,
                      style: TextStyle(
                        fontSize: 16,
                        color: _statusMessage.contains('✅') ? Colors.green : 
                               _statusMessage.contains('❌') ? Colors.red : Colors.blue,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}