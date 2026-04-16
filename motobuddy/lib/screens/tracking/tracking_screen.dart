import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/services/api_service.dart';
import '../booking/service_summary_screen.dart';
import '../booking/payment_checkout_screen.dart';

class TrackingScreen extends StatefulWidget {
  final String bookingId;
  const TrackingScreen({super.key, required this.bookingId});

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  String status = "Request Sent";
  Map<String, dynamic>? agentInfo;
  bool isLoading = true;
  Timer? _timer;
  String eta = "Calculating...";
  double progress = 0.1;

  @override
  void initState() {
    super.initState();
    _fetchStatus();
    // Poll every 5 seconds for real-time updates
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) => _fetchStatus());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _fetchStatus() async {
    final res = await ApiService.getTrackingStatus(widget.bookingId);
    if (mounted) {
      setState(() {
        status = res["status"] ?? "Request Sent";
        agentInfo = res["agent"];
        eta = res["eta"] ?? (agentInfo != null ? "12 Mins" : "Searching...");
        isLoading = false;
        
        // Map status to progress bar
        _updateProgress();

        if (status == "Service Completed") {
          _timer?.cancel();
          // Extract amount or default to 450
          double amount = 450.0;
          if (res["totalAmount"] != null) {
            amount = double.tryParse(res["totalAmount"].toString()) ?? 450.0;
          }
          Navigator.pushReplacement(
            context, 
            MaterialPageRoute(
              builder: (_) => PaymentCheckoutScreen(
                bookingId: widget.bookingId, 
                amount: amount,
              )
            )
          );
        }
      });
    }
  }

  void _updateProgress() {
    final steps = ["Pending", "Accepted", "Mechanic Assigned", "Mechanic On The Way", "Service Started", "Service Completed"];
    int index = steps.indexOf(status);
    if (index == -1) index = 0;
    progress = (index + 1) / steps.length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text("Live Tracking", style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 22, color: Colors.black87)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black87, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: isLoading 
        ? const Center(child: CircularProgressIndicator(color: Colors.blueAccent))
        : SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                _buildEtaHeader(),
                const SizedBox(height: 30),
                _buildProfessionalStepper(),
                const SizedBox(height: 40),
                if (agentInfo != null) _buildMechanicInfoCard().animate().fadeIn().slideY(begin: 0.1),
                const SizedBox(height: 40),
                _buildCancelButton(),
                const SizedBox(height: 50),
              ],
            ),
          ),
    );
  }

  Widget _buildEtaHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Colors.blueAccent, Color(0xFF1E40AF)]),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [BoxShadow(color: Colors.blueAccent.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Estimated Arrival", style: GoogleFonts.outfit(color: Colors.white70, fontSize: 14)),
                  const SizedBox(height: 4),
                  Text(eta, style: GoogleFonts.outfit(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
                child: const Icon(Icons.timer_outlined, color: Colors.white, size: 30),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white.withOpacity(0.2),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              minHeight: 8,
            ),
          ).animate().shimmer(duration: 2.seconds),
        ],
      ),
    );
  }

  Widget _buildProfessionalStepper() {
    final steps = [
      {"title": "Request Sent", "desc": "We have received your request", "icon": Icons.send_rounded},
      {"title": "Accepted", "desc": "Agent has accepted your booking", "icon": Icons.check_circle_outline},
      {"title": "On The Way", "desc": "Mechanic is heading to your location", "icon": Icons.directions_bike},
      {"title": "At Location", "desc": "Mechanic has reached the destination", "icon": Icons.location_on},
      {"title": "Work in Progress", "desc": "Your vehicle is being serviced", "icon": Icons.build_circle_outlined},
    ];

    // Simple mapping for current step
    int currentStep = 0;
    if (status == "Accepted") currentStep = 1;
    if (status == "Mechanic Assigned" || status == "Mechanic On The Way") currentStep = 2;
    if (status == "At Location") currentStep = 3;
    if (status == "Service Started") currentStep = 4;
    if (status == "Service Completed") currentStep = 5;

    return Column(
      children: List.generate(steps.length, (index) {
        bool isCompleted = index < currentStep;
        bool isActive = index == currentStep;
        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  AnimatedContainer(
                    duration: 500.ms,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isCompleted ? Colors.blueAccent : (isActive ? Colors.blue.shade100 : Colors.white),
                      shape: BoxShape.circle,
                      border: Border.all(color: isActive ? Colors.blueAccent : Colors.grey.shade300, width: 2),
                    ),
                    child: Icon(
                      steps[index]["icon"] as IconData,
                      size: 18,
                      color: isCompleted ? Colors.white : (isActive ? Colors.blueAccent : Colors.grey.shade400),
                    ),
                  ),
                  if (index != steps.length - 1)
                    Expanded(
                      child: Container(
                        width: 2,
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        color: isCompleted ? Colors.blueAccent : Colors.grey.shade300,
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        steps[index]["title"] as String,
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
                          color: isActive || isCompleted ? Colors.black87 : Colors.grey.shade400,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        steps[index]["desc"] as String,
                        style: GoogleFonts.outfit(fontSize: 13, color: Colors.grey.shade500),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildMechanicInfoCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.blueAccent, width: 2)),
                child: const CircleAvatar(radius: 28, backgroundColor: Color(0xFFE0E7FF), child: Icon(Icons.person, color: Colors.blueAccent, size: 30)),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(agentInfo?['name'] ?? "Mechanic Name", style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18)),
                    const SizedBox(height: 2),
                    Text("Licensed Professional Mechanic", style: GoogleFonts.outfit(color: Colors.grey, fontSize: 13)),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {}, // Call trigger
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
                  child: const Icon(Icons.phone_in_talk, color: Colors.white, size: 20),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildDetailItem(Icons.star_rounded, "4.9", "Rating", Colors.amber),
              _buildDetailItem(Icons.history, "800+", "Jobs Done", Colors.blueAccent),
              _buildDetailItem(Icons.verified_user, "Verified", "Security", Colors.green),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String val, String label, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 8),
        Text(val, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 15)),
        Text(label, style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _buildCancelButton() {
    return Column(
      children: [
        Text(
          "Mechanic is following the safest route to reach you.",
          style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey, fontStyle: FontStyle.italic),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        TextButton(
          onPressed: () {},
          child: Text("CANCEL ASSISTANCE", style: GoogleFonts.outfit(color: Colors.red.shade400, fontWeight: FontWeight.bold, letterSpacing: 1, fontSize: 12)),
        ),
      ],
    );
  }
}
