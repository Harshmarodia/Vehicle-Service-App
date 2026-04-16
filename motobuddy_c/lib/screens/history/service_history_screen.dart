import 'package:flutter/material.dart';
import '../../core/services/api_service.dart';
import '../tracking/live_tracking_screen.dart';

class ServiceHistoryScreen extends StatefulWidget {
  const ServiceHistoryScreen({super.key});

  @override
  State<ServiceHistoryScreen> createState() => _ServiceHistoryScreenState();
}

class _ServiceHistoryScreenState extends State<ServiceHistoryScreen> {
  List<dynamic> bookings = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchHistory();
  }

  Future<void> _fetchHistory() async {
    setState(() => isLoading = true);
    final res = await ApiService.getCustomerBookings();
    if (mounted) {
      setState(() {
        bookings = res["bookings"] ?? [];
        isLoading = false;
      });
    }
  }

  Future<void> _submitRandomFeedback(String bookingId, String? agentId) async {
    final List<String> comments = [
      "Excellent service, very professional!",
      "Quick and efficient repairs.",
      "The mechanic was very helpful and friendly.",
      "Great experience, would recommend.",
      "Good job but can be slightly faster.",
      "Service was top notch. Prices are reasonable.",
      "Smooth experience from start to finish."
    ];
    final rating = (DateTime.now().millisecond % 2) + 4; // Random 4 or 5
    final comment = comments[DateTime.now().millisecond % comments.length];

    final res = await ApiService.submitFeedback(
      bookingId: bookingId,
      rating: rating.toDouble(),
      review: comment,
    );

    if (res['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Random Feedback Submitted!")),
      );
      _fetchHistory();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("Request History", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: isLoading 
        ? const Center(child: CircularProgressIndicator())
        : bookings.isEmpty 
          ? const Center(child: Text("No requests found"))
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: bookings.length,
              itemBuilder: (context, index) {
                final req = bookings[index];
                return InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => LiveTrackingScreen(bookingId: req['_id']),
                      ),
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 15),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(color: Colors.yellow.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                              child: const Icon(Icons.car_repair, color: Colors.yellow),
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(req['serviceType'] ?? "Service", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                  const SizedBox(height: 4),
                                  Text("Vehicle: ${req['vehicleType']}", style: const TextStyle(color: Colors.grey, fontSize: 13)),
                                  Text("Date: ${req['createdAt']?.toString().substring(0, 10) ?? 'N/A'}", style: const TextStyle(color: Colors.grey, fontSize: 12)),
                                ],
                              ),
                            ),
                            _buildStatusChip(req['status'] ?? "Pending"),
                          ],
                        ),
                        if (req['feedback'] != null) ...[
                          const SizedBox(height: 12),
                          const Divider(),
                          const Text("Your Feedback", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey)),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              ...List.generate(5, (i) => Icon(
                                Icons.star, 
                                size: 14, 
                                color: i < req['feedback']['rating'] ? Colors.orange : Colors.grey.shade300
                              )),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  req['feedback']['comment'] ?? "No comment",
                                  style: const TextStyle(fontSize: 13, fontStyle: FontStyle.italic),
                                ),
                              ),
                            ],
                          ),
                        ] else if (req['status']?.toLowerCase() == "completed") ...[
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: () => _submitRandomFeedback(req['_id'], req['agentId']?['_id']),
                              icon: const Icon(Icons.auto_awesome, size: 14),
                              label: const Text("Give Random Feedback"),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Colors.yellow),
                                foregroundColor: Colors.black,
                                padding: const EdgeInsets.symmetric(vertical: 8),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color = Colors.orange;
    if (status == "Completed") color = Colors.green;
    if (status == "Cancelled") color = Colors.red;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
      child: Text(status, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }
}