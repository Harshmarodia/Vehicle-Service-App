import 'package:flutter/material.dart';
import 'dart:convert';
import '../../core/services/api_service.dart';
import 'product_detail_screen.dart';
import 'widgets/add_product_form.dart';

class ProductManagementScreen extends StatefulWidget {
  final String garageId;
  const ProductManagementScreen({super.key, required this.garageId});

  @override
  State<ProductManagementScreen> createState() => _ProductManagementScreenState();
}

class _ProductManagementScreenState extends State<ProductManagementScreen> {
  List<dynamic> products = [];
  List<dynamic> filteredProducts = [];
  bool isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  String selectedCategory = "All";

  final List<String> categories = ["All", "Engine Parts", "Brake System", "Suspension", "Lubricants & Oils", "Accessories", "Body Parts", "Tires"];

  @override
  void initState() {
    super.initState();
    _fetchProducts();
    _searchController.addListener(_filterProducts);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchProducts() async {
    final result = await ApiService.getGarageProducts(widget.garageId);
    if (result['success'] == true) {
      if (mounted) {
        setState(() {
          products = result['products'];
          filteredProducts = products;
          isLoading = false;
        });
      }
    }
  }

  void _filterProducts() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      filteredProducts = products.where((p) {
        final name = p['name'].toString().toLowerCase();
        final brand = (p['brand'] ?? "").toString().toLowerCase();
        final sku = (p['sku'] ?? "").toString().toLowerCase();
        final catMatches = selectedCategory == "All" || p['category'].toString().toLowerCase() == selectedCategory.toLowerCase();
        return catMatches && (name.contains(query) || brand.contains(query) || sku.contains(query));
      }).toList();
    });
  }

  void _showAddProductDialog() {
    showDialog(
      context: context,
      builder: (context) => AddProductForm(
        garageId: widget.garageId,
        onProductAdded: _fetchProducts,
      ),
    );
  }

  Widget _buildField(String label, TextEditingController ctrl, String hint, {double width = double.infinity, TextInputType type = TextInputType.text, int maxLines = 1, bool readOnly = false}) {
    return SizedBox(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black54)),
          const SizedBox(height: 8),
          TextField(
            controller: ctrl,
            keyboardType: type,
            maxLines: maxLines,
            readOnly: readOnly,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(fontSize: 14, color: Colors.grey),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Colors.blue)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownField(String label, String value, List<String> items, Function(String?) onChanged, {double width = double.infinity}) {
    return SizedBox(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black54)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(8)),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                value: value,
                items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 14)))).toList(),
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Row(
        children: [
          // Sidebar Filters
          Container(
            width: 250,
            color: Colors.white,
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.inventory_2, color: Colors.blue),
                    SizedBox(width: 12),
                    Text("Products", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 40),
                const Text("CATEGORIES", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.2)),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final cat = categories[index];
                      final isSelected = selectedCategory == cat;
                      return ListTile(
                        onTap: () {
                          setState(() {
                            selectedCategory = cat;
                            _filterProducts();
                          });
                        },
                        contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                        leading: Icon(Icons.circle, size: 8, color: isSelected ? Colors.blue : Colors.grey.shade300),
                        title: Text(cat, style: TextStyle(fontSize: 14, color: isSelected ? Colors.blue : Colors.black87, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          
          // Main Content
          Expanded(
            child: Column(
              children: [
                // Top Bar
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                  color: Colors.white,
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: "Search products (Name, SKU, Brand)...",
                            prefixIcon: const Icon(Icons.search, size: 20),
                            fillColor: const Color(0xFFF8F9FA),
                            filled: true,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      ElevatedButton.icon(
                        onPressed: _showAddProductDialog,
                        icon: const Icon(Icons.add_shopping_cart, size: 18),
                        label: const Text("List New Part", style: TextStyle(fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: const Color(0xFFFFD700),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ],
                  ),
                ),

                // Data Table
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 4))],
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : filteredProducts.isEmpty
                              ? const Center(child: Text("No products found in this category."))
                              : SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: SingleChildScrollView(
                                    child: DataTable(
                                      columnSpacing: 40,
                                      headingRowColor: WidgetStateProperty.all(const Color(0xFFF8F9FA)),
                                      columns: const [
                                        DataColumn(label: Text("PRODUCT NAME")),
                                        DataColumn(label: Text("SKU / BRAND")),
                                        DataColumn(label: Text("COST (₹)")),
                                        DataColumn(label: Text("SALE (₹)")),
                                        DataColumn(label: Text("STOCK")),
                                        DataColumn(label: Text("STATUS")),
                                        DataColumn(label: Text("ACTIONS")),
                                      ],
                                      rows: filteredProducts.map((p) {
                                        final stock = p['stock'] ?? 0;
                                        final reorder = p['reorderLevel'] ?? 10;
                                        final isLow = stock <= reorder;

                                        return DataRow(cells: [
                                          DataCell(
                                            Row(
                                              children: [
                                                ClipRRect(
                                                  borderRadius: BorderRadius.circular(8),
                                                  child: p['image'] != null && (p['image'].toString().startsWith('data:image') || p['image'].toString().startsWith('http'))
                                                      ? (p['image'].toString().startsWith('data:image')
                                                          ? Image.memory(
                                                              base64Decode(p['image'].toString().split(',')[1]),
                                                              width: 40,
                                                              height: 40,
                                                              fit: BoxFit.cover,
                                                              errorBuilder: (c, e, s) => const Icon(Icons.broken_image, size: 20, color: Colors.grey),
                                                            )
                                                          : Image.network(
                                                              p['image'],
                                                              width: 40,
                                                              height: 40,
                                                              fit: BoxFit.cover,
                                                              errorBuilder: (c, e, s) => const Icon(Icons.image_not_supported, size: 20, color: Colors.grey),
                                                            ))
                                                      : const Icon(Icons.image_outlined, size: 20, color: Colors.grey),
                                                ),
                                                const SizedBox(width: 12),
                                                Text(p['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                                              ],
                                            ),
                                          ),
                                          DataCell(Text("${p['sku'] ?? 'N/A'}\n${p['brand'] ?? 'N/A'}", style: const TextStyle(fontSize: 12, color: Colors.grey))),
                                          DataCell(Text("${p['purchasePrice'] ?? 0}")),
                                          DataCell(Text("${p['salePrice']}", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green))),
                                          DataCell(Text("$stock ${p['unit'] ?? 'pcs'}")),
                                          DataCell(
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: isLow ? Colors.red.shade50 : Colors.green.shade50,
                                                borderRadius: BorderRadius.circular(20),
                                              ),
                                              child: Text(
                                                isLow ? "Low Stock" : "Healthy",
                                                style: TextStyle(color: isLow ? Colors.red : Colors.green, fontSize: 11, fontWeight: FontWeight.bold),
                                              ),
                                            ),
                                          ),
                                          DataCell(
                                            Row(
                                              children: [
                                                IconButton(icon: const Icon(Icons.edit_outlined, color: Colors.blue, size: 20), onPressed: () {}),
                                                IconButton(
                                                  icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                                                  onPressed: () async {
                                                    final confirm = await showDialog(
                                                      context: context,
                                                      builder: (context) => AlertDialog(
                                                        title: const Text("Delete Product?"),
                                                        content: const Text("Are you sure? This action cannot be undone."),
                                                        actions: [
                                                          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
                                                          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Delete", style: TextStyle(color: Colors.red))),
                                                        ],
                                                      ),
                                                    );
                                                    if (confirm == true) {
                                                      await ApiService.deleteProduct(p['_id']);
                                                      _fetchProducts();
                                                    }
                                                  },
                                                ),
                                              ],
                                            ),
                                          ),
                                        ]);
                                      }).toList(),
                                    ),
                                  ),
                                ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
