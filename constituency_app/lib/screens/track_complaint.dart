import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TrackComplaintScreen extends StatefulWidget {
  @override
  _TrackComplaintScreenState createState() => _TrackComplaintScreenState();
}

class _TrackComplaintScreenState extends State<TrackComplaintScreen> {
  final TextEditingController _searchController = TextEditingController();
  String? searchPhone;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Track Complaint'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // Search by phone number
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text('Enter your mobile number to track complaints',
                        style: TextStyle(fontSize: 16)),
                    SizedBox(height: 12),
                    TextField(
                      controller: _searchController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        hintText: 'Mobile Number',
                        prefixIcon: Icon(Icons.phone),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        suffixIcon: IconButton(
                          icon: Icon(Icons.search),
                          onPressed: () {
                            setState(() {
                              searchPhone = _searchController.text.trim();
                            });
                          },
                        ),
                      ),
                      onSubmitted: (value) {
                        setState(() {
                          searchPhone = value.trim();
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            
            SizedBox(height: 16),
            
            // Results
            if (searchPhone != null && searchPhone!.isNotEmpty)
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('grievances')
                      .where('phone', isEqualTo: searchPhone)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }
                    
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search_off, size: 64, color: Colors.grey),
                            SizedBox(height: 16),
                            Text('No complaints found for this number',
                                style: TextStyle(fontSize: 16, color: Colors.grey)),
                          ],
                        ),
                      );
                    }
                    
                    return ListView.builder(
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        var data = snapshot.data!.docs[index].data() as Map<String, dynamic>;
                        
                        Color statusColor = data['status'] == 'resolved'
                            ? Colors.green
                            : data['status'] == 'processed'
                                ? Colors.blue
                                : Colors.orange;
                        
                        IconData statusIcon = data['status'] == 'resolved'
                            ? Icons.check_circle
                            : data['status'] == 'processed'
                                ? Icons.pending
                                : Icons.hourglass_bottom;
                        
                        return Card(
                          margin: EdgeInsets.only(bottom: 12),
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Status Badge
                                Row(
                                  children: [
                                    Icon(statusIcon, color: statusColor),
                                    SizedBox(width: 8),
                                    Container(
                                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: statusColor.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        (data['status'] ?? 'pending').toUpperCase(),
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: statusColor,
                                        ),
                                      ),
                                    ),
                                    Spacer(),
                                    Text(
                                      'Priority: ${data['priority_score'] ?? 5}/10',
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                
                                SizedBox(height: 12),
                                
                                // Complaint text
                                Text(
                                  data['complaint_text'] ?? '',
                                  style: TextStyle(fontSize: 15),
                                ),
                                
                                SizedBox(height: 8),
                                
                                // Location
                                Row(
                                  children: [
                                    Icon(Icons.location_on, size: 16, color: Colors.grey),
                                    SizedBox(width: 4),
                                    Text(data['location_text'] ?? 'Unknown',
                                        style: TextStyle(color: Colors.grey)),
                                  ],
                                ),
                                
                                SizedBox(height: 4),
                                
                                // Category
                                Row(
                                  children: [
                                    Icon(Icons.category, size: 16, color: Colors.grey),
                                    SizedBox(width: 4),
                                    Text(data['category'] ?? 'Other',
                                        style: TextStyle(color: Colors.grey)),
                                  ],
                                ),
                                
                                // AI Summary (if available)
                                if (data['ai_summary'] != null) ...[
                                  SizedBox(height: 12),
                                  Container(
                                    padding: EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.blue[50],
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(Icons.smart_toy, size: 20, color: Colors.blue),
                                        SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            'AI: ${data['ai_summary']}',
                                            style: TextStyle(fontSize: 13),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}