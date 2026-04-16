import 'package:flutter/material.dart';
import '../../core/services/api_service.dart';

class GarageEarningsScreen extends StatefulWidget {
  final String agentId;
  const GarageEarningsScreen({super.key, required this.agentId});

  @override
  State<GarageEarningsScreen> createState() => _GarageEarningsScreenState();
}

class _GarageEarningsScreenState extends State<GarageEarningsScreen> {
  Map<String, dynamic>? earningsData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchEarnings();
  }

  Future<void> _fetchEarnings() async {
    final res = await ApiService.getAgentEarnings(widget.agentId);
    if (res['success'] == true) {
      if (mounted) {
        setState(() {
          earningsData = res;
          isLoading = false;
        });
      }
    } else {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const Center(child: CircularProgressIndicator());

    final daily = earningsData?['daily'] ?? 0;
    final weekly = earningsData?['weekly'] ?? 0;
    final monthly = earningsData?['monthly'] ?? 0;
    final total = earningsData?['total'] ?? 0;
    final count = earningsData?['count'] ?? 0;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Financial Insights", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const Text("Track your garage's revenue and performance.", style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 32),
          
          Wrap(
            spacing: 24,
            runSpacing: 24,
            children: [
              _EarningCard(title: "Today's Earnings", value: "₹$daily", icon: Icons.today, color: Colors.blue),
              _EarningCard(title: "This Week", value: "₹$weekly", icon: Icons.calendar_view_week, color: Colors.indigo),
              _EarningCard(title: "This Month", value: "₹$monthly", icon: Icons.calendar_month, color: Colors.purple),
              _EarningCard(title: "Total Revenue", value: "₹$total", icon: Icons.account_balance_wallet, color: Colors.green),
            ],
          ),
          
          const SizedBox(height: 48),
          Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 20)],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Service Volume", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      Text("Total completed jobs with success payments: $count", style: const TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.orange.withOpacity(0.1), shape: BoxShape.circle),
                  child: const Icon(Icons.analytics_outlined, color: Colors.orange),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 32),
          Center(
            child: ElevatedButton.icon(
              onPressed: _fetchEarnings,
              icon: const Icon(Icons.refresh),
              label: const Text("Refresh Earnings Report"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EarningCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _EarningCard({required this.title, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.grey, fontSize: 14)),
                Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
