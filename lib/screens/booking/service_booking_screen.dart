import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../core/services/api_service.dart';
import 'booking_address_screen.dart';

class ServiceBookingScreen extends StatefulWidget {
  const ServiceBookingScreen({super.key});

  @override
  State<ServiceBookingScreen> createState() => _ServiceBookingScreenState();
}

class _ServiceBookingScreenState extends State<ServiceBookingScreen> {
  bool loading = false;
  
  // Selection data
  String? selectedVehicleType;
  final List<Map<String, dynamic>> vehicleTypes = [
    {"type": "Two Wheeler", "icon": Icons.two_wheeler},
    {"type": "Three Wheeler", "icon": Icons.electric_rickshaw},
    {"type": "Four Wheeler", "icon": Icons.directions_car},
  ];

  String? serviceCategory;
  final TextEditingController _descController = TextEditingController();
  
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  final List<String> categories = ["Flat Tyre", "Battery Issue", "Engine Problem", "Fuel Issue", "Accident", "Other"];
  final List<IconData> categoryIcons = [Icons.adjust, Icons.battery_alert, Icons.settings_input_component, Icons.local_gas_station, Icons.minor_crash, Icons.more_horiz];

  // Speech to Text
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      setState(() => _selectedImage = File(image.path));
    }
  }

  void _listen() async {
    if (!_isListening) {
      // Check microphone permission first
      var status = await Permission.microphone.status;
      if (status.isDenied) {
        status = await Permission.microphone.request();
        if (status.isDenied) {
          _showError("Microphone permission denied.");
          return;
        }
      }

      if (status.isPermanentlyDenied) {
        _showError("Please enable microphone access in settings.");
        openAppSettings();
        return;
      }

      bool available = await _speech.initialize(
        onStatus: (status) {
          if (status == 'done' || status == 'notListening') {
            if (mounted) setState(() => _isListening = false);
          }
        },
        onError: (errorNotification) {
          debugPrint('Speech error: $errorNotification');
          if (mounted) {
            setState(() => _isListening = false);
            _showError("Voice input error: ${errorNotification.errorMsg}");
          }
        },
      );
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) {
            setState(() {
              if (val.recognizedWords.isNotEmpty) {
                _descController.text = val.recognizedWords;
              }
              if (val.finalResult) _isListening = false;
            });
          },
        );
      } else {
        _showError("Voice input not available on this device.");
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  @override
  void dispose() {
    _descController.dispose();
    _speech.stop();
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

  Future<void> _proceedToNext() async {
    if (selectedVehicleType == null) {
      _showError("Bhai, pehle gaadi ka type select kar lo!");
      return;
    }
    if (serviceCategory == null) {
      _showError("Kya problem hui hai, batana padega.");
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BookingAddressScreen(
          vehicleType: selectedVehicleType!,
          serviceCategory: serviceCategory!,
          description: _descController.text,
          image: _selectedImage,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Quick Service", style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 22, color: Colors.blueAccent)),
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
                _buildHeaderImage(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildVehicleTypeSelector(),
                      const SizedBox(height: 30),
                      Text("Select Service Type", style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)).animate().fadeIn(delay: 200.ms).slideX(begin: -0.1),
                      const SizedBox(height: 15),
                      _buildProfessionalCategoryGrid().animate().fadeIn(delay: 300.ms),
                      const SizedBox(height: 30),
                      Text("Issue Description", style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)).animate().fadeIn(delay: 400.ms).slideX(begin: -0.1),
                      const SizedBox(height: 15),
                      _buildProfessionalDescriptionBox().animate().fadeIn(delay: 500.ms),
                      const SizedBox(height: 40),
                      _buildNextButton(),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildHeaderImage() {
    return Container(
      width: double.infinity,
      height: 220,
      decoration: const BoxDecoration(
        color: Colors.black,
        image: DecorationImage(
          image: NetworkImage("https://images.unsplash.com/photo-1552526149-868df32f0eb3?auto=format&fit=crop&w=800&q=80"),
          fit: BoxFit.cover,
          opacity: 0.7,
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: Colors.blueAccent, borderRadius: BorderRadius.circular(20)),
                child: Text("24/7 ASSISTANCE", style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10, letterSpacing: 1.2)),
              ).animate().fadeIn().slideY(begin: 0.5),
              const SizedBox(height: 12),
              Text("We'll get you back\non the road.", style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 28, height: 1.2)).animate().fadeIn(delay: 200.ms).slideX(begin: -0.2),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVehicleTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("What are you driving?", style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 15),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: vehicleTypes.map((v) {
            bool isSelected = selectedVehicleType == v['type'];
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => selectedVehicleType = v['type']),
                child: AnimatedContainer(
                  duration: 300.ms,
                  margin: EdgeInsets.only(right: v == vehicleTypes.last ? 0 : 10),
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.blueAccent : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: isSelected ? Colors.blueAccent : Colors.grey.shade200, width: 2),
                    boxShadow: [
                      if (isSelected) BoxShadow(color: Colors.blueAccent.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))
                    ],
                  ),
                  child: Column(
                    children: [
                      Icon(v['icon'], size: 36, color: isSelected ? Colors.white : Colors.grey.shade600),
                      const SizedBox(height: 8),
                      Text(
                        v['type'], 
                        textAlign: TextAlign.center,
                        style: GoogleFonts.outfit(
                          fontSize: 13, 
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500, 
                          color: isSelected ? Colors.white : Colors.black87
                        )
                      ),
                    ],
                  ),
                ),
              ).animate(target: isSelected ? 1 : 0).scale(begin: const Offset(1, 1), end: const Offset(1.05, 1.05), duration: 200.ms),
            );
          }).toList(),
        ),
      ],
    ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.1);
  }

  Widget _buildProfessionalCategoryGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 120,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.9,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        bool isSelected = serviceCategory == categories[index];
        return InkWell(
          onTap: () => setState(() => serviceCategory = categories[index]),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            decoration: BoxDecoration(
              color: isSelected ? Colors.blue.shade50 : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: isSelected ? Colors.blueAccent : Colors.grey.shade200, width: 1.5),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(categoryIcons[index], color: isSelected ? Colors.blueAccent : Colors.grey.shade600, size: 28),
                const SizedBox(height: 8),
                Text(
                  categories[index], 
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(fontSize: 12, fontWeight: isSelected ? FontWeight.bold : FontWeight.w500, color: isSelected ? Colors.blueAccent : Colors.black87),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfessionalDescriptionBox() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          TextField(
            controller: _descController,
            maxLines: 4,
            style: GoogleFonts.outfit(fontSize: 15),
            decoration: InputDecoration(
              hintText: "Tell us what happened...",
              hintStyle: GoogleFonts.outfit(color: Colors.grey.shade400),
              contentPadding: const EdgeInsets.all(20),
              border: InputBorder.none,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(15),
            child: Row(
              children: [
                GestureDetector(
                  onTap: _listen,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: _isListening ? Colors.blueAccent : Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)],
                    ),
                    child: Row(
                      children: [
                        Icon(_isListening ? Icons.stop : Icons.mic, color: _isListening ? Colors.white : Colors.blueAccent, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          _isListening ? "Listening..." : "Voice Input", 
                          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: _isListening ? Colors.white : Colors.blueAccent, fontSize: 13)
                        ),
                      ],
                    ),
                  ).animate(target: _isListening ? 1 : 0).shimmer(duration: 1.seconds, color: Colors.blue.shade200),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
                    child: Icon(Icons.camera_alt_outlined, color: Colors.grey.shade700, size: 22),
                  ),
                ),
                if (_selectedImage != null) ...[
                  const SizedBox(width: 12),
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(_selectedImage!, width: 45, height: 45, fit: BoxFit.cover),
                      ),
                      Positioned(
                        right: 0,
                        top: 0,
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedImage = null),
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                            child: const Icon(Icons.close, color: Colors.white, size: 10),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNextButton() {
    return SizedBox(
      width: double.infinity,
      height: 65,
      child: ElevatedButton(
        onPressed: _proceedToNext,
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
            Text("NEXT", style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18, letterSpacing: 1)),
            const SizedBox(width: 10),
            const Icon(Icons.arrow_forward, size: 20),
          ],
        ),
      ).animate(onPlay: (controller) => controller.repeat())
       .shimmer(duration: 2.seconds, color: Colors.white.withOpacity(0.1)),
    );
  }
}
