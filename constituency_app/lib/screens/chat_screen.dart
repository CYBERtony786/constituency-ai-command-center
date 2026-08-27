// File: lib/screens/chat_screen.dart

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
          padding: const EdgeInsets.all(12),
          color: Colors.purple[50],
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.purple,
                child: const Icon(Icons.smart_toy, color: Colors.white),
              ),
              const SizedBox(width: 12),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'AI Assistant',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Powered by Gemini',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
              const Spacer(),
              
              // ════════════════════════════════════════════════════
              // IMPROVED TYPING INDICATOR (Day 14)
              // ════════════════════════════════════════════════════
              if (isTyping)
                Row(
                  children: [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.purple),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Thinking...',
                      style: TextStyle(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        color: Colors.purple,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
        
        // Suggestion chips (show if few messages)
        if (messages.length <= 2)
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: suggestions.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ActionChip(
                    label: Text(
                      suggestions[index],
                      style: const TextStyle(fontSize: 12),
                    ),
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
            padding: const EdgeInsets.all(12),
            itemCount: messages.length,
            itemBuilder: (context, index) {
              return _buildMessageBubble(messages[index]);
            },
          ),
        ),
        
        // Input area
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                blurRadius: 5,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _messageController,
                  decoration: InputDecoration(
                    hintText: 'Ask a question...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                  maxLines: null,
                  textCapitalization: TextCapitalization.sentences,
                  onSubmitted: (text) {
                    if (text.isNotEmpty) {
                      _sendMessage(text);
                    }
                  },
                ),
              ),
              const SizedBox(width: 8),
              FloatingActionButton(
                mini: true,
                onPressed: () {
                  if (_messageController.text.isNotEmpty) {
                    _sendMessage(_messageController.text);
                  }
                },
                child: const Icon(Icons.send),
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
        margin: const EdgeInsets.only(bottom: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Column(
          crossAxisAlignment: isUser
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            if (!isUser)
              Padding(
                padding: const EdgeInsets.only(bottom: 4, left: 12),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.auto_awesome, size: 14, color: Colors.purple),
                    const SizedBox(width: 4),
                    const Text(
                      'AI Assistant',
                      style: TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isUser ? Colors.blue[100] : Colors.grey[200],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                message['text'] ?? '',
                style: const TextStyle(fontSize: 14, height: 1.4),
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.only(top: 4, left: 12, right: 12),
              child: Text(
                _formatTime(DateTime.now()),
                style: const TextStyle(fontSize: 10, color: Colors.grey),
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
      messages.add({
        'role': 'user',
        'text': text,
      });
      isTyping = true;
    });
    
    _messageController.clear();
    _scrollToBottom();
    
    try {
      // Get AI response
      String response = await _gemini.chat(text);
      
      // Add AI response
      setState(() {
        messages.add({
          'role': 'ai',
          'text': response,
        });
        isTyping = false;
      });
      
      _scrollToBottom();
      
    } catch (e) {
      setState(() {
        messages.add({
          'role': 'ai',
          'text': '❌ Error: $e\n\nPlease try again.',
        });
        isTyping = false;
      });
    }
  }
  
  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }
  
  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}