import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../booking/add_address_screen.dart';

class AddressesScreen extends StatefulWidget {
  const AddressesScreen({super.key});

  @override
  State<AddressesScreen> createState() => _AddressesScreenState();
}

class _AddressesScreenState extends State<AddressesScreen> {
  List<Map<String, dynamic>> _addresses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAddresses();
  }

  Future<void> _loadAddresses() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('saved_addresses');
    if (raw != null) {
      final List decoded = jsonDecode(raw);
      setState(() {
        _addresses = decoded.map((e) => Map<String, dynamic>.from(e)).toList();
      });
    }
    setState(() => _isLoading = false);
  }

  Future<void> _saveAddresses() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('saved_addresses', jsonEncode(_addresses));
  }

  Future<void> _addNewAddress() async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(builder: (_) => const AddAddressScreen()),
    );
    if (result != null) {
      setState(() => _addresses.add(result));
      await _saveAddresses();
    }
  }

  Future<void> _editAddress(int index) async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (_) => AddAddressScreen(existingAddress: _addresses[index]),
      ),
    );
    if (result != null) {
      setState(() => _addresses[index] = result);
      await _saveAddresses();
    }
  }

  Future<void> _deleteAddress(int index) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text("Delete Address", style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        content: Text("Are you sure you want to delete this address?", style: GoogleFonts.outfit()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text("Cancel", style: GoogleFonts.outfit(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text("Delete", style: GoogleFonts.outfit(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      setState(() => _addresses.removeAt(index));
      await _saveAddresses();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Address deleted", style: GoogleFonts.outfit()),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text("Saved Addresses", style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _addresses.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: _addresses.length,
                  itemBuilder: (context, index) =>
                      _buildAddressTile(index, _addresses[index]),
                ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        child: ElevatedButton.icon(
          onPressed: _addNewAddress,
          icon: const Icon(Icons.add_location_alt_outlined),
          label: Text("Add New Address", style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16)),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            foregroundColor: Colors.yellow,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.location_off_outlined, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 20),
          Text("No Saved Addresses", style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87)),
          const SizedBox(height: 8),
          Text("Add your home, office or any address.", style: GoogleFonts.outfit(color: Colors.grey, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildAddressTile(int index, Map<String, dynamic> address) {
    final label = address['name'] ?? "Address ${index + 1}";
    final addressText = address['address'] ?? "";
    final isDefault = index == 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDefault ? Colors.black : Colors.grey.shade200,
          width: isDefault ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        leading: CircleAvatar(
          backgroundColor: isDefault ? Colors.black : Colors.grey.shade100,
          child: Icon(
            Icons.location_on,
            color: isDefault ? Colors.yellow : Colors.grey.shade600,
            size: 22,
          ),
        ),
        title: Row(
          children: [
            Flexible(
              child: Text(label, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 15), overflow: TextOverflow.ellipsis),
            ),
            if (isDefault) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(6)),
                child: Text("DEFAULT", style: GoogleFonts.outfit(fontSize: 9, color: Colors.yellow, fontWeight: FontWeight.bold, letterSpacing: 1)),
              ),
            ],
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(addressText, style: GoogleFonts.outfit(color: Colors.black54, fontSize: 13), maxLines: 2, overflow: TextOverflow.ellipsis),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit_outlined, size: 20),
              onPressed: () => _editAddress(index),
              color: Colors.blueAccent,
              tooltip: "Edit",
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 20),
              onPressed: () => _deleteAddress(index),
              color: Colors.redAccent,
              tooltip: "Delete",
            ),
          ],
        ),
      ),
    );
  }
}
