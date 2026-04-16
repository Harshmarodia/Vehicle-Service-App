import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../auth/login_screen.dart';
import '../landing/landing_page.dart';
import '../content/video_content_screen.dart';
import '../../shop/shop_screen.dart';
import '../../../core/services/api_service.dart';
import '../../../core/theme/app_theme.dart';
// import 'blur_dropdown.dart';
import '../../profile/profile_screen.dart';
import '../../history/service_history_screen.dart';
import '../../shop/cart_screen.dart';
import '../../booking/service_booking_screen.dart';
import '../../support/support_screen.dart';
import '../../subscription/subscription_screen.dart';
import '../../../core/services/cart_service.dart';

class CustomNavbar extends StatefulWidget {
  final bool isScrolled;

  const CustomNavbar({super.key, required this.isScrolled});

  @override
  State<CustomNavbar> createState() => CustomNavbarState();
}

class CustomNavbarState extends State<CustomNavbar> {
  bool isLoggedIn = false;
  String userName = "U";
  int cartCount = 0;

  @override
  void initState() {
    super.initState();
    _checkStatus();
    ApiService.authNotifier.addListener(_checkStatus);
  }

  @override
  void dispose() {
    ApiService.authNotifier.removeListener(_checkStatus);
    super.dispose();
  }

  Future<void> refresh() => _checkStatus();

  Future<void> _checkStatus() async {
    bool status = await ApiService.isLoggedIn();
    final items = await CartService.getCartItems();
    String initials = "U";
    
    if (status) {
      final user = await ApiService.getProfile();
      if (user['success'] == true && user['user'] != null) {
        String name = user['user']['name'] ?? "User";
        initials = name.isNotEmpty ? name[0].toUpperCase() : "U";
      }
    }

    if (mounted) {
      setState(() {
        isLoggedIn = status;
        cartCount = items.length;
        userName = initials;
      });
    }
  }

