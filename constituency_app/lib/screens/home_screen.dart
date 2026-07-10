import 'grievance_form.dart';
// File: lib/screens/home_screen.dart

import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // This tracks which tab is selected (0, 1, 2, 3)
  int _selectedIndex = 0;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Constituency AI'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        actions: [
          // Language button (we'll add functionality later)
          IconButton(
            icon: Icon(Icons.language),
            onPressed: () {
              // Will add language selection later
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Language feature coming soon!')),
              );
            },
          ),
        ],
      ),
      
      // Body changes based on selected tab
      body: _getBody(),
      
      // Bottom Navigation Bar
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (int index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: [
          NavigationDestination(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.report_problem),
            label: 'Complaints',
          ),
          NavigationDestination(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.chat),
            label: 'AI Chat',
          ),
        ],
      ),
    );
  }
  
  // This returns different content based on selected tab
  Widget _getBody() {
    switch (_selectedIndex) {
      case 0:
        return _buildHomePage();
      case 1:
        return _buildComplaintsPlaceholder();
      case 2:
        return _buildDashboardPlaceholder();
      case 3:
        return _buildChatPlaceholder();
      default:
        return _buildHomePage();
    }
  }
  
  // HOME PAGE
  Widget _buildHomePage() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Card
          Card(
            color: Colors.blue[50],
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Row(
                children: [
                  Icon(Icons.account_balance, size: 50, color: Colors.blue[700]),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Namaste! 🙏',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'AI-powered governance for your constituency',
                          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          SizedBox(height: 20),
          
          // Stats Cards Row
          Text(
            'Today\'s Overview',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 12),
          
          Row(
            children: [
              Expanded(child: _buildStatCard('New\nComplaints', '23', Colors.red, Icons.warning)),
              SizedBox(width: 8),
              Expanded(child: _buildStatCard('Resolved\nToday', '15', Colors.green, Icons.check_circle)),
            ],
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _buildStatCard('Active\nProjects', '12', Colors.blue, Icons.construction)),
              SizedBox(width: 8),
              Expanded(child: _buildStatCard('Budget\nUsed', '62%', Colors.orange, Icons.currency_rupee)),
            ],
          ),
          
          SizedBox(height: 24),
          
          // Quick Actions
          Text(
            'Quick Actions',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 12),
          
          _buildActionCard(
            'File a Complaint',
            'Report infrastructure issues, water problems, etc.',
            Icons.report_problem,
            Colors.red,
            () {
              setState(() {
                _selectedIndex = 1; // Switch to complaints tab
              });
            },
          ),
          
          _buildActionCard(
            'View Dashboard',
            'See constituency overview and analytics',
            Icons.dashboard,
            Colors.blue,
            () {
              setState(() {
                _selectedIndex = 2; // Switch to dashboard tab
              });
            },
          ),
          
          _buildActionCard(
            'Ask AI Assistant',
            'Get instant answers about your constituency',
            Icons.smart_toy,
            Colors.purple,
            () {
              setState(() {
                _selectedIndex = 3; // Switch to chat tab
              });
            },
          ),
          
          _buildActionCard(
            'Track Complaint',
            'Check status of your existing complaint',
            Icons.track_changes,
            Colors.teal,
            () {
              // Will add tracking later
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Tracking feature coming soon!')),
              );
            },
          ),
        ],
      ),
    );
  }
  
  // Reusable stat card widget
  Widget _buildStatCard(String label, String value, Color color, IconData icon) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 30, color: color),
            SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
  
  // Reusable action card widget
  Widget _buildActionCard(String title, String subtitle, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      margin: EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.2),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
  
  // Placeholder screens (we'll build these later)
  Widget _buildComplaintsPlaceholder() {
  return GrievanceForm();
  }
  
  Widget _buildDashboardPlaceholder() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.construction, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text('Dashboard', style: TextStyle(fontSize: 20)),
          Text('Building this next...', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
  
  Widget _buildChatPlaceholder() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.construction, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text('AI Chat', style: TextStyle(fontSize: 20)),
          Text('Building this next...', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}