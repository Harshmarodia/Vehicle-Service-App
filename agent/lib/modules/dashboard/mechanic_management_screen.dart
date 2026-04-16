import 'package:flutter/material.dart';
import '../../core/services/api_service.dart';

class MechanicManagementScreen extends StatefulWidget {
  final String agentId;
  const MechanicManagementScreen({super.key, required this.agentId});

  @override
  State<MechanicManagementScreen> createState() => _MechanicManagementScreenState();
}

class _MechanicManagementScreenState extends State<MechanicManagementScreen> {
  List<dynamic> mechanics = [];
  List<dynamic> filteredMechanics = [];
  Map<String, dynamic> mechanicHours = {};
  bool isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchMechanicsAndHours();
    _searchController.addListener(_filterMechanics);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchMechanicsAndHours() async {
    final mechResult = await ApiService.getMechanics(widget.agentId);
    final hoursResult = await ApiService.getMechanicHours(widget.agentId);
    
    if (mechResult['success'] == true) {
      if (mounted) {
        setState(() {
          mechanics = mechResult['mechanics'];
          filteredMechanics = mechanics;
          if (hoursResult['success'] == true) {
            mechanicHours = hoursResult['stats'];
          }
          isLoading = false;
        });
      }
    }
  }

  void _filterMechanics() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      filteredMechanics = mechanics.where((m) {
        final name = (m['fullName'] ?? '').toString().toLowerCase();
        final phone = (m['phone'] ?? '').toString().toLowerCase();
        return name.contains(query) || phone.contains(query);
      }).toList();
    });
  }

  void _showAddMechanicDialog() {
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final passCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Register New Mechanic"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: "Full Name")),
              TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: "Email")),
              TextField(controller: phoneCtrl, decoration: const InputDecoration(labelText: "Phone (10-digit Indian)")),
              TextField(controller: passCtrl, decoration: const InputDecoration(labelText: "Password"), obscureText: true),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              if (nameCtrl.text.isEmpty || emailCtrl.text.isEmpty || phoneCtrl.text.isEmpty || passCtrl.text.isEmpty) return;
              
              if (!RegExp(r"^[6-9]\d{9}$").hasMatch(phoneCtrl.text)) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Invalid Indian phone number")));
                return;
              }

              final res = await ApiService.registerMechanic(
                name: nameCtrl.text,
                email: emailCtrl.text,
                phone: phoneCtrl.text,
                password: passCtrl.text,
                agentId: widget.agentId,
              );
              
              if (res['success'] == true) {
                if (context.mounted) Navigator.pop(context);
                _fetchMechanicsAndHours();
              } else {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res['message'] ?? "Error")));
                }
              }
            },
            child: const Text("Register"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Manage Mechanics", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            ElevatedButton.icon(
              onPressed: _showAddMechanicDialog,
              icon: const Icon(Icons.add),
              label: const Text("Add Mechanic"),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: const Color(0xFFFFD700)),
            ),
          ],
        ),
        const SizedBox(height: 20),
        TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: "Search mechanics by name or phone...",
            prefixIcon: const Icon(Icons.search),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
          ),
        ),
        const SizedBox(height: 20),
        if (isLoading)
          const Center(child: CircularProgressIndicator())
        else if (filteredMechanics.isEmpty)
          const Expanded(child: Center(child: Text("No mechanics found.")))
        else
          Expanded(
            child: ListView.builder(
              itemCount: filteredMechanics.length,
              itemBuilder: (context, index) {
                final m = filteredMechanics[index];
                final hours = mechanicHours[m['_id']] ?? 0.0;
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  elevation: 1,
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    leading: CircleAvatar(
                      backgroundColor: Colors.grey.shade100,
                      child: const Icon(Icons.engineering, color: Colors.black87),
                    ),
                    title: Text(m['fullName'] ?? 'Unnamed Mechanic', style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("${m['phone']} | ${m['email']} | Pass: ${m['password'] ?? 'N/A'}"),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.timer_outlined, size: 14, color: Colors.blue),
                            const SizedBox(width: 4),
                            Text(
                              "Work Hours: ${hours.toStringAsFixed(1)} hrs",
                              style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                          ],
                        ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Chip(
                          label: Text(m['status'].toString().toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                          backgroundColor: m['status'] == 'verified' || m['status'] == 'approved' ? Colors.green.shade50 : Colors.orange.shade50,
                          side: BorderSide.none,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: (m['isBusy'] ?? false) ? Colors.red.shade50 : Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            (m['isBusy'] ?? false) ? "BUSY" : "AVAILABLE",
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: (m['isBusy'] ?? false) ? Colors.red.shade800 : Colors.blue.shade800,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.red),
                          onPressed: () async {
                            final confirm = await showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text("Delete Mechanic?"),
                                content: const Text("Are you sure? This will also delete their access account."),
                                actions: [
                                  TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
                                  TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Delete", style: TextStyle(color: Colors.red))),
                                ],
                              ),
                            );
                            if (confirm == true) {
                              await ApiService.deleteMechanic(m['_id']);
                              _fetchMechanicsAndHours();
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}
