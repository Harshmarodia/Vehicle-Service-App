import 'package:flutter/material.dart';
import '../../core/services/api_service.dart';

class ServiceSummaryScreen extends StatefulWidget {
  final String bookingId;
  const ServiceSummaryScreen({super.key, required this.bookingId});

  @override
  State<ServiceSummaryScreen> createState() => _ServiceSummaryScreenState();
}

class _ServiceSummaryScreenState extends State<ServiceSummaryScreen> {
  double rating = 5.0;
  final reviewController = TextEditingController();
  bool isSubmitting = false;

  Future<void> _submitFeedback() async {
    setState(() => isSubmitting = true);
    // Implementation for submitting feedback
    // await ApiService.submitFeedback(widget.bookingId, rating, reviewController.text);
    
    if (mounted) {
       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Thank you for your feedback!")));
       Navigator.popUntil(context, (route) => route.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Service Summary", style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 80),
            const SizedBox(height: 20),
            const Text("Service Completed!", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            const Text("Your vehicle is ready and the service is done.", style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 40),
            
            _buildInfoRow("Job ID", widget.bookingId.substring(0, 8).toUpperCase()),
            _buildInfoRow("Amount", "₹ 450.00"),
            _buildInfoRow("Date", DateTime.now().toString().substring(0, 10)),
            
            const SizedBox(height: 40),
            const Divider(),
            const SizedBox(height: 30),
            
            const Text("Rate the Mechanic", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return IconButton(
                  icon: Icon(index < rating ? Icons.star : Icons.star_border, color: Colors.yellow, size: 35),
                  onPressed: () => setState(() => rating = index + 1.0),
                );
              }),
            ),
            const SizedBox(height: 30),
            TextField(
              controller: reviewController,
              maxLines: 3,
              decoration: InputDecoration(hintText: "Write a review (optional)", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: isSubmitting ? null : _submitFeedback,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.yellow, minimumSize: const Size(double.infinity, 55), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: const Text("Submit & Finish"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
