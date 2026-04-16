import 'package:flutter/material.dart';
import 'dart:convert';
import '../../core/services/api_service.dart';
import '../web/widgets/custom_navbar.dart';
import '../web/widgets/floating_chatbot.dart';
import '../web/components/footer.dart';
import '../../core/services/cart_service.dart';
import 'cart_screen.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}
class _ShopScreenState extends State<ShopScreen> {
  final GlobalKey<CustomNavbarState> _navbarKey = GlobalKey<CustomNavbarState>();
  List<dynamic> products = [];
  List<dynamic> filteredProducts = [];
  String selectedCategory = "All";
  bool isLoading = true;
  bool isLoadMore = false;
  int currentPage = 1;
  bool hasMore = true;
  final int limit = 12;

  final List<String> categories = [
    "All",
    "Engine Parts",
    "Brake System",
    "Suspension",
    "Lubricants & Oils",
    "Accessories"
  ];

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Future<void> _fetchProducts({bool loadMore = false}) async {
    if (!loadMore) {
      if (!mounted) return;
      setState(() {
        isLoading = true;
        currentPage = 1;
        products = [];
      });
    } else {
      if (!mounted) return;
      setState(() => isLoadMore = true);
    }

    final result = await ApiService.getAllProducts(page: currentPage, limit: limit);
    
    if (result['success'] == true) {
      final List newProducts = result['products'];
      
      // Pre-decode base64 images off the main UI rendering layer to avoid lag
      for (var p in newProducts) {
        if (p['image'] != null && p['image'].toString().startsWith('data:image')) {
          try {
            p['imageBytes'] = base64Decode(p['image'].toString().split(',')[1]);
          } catch (e) {
            // Ignore formatting errors
          }
        }
      }

      if (mounted) {
        setState(() {
          products.addAll(newProducts);
          filteredProducts = products;
          isLoading = false;
          isLoadMore = false;
          hasMore = newProducts.length == limit;
          if (hasMore) currentPage++;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          isLoading = false;
          isLoadMore = false;
        });
      }
    }
  }

