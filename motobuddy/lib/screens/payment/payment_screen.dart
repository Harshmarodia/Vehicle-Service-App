import 'package:flutter/material.dart';
import '../web/landing/landing_page.dart';
import '../../core/services/api_service.dart';
import '../../core/services/cart_service.dart';

class PaymentScreen extends StatefulWidget {
  final double? amount;
  final List<Map<String, dynamic>>? items;

  const PaymentScreen({super.key, this.amount, this.items});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String selectedMethod = "UPI";

  bool isProcessing = false;

  Future<void> _processPayment() async {
    setState(() => isProcessing = true);
    
    try {
      final userData = await ApiService.getUserProfile();
      final userId = userData['user']['_id'];

      final transactionData = {
        "userId": userId,
        "transactionType": widget.items != null ? "shop" : "service",
        "amount": widget.amount,
        "paymentMethod": selectedMethod,
        "items": widget.items?.map((item) => {
          "productId": item['_id'],
          "name": item['name'],
          "price": item['salePrice'] ?? item['price'],
          "quantity": item['quantity'] ?? 1
        }).toList(),
      };

      final result = await ApiService.createTransaction(transactionData);
      
      if (result['success']) {
        if (widget.items != null) {
          await CartService.clearCart();
        }
        _showReceipt(result['transaction']);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Payment failed: ${result['message']}")));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error processing payment: $e")));
    } finally {
      if (mounted) setState(() => isProcessing = false);
    }
  }

  void _showReceipt(Map<String, dynamic> transaction) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Container(
          padding: const EdgeInsets.all(40),
          width: 500,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Icon(Icons.motorcycle, color: Colors.yellow, size: 40),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text("TAX INVOICE", style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.black)),
                        Text("Invoice #: ${transaction['invoiceNumber']}", style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  ],
                ),
                const Divider(height: 40),
                
                // Transaction Details
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("BILLED ON", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
                        Text(DateTime.now().toString().split(' ')[0], style: const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text("PAYMENT METHOD", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
                        Text(selectedMethod, style: const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 30),

                // Items Table Header
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                  color: Colors.grey.shade100,
                  child: const Row(
                    children: [
                      Expanded(child: Text("DESCRIPTION", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey))),
                      SizedBox(width: 40, child: Text("QTY", textAlign: TextAlign.center, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey))),
                      SizedBox(width: 80, child: Text("TOTAL", textAlign: TextAlign.right, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey))),
                    ],
                  ),
                ),
                const SizedBox(height: 10),

                // Items List
                if (transaction['transactionType'] == 'shop' && transaction['items'] != null)
                  ...transaction['items'].map((item) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 15),
                    child: Row(
                      children: [
                        Expanded(child: Text(item['name'], style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500))),
                        SizedBox(width: 40, child: Text("${item['quantity']}", textAlign: TextAlign.center)),
                        SizedBox(width: 80, child: Text("₹${item['price'] * item['quantity']}", textAlign: TextAlign.right, style: const TextStyle(fontWeight: FontWeight.bold))),
                      ],
                    ),
                  ))
                else if (transaction['transactionType'] == 'service')
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20, horizontal: 15),
                    child: Row(
                      children: [
                        Expanded(child: Text("Professional Mobile Service & Setup", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500))),
                        SizedBox(width: 40, child: Text("1", textAlign: TextAlign.center)),
                        SizedBox(width: 80, child: Text("Included", textAlign: TextAlign.right)),
                      ],
                    ),
                  ),

                const Divider(height: 40),

                // Totals
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text("AMOUNT PAID", style: TextStyle(color: Colors.grey, fontSize: 13)),
                        Text("₹${transaction['amount']}", style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Colors.black)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                
                // Footer
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(12)),
                  child: const Row(
                    children: [
                      Icon(Icons.verified_user, color: Colors.green, size: 20),
                      SizedBox(width: 12),
                      Expanded(child: Text("Successfully processed by MotoBuddy Secure Gateway. This is a computer generated invoice.", style: TextStyle(fontSize: 11, color: Colors.green, height: 1.4))),
                    ],
                  ),
                ),

                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context); // Close receipt
                      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => LandingPage()), (r) => false);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    child: const Text("CLOSE & CONTINUE", style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(widget.amount != null ? "Checkout" : "Payment Methods"),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.amount != null) ...[
              const Text("Order Summary", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              if (widget.items != null)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(15)),
                  child: Column(
                    children: widget.items!.map((item) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("${item['quantity'] ?? 1}x ${item['name']}", style: const TextStyle(color: Colors.black87)),
                          Text("₹${((item['salePrice'] ?? item['price'] ?? 0) * (item['quantity'] ?? 1))}", style: const TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    )).toList(),
                  ),
                ),
              const SizedBox(height: 30),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(15)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Total Payable", style: TextStyle(color: Colors.white70, fontSize: 16)),
                    Text("₹ ${widget.amount!.toStringAsFixed(2)}", style: const TextStyle(color: Colors.yellow, fontSize: 24, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],

            const Text("Select Payment Method", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            _paymentMethodCard("UPI", Icons.account_balance_wallet_outlined),
            _paymentMethodCard("Credit / Debit Card", Icons.credit_card_outlined),
            _paymentMethodCard("Cash on Service", Icons.payments_outlined),

            const SizedBox(height: 50),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.yellow,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                onPressed: isProcessing ? null : _processPayment,
                child: isProcessing 
                  ? const CircularProgressIndicator(color: Colors.yellow)
                  : Text(
                      widget.amount != null ? "Confirm & Pay Now" : "Confirm Selection",
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _paymentMethodCard(String method, IconData icon) {
    bool isSelected = selectedMethod == method;
    return GestureDetector(
      onTap: () => setState(() => selectedMethod = method),
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        decoration: BoxDecoration(
          color: isSelected ? Colors.yellow.shade50 : Colors.white,
          border: Border.all(color: isSelected ? Colors.yellow.shade700 : Colors.grey.shade200, width: 2),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? Colors.black : Colors.grey),
            const SizedBox(width: 15),
            Text(method, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, fontSize: 16)),
            const Spacer(),
            if (isSelected) const Icon(Icons.check_circle, color: Colors.black),
          ],
        ),
      ),
    );
  }
}