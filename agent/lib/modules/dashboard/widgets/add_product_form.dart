import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/services/api_service.dart';

class AddProductForm extends StatefulWidget {
  final String garageId;
  final VoidCallback onProductAdded;

  const AddProductForm({super.key, required this.garageId, required this.onProductAdded});

  @override
  State<AddProductForm> createState() => _AddProductFormState();
}

class _AddProductFormState extends State<AddProductForm> {
  final nameCtrl = TextEditingController();
  final skuCtrl = TextEditingController();
  final brandCtrl = TextEditingController();
  final buyPriceCtrl = TextEditingController();
  final sellPriceCtrl = TextEditingController();
  final mrpCtrl = TextEditingController();
  final descCtrl = TextEditingController();
  
  String category = "Engine Parts";
  String unit = "pcs";
  int stock = 0;
  int reorder = 10;
  bool isSubmitting = false;

  final List<String> categories = ["Engine Parts", "Brake System", "Suspension", "Lubricants & Oils", "Accessories", "Body Parts", "Tires"];
  
  String? base64Image;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 50);
    
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        base64Image = "data:image/jpeg;base64,${base64Encode(bytes)}";
      });
    }
  }

  Future<void> _submitForm() async {
    if (nameCtrl.text.isEmpty || sellPriceCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Name and Selling Price are required.")));
      return;
    }

    setState(() => isSubmitting = true);

    final res = await ApiService.addProduct(
      name: nameCtrl.text,
      description: descCtrl.text,
      salePrice: double.tryParse(sellPriceCtrl.text) ?? 0,
      mrp: double.tryParse(mrpCtrl.text),
      purchasePrice: double.tryParse(buyPriceCtrl.text) ?? 0,
      category: category,
      sku: skuCtrl.text,
      brand: brandCtrl.text,
      unit: unit,
      reorderLevel: reorder,
      agentId: widget.garageId,
      stock: stock,
      // Adding image to the API if the backend supports it. If not, it just gets ignored or added as text if backend schema accepts it.
      // Assuming backend Product schema has an `image` field.
      image: base64Image
    );

    setState(() => isSubmitting = false);

    if (res['success'] == true) {
      Navigator.pop(context);
      widget.onProductAdded();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res['message'] ?? "Failed to add product.")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: 900,
        height: 700,
        padding: const EdgeInsets.all(0),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
              decoration: BoxDecoration(color: Colors.grey.shade50, border: Border(bottom: BorderSide(color: Colors.grey.shade200))),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Add New Product", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87)),
                  IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
                ],
              ),
            ),
            
            // Body
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left side (Image Upload)
                  Container(
                    width: 300,
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(border: Border(right: BorderSide(color: Colors.grey.shade200))),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text("Product Image", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        const Text("Upload a high-quality image", style: TextStyle(fontSize: 12, color: Colors.grey)),
                        const SizedBox(height: 24),
                        GestureDetector(
                          onTap: _pickImage,
                          child: Container(
                            width: 200,
                            height: 200,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.blue.shade200, style: BorderStyle.solid, width: 2),
                            ),
                            child: base64Image != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(14),
                                    child: Image.memory(base64Decode(base64Image!.split(',')[1]), fit: BoxFit.cover),
                                  )
                                : Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.cloud_upload_outlined, size: 48, color: Colors.blue.shade300),
                                      const SizedBox(height: 12),
                                      const Text("Click to Upload", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Right side (Form)
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Basic Information", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 20),
                          Wrap(
                            spacing: 20,
                            runSpacing: 20,
                            children: [
                              _buildField("Product name*", nameCtrl, "Part Name", width: 240),
                              _buildField("SKU", skuCtrl, "Unique SKU ID", width: 240),
                              _buildDropdownField("Category*", category, categories, (v) => setState(() => category = v!), width: 240),
                              _buildField("Brand", brandCtrl, "Manufacturer Brand", width: 240),
                              _buildField("Units*", TextEditingController(text: unit), "Select Unit", width: 240, readOnly: true),
                            ],
                          ),
                          
                          const SizedBox(height: 32),
                          const Divider(),
                          const SizedBox(height: 32),

                          const Text("Pricing & Inventory", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 20),
                          Wrap(
                            spacing: 20,
                            runSpacing: 20,
                            children: [
                              _buildField("Purchase Price*", buyPriceCtrl, "Buying Cost (₹)", width: 170, type: TextInputType.number),
                              _buildField("Selling Price*", sellPriceCtrl, "Price to Customer (₹)", width: 170, type: TextInputType.number),
                              _buildField("MRP*", mrpCtrl, "Max Retail Price (₹)", width: 170, type: TextInputType.number),
                              _buildField("Initial Stock", TextEditingController(text: stock.toString()), "", width: 170, type: TextInputType.number, onChanged: (v) => stock = int.tryParse(v) ?? 0),
                              _buildField("Low Stock Alert", TextEditingController(text: reorder.toString()), "", width: 170, type: TextInputType.number, onChanged: (v) => reorder = int.tryParse(v) ?? 10),
                            ],
                          ),

                          const SizedBox(height: 32),
                          _buildField("Product Description", descCtrl, "Short Description", width: double.infinity, maxLines: 3),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Footer
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
              decoration: BoxDecoration(color: Colors.grey.shade50, border: Border(top: BorderSide(color: Colors.grey.shade200))),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20), foregroundColor: Colors.grey.shade700),
                    child: const Text("Cancel", style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: isSubmitting ? null : _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2ECC71),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: isSubmitting 
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text("Save Product", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController ctrl, String hint, {double width = double.infinity, TextInputType type = TextInputType.text, int maxLines = 1, bool readOnly = false, Function(String)? onChanged}) {
    return SizedBox(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black87)),
          const SizedBox(height: 8),
          TextField(
            controller: ctrl,
            keyboardType: type,
            maxLines: maxLines,
            readOnly: readOnly,
            onChanged: onChanged,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(fontSize: 14, color: Colors.grey),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.blueAccent)),
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
          Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black87)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            height: 50,
            decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(10)),
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
}