  void _filterByCategory(String cat) {
    setState(() {
      selectedCategory = cat;
      if (cat == "All") {
        filteredProducts = products;
      } else {
        filteredProducts = products.where((p) => p['category'].toString().toLowerCase() == cat.toLowerCase()).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 768;
    
    int crossAxisCount = 4;
    if (size.width < 600) { crossAxisCount = 1; }
    else if (size.width < 900) { crossAxisCount = 2; }
    else if (size.width < 1200) { crossAxisCount = 3; }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: CustomNavbar(key: _navbarKey, isScrolled: true)),
          SliverToBoxAdapter(child: _buildHero()),
          SliverPadding(
            padding: EdgeInsets.symmetric(
              horizontal: size.width * 0.08, 
              vertical: isMobile ? 30 : 60
            ),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (size.width < 1000)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Genuine Spare Parts", style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: -1)),
                        const SizedBox(height: 12),
                        _buildSearchBar(double.infinity),
                      ],
                    )
                  else
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Genuine Spare Parts", style: TextStyle(fontSize: 42, fontWeight: FontWeight.w900, letterSpacing: -1)),
                            const SizedBox(height: 8),
                            Text("Direct from ${products.length} certified MotoBuddy garages.", style: const TextStyle(color: Colors.black54, fontSize: 18)),
                          ],
                        ),
                        _buildSearchBar(400),
                      ],
                    ),
                  const SizedBox(height: 40),
                  // Category Tabs
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: categories.map((cat) {
                        final isSelected = selectedCategory == cat;
                        return Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: ChoiceChip(
                            label: Text(cat),
                            selected: isSelected,
                            onSelected: (_) => _filterByCategory(cat),
                            selectedColor: const Color(0xFFFFD700),
                            backgroundColor: Colors.white,
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.black : Colors.black54,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal
                            ),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: BorderSide(color: isSelected ? const Color(0xFFFFD700) : Colors.grey.shade300)),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 40),
                  if (isLoading)
                    const Center(child: Padding(padding: EdgeInsets.all(100), child: CircularProgressIndicator()))
                  else if (filteredProducts.isEmpty)
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.inventory_2_outlined, size: 80, color: Colors.grey),
                          const SizedBox(height: 20),
                          Text(
                            "No products found in '$selectedCategory'", 
                            style: const TextStyle(fontSize: 18, color: Colors.grey, fontWeight: FontWeight.bold)
                          ),
                          const SizedBox(height: 10),
                          TextButton(onPressed: () => _filterByCategory("All"), child: const Text("Clear Filters")),
                        ],
                      )
                    ),
                ],
              ),
            ),
          ),
          if (!isLoading && filteredProducts.isNotEmpty)
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: size.width * 0.08),
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  childAspectRatio: 0.72,
                  crossAxisSpacing: 24,
                  mainAxisSpacing: 24,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    return _ProductCard(
                      p: filteredProducts[index],
                      onAddToCart: () => _navbarKey.currentState?.refresh(),
                    );
                  },
                  childCount: filteredProducts.length,
                ),
              ),
            ),
          if (hasMore && !isLoading && selectedCategory == "All")
            SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: isLoadMore
                      ? const CircularProgressIndicator()
                      : ElevatedButton(
                          onPressed: () => _fetchProducts(loadMore: true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: const Color(0xFFFFD700),
                            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: const Text("Load More Products", style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                ),
              ),
            ),
          const SliverPadding(padding: EdgeInsets.only(bottom: 60)),
          const SliverToBoxAdapter(child: Footer()),
        ],
      ),
      floatingActionButton: const FloatingChatbot(),
    );
  }

  Widget _buildSearchBar(double width) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20)],
      ),
      child: TextField(
        onChanged: (val) {
          setState(() {
            if (val.isEmpty) {
              _filterByCategory(selectedCategory);
            } else {
              filteredProducts = products.where((p) {
                final matchName = p['name'].toString().toLowerCase().contains(val.toLowerCase());
                final matchCat = selectedCategory == "All" || p['category'].toString().toLowerCase() == selectedCategory.toLowerCase();
                return matchName && matchCat;
              }).toList();
            }
          });
        },
        decoration: const InputDecoration(
          hintText: "Search for batteries, tires, oil...",
          border: InputBorder.none,
          icon: Icon(Icons.search, color: Colors.grey),
        ),
      ),
    );
  }

  Widget _buildHero() {
    return Container(
      width: double.infinity,
      height: 300,
      decoration: const BoxDecoration(
        color: Colors.black,
        image: DecorationImage(
          image: NetworkImage("https://images.unsplash.com/photo-1619642751034-765dfdf7c58e?auto=format&fit=crop&w=1200&q=80"),
          fit: BoxFit.cover,
          opacity: 0.5,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("MOTOBUDDY SHOP", style: TextStyle(color: Color(0xFFFFD700), fontSize: 48, fontWeight: FontWeight.w900)),
          const Text("Get parts that fit your ride perfectly", style: TextStyle(color: Colors.white, fontSize: 20)),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CartScreen())),
            icon: const Icon(Icons.inventory_2_outlined),
            label: const Text("View My Inventory / Cart"),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFD700),
              foregroundColor: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final dynamic p;
  final VoidCallback onAddToCart;
  const _ProductCard({required this.p, required this.onAddToCart});

  @override
  Widget build(BuildContext context) {

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  color: Colors.grey.shade100,
                  child: p['imageBytes'] != null
                      ? Image.memory(
                          p['imageBytes'],
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            color: Colors.grey.shade200,
                            child: const Center(child: Icon(Icons.broken_image_outlined, color: Colors.grey, size: 40)),
                          ),
                        )
                      : Image.network(
                          p['image'] != null && p['image'].toString().isNotEmpty ? p['image'] : "https://via.placeholder.com/400",
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            color: Colors.grey.shade200,
                            child: const Center(child: Icon(Icons.image_not_supported_outlined, color: Colors.grey, size: 40)),
                          ),
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              color: Colors.grey.shade100,
                              child: Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                      : null,
                                  strokeWidth: 2,
                                  color: const Color(0xFFFFD700),
                                ),
                              ),
                            );
                          },
                        ),
                ),
                Positioned(
                  top: 15,
                  right: 15,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black, 
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 5)],
                    ),
                    child: Text(
                      "₹${p['salePrice']}", 
                      style: const TextStyle(color: Color(0xFFFFD700), fontWeight: FontWeight.bold)
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(p['category']?.toString().toUpperCase() ?? "GENERAL", style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1.2)),
                const SizedBox(height: 5),
                Text(p['name'] ?? "Unknown Product", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 5),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      const Text("MRP: ", style: TextStyle(color: Colors.grey, fontSize: 13)),
                      Text("₹${p['mrp'] ?? p['salePrice']}", style: const TextStyle(color: Colors.grey, fontSize: 13, decoration: TextDecoration.lineThrough)),
                      const SizedBox(width: 8),
                      if (p['mrp'] != null && p['mrp'] > p['salePrice'])
                        Text(
                          "${(((p['mrp'] - p['salePrice']) / p['mrp']) * 100).toInt()}% OFF",
                          style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Seller: ${p['agent'] != null ? p['agent']['garageName'] ?? p['agent']['name'] : 'MotoBuddy Garage'}", 
                  style: const TextStyle(color: Colors.black54, fontSize: 13, fontWeight: FontWeight.w500),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 45,
                  child: ElevatedButton(
                    onPressed: () async {
                      await CartService.addToCart(p);
                      onAddToCart();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).hideCurrentSnackBar();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("${p['name']} added to cart!"),
                            duration: const Duration(seconds: 2), // Also limit its wait time
                            action: SnackBarAction(
                              label: "View", 
                              onPressed: () {
                                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                Navigator.push(context, MaterialPageRoute(builder: (_) => const CartScreen()));
                              }
                            ),
                          )
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: const Color(0xFFFFD700),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text("Add to Cart", style: TextStyle(fontWeight: FontWeight.bold)),
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
