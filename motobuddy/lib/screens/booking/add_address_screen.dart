import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AddAddressScreen extends StatefulWidget {
  final Map<String, dynamic>? existingAddress;
  const AddAddressScreen({super.key, this.existingAddress});

  @override
  State<AddAddressScreen> createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends State<AddAddressScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _landmarkController = TextEditingController();
  final _pincodeController = TextEditingController();
  
  double? latitude = 28.6139;
  double? longitude = 77.2090;
  bool isLocating = false;

  bool get _isEditing => widget.existingAddress != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final addr = widget.existingAddress!;
      _nameController.text = addr['name'] ?? '';
      _phoneController.text = addr['phone'] ?? '';
      _pincodeController.text = addr['pincode'] ?? '';
      // Parse address back — it was saved as "address, landmark, pincode"
      final fullAddress = (addr['address'] ?? '') as String;
      final parts = fullAddress.split(', ');
      if (parts.length >= 3) {
        _addressController.text = parts[0];
        _landmarkController.text = parts.sublist(1, parts.length - 1).join(', ');
      } else {
        _addressController.text = fullAddress;
      }
      latitude = (addr['latitude'] as num?)?.toDouble() ?? 28.6139;
      longitude = (addr['longitude'] as num?)?.toDouble() ?? 77.2090;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _landmarkController.dispose();
    _pincodeController.dispose();
    super.dispose();
  }

  void _saveAddress() {
    if (_formKey.currentState!.validate()) {
      Navigator.pop(context, {
        "name": _nameController.text,
        "phone": _phoneController.text,
        "address": "${_addressController.text}, ${_landmarkController.text}, ${_pincodeController.text}",
        "pincode": _pincodeController.text,
        "latitude": latitude,
        "longitude": longitude,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(_isEditing ? "Edit Address" : "New Address", style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                color: Colors.white,
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_isEditing ? "Update your address" : "Where should we come?", style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.w900, height: 1.1)),
                    const SizedBox(height: 8),
                    Text("Enter details for accurate navigation", style: GoogleFonts.outfit(color: Colors.grey.shade500, fontSize: 15)),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionLabel("CONTACT DETAILS"),
                    const SizedBox(height: 12),
                    _buildTextField(_nameController, "Full Name", Icons.person_outline),
                    const SizedBox(height: 16),
                    _buildTextField(_phoneController, "Mobile Number", Icons.phone_android_outlined, keyboardType: TextInputType.phone),
                    
                    const SizedBox(height: 32),
                    _sectionLabel("ADDRESS DETAILS"),
                    const SizedBox(height: 12),
                    _buildTextField(_pincodeController, "Pincode", Icons.pin_drop_outlined, keyboardType: TextInputType.number),
                    const SizedBox(height: 16),
                    _buildTextField(_addressController, "House / Flat / Building", Icons.home_outlined),
                    const SizedBox(height: 16),
                    _buildTextField(_landmarkController, "Landmark (Optional)", Icons.location_on_outlined),
                    
                    const SizedBox(height: 32),
                    _sectionLabel("LOCATE ON MAP"),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: () async {
                        setState(() => isLocating = true);
                        // Simulate finding location
                        await Future.delayed(const Duration(seconds: 2));
                        setState(() {
                          isLocating = false;
                          latitude = 28.4595; // Updated to a new dummy location
                          longitude = 77.0266;
                          _pincodeController.text = "122001";
                          _addressController.text = "Selected from Map";
                        });
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Location fetched successfully!"), backgroundColor: Colors.green)
                          );
                        }
                      },
                      child: Container(
                        height: 180,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(20),
                          image: const DecorationImage(
                            image: NetworkImage("https://images.unsplash.com/photo-1526778548025-fa2f459cd5c1?auto=format&fit=crop&w=600&q=80"),
                            fit: BoxFit.cover,
                            opacity: 0.6,
                          ),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 15, offset: const Offset(0, 5))],
                        ),
                        child: Stack(
                          children: [
                            Center(
                              child: isLocating 
                                ? const CircularProgressIndicator(color: Colors.yellow) 
                                : Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.location_searching, color: Colors.yellow, size: 40),
                                      const SizedBox(height: 12),
                                      Text(
                                        "TAP TO PIN ON MAP", 
                                        style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.2)
                                      ),
                                    ],
                                  ),
                            ),
                            if (!isLocating)
                              Positioned(
                                bottom: 12,
                                right: 12,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(color: Colors.black.withOpacity(0.7), borderRadius: BorderRadius.circular(8)),
                                  child: Text(
                                    "GPS: ${latitude?.toStringAsFixed(4)}, ${longitude?.toStringAsFixed(4)}",
                                    style: const TextStyle(color: Colors.white, fontSize: 10),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 48),
                    SizedBox(
                      width: double.infinity,
                      height: 60,
                      child: ElevatedButton(
                        onPressed: _saveAddress,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.yellow,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                          elevation: 0,
                        ),
                        child: Text(_isEditing ? "UPDATE ADDRESS" : "SAVE ADDRESS", style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionLabel(String label) {
    return Text(
      label, 
      style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.grey.shade400, letterSpacing: 1.5)
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {TextInputType keyboardType = TextInputType.text}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 16),
      validator: (value) => (value == null || value.isEmpty) && !label.contains("Optional") ? "Required" : null,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.outfit(color: Colors.grey.shade500, fontWeight: FontWeight.w400),
        prefixIcon: Icon(icon, color: Colors.black87),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: Colors.grey.shade200)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: Colors.grey.shade200)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Colors.black, width: 2)),
        contentPadding: const EdgeInsets.symmetric(vertical: 18),
      ),
    );
  }
}
