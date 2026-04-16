import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import '../../core/services/api_service.dart';
import 'mechanic_management_screen.dart';
import 'product_management_screen.dart';
import 'guide_detail_screen.dart';
import 'feedback_summary_screen.dart';
import '../earnings/garage_earnings_screen.dart';

class AgentDashboardScreen extends StatefulWidget {
  const AgentDashboardScreen({super.key});

  @override
  State<AgentDashboardScreen> createState() => _AgentDashboardScreenState();
}

class _AgentDashboardScreenState extends State<AgentDashboardScreen> {
  String? agentId;
  List<dynamic> pendingRequests = [];
  List<dynamic> acceptedJobs = [];
  bool isLoading = true;
  bool isHistoryLoading = false;
  Timer? _timer;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadAgentInfo();
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) => _fetchRequests());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadAgentInfo() async {
    agentId = await ApiService.getAgentId();
    _fetchRequests();
  }

  Future<void> _fetchRequests() async {
    if (agentId == null) return;
    final result = await ApiService.getAgentRequests(agentId!);
    if (result['success'] == true) {
      if (context.mounted) {
        setState(() {
          pendingRequests = result['requests'] ?? [];
          isLoading = false;
        });
      }
    }
  }

  Future<void> _fetchHistory() async {
    if (agentId == null) return;
    setState(() => isHistoryLoading = true);
    final result = await ApiService.getAgentHistory(agentId!);
    if (result['success'] == true) {
      if (context.mounted) {
        setState(() {
          acceptedJobs = result['history'] ?? [];
          isHistoryLoading = false;
        });
      }
    } else {
      setState(() => isHistoryLoading = false);
    }
  }

  Future<void> _acceptRequest(String requestId) async {
    final messenger = ScaffoldMessenger.of(context);
    final result = await ApiService.acceptRequest(requestId, agentId ?? "");
    if (result['success'] == true) {
      _fetchRequests();
      if (!context.mounted) return;
      
      if (result['mechanicAssigned'] == true) {
        messenger.showSnackBar(
          const SnackBar(content: Text("Request Accepted! Mechanic assigned."), backgroundColor: Colors.green),
        );
      } else {
        messenger.showSnackBar(
          const SnackBar(content: Text("Accepted! No mechanic available. Please assign manually."), backgroundColor: Colors.orange),
        );
        setState(() => _selectedIndex = 1); // Switch to Active Jobs
        _fetchHistory();
      }
    }
  }

  void _showAssignMechanicDialog(String requestId) async {
    final res = await ApiService.getMechanics(agentId ?? "");
    if (res['success'] != true) return;
    
    final List<dynamic> mechanics = res['mechanics'] ?? [];
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Assign Mechanic"),
        content: SizedBox(
          width: 400,
          child: mechanics.isEmpty 
            ? const Text("No mechanics registered. Please add one first.")
            : ListView.builder(
                shrinkWrap: true,
                itemCount: mechanics.length,
                itemBuilder: (context, index) {
                  final m = mechanics[index];
                  final bool isBusy = m['isBusy'] ?? false;
                  return ListTile(
                    leading: const Icon(Icons.engineering),
                    title: Text(m['fullName'] ?? 'Mechanic'),
                    subtitle: Text(isBusy ? "Currently Busy" : "Available"),
                    enabled: !isBusy,
                    onTap: () async {
                      final assignRes = await ApiService.assignMechanic(requestId, m['_id']);
                      if (context.mounted) {
                        Navigator.pop(context);
                        if (assignRes['success'] == true) {
                          _fetchHistory();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Mechanic assigned!"), backgroundColor: Colors.green),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(assignRes['message'] ?? "Error"), backgroundColor: Colors.red),
                          );
                        }
                      }
                    },
                  );
                },
              ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width >= 1100;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FA),
      drawer: !isDesktop ? _buildSidebar() : null,
      appBar: !isDesktop 
        ? AppBar(
            backgroundColor: const Color(0xFF0F172A),
            title: const Text("Garage Panel", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            iconTheme: const IconThemeData(color: Colors.white),
          ) 
        : null,
      body: Row(
        children: [
          // Premium Sidebar (Visible only on Desktop)
          if (isDesktop) _buildSidebar(),
          // Main Content Area
          Expanded(
            child: Column(
              children: [
                if (isDesktop) 
                  Container(
                    height: 80,
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    color: Colors.white,
                    child: Row(
                      children: [
                        Text(
                          ['Operations Overview', 'Active Jobs', 'Mechanic Management', 'Parts Inventory', 'Customer Feedback', 'Training & Tutorials', 'EV Hub', 'Garage Earnings'][_selectedIndex],
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const Spacer(),
                        IconButton(onPressed: _fetchRequests, icon: const Icon(Icons.refresh, color: Colors.blueAccent)),
                        const SizedBox(width: 20),
                        const CircleAvatar(
                          backgroundColor: Color(0xFFFFD700),
                          child: Icon(Icons.person, color: Colors.black),
                        ),
                      ],
                    ),
                  ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(size.width < 600 ? 10 : 40),
                    child: _getSelectedContent(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 280,
      height: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFF0F172A),
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 20)],
      ),
      child: Column(
        children: [
          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "MotoBuddy",
                style: GoogleFonts.outfit(
                  color: Colors.white, 
                  fontSize: 28, 
                  fontWeight: FontWeight.w900, 
                  letterSpacing: -0.5
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text("GARAGE PANEL", style: TextStyle(color: Colors.white54, fontSize: 10, letterSpacing: 3)),
          const SizedBox(height: 40),
          _SidebarItem(
            icon: Icons.grid_view_rounded,
            title: "Dashboard",
            isSelected: _selectedIndex == 0,
            onTap: () {
              setState(() => _selectedIndex = 0);
              if (Navigator.canPop(context)) Navigator.pop(context);
            },
          ),
          _SidebarItem(
            icon: Icons.assignment_rounded,
            title: "Active Jobs",
            isSelected: _selectedIndex == 1,
            onTap: () {
              setState(() => _selectedIndex = 1);
              _fetchHistory();
              if (Navigator.canPop(context)) Navigator.pop(context);
            },
          ),
          _SidebarItem(
            icon: Icons.engineering_rounded,
            title: "Mechanics",
            isSelected: _selectedIndex == 2,
            onTap: () {
              setState(() => _selectedIndex = 2);
              if (Navigator.canPop(context)) Navigator.pop(context);
            },
          ),
          _SidebarItem(
            icon: Icons.inventory_2_rounded,
            title: "Inventory",
            isSelected: _selectedIndex == 3,
            onTap: () {
              setState(() => _selectedIndex = 3);
              if (Navigator.canPop(context)) Navigator.pop(context);
            },
          ),
          _SidebarItem(
            icon: Icons.reviews_rounded,
            title: "Feedback",
            isSelected: _selectedIndex == 4,
            onTap: () {
              setState(() => _selectedIndex = 4);
              if (Navigator.canPop(context)) Navigator.pop(context);
            },
          ),
          _SidebarItem(
            icon: Icons.school_rounded,
            title: "Tutorials",
            isSelected: _selectedIndex == 5,
            onTap: () {
              setState(() => _selectedIndex = 5);
              if (Navigator.canPop(context)) Navigator.pop(context);
            },
          ),
          _SidebarItem(
            icon: Icons.ev_station_rounded,
            title: "EV Hub",
            isSelected: _selectedIndex == 6,
            onTap: () {
              setState(() => _selectedIndex = 6);
              if (Navigator.canPop(context)) Navigator.pop(context);
            },
          ),
          _SidebarItem(
            icon: Icons.payments_rounded,
            title: "Earnings",
            isSelected: _selectedIndex == 7,
            onTap: () {
              setState(() => _selectedIndex = 7);
              if (Navigator.canPop(context)) Navigator.pop(context);
            },
          ),
          const Spacer(),
          _SidebarItem(
            icon: Icons.logout_rounded,
            title: "Sign Out",
            isSelected: false,
            onTap: () async {
              final navigator = Navigator.of(context);
              await ApiService.logout();
              if (context.mounted) {
                navigator.pushReplacementNamed('/');
              }
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _getSelectedContent() {
    switch (_selectedIndex) {
      case 0:
        return _buildOverview();
      case 1:
        return _buildHistory();
      case 2:
        return MechanicManagementScreen(agentId: agentId ?? "");
      case 3:
        return ProductManagementScreen(garageId: agentId ?? "");
      case 4:
        return const FeedbackSummaryScreen();
      case 5:
        return _buildTutorials();
      case 6:
        return _buildEVHub();
      case 7:
        return GarageEarningsScreen(agentId: agentId ?? "");
      default:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.construction_rounded, size: 80, color: Colors.grey.shade300),
              const SizedBox(height: 20),
              Text(
                "${['Dashboard', 'Jobs', 'Mechanics', 'Inventory', 'Feedback', 'Tutorials', 'EV Hub', 'Earnings'][_selectedIndex]} is under optimization.",
                style: const TextStyle(fontSize: 18, color: Colors.grey),
              ),
            ],
          ),
        );
    }
  }

  Widget _buildOverview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("System Status", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 24),
        Wrap(
          spacing: 24,
          runSpacing: 24,
          children: [
            _StatCard(
              title: "New Requests", 
              value: pendingRequests.length.toString(), 
              icon: Icons.notifications_active, 
              color: Colors.orange,
              width: 300,
            ),
            _StatCard(
              title: "Today's Revenue", 
              value: "₹4,250", 
              icon: Icons.account_balance_wallet, 
              color: Colors.green,
              width: 300,
            ),
            _StatCard(
              title: "Active Mechanics", 
              value: "8/12", 
              icon: Icons.people, 
              color: Colors.blue,
              width: 300,
            ),
          ],
        ),
        const SizedBox(height: 48),
        const Text("Live Requests", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 24),
        if (isLoading)
          const Center(child: CircularProgressIndicator())
        else if (pendingRequests.isEmpty)
          const Expanded(child: Center(child: Text("All clear! No pending requests.", style: TextStyle(color: Colors.grey))))
        else
          Expanded(
            child: ListView.builder(
              itemCount: pendingRequests.length,
              itemBuilder: (context, index) {
                final req = pendingRequests[index];
                return _RequestCard(
                  data: req,
                  onAccept: () => _acceptRequest(req['_id']),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildHistory() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text("Active & Past Jobs", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const Spacer(),
            if (isHistoryLoading) const CircularProgressIndicator(strokeWidth: 2),
          ],
        ),
        const SizedBox(height: 24),
        if (acceptedJobs.isEmpty && !isHistoryLoading)
          const Expanded(child: Center(child: Text("No jobs in your history yet.", style: TextStyle(color: Colors.grey))))
        else
          Expanded(
            child: ListView.builder(
              itemCount: acceptedJobs.length,
              itemBuilder: (context, index) {
                final job = acceptedJobs[index];
                return _RequestCard(
                  data: job,
                  isHistory: true,
                  onAccept: () {}, 
                  onAssign: () => _showAssignMechanicDialog(job['_id']),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildTutorials() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Mechanic Training & Tutorials", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        const Text("Standard Operating Procedures for all vehicle types", style: TextStyle(color: Colors.grey)),
        const SizedBox(height: 32),
        Expanded(
          child: GridView.count(
            crossAxisCount: MediaQuery.of(context).size.width > 1200 ? 3 : 2,
            crossAxisSpacing: 20,
            mainAxisSpacing: 20,
            children: [
              _GuideCard(
                title: "Multi-point Inspection", 
                icon: Icons.playlist_add_check_rounded, 
                color: Colors.blue,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GuideDetailScreen(
                  title: "Multi-point Inspection",
                  icon: Icons.playlist_add_check_rounded,
                  color: Colors.blue,
                  steps: [
                    "Visual inspection of chassis and frame for cracks or rust.",
                    "Check all fluid levels (Engine Oil, Brake Fluid, Coolant).",
                    "Inspect tyre tread depth and air pressure.",
                    "Verify all electricals (Lights, Indicators, Horn).",
                    "Check drive chain/belt tension and lubrication.",
                    "Test brake performance and pad thickness.",
                  ],
                  tips: [
                    "Always use a professional torque wrench for critical bolts.",
                    "Wear safety gloves during inspection.",
                  ],
                ))),
              ),
              _GuideCard(
                title: "Engine Diagnostics", 
                icon: Icons.terminal_rounded, 
                color: Colors.red,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GuideDetailScreen(
                  title: "Engine Diagnostics",
                  icon: Icons.terminal_rounded,
                  color: Colors.red,
                  steps: [
                    "Connect OBD-II scanner to the vehicle port.",
                    "Scan for error codes (DTCs).",
                    "Check spark plug condition and gap.",
                    "Monitor engine idling RPM and sound.",
                    "Verify compression ratio if necessary.",
                  ],
                  tips: [
                    "Don't clear codes before recording them for the customer.",
                  ],
                ))),
              ),
              _GuideCard(
                title: "Brake System Service", 
                icon: Icons.settings_backup_restore_rounded, 
                color: Colors.orange,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GuideDetailScreen(
                  title: "Brake System Service",
                  icon: Icons.settings_backup_restore_rounded,
                  color: Colors.orange,
                  steps: [
                    "Dismantle brake calipers and clean with brake cleaner.",
                    "Inspect brake pads for uneven wear.",
                    "Flush old brake fluid and bleed air from the system.",
                    "Clean the disc rotor with isopropyl alcohol.",
                    "Apply high-temperature grease to caliper sliders.",
                  ],
                  tips: [
                    "Never let brake fluid touch the paintwork.",
                  ],
                ))),
              ),
              _GuideCard(
                title: "Oil Change SOP", 
                icon: Icons.water_drop_rounded, 
                color: Colors.amber,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GuideDetailScreen(
                  title: "Oil Change SOP",
                  icon: Icons.water_drop_rounded,
                  color: Colors.amber,
                  steps: [
                    "Warm up the engine for 5 minutes.",
                    "Place drain pan and remove the drain bolt.",
                    "Replace the oil filter with a new gasket.",
                    "Refill with recommended grade synthetic engine oil.",
                    "Run engine for a minute and re-check oil level.",
                  ],
                  tips: [
                    "Dispose of used oil responsibly at a recycling center.",
                  ],
                ))),
              ),
              _GuideCard(
                title: "Chain Maintenance", 
                icon: Icons.link_rounded, 
                color: Colors.green,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GuideDetailScreen(
                  title: "Chain Maintenance",
                  icon: Icons.link_rounded,
                  color: Colors.green,
                  steps: [
                    "Clean the chain using a specialized chain cleaner.",
                    "Scrub with a 3-sided brush to remove grit.",
                    "Dry the chain thoroughly with a lint-free cloth.",
                    "Apply chain lube while rotating the wheel manually.",
                    "Adjust chain slack to manufacturer specifications (usually 25-35mm).",
                  ],
                  tips: [
                    "Keep fingers away from the sprocket while the chain is moving.",
                  ],
                ))),
              ),
              _GuideCard(
                title: "Suspension Tuning", 
                icon: Icons.height_rounded, 
                color: Colors.purple,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GuideDetailScreen(
                  title: "Suspension Tuning",
                  icon: Icons.height_rounded,
                  color: Colors.purple,
                  steps: [
                    "Check fork seals for any signs of leakage.",
                    "Adjust preload based on rider weight.",
                    "Set compression and rebound damping (if adjustable).",
                    "Verify sag measurements for better stability.",
                  ],
                  tips: [
                    "Consistent settings bring more predictable handling.",
                  ],
                ))),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEVHub() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("EV Maintenance Hub", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        const Text("Specialized resources for Electric Vehicles", style: TextStyle(color: Colors.grey)),
        const SizedBox(height: 32),
        Expanded(
          child: GridView.count(
            crossAxisCount: MediaQuery.of(context).size.width > 1200 ? 3 : 2,
            crossAxisSpacing: 20,
            mainAxisSpacing: 20,
            children: [
              _GuideCard(
                title: "Battery Health Check", 
                icon: Icons.battery_charging_full_rounded, 
                color: Colors.green,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GuideDetailScreen(
                  title: "Battery Health Check",
                  icon: Icons.battery_charging_full_rounded,
                  color: Colors.green,
                  steps: [
                    "Check battery State of Charge (SOC) via dashboard.",
                    "Inspect battery casing for swelling or damage.",
                    "Clean terminal connectors to ensure good conductivity.",
                    "Check cell voltage balancing using diagnostic software.",
                    "Verify thermal management system is functioning.",
                  ],
                  tips: [
                    "Keep the battery charged between 20-80% for long life.",
                  ],
                ))),
              ),
              _GuideCard(
                title: "Motor Calibration", 
                icon: Icons.electric_bolt_rounded, 
                color: Colors.blue,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GuideDetailScreen(
                  title: "Motor Controller Calibration",
                  icon: Icons.electric_bolt_rounded,
                  color: Colors.blue,
                  steps: [
                    "Verify throttle response linearity.",
                    "Update motor controller firmware if available.",
                    "Check hall effect sensors and phase wires.",
                    "Monitor motor temperature during stress test.",
                  ],
                  tips: [
                    "Disconnect the main battery before working on motor phase wires.",
                  ],
                ))),
              ),
              _GuideCard(
                title: "Swap Station Manager", 
                icon: Icons.published_with_changes_rounded, 
                color: Colors.teal,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GuideDetailScreen(
                  title: "Swap Station Manager",
                  icon: Icons.published_with_changes_rounded,
                  color: Colors.teal,
                  steps: [
                    "Authenticate battery pack ID.",
                    "Initiate automated pack retrieval/insertion.",
                    "Verify charging status of swapped packs.",
                    "Sync swap transaction data to the cloud.",
                  ],
                  tips: [
                    "Ensure the station bay is clear of debris.",
                  ],
                ))),
              ),
              _GuideCard(
                title: "High Voltage Safety", 
                icon: Icons.warning_amber_rounded, 
                color: Colors.orange,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GuideDetailScreen(
                  title: "High Voltage Safety",
                  icon: Icons.warning_amber_rounded,
                  color: Colors.orange,
                  steps: [
                    "Identify high-voltage cables (usually orange).",
                    "Use insulated tools (rated for 1000V+).",
                    "Check the HV Isolation Resistance.",
                    "Always wear Class 0 electrical safety gloves.",
                  ],
                  tips: [
                    "Never work alone on HV systems.",
                  ],
                ))),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _GuideCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _GuideCard({required this.title, required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
                child: Icon(icon, color: color, size: 40),
              ),
              const SizedBox(height: 20),
              Text(title, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              const Text("View Guide", style: TextStyle(color: Colors.blue, fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final double width;

  const _StatCard({required this.title, required this.value, required this.icon, required this.color, required this.width});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.grey, fontSize: 14)),
                Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isSelected;
  final VoidCallback onTap;
  const _SidebarItem({required this.icon, required this.title, this.isSelected = false, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: isSelected ? Colors.white : Colors.white54),
      title: Text(title, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, color: isSelected ? Colors.white : Colors.white70)),
      tileColor: isSelected ? Colors.white.withValues(alpha: 0.1) : null,
      onTap: onTap,
    );
  }
}

class _RequestCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final VoidCallback onAccept;
  final VoidCallback? onAssign;
  final bool isHistory;
  
  const _RequestCard({
    required this.data, 
    required this.onAccept,
    this.onAssign,
    this.isHistory = false,
  });

  @override
  Widget build(BuildContext context) {
    final status = data['status'] ?? 'pending';
    final hasMechanic = data['mechanicId'] != null;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
      ),
      child: Row(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(10)),
            child: Icon(data['vehicleType'] == 'Two Wheeler' ? Icons.motorcycle : Icons.directions_car, size: 40, color: Colors.black87),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(data['serviceType'] ?? 'General Service', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text(data['description'] ?? '', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.grey)),
                const SizedBox(height: 5),
                Text("User: ${data['userId'] != null ? data['userId']['name'] : 'Guest'}", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                if (data['pincode'] != null)
                  Text("Area: ${data['pincode']}", style: const TextStyle(fontSize: 11, color: Colors.blueGrey)),
                if (isHistory && hasMechanic)
                  Text("Mechanic: ${data['mechanicId']['fullName']}", style: const TextStyle(fontSize: 12, color: Colors.blueAccent)),
                const SizedBox(height: 5),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: (data['serviceMode']?.toString().contains('Pickup') ?? false) ? Colors.blue.shade50 : Colors.green.shade50,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        data['serviceMode'] ?? 'On-Site',
                        style: TextStyle(
                          fontSize: 10, 
                          fontWeight: FontWeight.bold,
                          color: (data['serviceMode']?.toString().contains('Pickup') ?? false) ? Colors.blue : Colors.green,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (isHistory)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: status == 'completed' ? Colors.green.shade100 : Colors.orange.shade100,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          status.toUpperCase(),
                          style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: status == 'completed' ? Colors.green : Colors.orange),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          if (!isHistory)
            ElevatedButton(
              onPressed: onAccept,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: const Color(0xFFFFD700),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text("Accept Request"),
            )
          else if (status != 'completed')
            hasMechanic 
              ? _TrackingButton(requestId: data['_id'])
              : ElevatedButton(
                  onPressed: onAssign,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  child: const Text("Assign Mechanic", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                )
          else
            IconButton(
              onPressed: () {}, 
              icon: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ),
        ],
      ),
    );
  }
}

