import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:csv/csv.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/services/api_service.dart';
import '../../core/theme/app_theme.dart';

class ProjectReportScreen extends StatefulWidget {
  const ProjectReportScreen({super.key});

  @override
  State<ProjectReportScreen> createState() => _ProjectReportScreenState();
}

class _ProjectReportScreenState extends State<ProjectReportScreen> {
  bool isLoading = true;
  Map<String, dynamic> reportData = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final res = await ApiService.getCEOReport();
    if (mounted) {
      setState(() {
        reportData = res['stats'] ?? {};
        isLoading = false;
      });
    }
  }

  Future<void> _seedData() async {
    setState(() => isLoading = true);
    final res = await ApiService.seedFeedback();
    await _loadData();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res['message'] ?? "Seeding failed")),
      );
    }
  }

  Future<void> _exportCSV() async {
    List<List<dynamic>> rows = [
      ["Metric", "Value"],
      ["Total Users", reportData['totalUsers']],
      ["Total Agents", reportData['totalAgents']],
      ["Total Mechanics", reportData['totalMechanics']],
      ["Total Revenue", "₹${reportData['totalRevenue']}"],
      ["Avg Rating", reportData['avgRating']],
      ["Growth Rate", reportData['growthRate']],
    ];

    String csvData = const ListToCsvConverter().convert(rows);
    await Printing.sharePdf(
      bytes: utf8.encode(csvData),
      filename: 'MotoBuddy_CEO_Report_${DateTime.now().millisecondsSinceEpoch}.csv',
    );
  }

  Future<void> _exportPDF() async {
    final pdf = pw.Document();
    final font = await PdfGoogleFonts.interBold();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text("MOTOBUDDY EXECUTIVE REPORT", style: pw.TextStyle(font: font, fontSize: 24, color: PdfColors.blueGrey900)),
              pw.SizedBox(height: 10),
              pw.Text("Date: ${DateFormat('yyyy-MM-dd').format(DateTime.now())}"),
              pw.Divider(),
              pw.SizedBox(height: 20),
              pw.Text("1. BUSINESS OVERVIEW", style: pw.TextStyle(font: font, fontSize: 18)),
              pw.Bullet(text: "Total Revenue: ₹${reportData['totalRevenue']}"),
              pw.Bullet(text: "Total Registered Users: ${reportData['totalUsers']}"),
              pw.Bullet(text: "Growth this week: ${reportData['growthRate']}"),
              pw.SizedBox(height: 20),
              pw.Text("2. NETWORK CAPACITY", style: pw.TextStyle(font: font, fontSize: 18)),
              pw.Bullet(text: "Verified Agents: ${reportData['totalAgents']}"),
              pw.Bullet(text: "Field Mechanics: ${reportData['totalMechanics']}"),
              pw.SizedBox(height: 20),
              pw.Text("3. CUSTOMER SATISFACTION", style: pw.TextStyle(font: font, fontSize: 18)),
              pw.Bullet(text: "Average Platform Rating: ${reportData['avgRating']}/5.0"),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (format) => pdf.save());
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor));

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 40),
            _buildStatsGrid(),
            const SizedBox(height: 40),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 2, child: _buildRevenueChart()),
                const SizedBox(width: 30),
                Expanded(child: _buildSummaryList()),
              ],
            ),
            const SizedBox(height: 40),
            _buildActionSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Executive Overview", style: GoogleFonts.outfit(fontSize: 36, fontWeight: FontWeight.w900, color: AppTheme.primaryColor, letterSpacing: -1)),
            Text("Real-time performance analytics for MotoBuddy CEO", style: GoogleFonts.inter(color: AppTheme.textMuted, fontSize: 16)),
          ],
        ),
        Row(
          children: [
            _ExportButton(label: "Export CSV", icon: Icons.table_chart, color: Colors.blueAccent, onTap: _exportCSV),
            const SizedBox(width: 12),
            _ExportButton(label: "Download PDF", icon: Icons.picture_as_pdf, color: Colors.redAccent, onTap: _exportPDF),
          ],
        ),
      ],
    );
  }

  Widget _buildStatsGrid() {
    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 4,
      crossAxisSpacing: 24,
      mainAxisSpacing: 24,
      childAspectRatio: 1.6,
      children: [
        _StatCard(title: "TOTAL REVENUE", value: "₹${reportData['totalRevenue']}", trend: "+15.3%", icon: Icons.payments, color: Colors.green),
        _StatCard(title: "ACTIVE USERS", value: reportData['totalUsers'].toString(), trend: reportData['growthRate'], icon: Icons.group, color: Colors.blue),
        _StatCard(title: "SERVICES DONE", value: reportData['totalRequests'].toString(), trend: "+5.1%", icon: Icons.engineering, color: Colors.orange),
        _StatCard(title: "AVG RATING", value: "${reportData['avgRating']}/5.0", trend: "Stable", icon: Icons.star, color: Colors.amber),
      ],
    );
  }

  Widget _buildRevenueChart() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Revenue Velocity", style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 40),
          SizedBox(
            height: 300,
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: const FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: const [FlSpot(0, 3), FlSpot(1, 1), FlSpot(2, 4), FlSpot(3, 2), FlSpot(4, 5)],
                    isCurved: true,
                    color: AppTheme.primaryColor,
                    barWidth: 4,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(show: true, color: AppTheme.primaryColor.withOpacity(0.05)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryList() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Network Health", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          _SummaryRow("Verified Agents", reportData['totalAgents'].toString()),
          _SummaryRow("Mechanics On-Field", reportData['totalMechanics'].toString()),
          _SummaryRow("App Status", "HEALTHY", isStatus: true),
          const SizedBox(height: 32),
          Text("Last synced: ${DateFormat('HH:mm:ss').format(DateTime.now())}", style: const TextStyle(color: Colors.white30, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildActionSection() {
    return Center(
      child: OutlinedButton.icon(
        onPressed: _seedData,
        icon: const Icon(Icons.auto_awesome),
        label: const Text("Refresher / Seed Test Data"),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppTheme.textMuted,
          side: const BorderSide(color: Color(0xFFE2E8F0)),
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title, value, trend;
  final IconData icon;
  final Color color;
  const _StatCard({required this.title, required this.value, required this.trend, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: GoogleFonts.inter(color: AppTheme.textMuted, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1)),
              Icon(icon, color: color, size: 20),
            ],
          ),
          const Spacer(),
          Text(value, style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.w900, color: AppTheme.primaryColor)),
          const SizedBox(height: 4),
          Text(trend, style: GoogleFonts.inter(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12)),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label, value;
  final bool isStatus;
  const _SummaryRow(this.label, this.value, {this.isStatus = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 14)),
          Text(value, style: TextStyle(color: isStatus ? Colors.greenAccent : Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      ),
    );
  }
}

class _ExportButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _ExportButton({required this.label, required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      ),
    );
  }
}
