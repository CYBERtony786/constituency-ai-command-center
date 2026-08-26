import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/gemini_service.dart';

class ResourcePlanner extends StatefulWidget {
  @override
  _ResourcePlannerState createState() => _ResourcePlannerState();
}

class _ResourcePlannerState extends State<ResourcePlanner> {
  double budget = 5.0; // Default 5 crores
  bool isGenerating = false;
  String? allocationPlan;
  
  final GeminiService _gemini = GeminiService();
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('💰 Resource Planner'),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Budget Slider
            Card(
              color: Colors.green[50],
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text('MPLADS Budget', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    Text(
                      '₹${budget.toStringAsFixed(1)} Crores',
                      style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.green[800]),
                    ),
                    Slider(
                      value: budget,
                      min: 1,
                      max: 10,
                      divisions: 18,
                      activeColor: Colors.green,
                      label: '₹${budget.toStringAsFixed(1)} Cr',
                      onChanged: (value) {
                        setState(() {
                          budget = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            
            SizedBox(height: 16),
            
            // Current Grievance Stats
            Text('Current Grievance Pressure:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            _buildGrievanceStats(),
            
            SizedBox(height: 20),
            
            // Generate Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: isGenerating ? null : _generatePlan,
                icon: Icon(Icons.auto_awesome),
                label: Text(
                  isGenerating ? 'AI is generating plan...' : 'GENERATE AI ALLOCATION PLAN',
                  style: TextStyle(fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            
            if (isGenerating)
              Padding(
                padding: EdgeInsets.all(32),
                child: Center(child: CircularProgressIndicator()),
              ),
            
            // Show Plan
            if (allocationPlan != null) ...[
              SizedBox(height: 20),
              Card(
                color: Colors.blue[50],
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.auto_awesome, color: Colors.blue),
                          SizedBox(width: 8),
                          Text('AI Allocation Plan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      Divider(),
                      SizedBox(height: 8),
                      SelectableText(
                        allocationPlan!,
                        style: TextStyle(fontSize: 14, height: 1.6),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            
            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
  
  Widget _buildGrievanceStats() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('grievances').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return CircularProgressIndicator();
        
        Map<String, int> categoryCounts = {};
        for (var doc in snapshot.data!.docs) {
          var data = doc.data() as Map<String, dynamic>;
          String cat = data['category'] ?? 'other';
          categoryCounts[cat] = (categoryCounts[cat] ?? 0) + 1;
        }
        
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: categoryCounts.entries.map((entry) {
            return Chip(
              label: Text('${entry.key}: ${entry.value}'),
              backgroundColor: Colors.orange[50],
            );
          }).toList(),
        );
      },
    );
  }
  
  Future<void> _generatePlan() async {
    setState(() {
      isGenerating = true;
      allocationPlan = null;
    });
    
    try {
      // Get current grievance counts
      QuerySnapshot grievances = await FirebaseFirestore.instance.collection('grievances').get();
      
      Map<String, int> categoryCounts = {};
      for (var doc in grievances.docs) {
        var data = doc.data() as Map<String, dynamic>;
        String cat = data['category'] ?? 'other';
        categoryCounts[cat] = (categoryCounts[cat] ?? 0) + 1;
      }
      
      // Generate plan with Gemini
      String plan = await _gemini.generateAllocationPlan(budget, categoryCounts);
      
      setState(() {
        allocationPlan = plan;
        isGenerating = false;
      });
      
    } catch (e) {
      setState(() {
        allocationPlan = 'Error generating plan: $e';
        isGenerating = false;
      });
    }
  }
}