  void _navigateToContent(String category, List<Map<String, String>> content, {String? bg, bool isSupport = false}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => VideoContentScreen(
          category: category, 
          content: content, 
          backgroundImage: bg,
          isSupport: isSupport,
        ),
      ),
    );
  }

  Future<void> _handleAuthAction(BuildContext context, {String? targetPage}) async {
    if (targetPage == "Support") {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const SupportScreen()));
      return;
    }

    // Category Level Navigation
    if (targetPage == "Service") {
      _navigateToContent(
        "Vehicle Services", 
        [
          {"title": "Multi-point Inspection", "description": "Complete checkup of your vehicle 40+ parameters."},
          {"title": "Emergency Breakdown", "description": "What to do when your bike stops in middle of nowhere."},
          {"title": "Oil Change DIY", "description": "Simple steps to change your engine oil at home."},
        ],
        bg: "https://images.unsplash.com/photo-1486262715619-67b85e0b08d3?auto=format&fit=crop&w=1200&q=80", // Workshop car
      );
      return;
    } else if (targetPage == "Products") {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ShopScreen()),
      );
      return;
    } else if (targetPage == "Subscription") {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const SubscriptionScreen()));
      return;
    } else if (targetPage == "About") {
      _navigateToContent(
        "About MotoBuddy", 
        [
          {"title": "Our Mission", "description": "To provide seamless, tech-enabled vehicle care for every rider, anywhere and anytime."},
          {"title": "Smart Ecosystem", "description": "Connecting thousands of certified mechanics with vehicle owners through a single tap."},
          {"title": "Community Focus", "description": "Built by riders, for riders. We understand the heartbeat of your machine."},
          {"title": "Our Journey", "description": "From a small garage optimization tool to a nationwide service network across 50+ cities."},
          {"title": "Sustainability", "description": "Leading the transition to green energy with our specialized EV maintenance and swapping hubs."},
          {"title": "Quality Promise", "description": "Every part and service and MotoBuddy comes with a verified quality guarantee."},
        ],
        bg: "https://images.unsplash.com/photo-1558981806-ec527fa84c39?auto=format&fit=crop&w=1200&q=80", // Riders/Bikes
      );
    }

    bool logged = await ApiService.isLoggedIn();
    if (!context.mounted) return;
    if (!logged) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      ).then((_) => _checkStatus());
    } else if (targetPage == "Profile") {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
    } else if (targetPage == "Book Service") {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const ServiceBookingScreen()));
    } else if (targetPage == "Bookings") {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const ServiceHistoryScreen()));
    } else if (targetPage == "Cart") {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const CartScreen()));
    } else if (targetPage == "Logout") {
      await ApiService.logout();
      _checkStatus();
      if (context.mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LandingPage()),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isCompact = size.width < 1400; // Increased threshold to prevent overflow

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: 80,
      padding: EdgeInsets.symmetric(horizontal: size.width < 600 ? 20 : 40),
      decoration: BoxDecoration(
        color: widget.isScrolled 
            ? const Color(0xFF0F1113).withOpacity(0.7) 
            : const Color(0xFF0F1113),
        borderRadius: widget.isScrolled
            ? const BorderRadius.vertical(bottom: Radius.circular(32))
            : BorderRadius.zero,
        border: widget.isScrolled 
            ? Border.all(color: Colors.white.withOpacity(0.08)) 
            : null,
        boxShadow: widget.isScrolled
            ? [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 30, offset: const Offset(0, 10))]
            : [],
      ),
      child: ClipRRect(
        borderRadius: widget.isScrolled
            ? const BorderRadius.vertical(bottom: Radius.circular(30))
            : BorderRadius.zero,
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: widget.isScrolled ? 10 : 0, 
            sigmaY: widget.isScrolled ? 10 : 0
          ),
          child: Row(
            children: [
              // Logo
              InkWell(
                onTap: () => Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LandingPage()), (r) => false),
                child: Row(
                  children: [
                    Text(
                      "MotoBuddy",
                      style: GoogleFonts.outfit(
                        fontSize: size.width < 500 ? 20 : 26,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),

              if (!isCompact) ...[
                // Search Bar (Amazon/Flipkart Style)
                Expanded(
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 500), // Fixed: Use constraints instead of direct maxWidth
                    height: 40,
                    margin: const EdgeInsets.symmetric(horizontal: 40),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const TextField(
                      decoration: InputDecoration(
                        hintText: "Search parts...",
                        prefixIcon: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          child: Icon(Icons.search, color: Colors.grey, size: 20),
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                ),
                _navLink("Service"),
                _navLink("Products"),
                _navLink("Subscription"),
                _navLink("About"),
                const SizedBox(width: 10),
                TextButton.icon(
                  onPressed: () => _handleAuthAction(context, targetPage: "Support"),
                  icon: const Icon(Icons.headset_mic_outlined, color: Colors.white, size: 20),
                  label: const Text("Support", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.lightTheme.primaryColor,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  onPressed: () => _handleAuthAction(context, targetPage: "Book Service"),
                  child: const Text("Book Service"),
                ),
              ] else
                PopupMenuButton<String>(
                  icon: const Icon(Icons.menu, color: Colors.white, size: 30),
                  onSelected: (val) => _handleAuthAction(context, targetPage: val),
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: "Service", child: Text("Service")),
                    const PopupMenuItem(value: "Products", child: Text("Products")),
                    const PopupMenuItem(value: "Subscription", child: Text("Subscription")),
                    const PopupMenuItem(value: "About", child: Text("About")),
                    const PopupMenuItem(value: "Support", child: Text("Support")),
                    const PopupMenuItem(value: "Book Service", child: Text("Book Service", style: TextStyle(fontWeight: FontWeight.bold))),
                  ],
                ),

              const SizedBox(width: 15),

              if (!isLoggedIn)
                ElevatedButton(
                  onPressed: () => _handleAuthAction(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    side: const BorderSide(color: Colors.yellow),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    minimumSize: size.width < 500 ? const Size(60, 36) : null,
                  ),
                  child: const Text("Login"),
                )
              else ...[
                Stack(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.shopping_cart, color: Colors.yellow),
                      onPressed: () => _handleAuthAction(context, targetPage: "Cart"),
                      tooltip: "My Cart",
                    ),
                    Positioned(
                      right: 5,
                      top: 5,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                        constraints: const BoxConstraints(minWidth: 14, minHeight: 14),
                        child: Text("$cartCount", style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                      ),
                    )
                  ],
                ),
                const SizedBox(width: 15),
                PopupMenuButton<String>(
                  onSelected: (val) => _handleAuthAction(context, targetPage: val),
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: "Profile", child: Row(children: [Icon(Icons.person_outline), SizedBox(width: 10), Text("My Profile")])),
                    const PopupMenuItem(value: "Bookings", child: Row(children: [Icon(Icons.assignment_outlined), SizedBox(width: 10), Text("My Bookings")])),
                    const PopupMenuItem(value: "Cart", child: Row(children: [Icon(Icons.shopping_cart_outlined), SizedBox(width: 10), Text("My Cart")])),
                    const PopupMenuDivider(),
                    const PopupMenuItem(value: "Logout", child: Row(children: [Icon(Icons.logout, color: Colors.red), SizedBox(width: 10), Text("Logout", style: TextStyle(color: Colors.red))])),
                  ],
                  child: CircleAvatar(
                    backgroundColor: Colors.yellow,
                    radius: 18,
                    child: Text(userName, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 14)),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _navLink(String title) {
    return Padding(
      padding: const EdgeInsets.only(right: 20),
      child: TextButton(
        onPressed: () => _handleAuthAction(context, targetPage: title),
        child: Text(
          title == "About" ? "About Us" : title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
