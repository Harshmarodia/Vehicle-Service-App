import 'package:flutter/material.dart';
import '../../core/services/api_service.dart';
import 'voice_input_screen.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _controller = TextEditingController();
  List<Map<String, dynamic>> messages = [
    {"sender": "bot", "text": "Hi! I'm MotoBuddy Assistant. How can I help you today?"}
  ];
  bool isLoading = false;
  bool isEmergencyFlow = false;
  bool showComplaintBox = false;
  bool showTextInput = false;
  final TextEditingController _complaintController = TextEditingController();

  Future<void> sendMessage(String userText) async {
    if (userText.trim().isEmpty) return;

    setState(() {
      messages.add({"sender": "user", "text": userText});
      isLoading = true;
    });

    String botReply = "";

    // Specific Logic Flows
    if (isEmergencyFlow) {
      // Step 2 of emergency flow: getting address
      botReply = "Booking your emergency service at $userText...";
      var res = await ApiService.bookService(
        serviceType: "Emergency Breakdown",
        vehicleType: "Two Wheeler",
        description: "Emergency Breakdown requested via Chatbot",
        pincode: "AUTO",
        serviceMode: "On-Site (Mechanic)",
      );
      if (res["success"] == true) {
        botReply = "Emergency Booking Confirmed! Your confirmation number is ${res['bookingId'] ?? 'MB-9921'}. Help is on the way.";
      } else {
        botReply = "Sorry, I couldn't complete the booking. Please call our hotline.";
      }
      isEmergencyFlow = false;
    } else if (userText.toLowerCase().contains("current booking status")) {
      var res = await ApiService.getCustomerBookings();
      var bookings = res["bookings"] as List?;
      if (bookings != null && bookings.isNotEmpty) {
        var last = bookings.last;
        botReply = "Your latest booking for '${last['serviceType']}' is currently ${last['status']?.toUpperCase()}.";
      } else {
        botReply = "You have no active bookings at the moment.";
      }
    } else if (userText.toLowerCase().contains("emergency booking")) {
      botReply = "I can help with that immediately. Please provide your current address or location.";
      isEmergencyFlow = true;
    } else {
      var response = await ApiService.sendChatMessage(userText);
      botReply = response["reply"] ?? "I'm not sure how to answer that yet.";
    }

    setState(() {
      messages.add({
        "sender": "bot",
        "text": botReply,
        "showFeedback": true
      });
      isLoading = false;
    });

    _controller.clear();
  }

  void _submitComplaint() {
    if (_complaintController.text.trim().isEmpty) return;
    // Logic to save complaint would go here
    setState(() {
      showComplaintBox = false;
      messages.add({"sender": "bot", "text": "Thank you for your feedback. Our team will review your complaint shortly."});
    });
    _complaintController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("MotoBuddy Assistant"),
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: messages.length + (showTextInput ? 0 : 1),
              itemBuilder: (context, index) {
                if (!showTextInput && index == messages.length) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Center(
                      child: ElevatedButton.icon(
                        onPressed: () => setState(() => showTextInput = true),
                        icon: const Icon(Icons.support_agent),
                        label: const Text("Get Assistance"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        ),
                      ),
                    ),
                  );
                }
                final msg = messages[index];
                final isUser = msg["sender"] == "user";
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Row(
                        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (!isUser)
                            CircleAvatar(
                              backgroundColor: Theme.of(context).primaryColor,
                              child: const Icon(Icons.smart_toy, color: Colors.black, size: 20),
                            ),
                          const SizedBox(width: 10),
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.all(15),
                              decoration: BoxDecoration(
                                color: isUser 
                                  ? Theme.of(context).primaryColor 
                                  : Theme.of(context).colorScheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.only(
                                  topLeft: const Radius.circular(20),
                                  topRight: const Radius.circular(20),
                                  bottomLeft: Radius.circular(isUser ? 20 : 0),
                                  bottomRight: Radius.circular(isUser ? 0 : 20),
                                ),
                              ),
                              child: Text(
                                msg["text"] ?? "",
                                style: TextStyle(
                                  color: isUser ? Colors.black : Theme.of(context).colorScheme.onSurface,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          if (isUser)
                            CircleAvatar(
                              backgroundColor: Colors.grey.shade300,
                              child: const Icon(Icons.person, color: Colors.black54, size: 20),
                            ),
                        ],
                      ),
                    ),
                    if (!isUser && msg["showFeedback"] == true && index == messages.length - 1)
                      Padding(
                        padding: const EdgeInsets.only(left: 50, bottom: 20),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: TextButton(
                            onPressed: () => setState(() => showComplaintBox = true),
                            child: const Text("Not satisfied? Tell us more", style: TextStyle(color: Colors.redAccent, fontSize: 12, decoration: TextDecoration.underline)),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
          if (isLoading) const LinearProgressIndicator(),
          if (showComplaintBox)
            Container(
              padding: const EdgeInsets.all(20),
              color: Colors.red.shade50,
              child: Column(
                children: [
                  const Text("Please describe your issue", style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _complaintController,
                    maxLines: 2,
                    decoration: InputDecoration(
                      hintText: "Write your problem here...",
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(onPressed: () => setState(() => showComplaintBox = false), child: const Text("Cancel")),
                      const SizedBox(width: 10),
                      ElevatedButton(onPressed: _submitComplaint, child: const Text("Submit")),
                    ],
                  )
                ],
              ),
            ),
          if (showTextInput)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      onSubmitted: sendMessage,
                      decoration: InputDecoration(
                        hintText: "Ask me anything...",
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                        filled: true,
                        fillColor: Theme.of(context).colorScheme.surfaceContainerHigh,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.mic, color: Colors.blue),
                          onPressed: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const VoiceInputScreen()),
                            );
                            if (result != null && result is String) {
                              sendMessage(result);
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  FloatingActionButton(
                    onPressed: () => sendMessage(_controller.text),
                    backgroundColor: Theme.of(context).primaryColor,
                    child: const Icon(Icons.send, color: Colors.black),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
