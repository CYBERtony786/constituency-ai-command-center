import 'package:flutter/material.dart';
import '../services/gemini_service.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final GeminiService _gemini = GeminiService();
  
  List<Map<String, String>> messages = [];
  bool isTyping = false;
  
  // Suggested questions
  final List<String> suggestions = [
    'How many complaints did we receive this week?',
    'Which area has the most water complaints?',
    'Suggest budget allocation for ₹5 crore',
    'What should I prioritize today?',
    'Give me a morning briefing',
    'How to improve citizen satisfaction?',
    'Compare urban vs rural complaints',
    'List infrastructure gaps in my constituency',
  ];
  
  @override
  void initState() {
    super.initState();
    // Add welcome message
    messages.add({
      'role': 'ai',
      'text': '👋 Namaste! I\'m your AI constituency assistant powered by Google Gemini.\n\n'
              'Ask me anything about:\n'
              '• Grievance analysis\n'
              '• Budget allocation advice\n'
              '• Constituency insights\n'
              '• Priority recommendations\n\n'
              'Try one of the suggestions below! 👇',
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header
        Container(
          padding: EdgeInsets.all(12),
          color: Colors.purple[50],
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.purple,
                child: Icon(Icons.smart_toy, color: Colors.white),
              ),
              SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('AI Assistant', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text('Powered by Gemini', style: TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
              Spacer(),
              if (isTyping)
                Row(
                  children: [
                    SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                    SizedBox(width: 8),
                    Text('Thinking...', style: TextStyle(fontSize: 12, color: Colors.purple)),
                  ],
                ),
            ],
          ),
        ),
        
        // Suggestion chips (show if few messages)
        if (messages.length <= 2)
          Container(
            height: 50,
            padding: EdgeInsets.symmetric(vertical: 8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 12),
              itemCount: suggestions.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: EdgeInsets.only(right: 8),
                  child: ActionChip(
                    label: Text(suggestions[index], style: TextStyle(fontSize: 12)),
                    onPressed: () => _sendMessage(suggestions[index]),
                  ),
                );
              },
            ),
          ),
        
        // Chat messages
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: EdgeInsets.all(12),
            itemCount: messages.length,
            itemBuilder: (context, index) {
              return _buildMessageBubble(messages[index]);
            },
          ),
        ),
        
        // Input area
        Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 5, offset: Offset(0, -2)),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _messageController,
                  decoration: InputDecoration(
                    hintText: 'Ask a question...',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
                    contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    suffixIcon: IconButton(
                      icon: Icon(Icons.clear),
                      onPressed: () => _messageController.clear(),
                    ),
                  ),
                  onSubmitted: (text) {
                    if (text.isNotEmpty) _sendMessage(text);
                  },
                ),
              ),
              SizedBox(width: 8),
              FloatingActionButton(
                mini: true,
                onPressed: () {
                  if (_messageController.text.isNotEmpty) {
                    _sendMessage(_messageController.text);
                  }
                },
                child: Icon(Icons.send),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildMessageBubble(Map<String, String> message) {
    bool isUser = message['role'] == 'user';
    
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(
          bottom: 12,
          left: isUser ? 60 : 0,
          right: isUser ? 0 : 60,
        ),
        child: Column(
          crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            // Label
            Padding(
              padding: EdgeInsets.only(bottom: 4, left: 8, right: 8),
              child: Text(
                isUser ? 'You' : '🤖 AI Assistant',
                style: TextStyle(fontSize: 11, color: Colors.grey[600]),
              ),
            ),
            
            // Message bubble
            Container(
              padding: EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isUser ? Colors.blue[100] : Colors.grey[100],
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                  bottomLeft: isUser ? Radius.circular(16) : Radius.circular(4),
                  bottomRight: isUser ? Radius.circular(4) : Radius.circular(16),
                ),
              ),
              child: SelectableText(
                message['text'] ?? '',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Future<void> _sendMessage(String text) async {
    // Add user message
    setState(() {
      messages.add({'role': 'user', 'text': text});
      isTyping = true;
    });
    _messageController.clear();
    _scrollToBottom();
    
    try {
      // Get AI response
      String response = await _gemini.chat(text);
      
      // Add AI response
      setState(() {
        messages.add({'role': 'ai', 'text': response});
        isTyping = false;
      });
      _scrollToBottom();
      
    } catch (e) {
      setState(() {
        messages.add({'role': 'ai', 'text': '❌ Error: $e\n\nPlease try again.'});
        isTyping = false;
      });
    }
  }
  
  void _scrollToBottom() {
    Future.delayed(Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }
}