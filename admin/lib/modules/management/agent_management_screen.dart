import 'package:flutter/material.dart';
import '../../core/services/api_service.dart';

class AgentManagementScreen extends StatefulWidget {
  final VoidCallback? onActionComplete;
  const AgentManagementScreen({super.key, this.onActionComplete});

  @override
  State<AgentManagementScreen> createState() => _AgentManagementScreenState();
}

class _AgentManagementScreenState extends State<AgentManagementScreen> {
  List<dynamic> agents = [];
  String searchQuery = '';
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchAgents();
  }

  Future<void> _fetchAgents() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    final result = await ApiService.getAgents();
    if (mounted) {
      setState(() {
        if (result['success'] == true) {
          agents = result['agents'] ?? [];
        } else {
          errorMessage = result['message'] ?? 'Failed to load agents';
        }
        isLoading = false;
      });
    }
  }

  Future<void> _approveAgent(String id, String status) async {
    final result = await ApiService.approve('agent', id, status);
    if (result['success'] == true) {
      _fetchAgents();
      widget.onActionComplete?.call();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Agent ${status.toUpperCase()}"), 
        backgroundColor: status == 'approved' ? Colors.green : Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ));
    }
  }

  Future<void> _deleteAgent(String id) async {
    final result = await ApiService.deleteEntry('agent', id);
    if (result['success'] == true) {
      _fetchAgents();
      widget.onActionComplete?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded, size: 60, color: Colors.red),
            const SizedBox(height: 20),
            Text(errorMessage!, style: const TextStyle(fontSize: 18, color: Colors.blueGrey)),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _fetchAgents, child: const Text("Retry Connection")),
          ],
        ),
      );
    }

    final filteredAgents = agents.where((agent) {
      final name = agent['name']?.toString().toLowerCase() ?? '';
      final garageName = agent['garageName']?.toString().toLowerCase() ?? '';
      final query = searchQuery.toLowerCase();
      return name.contains(query) || garageName.contains(query);
    }).toList();

    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search by owner, garage, or location...',
                    prefixIcon: const Icon(Icons.search_rounded),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                  ),
                  onChanged: (value) => setState(() => searchQuery = value),
                ),
              ),
              const SizedBox(width: 20),
              _FilterChip(label: "Pending", count: agents.where((a) => a['status'] == 'pending').length),
              const SizedBox(width: 10),
              IconButton(onPressed: _fetchAgents, icon: const Icon(Icons.refresh_rounded), tooltip: "Reload Data"),
            ],
          ),
          const SizedBox(height: 30),
          if (isLoading)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else if (filteredAgents.isEmpty)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.inbox_rounded, size: 80, color: Colors.black.withValues(alpha: 0.05)),
                    const SizedBox(height: 20),
                    const Text("No agents found.", style: TextStyle(fontSize: 18, color: Colors.blueGrey, fontWeight: FontWeight.bold)),
                    const Text("New registrations will appear here for approval.", style: TextStyle(color: Colors.black38)),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 2.2,
                  crossAxisSpacing: 25,
                  mainAxisSpacing: 25,
                ),
                itemCount: filteredAgents.length,
                itemBuilder: (context, index) {
                  final agent = filteredAgents[index];
                  return _AgentCard(
                    agent: agent,
                    onApprove: () => _approveAgent(agent['_id'], 'approved'),
                    onReject: () => _approveAgent(agent['_id'], 'rejected'),
                    onDelete: () => _deleteAgent(agent['_id']),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _AgentCard extends StatelessWidget {
  final dynamic agent;
  final VoidCallback onApprove, onReject, onDelete;
  const _AgentCard({required this.agent, required this.onApprove, required this.onReject, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final status = agent['status']?.toString().toLowerCase() ?? 'pending';
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(15)),
                child: const Icon(Icons.garage_rounded, color: Color(0xFF0F172A), size: 30),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(agent['garageName'] ?? 'No Name', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text("Owner: ${agent['name']}", style: const TextStyle(color: Colors.black54, fontSize: 13)),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        const Icon(Icons.location_on_rounded, size: 12, color: Colors.blueGrey),
                        const SizedBox(width: 4),
                        Text(agent['pincode'] ?? 'N/A', style: const TextStyle(color: Colors.blueGrey, fontSize: 11)),
                      ],
                    ),
                  ],
                ),
              ),
              _StatusBadge(status: status),
            ],
          ),
          const Spacer(),
          const Divider(),
          Row(
            children: [
              if (status == 'pending') ...[
                TextButton.icon(
                  onPressed: onReject,
                  icon: const Icon(Icons.close_rounded, size: 16, color: Colors.red),
                  label: const Text("Reject", style: TextStyle(color: Colors.red, fontSize: 12)),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: onApprove,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text("Approve", style: TextStyle(fontSize: 12)),
                ),
              ] else ...[
                Text("Registered on: ${agent['createdAt']?.toString().substring(0, 10) ?? 'N/A'}", style: const TextStyle(color: Colors.black26, fontSize: 11)),
              ],
              const Spacer(),
              IconButton(onPressed: onDelete, icon: const Icon(Icons.delete_sweep_rounded, size: 20, color: Colors.grey), tooltip: "Delete entry"),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status) {
      case 'approved': color = Colors.green; break;
      case 'rejected': color = Colors.redAccent; break;
      default: color = Colors.orangeAccent;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
      child: Text(status.toUpperCase(), style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final int count;
  const _FilterChip({required this.label, required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
      child: Row(
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(8)),
            child: Text(count.toString(), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
