import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DashboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            '📊 MP Dashboard',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          Text(
            'Real-time constituency overview',
            style: TextStyle(color: Colors.grey[600]),
          ),
          
          SizedBox(height: 20),
          
          // Live Stats from Firebase
          _buildLiveStats(),
          
          SizedBox(height: 20),
          
          // Recent Complaints List
          Text(
            'Recent Complaints',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 12),
          _buildRecentComplaints(),
          
          SizedBox(height: 20),
          
          // Complaints by Category
          Text(
            'Complaints by Category',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 12),
          _buildCategoryBreakdown(),
          SizedBox(height: 20),

          // Projects Section
          Text(
            '🏗️ Active Projects',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 12),
        _buildProjectsList(),
        ],

      ),
    );
  }
  
  Widget _buildProjectsList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
        .collection('projects')
        .limit(5)
        .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return CircularProgressIndicator();
      
        return Column(
          children: snapshot.data!.docs.map((doc) {
            var data = doc.data() as Map<String, dynamic>;
            int progress = data['progress_percentage'] ?? 0;
            Color statusColor = data['status'] == 'completed' ? Colors.green :
                             data['status'] == 'delayed' ? Colors.red : Colors.orange;
          
            return Card(
              margin: EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 40, height: 40,
                      child: CircularProgressIndicator(
                        value: progress / 100,
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                        strokeWidth: 4,
                      ),
                    ),
                    Text('$progress%', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                  ],
                ),
                title: Text(data['project_name'] ?? '', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                subtitle: Text('Budget: ₹${((data['budget_sanctioned'] ?? 0) / 100000).toStringAsFixed(1)}L'),
                trailing: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    (data['status'] ?? '').toString().toUpperCase(),
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: statusColor),
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  } 
  // Live stats from Firestore
  Widget _buildLiveStats() {
    return StreamBuilder<QuerySnapshot>(
      // StreamBuilder automatically updates when data changes in Firebase
      stream: FirebaseFirestore.instance.collection('grievances').snapshots(),
      builder: (context, snapshot) {
        // While loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        
        // If error
        if (snapshot.hasError) {
          return Text('Error loading data');
        }
        
        // Calculate stats
        int total = snapshot.data?.docs.length ?? 0;
        int pending = 0;
        int resolved = 0;
        
        for (var doc in snapshot.data!.docs) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          if (data['status'] == 'resolved') {
            resolved++;
          } else {
            pending++;
          }
        }
        
        return Row(
          children: [
            Expanded(
              child: _buildDashStatCard('Total', '$total', Colors.blue, Icons.list_alt),
            ),
            SizedBox(width: 8),
            Expanded(
              child: _buildDashStatCard('Pending', '$pending', Colors.orange, Icons.pending),
            ),
            SizedBox(width: 8),
            Expanded(
              child: _buildDashStatCard('Resolved', '$resolved', Colors.green, Icons.check_circle),
            ),
          ],
        );
      },
    );
  }
  
  Widget _buildDashStatCard(String label, String value, Color color, IconData icon) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: color),
            ),
            Text(label, style: TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
  
  // Recent complaints from Firebase
  Widget _buildRecentComplaints() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('grievances')
          .orderBy('timestamp', descending: true)
          .limit(5)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Card(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Center(child: Text('No complaints yet. File one to test!')),
            ),
          );
        }
        
        return Column(
          children: snapshot.data!.docs.map((doc) {
            Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
            
            return Card(
              margin: EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: _getCategoryColor(data['category'] ?? 'other'),
                  child: Icon(_getCategoryIcon(data['category'] ?? 'other'), color: Colors.white, size: 20),
                ),
                title: Text(
                  data['complaint_text'] ?? 'No description',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 14),
                ),
                subtitle: Row(
                  children: [
                    Icon(Icons.location_on, size: 14, color: Colors.grey),
                    SizedBox(width: 4),
                    Text(
                      data['location_text'] ?? 'Unknown location',
                      style: TextStyle(fontSize: 12),
                    ),
                    Spacer(),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: data['status'] == 'resolved' ? Colors.green[100] : Colors.orange[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        (data['status'] ?? 'pending').toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: data['status'] == 'resolved' ? Colors.green[800] : Colors.orange[800],
                        ),
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
  
  // Category breakdown
  Widget _buildCategoryBreakdown() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('grievances').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return CircularProgressIndicator();
        
        // Count by category
        Map<String, int> categoryCounts = {};
        for (var doc in snapshot.data!.docs) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          String category = data['category'] ?? 'other';
          categoryCounts[category] = (categoryCounts[category] ?? 0) + 1;
        }
        
        if (categoryCounts.isEmpty) {
          return Text('No data yet');
        }
        
        // Sort by count
        var sortedEntries = categoryCounts.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));
        
        return Column(
          children: sortedEntries.map((entry) {
            double percentage = (entry.value / snapshot.data!.docs.length) * 100;
            
            return Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatCategory(entry.key),
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                      ),
                      Text(
                        '${entry.value} (${percentage.toStringAsFixed(0)}%)',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  SizedBox(height: 4),
                  // Progress bar showing percentage
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: percentage / 100,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _getCategoryColor(entry.key),
                      ),
                      minHeight: 8,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }
  
  // Helper: Get color for category
  Color _getCategoryColor(String category) {
  switch (category) {
    case 'roads': return Colors.brown;
    case 'water': return Colors.blue;
    case 'electricity': return Colors.amber;
    case 'health': return Colors.red;
    case 'education': return Colors.green;
    case 'sanitation': return Colors.teal;
    case 'street_lights': return Colors.orange;
    case 'drainage': return Colors.indigo;
    case 'garbage': return Colors.grey;
    default: return Colors.purple;
   }
  }
  
  // Helper: Get icon for category
  IconData _getCategoryIcon(String category) {
  switch (category) {
    case 'roads': return Icons.add_road;
    case 'water': return Icons.water_drop;
    case 'electricity': return Icons.electrical_services;
    case 'health': return Icons.local_hospital;
    case 'education': return Icons.school;
    case 'sanitation': return Icons.cleaning_services;
    case 'street_lights': return Icons.lightbulb;
    case 'drainage': return Icons.water;
    case 'garbage': return Icons.delete_outline;
    default: return Icons.more_horiz;
    }
  }
  
  // Helper: Format category name
  String _formatCategory(String category) {
    return category.replaceAll('_', ' ').split(' ').map((word) {
      return word[0].toUpperCase() + word.substring(1);
    }).join(' ');
  }
}