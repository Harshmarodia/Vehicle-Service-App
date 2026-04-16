import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/services/api_service.dart';
import '../../core/theme/app_theme.dart';
import 'job_details_screen.dart';
import 'ai_chat_screen.dart';
import 'history_screen.dart';
import 'profile_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<dynamic> _jobs = [];
  bool _isLoading = true;
  String? _mechanicId;
  String? _mechanicName;
  bool _isClockedIn = false;
  bool _isClocking = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final id = await ApiService.getMechanicId();
    final name = await ApiService.getMechanicName();
    if (id != null) {
      if (!mounted) return;
      setState(() {
        _mechanicId = id;
        _mechanicName = name;
      });
      final result = await ApiService.getMyJobs(id);
      final attendanceRes = await ApiService.getAttendanceStatus(id);
      
      if (!mounted) return;
      setState(() {
        _jobs = result['success'] == true ? result['jobs'] : [];
        _isClockedIn = attendanceRes['success'] == true ? attendanceRes['isClockedIn'] : false;
        _isLoading = false;
      });
    } else {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleAttendance() async {
    if (_mechanicId == null) return;
    setState(() => _isClocking = true);
    
    final result = _isClockedIn 
        ? await ApiService.clockOut(_mechanicId!)
        : await ApiService.clockIn(_mechanicId!);
        
    if (result['success'] == true) {
      setState(() => _isClockedIn = !_isClockedIn);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_isClockedIn ? "Duty Started! Clocked in." : "Duty Ended. Clocked out.")),
      );
    }
    setState(() => _isClocking = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Sidebar
          Container(
            width: 280,
            color: AppTheme.darkHeaderColor,
            child: Column(
              children: [
                const SizedBox(height: 40),
                const Icon(Icons.engineering, size: 50, color: AppTheme.primaryColor),
                const SizedBox(height: 10),
                Text(
                  _mechanicName != null ? "Welcome back,\n$_mechanicName" : "MECHANIC HUB",
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18, letterSpacing: 1.1),
                ),
                const SizedBox(height: 40),
                _buildSidebarItem(Icons.dashboard, "Active Jobs", true),
                _buildSidebarItem(Icons.history, "Job History", false, onTap: () {
                   Navigator.push(context, MaterialPageRoute(builder: (_) => const HistoryScreen()));
                }),
                _buildSidebarItem(Icons.person, "Profile", false, onTap: () {
                   Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
                }),
                const Spacer(),
                
                // Attendance Toggle
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: Colors.white.withAlpha(10), borderRadius: BorderRadius.circular(16)),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(Icons.access_time, color: _isClockedIn ? Colors.green : Colors.grey, size: 20),
                          const SizedBox(width: 10),
                          Text(_isClockedIn ? "ON DUTY" : "OFF DUTY", style: TextStyle(color: _isClockedIn ? Colors.green : Colors.grey, fontWeight: FontWeight.bold, fontSize: 12)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isClocking ? null : _toggleAttendance,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _isClockedIn ? Colors.red.withAlpha(50) : AppTheme.primaryColor,
                            foregroundColor: _isClockedIn ? Colors.red : AppTheme.darkHeaderColor,
                            elevation: 0,
                          ),
                          child: Text(_isClockedIn ? "Clock Out" : "Clock In"),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 20),
                const Divider(color: Colors.white24, indent: 20, endIndent: 20),
                _buildSidebarItem(Icons.logout, "Logout", false, onTap: () async {
                  await ApiService.logout();
                  if (!context.mounted) return;
                  Navigator.pushReplacementNamed(context, '/login');
                }),
                const SizedBox(height: 20),
              ],
            ),
          ),
          
          // Main Content
          Expanded(
            child: Container(
              color: AppTheme.backgroundColor,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // App Bar
                  Container(
                    height: 80,
                    color: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: Row(
                      children: [
                        Text(
                          _mechanicName != null ? "Welcome back, $_mechanicName" : "Active Assignments",
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: _loadData,
                          icon: const Icon(Icons.refresh),
                          tooltip: "Refresh Jobs",
                        ),
                        const SizedBox(width: 20),
                        const CircleAvatar(
                          backgroundColor: AppTheme.primaryColor,
                          child: Icon(Icons.person, color: AppTheme.darkHeaderColor),
                        ),
                      ],
                    ),
                  ),
                  
                  // Content
                  Expanded(
                    child: _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : _jobs.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.assignment_turned_in_outlined, size: 80, color: Colors.grey.shade300),
                                    const SizedBox(height: 16),
                                    Text("No active assignments found", style: TextStyle(color: Colors.grey.shade500, fontSize: 18)),
                                  ],
                                ),
                              )
                            : GridView.builder(
                                padding: const EdgeInsets.all(30),
                                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                                  maxCrossAxisExtent: 400,
                                  mainAxisExtent: 250,
                                  crossAxisSpacing: 30,
                                  mainAxisSpacing: 30,
                                ),
                                itemCount: _jobs.length,
                                itemBuilder: (context, index) {
                                  final job = _jobs[index];
                                  return _buildJobCard(job, index);
                                },
                              ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AIChatScreen())),
        backgroundColor: AppTheme.darkHeaderColor,
        foregroundColor: AppTheme.primaryColor,
        icon: const Icon(Icons.psychology),
        label: const Text("AI Assistant"),
      ).animate().scale(delay: 1.seconds, duration: 400.ms, curve: Curves.easeOutBack),
    );
  }

  Widget _buildSidebarItem(IconData icon, String title, bool isSelected, {VoidCallback? onTap}) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: isSelected ? AppTheme.primaryColor : Colors.white70),
      title: Text(
        title,
        style: TextStyle(color: isSelected ? AppTheme.primaryColor : Colors.white70, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
      ),
      tileColor: isSelected ? Colors.white.withAlpha(15) : null,
    );
  }

  Widget _buildJobCard(dynamic job, int index) {
    final customer = job['userId'];
    final status = job['status'];
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStatusColor(status).withAlpha(30),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  status.toString().toUpperCase(),
                  style: TextStyle(color: _getStatusColor(status), fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
              const Spacer(),
              Text("#${job['orderId']}", style: TextStyle(color: Colors.grey.shade400, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            customer != null ? customer['name'] : 'Unknown Customer',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 4),
          Text(
            job['serviceType'] ?? 'General Service',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
          ),
          const Spacer(),
          const Divider(),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => JobDetailsScreen(jobData: job)),
                );
                if (result == true) _loadData();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: AppTheme.darkHeaderColor,
                elevation: 0,
              ),
              child: const Text("View Details"),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: (100 * index).ms).slideY(begin: 0.1);
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending': return Colors.orange;
      case 'accepted': return Colors.blue;
      case 'completed': return Colors.green;
      case 'cancelled': return Colors.red;
      default: return Colors.grey;
    }
  }
}
