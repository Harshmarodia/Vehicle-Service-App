import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/services/cart_service.dart';
import '../web/widgets/custom_navbar.dart';
import '../web/components/footer.dart';
import '../payment/payment_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  List<Map<String, dynamic>> cartItems = [];
  bool isLoading = true;
  String purchaseStyle = "Dine-in (On-Site Setup)"; // Default: Spot
  final TextEditingController _addressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCart();
  }

  Future<void> _loadCart() async {
    final items = await CartService.getCartItems();
    setState(() {
      cartItems = items;
      isLoading = false;
    });
  }

  double get totalPrice {
    return cartItems.fold(0.0, (sum, item) => sum + ((item['salePrice'] ?? 0.0) * (item['quantity'] ?? 1)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            const CustomNavbar(isScrolled: true),
            const SizedBox(height: 100),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   const Text("Your Cart", style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold)),
                   const SizedBox(height: 10),
                   const Text("Manage your selected spare parts and accessories.", style: TextStyle(fontSize: 18, color: Colors.black54)),
                   const SizedBox(height: 40),
                   
                   if (isLoading)
                     const Center(child: CircularProgressIndicator())
                   else if (cartItems.isEmpty)
                     Center(
                       child: Column(
                         children: [
                           const Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey),
                           const SizedBox(height: 20),
                           const Text("Your cart is empty.", style: TextStyle(fontSize: 20, color: Colors.grey)),
                           const SizedBox(height: 20),
                           ElevatedButton(
                             onPressed: () => Navigator.pop(context),
                             child: const Text("Go Shop"),
                           )
                         ],
                       ),
                     )
                   else
                     Row(
                       crossAxisAlignment: CrossAxisAlignment.start,
                       children: [
                         Expanded(
                           flex: 2,
                           child: ListView.builder(
                             shrinkWrap: true,
                             physics: const NeverScrollableScrollPhysics(),
                             itemCount: cartItems.length,
                             itemBuilder: (context, index) {
                               final item = cartItems[index];
                               return _CartItemTile(
                                 item: item, 
                                 onRemove: () async {
                                   await CartService.removeFromCart(item['_id']);
                                   _loadCart();
                                 },
                               );
                             },
                           ),
                         ),
                         const SizedBox(width: 40),
                         Expanded(
                           child: _OrderSummary(
                             total: totalPrice,
                             purchaseStyle: purchaseStyle,
                             onStyleChange: (val) => setState(() => purchaseStyle = val),
                             addressController: _addressController,
                             cartItems: cartItems,
                           ),
                         ),
                       ],
                     ),
                ],
              ),
            ),
            const Footer(),
          ],
        ),
      ),
    );
  }
}

class _CartItemTile extends StatelessWidget {
  final Map<String, dynamic> item;
  final VoidCallback onRemove;

  const _CartItemTile({required this.item, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              item['image'],
              width: 90,
              height: 90,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['name'], 
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(fontSize: 18),
                ),
                const SizedBox(height: 4),
                Text(
                  item['category'], 
                  style: TextStyle(color: Colors.blue.shade700, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 0.5),
                ),
                const SizedBox(height: 8),
                Text(
                  "₹${item['salePrice'] ?? item['price'] ?? 0} x ${item['quantity'] ?? 1}", 
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(10),
            ),
            child: IconButton(
              onPressed: onRemove,
              icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderSummary extends StatelessWidget {
  final double total;
  final String purchaseStyle;
  final ValueChanged<String> onStyleChange;
  final TextEditingController addressController;
  final List<Map<String, dynamic>> cartItems;

  const _OrderSummary({
    required this.total, 
    required this.purchaseStyle, 
    required this.onStyleChange,
    required this.addressController,
    required this.cartItems,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.9),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 30, offset: const Offset(0, 15))
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Padding(
            padding: const EdgeInsets.all(30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Order Summary", 
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(color: Colors.white, fontSize: 24),
                ),
                const SizedBox(height: 30),
                
                // PURCHASE STYLE SELECTION
                const Text("Choose Purchase Style", style: TextStyle(color: Colors.white54, fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 1)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _styleChip("Spot Setup", purchaseStyle == "Dine-in (On-Site Setup)", () => onStyleChange("Dine-in (On-Site Setup)")),
                    const SizedBox(width: 10),
                    _styleChip("Delivery", purchaseStyle == "Home Delivery", () => onStyleChange("Home Delivery")),
                  ],
                ),
                const SizedBox(height: 30),
      
                if (purchaseStyle == "Home Delivery") ...[
                  const Text("Delivery Address", style: TextStyle(color: Colors.white54, fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 1)),
                  const SizedBox(height: 12),
                  TextField(
                    controller: addressController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: "Enter full delivery address",
                      hintStyle: const TextStyle(color: Colors.white24),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.05),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: Colors.white.withOpacity(0.1))),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: Colors.white.withOpacity(0.1))),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 30),
                ] else ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05), 
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.garage_rounded, color: Color(0xFFFFCC00), size: 20),
                        SizedBox(width: 12),
                        Expanded(child: Text("Ready for professional setup at our service hub. Track order for details.", style: TextStyle(color: Colors.white70, fontSize: 12, height: 1.4))),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
      
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Subtotal", style: TextStyle(color: Colors.white60, fontSize: 16)),
                    Text("₹$total", style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(purchaseStyle == "Home Delivery" ? "Delivery Fee" : "Service Charge", style: const TextStyle(color: Colors.white60, fontSize: 16)),
                    const Text("₹99", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  ],
                ),
                const Divider(color: Colors.white10, height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Total", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900)),
                    Text("₹${total + 99}", style: const TextStyle(color: Color(0xFFFFCC00), fontSize: 24, fontWeight: FontWeight.w900)),
                  ],
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFCC00),
                      foregroundColor: Colors.black,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    onPressed: () {
                      if (purchaseStyle == "Home Delivery" && addressController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please enter delivery address")));
                        return;
                      }
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PaymentScreen(
                            amount: total + 99.0,
                            items: cartItems,
                          ),
                        ),
                      );
                    },
                    child: const Text("Proceed to Checkout", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _styleChip(String label, bool isSelected, VoidCallback onTap) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFFFCC00) : Colors.transparent,
            border: Border.all(color: isSelected ? const Color(0xFFFFCC00) : Colors.grey),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              label, 
              style: TextStyle(
                color: isSelected ? Colors.black : Colors.white, 
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal
              ),
            ),
          ),
        ),
      ),
    );
  }
}
