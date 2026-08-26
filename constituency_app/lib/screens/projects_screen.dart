import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProjectsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('🏗️ Project Monitor', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          Text('Track all constituency projects', style: TextStyle(color: Colors.grey[600])),
          SizedBox(height: 16),
          
          // Project summary
          _buildProjectSummary(),
          
          SizedBox(height: 20),
          
          // Project list
          _buildProjectList(),
        ],
      ),
    );
  }
  
  Widget _buildProjectSummary() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('projects').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return CircularProgressIndicator();
        
        int total = snapshot.data!.docs.length;
        int completed = 0;
        int inProgress = 0;
        int delayed = 0;
        double totalBudget = 0;
        
        for (var doc in snapshot.data!.docs) {
          var data = doc.data() as Map<String, dynamic>;
          if (data['status'] == 'completed') completed++;
          else if (data['status'] == 'delayed') delayed++;
          else inProgress++;
          totalBudget += (data['budget_sanctioned'] ?? 0).toDouble();
        }
        
        return Column(
          children: [
            Row(
              children: [
                Expanded(child: _buildMiniStat('Total', '$total', Colors.blue)),
                SizedBox(width: 6),
                Expanded(child: _buildMiniStat('Active', '$inProgress', Colors.orange)),
                SizedBox(width: 6),
                Expanded(child: _buildMiniStat('Done', '$completed', Colors.green)),
                SizedBox(width: 6),
                Expanded(child: _buildMiniStat('Delayed', '$delayed', Colors.red)),
              ],
            ),
            SizedBox(height: 8),
            Card(
              color: Colors.blue[50],
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.currency_rupee, color: Colors.blue),
                    Text(
                      ' Total Budget: ₹${(totalBudget / 10000000).toStringAsFixed(2)} Crores',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue[800]),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
  
  Widget _buildMiniStat(String label, String value, Color color) {
    return Card(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Column(
          children: [
            Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
            Text(label, style: TextStyle(fontSize: 11, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
  
  Widget _buildProjectList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('projects').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return CircularProgressIndicator();
        
        if (snapshot.data!.docs.isEmpty) {
          return Card(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Center(child: Text('No projects yet')),
            ),
          );
        }
        
        return Column(
          children: snapshot.data!.docs.map((doc) {
            var data = doc.data() as Map<String, dynamic>;
            
            Color statusColor = data['status'] == 'completed' ? Colors.green :
                               data['status'] == 'delayed' ? Colors.red : Colors.orange;
            String statusText = (data['status'] ?? 'unknown').toString().toUpperCase();
            int progress = data['progress_percentage'] ?? 0;
            double budget = (data['budget_sanctioned'] ?? 0).toDouble();
            
            return Card(
              margin: EdgeInsets.only(bottom: 12),
              elevation: 2,
              child: Column(
                children: [
                  // Header
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border(left: BorderSide(color: statusColor, width: 4)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                data['project_name'] ?? 'Unnamed Project',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: statusColor.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                statusText,
                                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: statusColor),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 4),
                        Text(
                          data['location'] ?? '',
                          style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                  
                  // Progress
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Progress', style: TextStyle(fontSize: 12)),
                            Text('$progress%', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        SizedBox(height: 4),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: progress / 100,
                            backgroundColor: Colors.grey[200],
                            valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                            minHeight: 8,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  SizedBox(height: 8),
                  
                  // Stats row
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildProjectDetailItem(Icons.currency_rupee, '₹${(budget / 100000).toStringAsFixed(1)}L', 'Budget'),
                        _buildProjectDetailItem(Icons.people, '${data['beneficiaries_count'] ?? 0}', 'Beneficiaries'),
                        _buildProjectDetailItem(Icons.category, _formatCategory(data['category'] ?? ''), 'Type'),
                      ],
                    ),
                  ),
                  
                  SizedBox(height: 12),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }
  
  Widget _buildProjectDetailItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, size: 18, color: Colors.grey[600]),
        SizedBox(height: 2),
        Text(value, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        Text(label, style: TextStyle(fontSize: 10, color: Colors.grey)),
      ],
    );
  }
  
  String _formatCategory(String category) {
    return category.replaceAll('_', ' ').split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1);
    }).join(' ');
  }
}