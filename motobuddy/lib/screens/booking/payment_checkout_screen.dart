import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'service_summary_screen.dart';
import '../../core/services/api_service.dart';

class PaymentCheckoutScreen extends StatefulWidget {
  final String bookingId;
  final double amount;
  
  const PaymentCheckoutScreen({super.key, required this.bookingId, required this.amount});

  @override
  State<PaymentCheckoutScreen> createState() => _PaymentCheckoutScreenState();
}

class _PaymentCheckoutScreenState extends State<PaymentCheckoutScreen> {
  bool isProcessing = false;
  String selectedMethod = "UPI";

  void _processPayment() async {
    setState(() => isProcessing = true);
    
    // Simulate Razorpay payment processing delay
    await Future.delayed(const Duration(seconds: 3));
    
    if (mounted) {
      setState(() => isProcessing = false);
      // Navigate to success summary
      Navigator.pushReplacement(
        context, 
        MaterialPageRoute(builder: (_) => ServiceSummaryScreen(bookingId: widget.bookingId))
      );
    }
  }

  void _showRazorpayBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.75,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: isProcessing 
                ? _buildProcessingState() 
                : Column(
                  children: [
                    // Razorpay Header
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1932B2),
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                                child: const Icon(Icons.security, color: Color(0xFF1932B2), size: 20), // Mock Razorpay Logo
                              ),
                              const SizedBox(width: 15),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("MotoBuddy Services", style: GoogleFonts.outfit(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                                  Text("razorpay.com", style: GoogleFonts.outfit(color: Colors.white70, fontSize: 12)),
                                ],
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text("₹${widget.amount.toStringAsFixed(2)}", style: GoogleFonts.outfit(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                              Text("View Details", style: GoogleFonts.outfit(color: Colors.blue.shade100, fontSize: 12, decoration: TextDecoration.underline)),
                            ],
                          )
                        ],
                      ),
                    ),
                    
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.all(24),
                        children: [
                          Text("CARDS, UPI & MORE", style: GoogleFonts.outfit(color: Colors.grey.shade600, fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                          const SizedBox(height: 16),
                          _buildPaymentOption(
                            icon: Icons.qr_code_scanner, 
                            title: "UPI / QR", 
                            subtitle: "Google Pay, PhonePe, Paytm & more", 
                            method: "UPI",
                            setSheetState: setSheetState
                          ),
                          _buildPaymentOption(
                            icon: Icons.credit_card, 
                            title: "Card", 
                            subtitle: "Visa, MasterCard, RuPay & more", 
                            method: "Card",
                            setSheetState: setSheetState
                          ),
                          _buildPaymentOption(
                            icon: Icons.account_balance, 
                            title: "Netbanking", 
                            subtitle: "All Indian banks", 
                            method: "Netbanking",
                            setSheetState: setSheetState
                          ),
                          _buildPaymentOption(
                            icon: Icons.account_balance_wallet, 
                            title: "Wallet", 
                            subtitle: "Amazon Pay, Mobikwik & more", 
                            method: "Wallet",
                            setSheetState: setSheetState
                          ),
                          _buildPaymentOption(
                            icon: Icons.money, 
                            title: "Cash on Delivery", 
                            subtitle: "Pay via cash after service", 
                            method: "Cash",
                            setSheetState: setSheetState
                          ),
                        ],
                      ),
                    ),
                    
                    // Footer Button
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          setSheetState(() => isProcessing = true);
                          _processPayment();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1932B2),
                          minimumSize: const Size(double.infinity, 56),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.lock_outline, color: Colors.white, size: 18),
                            const SizedBox(width: 8),
                            Text("Pay ₹${widget.amount.toStringAsFixed(2)}", style: GoogleFonts.outfit(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
            );
          }
        );
      }
    );
  }
  
  Widget _buildPaymentOption({required IconData icon, required String title, required String subtitle, required String method, required Function setSheetState}) {
    bool isSelected = selectedMethod == method;
    return GestureDetector(
      onTap: () => setSheetState(() => selectedMethod = method),
      child: AnimatedContainer(
        duration: 200.ms,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.withOpacity(0.05) : Colors.white,
          border: Border.all(color: isSelected ? const Color(0xFF1932B2) : Colors.grey.shade200, width: isSelected ? 2 : 1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(8)),
              child: Icon(icon, color: Colors.black87),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text(subtitle, style: GoogleFonts.outfit(color: Colors.grey.shade600, fontSize: 12)),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: Color(0xFF1932B2)),
          ],
        ),
      ),
    );
  }
  
  Widget _buildProcessingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: Color(0xFF1932B2)),
          const SizedBox(height: 24),
          Text("Processing Payment...", style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
          Text("Please do not press back or close this screen.", style: GoogleFonts.outfit(color: Colors.grey)),
        ],
      ).animate().fadeIn(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text("Checkout", style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.black87)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black87, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             Text("Payment Details", style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold)),
             const SizedBox(height: 20),
             Container(
               padding: const EdgeInsets.all(24),
               decoration: BoxDecoration(
                 color: Colors.white,
                 borderRadius: BorderRadius.circular(20),
                 border: Border.all(color: Colors.grey.shade100),
                 boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 5))],
               ),
               child: Column(
                 children: [
                   _buildInvoiceRow("Service Charge", "₹${(widget.amount * 0.8).toStringAsFixed(2)}"),
                   const SizedBox(height: 12),
                   _buildInvoiceRow("Taxes & Fees", "₹${(widget.amount * 0.2).toStringAsFixed(2)}"),
                   const SizedBox(height: 16),
                   const Divider(),
                   const SizedBox(height: 16),
                   Row(
                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                     children: [
                       Text("Total Amount", style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
                       Text("₹${widget.amount.toStringAsFixed(2)}", style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold, color: const Color(0xFF1932B2))),
                     ],
                   )
                 ],
               ),
             ).animate().slideY(begin: 0.1).fadeIn(),
             
             const SizedBox(height: 40),
             
             Container(
               width: double.infinity,
               padding: const EdgeInsets.all(24),
               decoration: BoxDecoration(
                 gradient: const LinearGradient(colors: [Color(0xFF1932B2), Color(0xFF2563EB)]),
                 borderRadius: BorderRadius.circular(20),
                 boxShadow: [BoxShadow(color: Colors.blue.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))],
               ),
               child: Column(
                 crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                   Row(
                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                     children: [
                        Text("Pay Securely", style: GoogleFonts.outfit(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                        const Icon(Icons.shield, color: Colors.white70),
                     ],
                   ),
                   const SizedBox(height: 10),
                   Text("100% secure payments powered by Razorpay checkout interface.", style: GoogleFonts.outfit(color: Colors.white70, fontSize: 13)),
                   const SizedBox(height: 24),
                   ElevatedButton(
                     onPressed: _showRazorpayBottomSheet,
                     style: ElevatedButton.styleFrom(
                       backgroundColor: Colors.white,
                       foregroundColor: const Color(0xFF1932B2),
                       minimumSize: const Size(double.infinity, 50),
                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                     ),
                     child: Text("Proceed to Pay", style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16)),
                   )
                 ],
               ),
             ).animate().slideY(begin: 0.2).fadeIn(delay: 200.ms),
             
             const SizedBox(height: 40),
             Center(
               child: Row(
                 mainAxisAlignment: MainAxisAlignment.center,
                 children: [
                   const Icon(Icons.lock, size: 14, color: Colors.grey),
                   const SizedBox(width: 6),
                   Text("Payments are 100% secure & encrypted", style: GoogleFonts.outfit(color: Colors.grey, fontSize: 12)),
                 ],
               ),
             )
          ],
        ),
      ),
    );
  }

  Widget _buildInvoiceRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.outfit(color: Colors.grey.shade600, fontSize: 15)),
        Text(value, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 15)),
      ],
    );
  }
}
