import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart'; // Added for calling/maps
import '../../core/services/api_service.dart';
import '../../core/theme/app_theme.dart';
import 'dart:ui';
import 'dart:async';

class JobDetailsScreen extends StatefulWidget {
  final dynamic jobData;
  const JobDetailsScreen({super.key, required this.jobData});

  @override
  State<JobDetailsScreen> createState() => _JobDetailsScreenState();
}

class _JobDetailsScreenState extends State<JobDetailsScreen> {
  late String _status;
  bool _isUpdating = false;
  late List<dynamic> _checklist;
  List<dynamic> _partsUsed = [];
  List<String> _photos = [];
  LatLng? _currentLoc;
  Timer? _trackingTimer;
  final List<LatLng> _routePoints = [];
  final TextEditingController _descriptionController = TextEditingController();
  String currentView = 'main';

  @override
  void initState() {
    super.initState();
    _status = widget.jobData['status'];
    _descriptionController.text = widget.jobData['description'] ?? '';
    _checklist = widget.jobData['serviceChecklist'] ?? [
      {"task": "Engine Inspection", "isDone": false},
      {"task": "Oil Level Check", "isDone": false},
      {"task": "Brake Testing", "isDone": false},
      {"task": "Battery Health", "isDone": false},
    ];
    
    // Initial customer location
    _routePoints.add(LatLng(
      widget.jobData['latitude']?.toDouble() ?? 28.6139,
      widget.jobData['longitude']?.toDouble() ?? 77.2090
    ));
    
    if (_status == 'on_the_way') _startTracking();
  }

  @override
  void dispose() {
    _trackingTimer?.cancel();
    super.dispose();
  }

  double _calculateTotal() {
    double total = 0;
    for (var part in _partsUsed) {
      total += (part['price'] ?? 0) * (part['quantity'] ?? 1);
    }
    if (widget.jobData['bookingPaymentMethod'] == 'Cash') {
      total += (widget.jobData['bookingCharge'] ?? 399).toDouble();
    }
    return total;
  }

