import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'add_address_screen.dart';

class AddressSelectionScreen extends StatefulWidget {
  const AddressSelectionScreen({super.key});

  @override
  State<AddressSelectionScreen> createState() => _AddressSelectionScreenState();
}

class _AddressSelectionScreenState extends State<AddressSelectionScreen> {
  final List<Map<String, dynamic>> savedAddresses = [
    {
      "name": "Home",
      "address": "123, Green Avenue, DLF Phase 3, Gurgaon - 122002",
      "pincode": "122002",
      "city": "Gurgaon",
      "latitude": 28.4901,
      "longitude": 77.0890,
    },
    {
      "name": "Work",
      "address": "Tech Park, Tower B, Sector 62, Noida - 201301",
      "pincode": "201301",
      "city": "Noida",
      "latitude": 28.6274,
      "longitude": 77.3725,
    }
  ];

  String? selectedId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text("Select Location", style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          TextButton.icon(
            onPressed: () async {
              final result = await Navigator.push(
                context, 
                MaterialPageRoute(builder: (_) => const AddAddressScreen())
              );
              if (result != null && result is Map) {
                Navigator.pop(context, result);
              }
            },
            icon: const Icon(Icons.add, size: 20),
            label: Text("Add New", style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
            style: TextButton.styleFrom(foregroundColor: Colors.black),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            height: 180,
            decoration: const BoxDecoration(
              color: Colors.black,
              image: DecorationImage(
                image: NetworkImage("https://images.unsplash.com/photo-1548345680-f5475ea902f4?auto=format&fit=crop&w=800&q=80"),
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
                    Text("Saved Locations", style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 26, height: 1.2)).animate().fadeIn().slideX(begin: -0.2),
                    const SizedBox(height: 8),
                    Text("Choose where you want the service", style: GoogleFonts.outfit(color: Colors.yellow, fontWeight: FontWeight.bold, fontSize: 14)).animate().fadeIn(delay: 200.ms),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              itemCount: savedAddresses.length,
              itemBuilder: (context, index) {
                final addr = savedAddresses[index];
                bool isSelected = selectedId == addr["name"];
                return GestureDetector(
                  onTap: () => setState(() => selectedId = addr["name"]),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected ? Colors.black : Colors.grey.shade200, 
                        width: isSelected ? 2 : 1.5
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: isSelected ? Colors.black.withOpacity(0.08) : Colors.black.withOpacity(0.02), 
                          blurRadius: 12, 
                          offset: const Offset(0, 4)
                        )
                      ],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.black : Colors.grey.shade100,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isSelected ? Icons.check : (addr["name"] == "Home" ? Icons.home : Icons.work), 
                            color: isSelected ? Colors.yellow : Colors.grey,
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
                                style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.black87)
                              ),
                              const SizedBox(height: 6),
                              Text(
                                addr["address"]!, 
                                style: GoogleFonts.outfit(color: Colors.grey.shade600, height: 1.4, fontSize: 14)
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ).animate(target: isSelected ? 1 : 0).scale(begin: const Offset(1, 1), end: const Offset(1.02, 1.02), duration: 200.ms),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, -5))],
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
            ),
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: selectedId == null ? null : () {
                    final addr = savedAddresses.firstWhere((e) => e["name"] == selectedId);
                    Navigator.pop(context, addr);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.yellow,
                    disabledBackgroundColor: Colors.grey.shade300,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    elevation: 0,
                  ),
                  child: Text(
                    "CONFIRM ADDRESS", 
                    style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 0.8)
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
