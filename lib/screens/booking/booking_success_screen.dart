import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../tracking/live_tracking_screen.dart';

class BookingSuccessScreen extends StatelessWidget {
  final String bookingId;
  final String paymentMethod;

  const BookingSuccessScreen({
    super.key, 
    required this.bookingId, 
    required this.paymentMethod
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle, color: Colors.green, size: 80),
              ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),
              
              const SizedBox(height: 32),
              
              Text(
                "BOOKING SUCCESSFUL!",
                style: GoogleFonts.outfit(
                  fontSize: 28, 
                  fontWeight: FontWeight.w900, 
                  letterSpacing: 1.5,
                  color: Colors.black,
                ),
              ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),
              
              const SizedBox(height: 16),
              
              Text(
                paymentMethod == "Cash" 
                  ? "Your request has been placed. Please keep ₹399 cash ready to pay the mechanic."
                  : "Payment received. Your expert mechanic is being assigned.",
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  fontSize: 16, 
                  color: Colors.grey.shade600,
                  height: 1.5,
                ),
              ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2),
              
              const SizedBox(height: 48),
              
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context, 
                    MaterialPageRoute(builder: (_) => LiveTrackingScreen(bookingId: bookingId))
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: Text(
                  "TRACK YOUR MECHANIC", 
                  style: GoogleFonts.outfit(fontWeight: FontWeight.bold, letterSpacing: 1),
                ),
              ).animate().fadeIn(delay: 600.ms).scale(),
              
              const SizedBox(height: 20),
              
              TextButton(
                onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
                child: Text(
                  "BACK TO HOME",
                  style: GoogleFonts.outfit(color: Colors.grey, fontWeight: FontWeight.bold),
                ),
              ).animate().fadeIn(delay: 800.ms),
            ],
          ),
        ),
      ),
    );
  }
}