  void _startTracking() {
    _trackingTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (!mounted) return;
      // Mock movement for demonstration
      setState(() {
        final dest = _routePoints.first;
        _currentLoc = LatLng(
          dest.latitude - 0.001 * (10 - timer.tick % 10),
          dest.longitude - 0.001 * (10 - timer.tick % 10)
        );
        // In real app, we would send this to backend via ApiService.updateLocation
      });
    });
  }

  Future<void> _updateStatus(String newStatus) async {
    setState(() => _isUpdating = true);
    final result = await ApiService.updateJobStatus(
      requestId: widget.jobData['_id'],
      status: newStatus,
      checklist: _checklist,
      parts: _partsUsed,
      description: _descriptionController.text, // Include description
    );
    if (result['success'] == true) {
      if (!mounted) return;
      setState(() {
        _status = newStatus;
        if (newStatus == 'on_the_way') _startTracking();
        if (newStatus == 'completed') _trackingTimer?.cancel();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Step Complete: $newStatus")),
      );
    }
    if (mounted) setState(() => _isUpdating = false);
  }

  void _openMaps() async {
    final lat = widget.jobData['latitude'];
    final lng = widget.jobData['longitude'];
    final url = 'https://www.google.com/maps/search/?api=1&query=$lat,$lng';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }

  void _makeCall() async {
    final phone = widget.jobData['userId']?['phone'] ?? '';
    final url = 'tel:$phone';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }

  @override
  Widget build(BuildContext context) {
    final customer = widget.jobData['userId'];
    final double destLat = widget.jobData['latitude']?.toDouble() ?? 28.6139;
    final double destLng = widget.jobData['longitude']?.toDouble() ?? 77.2090;

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: Row(
        children: [
          // Action Control Panel (Glassmorphic)
          _buildActionPanel(customer),
          
          // Map View with Floating Controls
          Expanded(
            child: Stack(
              children: [
                _buildMap(destLat, destLng),
                _buildOverlayHeader(),
                _buildFloatingNav(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionPanel(dynamic customer) {
    return Container(
      width: 450,
      margin: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(5), blurRadius: 40, offset: const Offset(0, 20))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPanelHeader(),
              const SizedBox(height: 32),
              _buildCustomerCard(customer),
              const SizedBox(height: 32),
              _buildStatusStepper(),
              const SizedBox(height: 32),
              _buildChecklistSection(),
              const SizedBox(height: 32),
              _buildPartsSection(),
              const SizedBox(height: 32),
              _buildDescriptionSection(),
              const SizedBox(height: 32),
              _buildPhotoSection(),
              const SizedBox(height: 32),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPanelHeader() {
    return Row(
      children: [
        IconButton(
          onPressed: () => Navigator.pop(context, true),
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("JOB #${widget.jobData['orderId']}", style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, letterSpacing: 1.1)),
            Text(_status.toUpperCase(), style: TextStyle(color: Colors.blue.shade700, fontSize: 12, fontWeight: FontWeight.bold)),
          ],
        ),
      ],
    );
  }

  Widget _buildCustomerCard(dynamic customer) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(24)),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(radius: 24, backgroundColor: Colors.white, child: Text(customer?['name']?[0] ?? "U")),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(customer?['name'] ?? "Unknown", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text(widget.jobData['vehicleType'] ?? "Unknown Vehicle", style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                  ],
                ),
              ),
              IconButton(onPressed: _makeCall, icon: const Icon(Icons.phone_in_talk, color: Colors.green)),
              IconButton(onPressed: () {}, icon: const Icon(Icons.chat_bubble_outline, color: Colors.blue)),
            ],
          ),
          const Divider(height: 32),
          _buildDetailRow(Icons.build_circle_outlined, "Service", widget.jobData['serviceType'] ?? "Repair"),
          const SizedBox(height: 12),
          _buildDetailRow(Icons.location_on_outlined, "Address", widget.jobData['pincode'] ?? "Delhi, India"),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 10),
        Text("$label: ", style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
      ],
    );
  }

  Widget _buildStatusStepper() {
    final steps = ['accepted', 'on_the_way', 'arrived', 'working', 'completed'];
    final currentIndex = steps.indexOf(_status);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("JOB PROGRESS", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey, letterSpacing: 1.2)),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: steps.map((step) {
            final index = steps.indexOf(step);
            final isActive = index <= currentIndex;
            return Container(
              height: 4,
              width: 70,
              decoration: BoxDecoration(
                color: isActive ? Colors.blue : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(2),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildChecklistSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("SERVICE CHECKLIST", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey, letterSpacing: 1.2)),
        const SizedBox(height: 16),
        ..._checklist.map((item) => CheckboxListTile(
          value: item['isDone'],
          onChanged: _status == 'working' ? (val) {
            setState(() => item['isDone'] = val);
          } : null,
          title: Text(item['task'], style: const TextStyle(fontSize: 14)),
          contentPadding: EdgeInsets.zero,
          dense: true,
          controlAffinity: ListTileControlAffinity.leading,
        )),
      ],
    );
  }

  Widget _buildPartsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("PARTS & BILLING", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey, letterSpacing: 1.2)),
            if (_status == 'working') TextButton(onPressed: _showPartsDialog, child: const Text("+ Add Part")),
          ],
        ),
        const SizedBox(height: 12),
        if (_partsUsed.isEmpty) Text("No parts added yet", style: TextStyle(color: Colors.grey.shade400, fontSize: 12)),
        ..._partsUsed.map((part) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              Text("${part['name']} x${part['quantity']}", style: const TextStyle(fontSize: 14)),
              const Spacer(),
              Text("₹${part['price'] * part['quantity']}", style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        )),
      ],
    );
  }

  Widget _buildDescriptionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("JOB DESCRIPTION / NOTES", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey, letterSpacing: 1.2)),
        const SizedBox(height: 12),
        TextField(
          controller: _descriptionController,
          maxLines: 3,
          enabled: _status == 'working' || _status == 'arrived',
          decoration: InputDecoration(
            hintText: "Enter work details...",
            fillColor: const Color(0xFFF8FAFC),
            filled: true,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
          style: const TextStyle(fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildPhotoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("PHOTO PROOF", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey, letterSpacing: 1.2)),
            if (_status == 'working') IconButton(onPressed: () {}, icon: const Icon(Icons.add_a_photo, size: 18)),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 80,
          child: _photos.isEmpty 
              ? Center(child: Text("No photos uploaded", style: TextStyle(color: Colors.grey.shade400, fontSize: 12)))
              : ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _photos.length,
                  itemBuilder: (c, i) => Container(
                    margin: const EdgeInsets.only(right: 12),
                    width: 80,
                    decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(12)),
                    child: const Icon(Icons.image, color: Colors.grey),
                  ),
                ),
        ),
      ],
    );
  }

  void _showPartsDialog() {
    String name = '';
    int price = 0;
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text("Add Spare Part"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(onChanged: (v) => name = v, decoration: const InputDecoration(labelText: "Part Name")),
            TextField(onChanged: (v) => price = int.tryParse(v) ?? 0, decoration: const InputDecoration(labelText: "Price"), keyboardType: TextInputType.number),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c), child: const Text("Cancel")),
          ElevatedButton(onPressed: () {
            setState(() {
              _partsUsed.add({"name": name, "price": price, "quantity": 1});
            });
            Navigator.pop(c);
          }, child: const Text("Add")),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    if (_status == 'completed' || _status == 'cancelled') return const SizedBox();

    String nextStatus = '';
    String label = '';
    Color color = Colors.blue;

    if (_status == 'accepted') { 
      nextStatus = 'on_the_way'; label = 'Start Trip'; color = Colors.blue; 
    } else if (_status == 'on_the_way') { 
      nextStatus = 'arrived'; label = 'Reached Destination'; color = Colors.indigo; 
    } else if (_status == 'arrived') { 
      nextStatus = 'working'; label = 'Start Work / Analysis'; color = Colors.purple; 
    } else if (_status == 'working') { 
      nextStatus = 'completed'; label = 'Complete Job'; color = Colors.green; 
    }

    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 60,
          child: ElevatedButton(
            onPressed: _isUpdating ? null : () {
              if (nextStatus == 'completed') {
                _showRazorpayPaymentSheet();
              } else {
                _updateStatus(nextStatus);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
            child: _isUpdating 
                ? const CircularProgressIndicator(color: Colors.white) 
                : Text(label.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: TextButton(
            onPressed: () => _updateStatus('cancelled'),
            child: const Text("Emergency Cancel", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }

  void _showRazorpayPaymentSheet() {
    final total = _calculateTotal();
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
                                const Text("MotoBuddy", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                                Text("Order ID: ${widget.jobData['orderId'] ?? 'MB-9921'}", style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12)),
                              ],
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            if (widget.jobData['bookingPaymentMethod'] == 'Cash') ...[
                              Text("Booking (Cash): ₹${widget.jobData['bookingCharge'] ?? 399}", style: TextStyle(color: Colors.white70, fontSize: 11)),
                              Text("Parts/Labor: ₹${_calculateTotal() - (widget.jobData['bookingCharge'] ?? 399)}", style: TextStyle(color: Colors.white70, fontSize: 11)),
                              const SizedBox(height: 4),
                            ],
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                              child: Text("Total: ₹$total", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: _buildPaymentContent(currentView, setModalState, sheetContext),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentContent(String view, StateSetter setModalState, BuildContext context) {
    switch (view) {
      case 'card': return _buildCardView(context);
      case 'upi': return _buildUPIView(context);
      case 'netbanking': return _buildNetbankingView(context);
      default: return _buildMainPaymentView(setModalState, context);
    }
  }

  Widget _buildMainPaymentView(StateSetter setModalState, BuildContext context) {
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
          onTap: () => setModalState(() => currentView = 'netbanking'),
        ),
        _buildRazorpayOption(
          title: "Wallet",
          subtitle: "PhonePe, Freecharge etc.",
          icon: Icons.account_balance_wallet,
          onTap: () { Navigator.pop(context); _finalizeJob("Online"); },
        ),
        
        const SizedBox(height: 24),
        _buildSectionTitle("MOTOBUDDY SPECIAL"),
        const SizedBox(height: 12),
        _buildRazorpayOption(
          title: "Cash Payment",
          subtitle: "Collect cash directly from customer",
          icon: Icons.payments,
          color: Colors.green,
          onTap: () { Navigator.pop(context); _finalizeJob("Cash"); },
          isProminent: true,
        ),
        const SizedBox(height: 32),
        _buildRazorpayFooter(),
      ],
    );
  }

  Widget _buildCardView(BuildContext context) {
    return Padding(
      key: const ValueKey('card'),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Enter Card Details", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
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
          _buildRazorpayCommandButton(context, "PAY NOW", () => _finalizeJob("Online")),
          const Spacer(),
          _buildRazorpayFooter(),
        ],
      ),
    );
  }

  Widget _buildUPIView(BuildContext context) {
    return ListView(
      key: const ValueKey('upi'),
      padding: const EdgeInsets.all(24),
      children: [
        const Text("Choose UPI App", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        const SizedBox(height: 20),
        _buildUPIOption(context, "Google Pay", Icons.account_balance_wallet),
        _buildUPIOption(context, "PhonePe", Icons.account_balance_wallet),
        _buildUPIOption(context, "Paytm", Icons.account_balance_wallet),
        const SizedBox(height: 20),
        const Divider(),
        const SizedBox(height: 20),
        _buildRazorpayTextField("Or enter UPI ID", "user@upi"),
        const SizedBox(height: 20),
        _buildRazorpayCommandButton(context, "PAY NOW", () => _finalizeJob("UPI")),
        const SizedBox(height: 32),
        _buildRazorpayFooter(),
      ],
    );
  }

  Widget _buildNetbankingView(BuildContext context) {
    return ListView(
      key: const ValueKey('netbanking'),
      padding: const EdgeInsets.all(24),
      children: [
        const Text("Select Bank", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        const SizedBox(height: 20),
        _buildBankOption(context, "SBI", Icons.account_balance),
        _buildBankOption(context, "HDFC", Icons.account_balance),
        _buildBankOption(context, "ICICI", Icons.account_balance),
        _buildBankOption(context, "Axis", Icons.account_balance),
        const SizedBox(height: 32),
        _buildRazorpayFooter(),
      ],
    );
  }

  Widget _buildRazorpayTextField(String label, String hint, {bool isPassword = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
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
        onPressed: () { Navigator.pop(context); onTap(); },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF5266EB),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      ),
    );
  }

  Widget _buildUPIOption(BuildContext context, String name, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue),
      title: Text(name),
      trailing: const Icon(Icons.arrow_forward_ios, size: 14),
      onTap: () { Navigator.pop(context); _finalizeJob("UPI"); },
    );
  }

  Widget _buildBankOption(BuildContext context, String name, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: Colors.orange),
      title: Text(name),
      trailing: const Icon(Icons.arrow_forward_ios, size: 14),
      onTap: () { Navigator.pop(context); _finalizeJob("Online"); },
    );
  }

  Widget _buildRazorpayFooter() {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.verified_user, size: 14, color: Colors.blueGrey),
          const SizedBox(width: 8),
          Text("PAYMENTS SECURED BY RAZORPAY", style: TextStyle(color: Colors.blueGrey.shade400, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(title, style: TextStyle(color: Colors.blueGrey.shade400, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
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
                        Text(title, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: isProminent ? Colors.green.shade900 : const Color(0xFF2A2E43))),
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
                    Text(subtitle, style: TextStyle(color: Colors.blueGrey.shade300, fontSize: 11)),
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

  Future<void> _finalizeJob(String method) async {
    setState(() => _isUpdating = true);
    final result = await ApiService.updateJobStatus(
      requestId: widget.jobData['_id'],
      status: 'completed',
      paymentMethod: method,
      checklist: _checklist,
      parts: _partsUsed,
      description: _descriptionController.text, 
    );
    if (result['success'] == true) {
      if (!mounted) return;
      setState(() => _status = 'completed');
      _showSuccessScreen(method);
    }
    if (mounted) setState(() => _isUpdating = false);
  }

  void _showSuccessScreen(String method) {
    final total = _calculateTotal();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (c) => Dialog.fullscreen(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animated Success Icon with Glow
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.green.withOpacity(0.1),
                  border: Border.all(color: Colors.green.withOpacity(0.2), width: 2),
                ),
                child: const Icon(Icons.check_circle_rounded, color: Colors.green, size: 100),
              ).animate().scale(duration: 800.ms, curve: Curves.elasticOut).shimmer(delay: 1.seconds, duration: 2.seconds),
              
              const SizedBox(height: 40),
              
              Text(
                "JOB COMPLETED", 
                style: GoogleFonts.outfit(
                  fontSize: 32, 
                  fontWeight: FontWeight.w900, 
                  letterSpacing: 4, 
                  color: Colors.white
                )
              ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.3),
              
              const SizedBox(height: 16),
              
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  "BILLING SUCCESSFUL", 
                  style: GoogleFonts.outfit(color: Colors.greenAccent, fontWeight: FontWeight.bold, letterSpacing: 1)
                ),
              ).animate().fadeIn(delay: 500.ms),
              
              const SizedBox(height: 48),
              
              // Summary Card (Glassmorphic)
              Container(
                width: 350,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                child: Column(
                  children: [
                    _buildSummaryRow("Status", "Finalized", Colors.blueAccent),
                    const Divider(height: 32, color: Colors.white10),
                    _buildSummaryRow("Amount Collected", "₹$total", Colors.greenAccent),
                    const Divider(height: 32, color: Colors.white10),
                    _buildSummaryRow("Payment Method", method, Colors.orangeAccent),
                  ],
                ),
              ).animate().fadeIn(delay: 700.ms).scale(begin: const Offset(0.9, 0.9)),
              
              const SizedBox(height: 60),
              
              SizedBox(
                width: 250,
                height: 60,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(c); 
                    Navigator.pop(context, true); 
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: Text(
                    "BACK TO DASHBOARD", 
                    style: GoogleFonts.outfit(fontWeight: FontWeight.w900, letterSpacing: 1.2)
                  ),
                ),
              ).animate().fadeIn(delay: 1.seconds),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, Color valueColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: Colors.grey.shade400, fontSize: 14)),
        Text(value, style: TextStyle(color: valueColor, fontWeight: FontWeight.bold, fontSize: 16)),
      ],
    );
  }

  Widget _buildMap(double lat, double lng) {
    return FlutterMap(
      options: MapOptions(
        initialCenter: LatLng(lat, lng),
        initialZoom: 15.0,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.motobuddy.mechanic',
        ),
        MarkerLayer(
          markers: [
            // Customer Marker
            Marker(
              point: LatLng(lat, lng),
              width: 80,
              height: 100,
              child: const Column(
                children: [
                  Icon(Icons.location_on, color: Colors.red, size: 40),
                ],
              ),
            ),
            // Mechanic Marker (Live)
            if (_currentLoc != null)
              Marker(
                point: _currentLoc!,
                width: 60,
                height: 60,
                child: const Icon(Icons.engineering, color: Colors.blue, size: 40).animate().scale(),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildOverlayHeader() {
    return Positioned(
      top: 40,
      left: 40,
      right: 40,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(200),
            borderRadius: BorderRadius.circular(100),
            boxShadow: [BoxShadow(color: Colors.black.withAlpha(5), blurRadius: 10)],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.timer, size: 16, color: Colors.blue),
              const SizedBox(width: 8),
              const Text("ESTIMATED REACHED: ", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              Text(_status == 'on_the_way' ? "12 MINS" : "READY", style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.blue)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingNav() {
    return Positioned(
      bottom: 40,
      right: 40,
      child: FloatingActionButton.extended(
        onPressed: _openMaps,
        backgroundColor: AppTheme.darkHeaderColor,
        icon: const Icon(Icons.navigation, color: AppTheme.primaryColor),
        label: const Text("NAVIGATE", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