class _TrackingButton extends StatefulWidget {
  final String requestId;
  const _TrackingButton({required this.requestId});

  @override
  State<_TrackingButton> createState() => _TrackingButtonState();
}

class _TrackingButtonState extends State<_TrackingButton> {
  bool isTracking = false;
  Timer? _timer;
  double distance = 5.2; // km

  void _startTracking() {
    setState(() => isTracking = true);
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (distance <= 0.2) {
        timer.cancel();
        ApiService.updateLocation(
          requestId: widget.requestId, 
          lat: 23.0225, 
          lng: 72.5714, 
          status: 'arrived',
          eta: 'Arrived'
        );
        if (mounted) setState(() { distance = 0; isTracking = false; });
        return;
      }
      setState(() => distance -= 0.5);
      final eta = "${(distance * 2.5).toInt()} mins";
      ApiService.updateLocation(
        requestId: widget.requestId, 
        lat: 23.0225 + (distance * 0.001), 
        lng: 72.5714 + (distance * 0.001), 
        status: 'moving',
        eta: eta
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (isTracking)
          Text("${distance.toStringAsFixed(1)} km", style: const TextStyle(fontSize: 10, color: Colors.blue, fontWeight: FontWeight.bold)),
        IconButton(
          onPressed: isTracking ? null : _startTracking, 
          icon: Icon(
            isTracking ? Icons.navigation : Icons.play_circle_fill, 
            color: isTracking ? Colors.blue : Colors.green,
            size: 32,
          ),
        ),
      ],
    );
  }
}
