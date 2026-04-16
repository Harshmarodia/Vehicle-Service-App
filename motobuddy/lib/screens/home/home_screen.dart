import 'package:flutter/material.dart';
import '../booking/service_booking_screen.dart';
import '../profile/profile_screen.dart';
import '../history/service_history_screen.dart';
import '../profile/vehicle_management_screen.dart';
import '../support/support_screen.dart';
import '../../core/services/api_service.dart';
import '../../widgets/dashboard_layout.dart';

class HomeScreen extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback onToggleTheme;

  const HomeScreen({
    super.key,
    required this.isDarkMode,
    required this.onToggleTheme,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<dynamic> nearbyGarages = [];
  List<dynamic> recentRequests = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
  }

  Future<void> _fetchDashboardData() async {
    setState(() => isLoading = true);
    try {
      final garagesRes = await ApiService.getNearbyGarages("380001"); // Default for now
      final bookingsRes = await ApiService.getCustomerBookings();
      
      if (mounted) {
        setState(() {
          nearbyGarages = garagesRes["garages"] ?? [];
          recentRequests = (bookingsRes["bookings"] ?? []).take(3).toList();
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DashboardLayout(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Welcome back, Rider!",
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: -0.5),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Your vehicle health looks good. We have 24 active mechanics nearby.",
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 15),
                    ),
                  ],
                ),
                _buildEmergencyAction(),
              ],
            ),

            const SizedBox(height: 40),

            // Statistics/Quick Info Grid
            LayoutBuilder(
              builder: (context, constraints) {
                final cardWidth = (constraints.maxWidth - 40) / 3;
                return Row(
                  children: [
                    _buildStatusCard("Active Requests", "0", Icons.pending_actions, Colors.blue, cardWidth),
                    const SizedBox(width: 20),
                    _buildStatusCard("Service History", recentRequests.length.toString(), Icons.history_edu, Colors.green, cardWidth),
                    const SizedBox(width: 20),
                    _buildStatusCard("Nearby Garages", nearbyGarages.length.toString(), Icons.garage_outlined, Colors.orange, cardWidth),
                  ],
                );
              },
            ),

            const SizedBox(height: 50),

            // Main Dashboard Content Grid
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Activity & Map Section
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Map Placeholder
                      const Text("Live Service Status", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 20),
                      Container(
                        height: 350,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          image: const DecorationImage(
                            image: ResizeImage(
                              NetworkImage("https://images.unsplash.com/photo-1526778548025-fa2f459cd5ce?auto=format&fit=crop&w=1200&q=80"),
                              width: 800,
                            ),
                            fit: BoxFit.cover,
                            opacity: 0.8,
                          ),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 20, offset: const Offset(0, 10)),
                          ],
                        ),
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)],
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.location_on, color: Colors.red),
                                SizedBox(width: 8),
                                Text("Ahmedabad, Gujarat", style: TextStyle(fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                      const Text("Recent Activity", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 20),
                      _buildRecentActivity(),
                    ],
                  ),
                ),
                const SizedBox(width: 40),
                // Nearby Mechanics Column
                Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Nearby Mechanics", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 20),
                      _buildNearbyListVertical(),
                      const SizedBox(height: 30),
                      _buildSupportCard(),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSupportCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.blue.shade900, Colors.blue.shade700]),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.headset_mic, color: Colors.white, size: 30),
          const SizedBox(height: 16),
          const Text("Need Assistance?", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text("Our 24/7 support team is here to help you with any vehicle issues.", style: TextStyle(color: Colors.white70, fontSize: 13)),
          const SizedBox(height: 20),
          TextButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SupportScreen())),
            style: TextButton.styleFrom(
              backgroundColor: Colors.white.withOpacity(0.2),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: const Text("Chat with Support"),
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencyAction() {
    return ElevatedButton.icon(
      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ServiceBookingScreen())),
      icon: const Icon(Icons.flash_on, color: Colors.white, size: 20),
      label: const Text("REQUEST BREAKDOWN HELP", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.1)),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.orange.shade800,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 8,
        shadowColor: Colors.orange.withOpacity(0.4),
      ),
    );
  }

  Widget _buildStatusCard(String title, String value, IconData icon, Color color, double width) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(color: Colors.grey.shade500, fontSize: 13, fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNearbyListVertical() {
    if (isLoading) return const Center(child: CircularProgressIndicator());
    if (nearbyGarages.isEmpty) return const Text("No mechanics found nearby.");

    return Column(
      children: nearbyGarages.take(5).map((garage) {
        return Container(
          margin: const EdgeInsets.only(bottom: 15),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFEEEEEE)),
          ),
          child: Row(
            children: [
              const Icon(Icons.garage_rounded, color: Colors.blueAccent),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(garage['garageName'] ?? garage['name'] ?? "Garage", style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text(garage['address'] ?? "", style: TextStyle(color: Colors.grey.shade500, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildEmergenyBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Colors.black, Color(0xFF222222)]),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 15, offset: const Offset(0, 10))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("In an Emergency?", style: TextStyle(color: Colors.yellow, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text("Request instant breakdown assistance around you.", style: TextStyle(color: Colors.white70, fontSize: 14)),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ServiceBookingScreen())),
            icon: const Icon(Icons.warning_amber_rounded, color: Colors.black),
            label: const Text("Request Breakdown Assistance", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.yellow,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: widget.isDarkMode ? Colors.black : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: widget.isDarkMode ? Colors.white12 : Colors.grey.shade200),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 10),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          ],
        ),
      ),
    );
  }

  Widget _buildNearbyList() {
    if (isLoading) return const Center(child: CircularProgressIndicator());
    if (nearbyGarages.isEmpty) return const Text("No mechanics found nearby.");

    return SizedBox(
      height: 180,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: nearbyGarages.length,
        itemBuilder: (context, index) {
          final garage = nearbyGarages[index];
          return Container(
            width: 200,
            margin: const EdgeInsets.only(right: 15),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: widget.isDarkMode ? Colors.black : Colors.white,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: widget.isDarkMode ? Colors.white12 : Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Icon(Icons.garage, color: Colors.yellow),
                    Text("⭐ ${garage['rating'] ?? '4.5'}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 15),
                Text(garage['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 5),
                Text(garage['address']['street'], style: const TextStyle(color: Colors.grey, fontSize: 12), maxLines: 2, overflow: TextOverflow.ellipsis),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildRecentActivity() {
    if (isLoading) return const SizedBox();
    if (recentRequests.isEmpty) return const Text("No recent activity.", style: TextStyle(color: Colors.grey));

    return Column(
      children: recentRequests.map((req) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: widget.isDarkMode ? Colors.black : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: widget.isDarkMode ? Colors.white12 : Colors.grey.shade200),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.yellow.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.history, color: Colors.yellow),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(req['serviceType'] ?? "Service", style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text(req['description'] ?? "", style: const TextStyle(color: Colors.grey, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                child: Text(req['status'] ?? "Pending", style: const TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}