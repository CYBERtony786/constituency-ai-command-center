// File: lib/screens/home_screen.dart
import 'grievance_form.dart';
import 'package:flutter/material.dart';
import 'dashboard_screen.dart';
import 'admin_screen.dart';
import 'projects_screen.dart';
import 'chat_screen.dart';
import 'resource_planner.dart';
import 'track_complaint.dart';

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
        title: GestureDetector(
          onLongPress: () {
            // Secret admin access - long press title
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AdminScreen()),
            );
          },
          child: Text('Constituency AI'),
        ),
        // ... rest stays same
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
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ════════════════════════════════════════════════════════
        // WELCOME BANNER (Improved Day 14)
        // ════════════════════════════════════════════════════════
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFF0B57D0),
                Color(0xFF4285F4),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.20),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.account_balance,
                  color: Colors.white,
                  size: 32,
                ),
              ),

              const SizedBox(width: 16),

              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Namaste! 🙏',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    SizedBox(height: 6),

                    Text(
                      'AI-powered governance for a smarter, more responsive constituency.',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // ════════════════════════════════════════════════════════
        // TODAY'S OVERVIEW
        // ════════════════════════════════════════════════════════
        const Text(
          "Today's Overview",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 12),

        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'New\nComplaints',
                '23',
                Colors.red,
                Icons.warning,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildStatCard(
                'Resolved\nToday',
                '15',
                Colors.green,
                Icons.check_circle,
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Active\nProjects',
                '12',
                Colors.blue,
                Icons.construction,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildStatCard(
                'Budget\nUsed',
                '62%',
                Colors.orange,
                Icons.currency_rupee,
              ),
            ),
          ],
        ),

        const SizedBox(height: 24),

        // ════════════════════════════════════════════════════════
        // QUICK ACTIONS
        // ════════════════════════════════════════════════════════
        const Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 12),

        _buildActionCard(
          'File a Complaint',
          'Report infrastructure issues, water problems, etc.',
          Icons.report_problem,
          Colors.red,
          () {
            setState(() {
              _selectedIndex = 1;
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
              _selectedIndex = 2;
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
              _selectedIndex = 3;
            });
          },
        ),

        _buildActionCard(
          'Track Complaint',
          'Check status of your existing complaint',
          Icons.track_changes,
          Colors.teal,
          () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TrackComplaintScreen(),
              ),
            );
          },
        ),

        _buildActionCard(
          'AI Resource Planner',
          'Let AI plan your MPLADS budget allocation',
          Icons.currency_rupee,
          Colors.green,
          () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ResourcePlanner(),
              ),
            );
          },
        ),

        const SizedBox(height: 20),

        // ════════════════════════════════════════════════════════
        // BUILT FOR EVERY CITIZEN FOOTER
        // ════════════════════════════════════════════════════════
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.blue.withOpacity(0.18),
            ),
          ),
          child: const Column(
            children: [
              Icon(
                Icons.diversity_3,
                color: Color(0xFF0B57D0),
                size: 30,
              ),

              SizedBox(height: 8),

              Text(
                'Built for Every Citizen',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0B57D0),
                ),
              ),

              SizedBox(height: 5),

              Text(
                'Simple grievance reporting, AI-powered insights, and transparent constituency planning.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 30),
      ],
    ),
  );
}
  
  // Reusable stat card widget
  Widget _buildStatCard(
  String label,
  String value,
  Color color,
  IconData icon,
) {
  return Card(
    child: Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 16,
      ),
      child: Column(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              size: 23,
              color: color,
            ),
          ),

          const SizedBox(height: 10),

          Text(
            value,
            style: TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              height: 1.2,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    ),
  );
}
  
  // Reusable action card widget
  Widget _buildActionCard(
  String title,
  String subtitle,
  IconData icon,
  Color color,
  VoidCallback onTap,
) {
  return Card(
    margin: const EdgeInsets.only(bottom: 10),
    child: InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                icon,
                color: color,
                size: 27,
              ),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),

            const Icon(
              Icons.arrow_forward_ios,
              size: 17,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    ),
  );
}
  
  // Placeholder screens (we'll build these later)
  Widget _buildComplaintsPlaceholder() {
  return GrievanceForm();
}
  
  Widget _buildDashboardPlaceholder() {
  return DashboardScreen();
}
  
  Widget _buildChatPlaceholder() {
  return ChatScreen();
} 
}