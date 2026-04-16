import 'package:flutter/material.dart';
import '../../core/services/api_service.dart';
import '../../core/theme/app_theme.dart';
import 'add_mechanic_screen.dart';

class MechanicListScreen extends StatefulWidget {
  const MechanicListScreen({super.key});

  @override
  State<MechanicListScreen> createState() => _MechanicListScreenState();
}

class _MechanicListScreenState extends State<MechanicListScreen> {
  List<dynamic> mechanics = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchMechanics();
  }

  Future<void> _fetchMechanics() async {
    final agentId = await ApiService.getAgentId();
    if (agentId == null) return;
    
    final res = await ApiService.getMechanics(agentId);
    if (mounted) {
      setState(() {
        mechanics = res['mechanics'] ?? [];
        isLoading = false;
      });
    }
  }

  Future<void> _deleteMechanic(String id) async {
    final res = await ApiService.deleteMechanic(id);
    if (res['success']) {
      _fetchMechanics();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Mechanic removed")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Mechanics"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => Navigator.push(
              context, 
              MaterialPageRoute(builder: (context) => const AddMechanicScreen())
            ).then((_) => _fetchMechanics()),
          )
        ],
      ),
      body: isLoading 
          ? const Center(child: CircularProgressIndicator())
          : mechanics.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: mechanics.length,
                  itemBuilder: (context, index) {
                    final m = mechanics[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.blue.shade100,
                          child: Text(m['fullName'][0].toUpperCase()),
                        ),
                        title: Text(m['fullName'], style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(m['phone']),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: m['isBusy'] ? Colors.orange.shade100 : Colors.green.shade100,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                m['isBusy'] ? "BUSY" : "AVAILABLE",
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: m['isBusy'] ? Colors.orange.shade800 : Colors.green.shade800,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.red),
                              onPressed: () => _deleteMechanic(m['_id']),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.engineering_outlined, size: 60, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          const Text("No mechanics added yet", style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.push(
              context, 
              MaterialPageRoute(builder: (context) => const AddMechanicScreen())
            ).then((_) => _fetchMechanics()),
            child: const Text("Add Your First Mechanic"),
          ),
        ],
      ),
    );
  }
}
