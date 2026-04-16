import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/services/api_service.dart';
import '../../core/theme/app_theme.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Map<String, dynamic>? stats;
  List<dynamic>? revenueData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    final s = await ApiService.getStats();
    final r = await ApiService.getRevenueData();
    if (mounted) {
      setState(() {
        stats = s['success'] ? s['stats'] : null;
        revenueData = r['success'] ? r['revenueData'] : null;
        isLoading = false;
      });
    }
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: AppTheme.textMuted, fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                  const SizedBox(height: 8),
                  Text(value, style: const TextStyle(color: AppTheme.textMain, fontSize: 24, fontWeight: FontWeight.bold)),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRevenueChart() {
    if (revenueData == null || revenueData!.isEmpty) return const Center(child: Text("No Data"));
    
    List<FlSpot> spots = [];
    for (int i = 0; i < revenueData!.length; i++) {
      spots.add(FlSpot(i.toDouble(), (revenueData![i]['revenue'] as num).toDouble()));
    }

    return AspectRatio(
      aspectRatio: 2.5,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 10000,
            getDrawingHorizontalLine: (value) => const FlLine(color: Color(0xFFF1F5F9), strokeWidth: 1),
          ),
          titlesData: FlTitlesData(
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() >= 0 && value.toInt() < revenueData!.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(revenueData![value.toInt()]['month'], style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                    );
                  }
                  return const Text('');
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 45,
                getTitlesWidget: (value, meta) {
                  return Text('\$${(value / 1000).toInt()}k', style: const TextStyle(color: AppTheme.textMuted, fontSize: 12));
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: AppTheme.primaryColor,
              barWidth: 4,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: AppTheme.primaryColor.withValues(alpha: 0.1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor));
    if (stats == null) return const Center(child: Text("Failed to load dashboard data", style: TextStyle(color: Colors.red)));

    return ListView(
      padding: const EdgeInsets.all(40),
      children: [
        // Top Stats Row
        Row(
          children: [
            _buildStatCard("TOTAL USERS", "${stats!['users']}", Icons.people_outline, Colors.blue),
            const SizedBox(width: 20),
            _buildStatCard("OWNERS/GARAGES", "${stats!['agents']}", Icons.storefront_outlined, Colors.purple),
            const SizedBox(width: 20),
            _buildStatCard("MECHANICS", "${stats!['mechanics']}", Icons.build_circle_outlined, Colors.orange),
            const SizedBox(width: 20),
            _buildStatCard("PENDING REQUESTS", "${stats!['pendingApprovals']}", Icons.pending_actions, Colors.red),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            _buildStatCard("TOTAL REQUESTS", "${stats!['totalRequests']}", Icons.assignment_outlined, AppTheme.primaryColor),
            const SizedBox(width: 20),
            _buildStatCard("JOBS COMPLETED", "${stats!['completedRequests']}", Icons.check_circle_outline, Colors.green),
            const SizedBox(width: 20),
            _buildStatCard("SYSTEM RATING", "${stats!['avgRating'] ?? '5.0'} / 5", Icons.star_border, AppTheme.accentColor),
            const SizedBox(width: 20),
            const Expanded(child: SizedBox()), // Placeholder
          ],
        ),
        
        const SizedBox(height: 40),
        
        // Charts Section
        Card(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Platform Revenue Overview", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textMain)),
                const SizedBox(height: 8),
                const Text("Estimated monthly earnings generated across all active garages", style: TextStyle(color: AppTheme.textMuted, fontSize: 14)),
                const SizedBox(height: 32),
                _buildRevenueChart(),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
