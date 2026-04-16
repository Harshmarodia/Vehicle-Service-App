import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/services/api_service.dart';
import '../../core/theme/app_theme.dart';

class AIChatScreen extends StatefulWidget {
  const AIChatScreen({super.key});

  @override
  State<AIChatScreen> createState() => _AIChatScreenState();
}

class _AIChatScreenState extends State<AIChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [
    {"role": "ai", "content": "Hello! I'm your AI Repair Assistant. How can I help you today? You can ask about spare parts, torque specs, or troubleshooting steps."}
  ];
  bool _isTyping = false;

  Future<void> _sendMessage() async {
    if (_controller.text.isEmpty) return;

    final userMsg = _controller.text;
    setState(() {
      _messages.add({"role": "user", "content": userMsg});
      _controller.clear();
      _isTyping = true;
    });

    try {
      final response = await ApiService.chatWithAI(userMsg);
      if (mounted) {
        setState(() {
          _messages.add({"role": "ai", "content": response['reply'] ?? "I'm sorry, I couldn't process that."});
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _messages.add({"role": "ai", "content": "Error connecting to AI service."});
        });
      }
    } finally {
      if (mounted) setState(() => _isTyping = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("AI Repair Assistant"),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: Center(
        child: Container(
          width: 800,
          margin: const EdgeInsets.all(40),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(color: Colors.black.withAlpha(20), blurRadius: 20),
            ],
          ),
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(24),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final msg = _messages[index];
                    final isAi = msg['role'] == 'ai';
                    return _buildMessageBubble(msg['content']!, isAi);
                  },
                ),
              ),
              if (_isTyping)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: Row(
                    children: [
                      Text("AI is typing...", style: TextStyle(color: Colors.grey, fontSize: 12, fontStyle: FontStyle.italic)),
                    ],
                  ),
                ),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: Colors.grey.shade100)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        onSubmitted: (_) => _sendMessage(),
                        decoration: const InputDecoration(
                          hintText: "Type your question...",
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: _sendMessage,
                      icon: const Icon(Icons.send, color: AppTheme.darkHeaderColor),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().slideY(begin: 0.1, duration: 400.ms);
  }

  Widget _buildMessageBubble(String content, bool isAi) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: isAi ? MainAxisAlignment.start : MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isAi)
            const CircleAvatar(
              backgroundColor: AppTheme.primaryColor,
              child: Icon(Icons.psychology, size: 20, color: AppTheme.darkHeaderColor),
            ),
          const SizedBox(width: 12),
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isAi ? Colors.grey.shade100 : AppTheme.darkHeaderColor,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: isAi ? Radius.zero : const Radius.circular(16),
                  bottomRight: isAi ? const Radius.circular(16) : Radius.zero,
                ),
              ),
              child: Text(
                content,
                style: TextStyle(color: isAi ? Colors.black87 : Colors.white, height: 1.4),
              ),
            ),
          ),
          if (!isAi) const SizedBox(width: 12),
          if (!isAi)
            const CircleAvatar(
              backgroundColor: AppTheme.darkHeaderColor,
              child: Icon(Icons.person, size: 20, color: Colors.white),
            ),
        ],
      ).animate().fadeIn().slideX(begin: isAi ? -0.1 : 0.1),
    );
  }
}
