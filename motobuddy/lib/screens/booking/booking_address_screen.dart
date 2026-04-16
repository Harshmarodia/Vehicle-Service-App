import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../core/services/api_service.dart';
import '../tracking/live_tracking_screen.dart';
import 'add_address_screen.dart';
import 'booking_success_screen.dart';

class BookingAddressScreen extends StatefulWidget {
  final String vehicleType;
  final String serviceCategory;
  final String description;
  final File? image;

  const BookingAddressScreen({
    super.key,
    required this.vehicleType,
    required this.serviceCategory,
    required this.description,
    this.image,
  });

  @override
  State<BookingAddressScreen> createState() => _BookingAddressScreenState();
}

class _BookingAddressScreenState extends State<BookingAddressScreen> {
  final TextEditingController _vehicleNumberController = TextEditingController();
  bool loading = false;
  String currentView = 'main';
  
  List<Map<String, dynamic>> savedAddresses = [];
  Map<String, dynamic>? selectedAddress;

  @override
  void initState() {
    super.initState();
    _loadAddresses();
  }

  Future<void> _loadAddresses() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('saved_addresses');
    if (raw != null) {
      final List decoded = jsonDecode(raw);
      setState(() {
        savedAddresses = decoded.map((e) => Map<String, dynamic>.from(e)).toList();
        if (savedAddresses.isNotEmpty) {
          selectedAddress = savedAddresses[0]; 
        }
      });
    }
  }

  Future<void> _saveAddresses() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('saved_addresses', jsonEncode(savedAddresses));
  }

  @override
  void dispose() {
    _vehicleNumberController.dispose();
    super.dispose();
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: GoogleFonts.outfit()), 
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Future<void> _submitBooking() async {
    if (_vehicleNumberController.text.trim().isEmpty) {
      _showError("Vehicle Number is required.");
      return;
    }
    if (selectedAddress == null) {
      _showError("Please select a service location.");
      return;
    }

    setState(() => loading = true);
    
    final result = await ApiService.bookService(
      serviceType: widget.serviceCategory,
      vehicleType: widget.vehicleType,
      description: widget.description + " (Vehicle: ${_vehicleNumberController.text.toUpperCase()})",
      pincode: selectedAddress!["pincode"],
      serviceMode: "On-Site",
      latitude: selectedAddress!["latitude"],
      longitude: selectedAddress!["longitude"],
    );

    if (mounted) setState(() => loading = false);

    if (result["success"] == true) {
      if (!mounted) return;
      _showRazorpayPaymentSheet(result["bookingId"] ?? "");
    } else {
      _showError(result["message"] ?? "Booking failed. Check network.");
    }
  }

  void _showRazorpayPaymentSheet(String bookingId) {
    setState(() => currentView = 'main'); 

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (c) => StatefulBuilder(
        builder: (sheetContext, setModalState) => Container(
          height: MediaQuery.of(c).size.height * 0.85,
          decoration: const BoxDecoration(
            color: Color(0xFFF5F8FA),
            borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Razorpay Style Header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                decoration: const BoxDecoration(
                  color: Color(0xFF2A2E43),
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            if (currentView != 'main') 
                              IconButton(
                                icon: const Icon(Icons.arrow_back, color: Colors.white),
                                onPressed: () => setModalState(() => currentView = 'main'),
                              ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("MotoBuddy", style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                                Text("Service Charge", style: GoogleFonts.outfit(color: Colors.white.withOpacity(0.6), fontSize: 12)),
                              ],
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                          child: Text("₹399", style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: _buildPaymentContent(currentView, setModalState, sheetContext, bookingId),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentContent(String view, StateSetter setModalState, BuildContext context, String bookingId) {
    switch (view) {
      case 'card': return _buildCardView(context, bookingId);
      case 'upi': return _buildUPIView(context, bookingId);
      default: return _buildMainPaymentView(setModalState, context, bookingId);
    }
  }

  Widget _buildMainPaymentView(StateSetter setModalState, BuildContext context, String bookingId) {
    return ListView(
      key: const ValueKey('main'),
      padding: const EdgeInsets.all(20),
      children: [
        _buildSectionTitle("CARDS, UPI & MORE"),
        const SizedBox(height: 12),
        _buildRazorpayOption(
          title: "Cards",
          subtitle: "Visa, MasterCard, RuPay & More",
          icon: Icons.credit_card,
          onTap: () => setModalState(() => currentView = 'card'),
        ),
        _buildRazorpayOption(
          title: "UPI / QR",
          subtitle: "Google Pay, PhonePe, BHIM & more",
          icon: Icons.qr_code_2,
          onTap: () => setModalState(() => currentView = 'upi'),
          isNew: true,
        ),
        _buildRazorpayOption(
          title: "Netbanking",
          subtitle: "All Indian Banks",
          icon: Icons.account_balance,
          onTap: () => _finishPayment(context, bookingId, "Online"),
        ),
        
        const SizedBox(height: 24),
        _buildSectionTitle("MOTOBUDDY SPECIAL"),
        const SizedBox(height: 12),
        _buildRazorpayOption(
          title: "Cash on Service",
          subtitle: "Pay to mechanic after service",
          icon: Icons.payments,
          color: Colors.green,
          onTap: () => _finishPayment(context, bookingId, "Cash"),
          isProminent: true,
        ),
        const SizedBox(height: 32),
        _buildRazorpayFooter(),
      ],
    );
  }

  Widget _buildCardView(BuildContext context, String bookingId) {
    return Padding(
      key: const ValueKey('card'),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Enter Card Details", style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 20),
          _buildRazorpayTextField("Card Number", "XXXX XXXX XXXX XXXX"),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildRazorpayTextField("Expiry", "MM/YY")),
              const SizedBox(width: 16),
              Expanded(child: _buildRazorpayTextField("CVV", "XXX", isPassword: true)),
            ],
          ),
          const SizedBox(height: 32),
          _buildRazorpayCommandButton(context, "PAY ₹399", () => _finishPayment(context, bookingId, "Online")),
          const Spacer(),
          _buildRazorpayFooter(),
        ],
      ),
    );
  }

  Widget _buildUPIView(BuildContext context, String bookingId) {
    return ListView(
      key: const ValueKey('upi'),
      padding: const EdgeInsets.all(24),
      children: [
        Text("Choose UPI App", style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18)),
        const SizedBox(height: 20),
        _buildUPIOption(context, "Google Pay", Icons.account_balance_wallet, bookingId),
        _buildUPIOption(context, "PhonePe", Icons.account_balance_wallet, bookingId),
        const SizedBox(height: 20),
        const Divider(),
        const SizedBox(height: 20),
        _buildRazorpayTextField("Or enter UPI ID", "user@upi"),
        const SizedBox(height: 20),
        _buildRazorpayCommandButton(context, "PAY ₹399", () => _finishPayment(context, bookingId, "UPI")),
        const SizedBox(height: 32),
        _buildRazorpayFooter(),
      ],
    );
  }

  Future<void> _finishPayment(BuildContext context, String bookingId, String method) async {
    setState(() => loading = true);
    Navigator.pop(context); // Close sheet
    
    await ApiService.updateBookingPayment(bookingId: bookingId, method: method);
    
    if (mounted) setState(() => loading = false);

    if (mounted) {
      Navigator.pushReplacement(
        this.context,
        MaterialPageRoute(builder: (_) => BookingSuccessScreen(bookingId: bookingId, paymentMethod: method))
      );
    }
  }

  Widget _buildRazorpayTextField(String label, String hint, {bool isPassword = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
        const SizedBox(height: 8),
        TextField(
          obscureText: isPassword,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildRazorpayCommandButton(BuildContext context, String label, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF5266EB),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(label, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16)),
      ),
    );
  }

  Widget _buildUPIOption(BuildContext context, String name, IconData icon, String bookingId) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue),
      title: Text(name, style: GoogleFonts.outfit()),
      trailing: const Icon(Icons.arrow_forward_ios, size: 14),
      onTap: () => _finishPayment(context, bookingId, "UPI"),
    );
  }

  Widget _buildRazorpaySectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(title, style: GoogleFonts.outfit(color: Colors.blueGrey.shade400, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
    );
  }

  Widget _buildRazorpayFooter() {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.verified_user, size: 14, color: Colors.blueGrey),
          const SizedBox(width: 8),
          Text("PAYMENTS SECURED BY RAZORPAY", style: GoogleFonts.outfit(color: Colors.blueGrey.shade400, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(title, style: GoogleFonts.outfit(color: Colors.blueGrey.shade400, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
    );
  }

  Widget _buildRazorpayOption({
    required String title, 
    required String subtitle, 
    required IconData icon, 
    required VoidCallback onTap, 
    Color color = Colors.indigo,
    bool isNew = false,
    bool isProminent = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 1),
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: isProminent ? Colors.green.withOpacity(0.05) : Colors.white,
            border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
          ),
          child: Row(
            children: [
              Icon(icon, color: isProminent ? Colors.green : const Color(0xFF5266EB), size: 22),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(title, style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 14, color: isProminent ? Colors.green.shade900 : const Color(0xFF2A2E43))),
                        if (isNew) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(4)),
                            child: const Text("NEW", style: TextStyle(color: Colors.blue, fontSize: 8, fontWeight: FontWeight.bold)),
                          ),
                        ]
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(subtitle, style: GoogleFonts.outfit(color: Colors.blueGrey.shade300, fontSize: 11)),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 12, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text("Vehicle & Location", style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 20)),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        centerTitle: true,
      ),
      body: loading 
        ? const Center(child: CircularProgressIndicator(color: Colors.blueAccent))
        : SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildVehicleDetails(),
                      const SizedBox(height: 30),
                      _buildSavedAddresses(),
                      const SizedBox(height: 20),
                      _buildAddAddressButton(),
                      const SizedBox(height: 40),
                      _buildConfirmButton(),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: const BoxDecoration(
        color: Colors.black,
        image: DecorationImage(
          image: NetworkImage("https://images.unsplash.com/photo-1590202422730-1c0733a18a5e?auto=format&fit=crop&w=800&q=80"),
          fit: BoxFit.cover,
          opacity: 0.6,
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text("Almost Done!", style: GoogleFonts.outfit(color: Colors.yellow, fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1.5)).animate().fadeIn().slideY(begin: 0.5),
              const SizedBox(height: 8),
              Text("Where should our mechanic reach?", style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 24, height: 1.2)).animate().fadeIn(delay: 200.ms).slideX(begin: -0.2),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVehicleDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Vehicle Details", style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 15),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    widget.vehicleType.contains("Two") ? Icons.two_wheeler : 
                    widget.vehicleType.contains("Three") ? Icons.electric_rickshaw : Icons.directions_car,
                    color: Colors.blueAccent,
                  ),
                  const SizedBox(width: 10),
                  Text(widget.vehicleType, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16)),
                ],
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _vehicleNumberController,
                textCapitalization: TextCapitalization.characters,
                style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18, letterSpacing: 1.5),
                decoration: InputDecoration(
                  labelText: "Vehicle Registration Number*",
                  labelStyle: GoogleFonts.outfit(color: Colors.grey.shade500, fontSize: 14, fontWeight: FontWeight.normal, letterSpacing: 0),
                  hintText: "e.g. DL 01 AB 1234",
                  hintStyle: GoogleFonts.outfit(color: Colors.grey.shade300),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.blueAccent, width: 2)),
                ),
              ),
            ],
          ),
        ),
      ],
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1);
  }

  Widget _buildSavedAddresses() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Select Service Location", style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 15),
        ...savedAddresses.map((addr) {
          bool isSelected = selectedAddress?["name"] == addr["name"] && selectedAddress?["address"] == addr["address"];
          return GestureDetector(
            onTap: () => setState(() => selectedAddress = addr),
            child: Container(
              margin: const EdgeInsets.only(bottom: 15),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? Colors.blueAccent : Colors.grey.shade200, 
                  width: isSelected ? 2 : 1
                ),
                boxShadow: [
                  if (isSelected) BoxShadow(color: Colors.blueAccent.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.blueAccent : Colors.grey.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      addr["name"] == "Home" ? Icons.home : 
                      addr["name"] == "Work" ? Icons.work : Icons.location_on, 
                      color: isSelected ? Colors.white : Colors.grey,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          addr["name"]!, 
                          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87)
                        ),
                        const SizedBox(height: 4),
                        Text(
                          addr["address"]!, 
                          style: GoogleFonts.outfit(color: Colors.grey.shade600, height: 1.4, fontSize: 13)
                        ),
                      ],
                    ),
                  ),
                  if (isSelected)
                    const Icon(Icons.check_circle, color: Colors.blueAccent, size: 24).animate().scale(),
                ],
              ),
            ),
          ).animate(target: isSelected ? 1 : 0).scale(begin: const Offset(1, 1), end: const Offset(1.02, 1.02), duration: 200.ms);
        }).toList(),
      ],
    ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.1);
  }

  Widget _buildAddAddressButton() {
    return InkWell(
      onTap: () async {
        final result = await Navigator.push(
          context, 
          MaterialPageRoute(builder: (_) => const AddAddressScreen())
        );
        if (result != null && result is Map<String, dynamic>) {
          setState(() {
            savedAddresses.add(result);
            selectedAddress = result;
          });
          _saveAddresses();
        }
      },
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.blue.shade100, width: 1.5, style: BorderStyle.solid),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.add_location_alt, color: Colors.blueAccent),
            const SizedBox(width: 10),
            Text("Add New Location", style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.blueAccent, fontSize: 16)),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 200.ms);
  }

  Widget _buildConfirmButton() {
    return SizedBox(
      width: double.infinity,
      height: 65,
      child: ElevatedButton(
        onPressed: loading ? null : _submitBooking,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black, 
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 10,
          shadowColor: Colors.black38,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("CONFIRM BOOKING", style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18, letterSpacing: 1)),
            const SizedBox(width: 10),
            const Icon(Icons.check_circle_outline, size: 22),
          ],
        ),
      ).animate(onPlay: (controller) => controller.repeat())
       .shimmer(duration: 2.seconds, color: Colors.white.withOpacity(0.1)),
    );
  }
}
