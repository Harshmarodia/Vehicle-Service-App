import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../core/services/api_service.dart';
import '../../booking/voice_input_screen.dart';

class FloatingChatbot extends StatefulWidget {
  const FloatingChatbot({super.key});

  @override
  State<FloatingChatbot> createState() => _FloatingChatbotState();
}

class _FloatingChatbotState extends State<FloatingChatbot> {
  bool _isOpen = false;
  bool _isLoggedIn = false;

  void _toggleChat() {
    setState(() => _isOpen = !_isOpen);
  }

  @override
  void initState() {
    super.initState();
    _checkAuth();
    ApiService.authNotifier.addListener(_checkAuth);
  }

  @override
  void dispose() {
    ApiService.authNotifier.removeListener(_checkAuth);
    super.dispose();
  }

  Future<void> _checkAuth() async {
    bool logged = await ApiService.isLoggedIn();
    if (mounted) {
      setState(() {
        _isLoggedIn = logged;
        if (!_isLoggedIn) {
          _messages.clear();
          _messages.add({"text": "Hi Guest! Welcome to Go MotoBuddy. Login to access expert features.", "sender": "bot"});
        } else {
          _messages.clear();
          _messages.add({"text": "Hi! I'm your MotoBuddy Expert AI. How can I help you today?", "sender": "bot"});
        }
      });
    }
  }

  final List<Map<String, dynamic>> _messages = [
    {"text": "Hi! Welcome to Go MotoBuddy. How can I assist you today?", "isBot": true},
  ];
  final TextEditingController _msgController = TextEditingController();
  final TextEditingController _complaintController = TextEditingController();
  bool _isEmergencyFlow = false;
  bool _showComplaintBox = false;
  bool _showTextInput = false;
  bool _isTyping = false;

  void _sendMessage({String? text}) {
    String userText = text ?? _msgController.text.trim();
    if (userText.isEmpty) return;
    
    setState(() {
      _messages.add({"text": userText, "sender": "user"});
      if (text == null) _msgController.clear();
      _isTyping = true;
    });

    Future.delayed(const Duration(milliseconds: 300), () async {
      String botReply = "";
      bool showFeedback = true;

      if (_isEmergencyFlow) {
        botReply = "Booking emergency service at $userText...";
        var res = await ApiService.bookService(
          serviceType: "Emergency Breakdown",
          vehicleType: "Two Wheeler",
          description: "Emergency requested via web chatbot",
          pincode: "AUTO",
          serviceMode: "On-Site (Mechanic)",
        );
        botReply = res["success"] == true 
          ? "Confirmed! ID: ${res['bookingId'] ?? 'MB-WEB-01'}. Help dispatched." 
          : "Error booking. Please call support.";
        _isEmergencyFlow = false;
      } else if (userText.toLowerCase().contains("booking status")) {
        var res = await ApiService.getCustomerBookings();
        var bookings = res["bookings"] as List?;
        botReply = (bookings != null && bookings.isNotEmpty)
          ? "Your latest booking: ${bookings.last['status']?.toString().toUpperCase()}"
          : "No bookings found.";
      } else if (userText.toLowerCase().contains("emergency booking") || userText.contains("Book Emergency Help")) {
        botReply = "EMERGENCY: Please enter your location/address below.";
        _isEmergencyFlow = true;
      } else {
        final result = await ApiService.sendChatMessage(userText);
        botReply = result["reply"] ?? "I'm having trouble thinking right now.";
      }

      if (mounted) {
        setState(() {
          _isTyping = false;
          _messages.add({"text": botReply, "sender": "bot", "showFeedback": showFeedback});
        });
      }
    });
  }

