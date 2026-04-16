import 'package:flutter/material.dart';
import '../../core/services/api_service.dart';

class MechanicManagementScreen extends StatefulWidget {
  final VoidCallback? onActionComplete;
  const MechanicManagementScreen({super.key, this.onActionComplete});

  @override
  State<MechanicManagementScreen> createState() => _MechanicManagementScreenState();
}

class _MechanicManagementScreenState extends State<MechanicManagementScreen> {
  List<dynamic> mechanics = [];
  String searchQuery = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchMechanics();
  }

  Future<void> _fetchMechanics() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    final result = await ApiService.getMechanics();
    if (mounted) {
      setState(() {
        if (result['success'] == true) {
          mechanics = result['mechanics'] ?? [];
        } else {
          errorMessage = result['message'] ?? 'Failed to load mechanics';
        }
        isLoading = false;
      });
    }
  }

  String? errorMessage;

  Future<void> _approveMechanic(String id, String status) async {
    final result = await ApiService.approve('mechanic', id, status);
    if (result['success'] == true) {
      _fetchMechanics();
      widget.onActionComplete?.call();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Mechanic ${status == 'verified' ? 'APPROVED' : status.toUpperCase()}"), 
        backgroundColor: status == 'verified' ? Colors.green : Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ));
    }
  }

  Future<void> _deleteMechanic(String id) async {
    final result = await ApiService.deleteEntry('mechanic', id);
    if (result['success'] == true) {
      _fetchMechanics();
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
            ElevatedButton(onPressed: _fetchMechanics, child: const Text("Retry Connection")),
          ],
        ),
      );
    }

    final filteredMechanics = mechanics.where((mech) {
      final name = mech['fullName']?.toString().toLowerCase() ?? mech['name']?.toString().toLowerCase() ?? '';
      final garage = mech['garage'] != null ? (mech['garage']['garageName']?.toString().toLowerCase() ?? '') : '';
      return name.contains(searchQuery.toLowerCase()) || garage.contains(searchQuery.toLowerCase());
    }).toList();

    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search mechanics by name or garage...',
                    prefixIcon: const Icon(Icons.search_rounded),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                  ),
                  onChanged: (val) => setState(() => searchQuery = val),
                ),
              ),
              const SizedBox(width: 20),
              _FilterChip(label: "Pending", count: mechanics.where((m) => m['status'] == 'pending').length),
              const SizedBox(width: 10),
              IconButton(onPressed: _fetchMechanics, icon: const Icon(Icons.refresh_rounded), tooltip: "Reload Data"),
            ],
          ),
          const SizedBox(height: 30),
          if (isLoading)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else if (filteredMechanics.isEmpty)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.engineering_rounded, size: 80, color: Colors.black.withValues(alpha: 0.05)),
                    const SizedBox(height: 20),
                    const Text("No mechanics found.", style: TextStyle(fontSize: 18, color: Colors.blueGrey, fontWeight: FontWeight.bold)),
                    const Text("Search results will appear here.", style: TextStyle(color: Colors.black38)),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 1.4,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                ),
                itemCount: filteredMechanics.length,
                itemBuilder: (context, index) {
                  final mech = filteredMechanics[index];
                  final status = mech['status']?.toString().toLowerCase() ?? 'pending';
                  final garageName = mech['garage'] != null ? mech['garage']['garageName'] : "Independent";

                  return Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 15, offset: const Offset(0, 5))],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: Colors.blue.withValues(alpha: 0.1),
                              child: const Icon(Icons.engineering_rounded, color: Colors.blue),
                            ),
                            const Spacer(),
                            _StatusChip(status: status),
                          ],
                        ),
                        const SizedBox(height: 15),
                        Text(mech['fullName'] ?? mech['name'] ?? 'N/A', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        Text("Garage: $garageName", style: const TextStyle(color: Colors.black54, fontSize: 13)),
                        const Spacer(),
                        const Divider(),
                        Row(
                          children: [
                            if (status == 'pending') ...[
                              TextButton(
                                onPressed: () => _approveMechanic(mech['_id'], 'rejected'),
                                child: const Text("Reject", style: TextStyle(color: Colors.red, fontSize: 12)),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                onPressed: () => _approveMechanic(mech['_id'], 'verified'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                child: const Text("Approve", style: TextStyle(fontSize: 12)),
                              ),
                            ] else ...[
                               Text(mech['phone'] ?? '', style: const TextStyle(fontSize: 11, color: Colors.black38)),
                            ],
                            const Spacer(),
                            IconButton(
                              onPressed: () => _deleteMechanic(mech['_id']),
                              icon: const Icon(Icons.delete_outline_rounded, size: 20, color: Colors.grey),
                              tooltip: "Delete",
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;
  const _StatusChip({required this.status});
  @override
  Widget build(BuildContext context) {
    bool isOk = status == 'verified' || status == 'approved';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: isOk ? Colors.green.withValues(alpha: 0.1) : (status == 'rejected' ? Colors.red.withValues(alpha: 0.1) : Colors.orange.withValues(alpha: 0.1)), borderRadius: BorderRadius.circular(6)),
      child: Text(status == 'verified' ? 'APPROVED' : status.toUpperCase(), style: TextStyle(color: isOk ? Colors.green : (status == 'rejected' ? Colors.red : Colors.orange), fontSize: 9, fontWeight: FontWeight.bold)),
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
