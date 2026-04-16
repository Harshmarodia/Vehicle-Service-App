import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/services/api_service.dart';

class FeedbackSummaryScreen extends StatefulWidget {
  const FeedbackSummaryScreen({super.key});

  @override
  State<FeedbackSummaryScreen> createState() => _FeedbackSummaryScreenState();
}

class _FeedbackSummaryScreenState extends State<FeedbackSummaryScreen> {
  Map<String, dynamic>? summary;
  List<dynamic> feedback = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchFeedback();
  }

  Future<void> _fetchFeedback() async {
    final res = await ApiService.getFeedbackSummary();
    if (res['success'] == true) {
      if (!mounted) return;
      setState(() {
        summary = res['summary'];
        feedback = res['feedback'];
        isLoading = false;
      });
    } else {
      if (!mounted) return;
      setState(() => isLoading = false);
    }
  }

  Future<void> _downloadSummary() async {
    final String url = '${ApiService.baseUrl}/api/admin/feedback-summary?download=true';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Could not start download")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Customer Feedback Hub",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: -0.5),
            ),
            ElevatedButton.icon(
              onPressed: _downloadSummary,
              icon: const Icon(Icons.download),
              label: const Text("Export to CSV"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: const Color(0xFFFFD700),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
        if (isLoading)
          const Center(child: CircularProgressIndicator())
        else ...[
          _buildSummaryCards(),
          const SizedBox(height: 32),
          const Text("Detailed Reviews", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Expanded(child: _buildFeedbackList()),
        ],
      ],
    );
  }

  Widget _buildSummaryCards() {
    return Row(
      children: [
        _buildStatCard("Total Requests", summary?['totalRequests']?.toString() ?? "0", Colors.blue),
        const SizedBox(width: 20),
        _buildStatCard("Total Reviews", summary?['totalFeedback']?.toString() ?? "0", Colors.purple),
        const SizedBox(width: 20),
        _buildStatCard("Avg. Rating", "${summary?['averageRating'] ?? "0.0"}/5.0", Colors.orange),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withAlpha(5), blurRadius: 20)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(value, style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: color)),
          ],
        ),
      ),
    );
  }

  Widget _buildFeedbackList() {
    if (feedback.isEmpty) {
      return const Center(child: Text("No feedback received yet."));
    }
    return ListView.builder(
      itemCount: feedback.length,
      itemBuilder: (context, index) {
        final f = feedback[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: ListTile(
            contentPadding: const EdgeInsets.all(20),
            leading: CircleAvatar(
              backgroundColor: Colors.grey.shade100,
              child: Text(f['rating'].toString(), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
            ),
            title: Row(
              children: [
                Text(f['userId']?['name'] ?? 'Anonymous', style: const TextStyle(fontWeight: FontWeight.bold)),
                const Spacer(),
                Text(f['targetType'].toString().toUpperCase(), style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Text(f['comment'] ?? 'No comment provided.', style: const TextStyle(fontSize: 15)),
                const SizedBox(height: 4),
                Text(DateTime.parse(f['createdAt']).toString().split('.')[0], style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
        );
      },
    );
  }
}
