import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/services/api_service.dart';

class LiveTrackingScreen extends StatefulWidget {
  final String bookingId;
  const LiveTrackingScreen({super.key, required this.bookingId});

  @override
  State<LiveTrackingScreen> createState() => _LiveTrackingScreenState();
}

class _LiveTrackingScreenState extends State<LiveTrackingScreen> {
  Map<String, dynamic>? booking;
  bool isLoading = true;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _fetchStatus();
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) => _fetchStatus());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _fetchStatus() async {
    try {
      final result = await ApiService.getTrackingStatus(widget.bookingId);
      if (mounted) {
        if (result['success'] == true) {
          setState(() {
            booking = result['booking'];
            isLoading = false;
          });
        } else {
          // If booking not found or error, stop loading so we don't hang
          setState(() => isLoading = false);
        }
      }
    } catch (e) {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator(color: Colors.blueAccent)));
    }

    final status = booking?['status'] ?? 'pending';
    final liveStatus = booking?['liveStatus'] ?? 'idle';
    final eta = booking?['estimatedETA'] ?? 'Calculating...';
    final mechanic = booking?['mechanicId'];

    double progress = 0.1;
    if (status == 'accepted') progress = 0.3;
    if (liveStatus == 'moving') progress = 0.5;
    if (liveStatus == 'arrived') progress = 0.8;
    if (status == 'completed') progress = 1.0;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text("Live Tracking", style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // ===== Map Placeholder =====
          Container(
            height: 300,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              image: const DecorationImage(
                image: ResizeImage(
                  NetworkImage("https://images.unsplash.com/photo-1526778548025-fa2f459cd5c1?auto=format&fit=crop&w=800&q=80"),
                  width: 600,
                ),
                fit: BoxFit.cover,
                opacity: 0.2,
              ),
            ),
            child: Stack(
              children: [
                const Center(
                  child: Icon(Icons.location_on, size: 60, color: Colors.redAccent),
                ),
                if (liveStatus == 'moving' || liveStatus == 'arrived')
                  Positioned(
                    top: 100,
                    left: 150,
                    child: Column(
                      children: [
                        const Icon(Icons.motorcycle, size: 40, color: Colors.blueAccent),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: Colors.blueAccent, borderRadius: BorderRadius.circular(8)),
                          child: Text("Mechanic", style: GoogleFonts.outfit(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          // ===== Service Status =====
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Service Progress",
                      style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: (status == 'completed' ? Colors.green : Colors.orange).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        status.toUpperCase(),
                        style: GoogleFonts.outfit(
                          fontSize: 11, 
                          fontWeight: FontWeight.bold, 
                          color: status == 'completed' ? Colors.green : Colors.orange
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 10,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.blueAccent),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  liveStatus == 'arrived' ? "Mechanic has arrived at your location" : 
                  liveStatus == 'moving' ? "Mechanic is on the way" :
                  status == 'accepted' ? "Agent has accepted your request" : "Looking for nearby agents...",
                  style: GoogleFonts.outfit(fontSize: 14, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          // ===== Mechanic Details =====
          if (mechanic != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
                ),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 25,
                      backgroundColor: Color(0xFFE0E7FF),
                      child: Icon(Icons.person, color: Colors.blueAccent),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(mechanic['fullName'] ?? "Mechanic Assigned", style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16)),
                          Text("Estimated Arrival: $eta", style: GoogleFonts.outfit(color: Colors.grey, fontSize: 13)),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.phone_in_talk, color: Colors.green),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                padding: const EdgeInsets.all(20),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey.shade100),
                ),
                child: Text(
                  "Waiting for agent to assign a mechanic...", 
                  style: GoogleFonts.outfit(color: Colors.grey, fontSize: 14, fontStyle: FontStyle.italic),
                  textAlign: TextAlign.center,
                ),
              ),
            ),

          const Spacer(),

          // ===== Cancel Button =====
          if (status == 'pending' || status == 'accepted')
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.redAccent,
                  side: const BorderSide(color: Colors.redAccent, width: 1.5),
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: () => Navigator.pop(context),
                child: Text("CANCEL SERVICE", style: GoogleFonts.outfit(fontWeight: FontWeight.bold, letterSpacing: 1)),
              ),
            )
        ],
      ),
    );
  }
}