  void _handleOptionTap(String option) async {
    setState(() {
      _messages.add({"sender": "user", "text": option});
      _isTyping = true;
    });

    String botResponse = "";
    bool showFeedback = true;

    if (option == "Check Active Booking") { // Changed from "Current Booking Status" to match quick options
      final bookings = await ApiService.getCustomerBookings(); // Using existing getCustomerBookings
      if (bookings["bookings"] != null && bookings["bookings"].isNotEmpty) {
        final last = bookings["bookings"].first;
        botResponse = "Your latest booking (${last['bookingId']}) is currently: ${last['status'] ?? 'Active'}. Service Type: ${last['serviceType'] ?? 'N/A'}";
      } else {
        botResponse = "I couldn't find any active bookings for your account.";
      }
    } else if (option == "Book Emergency Help") { // Changed from "Book Emergency" to match quick options
      botResponse = "Redirecting you to our Priority Emergency Booking portal...";
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) Navigator.pushNamed(context, '/book-service'); 
      });
      showFeedback = false;
    } else if (option == "Get Personal Assistance") {
      setState(() => _showTextInput = true);
      botResponse = "I've enabled the text input for you. Please type your query below.";
      showFeedback = false;
    } else {
      // For other options, send them as a regular message to the chatbot API
      final result = await ApiService.sendChatMessage(option);
      botResponse = result["reply"] ?? "I'm here to help with your $option query. What specific detail would you like to know?";
    }

    await Future.delayed(const Duration(milliseconds: 800));
    
    if (mounted) {
      setState(() {
        _isTyping = false;
        _messages.add({"sender": "bot", "text": botResponse, "showFeedback": showFeedback});
      });
    }
  }

  void _handleMessageTap(String message) {
    _sendMessage(text: message);
  }

  void _submitComplaint() {
    if (_complaintController.text.trim().isEmpty) return;
    setState(() {
      _showComplaintBox = false;
      _messages.add({"text": "Your complaint has been logged. We'll get back to you.", "sender": "bot"});
    });
    _complaintController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 40,
      right: 40,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_isOpen)
            Container(
              margin: const EdgeInsets.only(bottom: 20),
              width: 320,
              height: 450,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.7),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.3)),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 20, offset: const Offset(0, 10))
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                  child: Column(
                    children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Theme.of(context).primaryColor, const Color(0xFFFFE033)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10)
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(color: Colors.black, shape: BoxShape.circle),
                              child: Icon(Icons.bolt, color: _isLoggedIn ? Colors.yellow : Colors.grey, size: 16),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              _isLoggedIn ? "MotoBuddy Expert AI" : "MotoBuddy Guest Bot",
                              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: Colors.black, letterSpacing: -0.3),
                            ),
                          ],
                        ),
                        InkWell(
                          onTap: _toggleChat,
                          child: const Icon(Icons.close_rounded, color: Colors.black54),
                        )
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(15),
                      itemCount: _messages.length + (_isTyping ? 1 : 0) + 1, // +1 for quick options, +1 for typing indicator
                      itemBuilder: (context, index) {
                        if (index < _messages.length) {
                          final msg = _messages[index];
                          return _buildMessage(msg);
                        } else if (index == _messages.length && _isTyping) {
                          return Align(
                            alignment: Alignment.centerLeft,
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.only(
                                  topLeft: const Radius.circular(15),
                                  topRight: const Radius.circular(15),
                                  bottomLeft: const Radius.circular(0),
                                  bottomRight: const Radius.circular(15),
                                ),
                              ),
                              child: const Text("Typing...", style: TextStyle(color: Colors.black87)),
                            ),
                          );
                        }
                        return _quickOptions();
                      },
                    ),
                  ),
                  if (_showComplaintBox)
                    Container(
                      padding: const EdgeInsets.all(10),
                      color: Colors.grey.shade100,
                      child: Column(
                        children: [
                          TextField(
                            controller: _complaintController,
                            decoration: const InputDecoration(hintText: "What went wrong?", border: OutlineInputBorder()),
                            style: const TextStyle(fontSize: 12),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(onPressed: () => setState(() => _showComplaintBox = false), child: const Text("X", style: TextStyle(color: Colors.grey))),
                              IconButton(onPressed: _submitComplaint, icon: const Icon(Icons.send, size: 16)),
                            ],
                          )
                        ],
                      ),
                    ),
                  if (_showTextInput)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(15)),
                        border: Border(top: BorderSide(color: Colors.grey.shade300)),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _msgController,
                              onSubmitted: (_) => _sendMessage(),
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                hintText: "Type a message...",
                                hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
                                border: InputBorder.none,
                                suffixIcon: IconButton(
                                  icon: const Icon(Icons.mic, color: Colors.yellow, size: 20),
                                  onPressed: () async {
                                    final result = await Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (_) => const VoiceInputScreen()),
                                    );
                                    if (result != null && result is String) {
                                      _sendMessage(text: result);
                                    }
                                  },
                                ),
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.send, color: Colors.white),
                            onPressed: _sendMessage,
                          )
                        ],
                      ),
                    )
                  else
                    const SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
            ),
          FloatingActionButton(
            backgroundColor: Theme.of(context).primaryColor,
            onPressed: _toggleChat,
            child: Icon(
              _isOpen ? Icons.close : Icons.chat,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessage(Map<String, dynamic> msg) {
    bool isBot = msg["sender"] == "bot";
    return Column(
      crossAxisAlignment: isBot ? CrossAxisAlignment.start : CrossAxisAlignment.end,
      children: [
        Align(
          alignment: isBot ? Alignment.centerLeft : Alignment.centerRight,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 4),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isBot ? const Color(0xFFE9E9EB) : Colors.yellow,
              borderRadius: BorderRadius.circular(20).copyWith(
                bottomLeft: isBot ? const Radius.circular(0) : const Radius.circular(20),
                bottomRight: isBot ? const Radius.circular(20) : const Radius.circular(0),
              ),
            ),
            child: Text(
              msg["text"] ?? "",
              style: TextStyle(
                color: isBot ? Colors.black : Colors.black, 
                fontSize: 15,
                fontWeight: isBot ? FontWeight.w400 : FontWeight.w500,
              ),
            ),
          ),
        ),
        if (isBot && msg["showFeedback"] == true)
          Padding(
            padding: const EdgeInsets.only(left: 10, bottom: 8),
            child: Row(
              children: [
                const Text("Was this helpful?", style: TextStyle(fontSize: 10, color: Colors.grey)),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.thumb_up_alt_outlined, size: 14, color: Colors.green),
                  onPressed: () {},
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.thumb_down_alt_outlined, size: 14, color: Colors.red),
                  onPressed: () {
                    setState(() => _showTextInput = true);
                    _handleMessageTap("I need more help with this.");
                  },
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _quickOptions() {
    final options = [
      "Get Personal Assistance",
      "Book Emergency Help",
      "Schedule Regular Service",
      "Buy Garage Products",
      "Check Active Booking"
    ];

    return Column(
      children: options.map((option) {
        return Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 8),
          child: OutlinedButton(
            onPressed: () {
              if (option == "Get Personal Assistance") {
                setState(() => _showTextInput = true);
              } else {
                _sendMessage(text: option);
              }
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.black87,
              side: BorderSide(color: Colors.grey.shade300),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: Text(option),
          ),
        );
      }).toList(),
    );
  }
}
