import 'package:flutter/material.dart';
import '../../core/services/api_service.dart';

class VehicleManagementScreen extends StatefulWidget {
  const VehicleManagementScreen({super.key});

  @override
  State<VehicleManagementScreen> createState() => _VehicleManagementScreenState();
}

class _VehicleManagementScreenState extends State<VehicleManagementScreen> {
  List<dynamic> vehicles = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchVehicles();
  }

  Future<void> _fetchVehicles() async {
    final res = await ApiService.getVehicles();
    if (mounted) {
      setState(() {
        vehicles = res["vehicles"] ?? [];
        isLoading = false;
      });
    }
  }

  void _showAddVehicleSheet() {
    final brandController = TextEditingController();
    final modelController = TextEditingController();
    final numberController = TextEditingController();
    String type = "Two Wheeler";

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 24, right: 24, top: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Add New Vehicle", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: type,
              items: const [
                DropdownMenuItem(value: "Two Wheeler", child: Text("Two Wheeler")),
                DropdownMenuItem(value: "Four Wheeler", child: Text("Four Wheeler")),
              ],
              onChanged: (val) => type = val!,
              decoration: InputDecoration(labelText: "Vehicle Type", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
            ),
            const SizedBox(height: 15),
            TextField(controller: brandController, decoration: InputDecoration(labelText: "Brand", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
            const SizedBox(height: 15),
            TextField(controller: modelController, decoration: InputDecoration(labelText: "Model", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
            const SizedBox(height: 15),
            TextField(controller: numberController, decoration: InputDecoration(labelText: "Vehicle Number (e.g. GJ01 XX 0000)", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
            const SizedBox(height: 25),
            ElevatedButton(
              onPressed: () async {
                await ApiService.addVehicle(type: type, brand: brandController.text, model: modelController.text, number: numberController.text);
                Navigator.pop(context);
                _fetchVehicles();
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.yellow, minimumSize: const Size(double.infinity, 55)),
              child: const Text("Save Vehicle"),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("My Vehicles", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: isLoading 
        ? const Center(child: CircularProgressIndicator())
        : ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: vehicles.length,
            itemBuilder: (context, index) {
              final v = vehicles[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 15),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    Icon(v['type'] == 'Four Wheeler' ? Icons.directions_car : Icons.two_wheeler, size: 30, color: Colors.black54),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("${v['brand']} ${v['model']}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          Text(v['number'], style: const TextStyle(color: Colors.grey, fontSize: 14)),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () async {
                        await ApiService.deleteVehicle(v['_id']);
                        _fetchVehicles();
                      },
                      icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                    ),
                  ],
                ),
              );
            },
          ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddVehicleSheet,
        backgroundColor: Colors.black,
        icon: const Icon(Icons.add, color: Colors.yellow),
        label: const Text("Add Vehicle", style: TextStyle(color: Colors.yellow, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
