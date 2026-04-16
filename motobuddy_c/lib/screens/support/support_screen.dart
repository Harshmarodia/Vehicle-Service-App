import 'package:flutter/material.dart';
import 'support_detail_screen.dart';
import '../web/widgets/floating_chatbot.dart';
import '../web/widgets/custom_navbar.dart';
import '../web/components/footer.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  final List<Map<String, dynamic>> supportCategories = const [
    {
      "title": "Service Help",
      "desc": "Issues related to booking a mechanic or service request.",
      "icon": Icons.build_circle_outlined,
      "color": Colors.orange
    },
    {
      "title": "Emergency Assistance",
      "desc": "Breakdown help or urgent roadside service.",
      "icon": Icons.emergency_outlined,
      "color": Colors.red
    },
    {
      "title": "Payment & Billing",
      "desc": "Problems with payment, refunds, or wallet balance.",
      "icon": Icons.account_balance_wallet_outlined,
      "color": Colors.green
    },
    {
      "title": "Subscription Help",
      "desc": "Questions related to plans and benefits.",
      "icon": Icons.card_membership_outlined,
      "color": Colors.blue
    },
    {
      "title": "Account & Profile",
      "desc": "Updating name, email, phone, or address.",
      "icon": Icons.person_outline,
      "color": Colors.purple
    },
    {
      "title": "Technical Support",
      "desc": "App errors, login issues, or bugs.",
      "icon": Icons.code_outlined,
      "color": Colors.cyan
    },
    {
      "title": "Chat With Support",
      "desc": "Direct live chat with MotoBuddy support agent.",
      "icon": Icons.chat_bubble_outline,
      "color": Colors.indigo
    },
    {
      "title": "Call Support",
      "desc": "Option to call customer service.",
      "icon": Icons.phone_android_outlined,
      "color": Colors.teal
    },
  ];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 1200;
    final isTablet = size.width > 800 && size.width <= 1200;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 80),
                // Hero Section
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 40),
                  color: Colors.black,
                  child: Column(
                    children: [
                      const Text(
                        "How can we help you today?",
                        style: TextStyle(color: Colors.white, fontSize: 42, fontWeight: FontWeight.w900, letterSpacing: -1),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 15),
                      const Text(
                        "Search help articles or choose a category below",
                        style: TextStyle(color: Colors.white70, fontSize: 18),
                      ),
                      const SizedBox(height: 40),
                      Container(
                        constraints: const BoxConstraints(maxWidth: 600),
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: const TextField(
                          decoration: InputDecoration(
                            hintText: "Search for issues...",
                            border: InputBorder.none,
                            icon: Icon(Icons.search, color: Colors.grey),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Grid Section
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: size.width * 0.08,
                    vertical: 60,
                  ),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: isDesktop ? 4 : (isTablet ? 2 : 1),
                      crossAxisSpacing: 30,
                      mainAxisSpacing: 30,
                      childAspectRatio: 0.9,
                    ),
                    itemCount: supportCategories.length,
                    itemBuilder: (context, index) {
                      final cat = supportCategories[index];
                      return _SupportCard(category: cat);
                    },
                  ),
                ),
                const Footer(),
              ],
            ),
          ),
          const CustomNavbar(isScrolled: false),
        ],
      ),
      floatingActionButton: const FloatingChatbot(),
    );
  }
}

class _SupportCard extends StatefulWidget {
  final Map<String, dynamic> category;
  const _SupportCard({required this.category});

  @override
  State<_SupportCard> createState() => _SupportCardState();
}

class _SupportCardState extends State<_SupportCard> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => SupportDetailScreen(category: widget.category)),
        ),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: isHovered ? Colors.black12 : Colors.black.withValues(alpha: 0.03),
                blurRadius: isHovered ? 30 : 20,
                offset: const Offset(0, 10),
              )
            ],
            border: Border.all(color: isHovered ? const Color(0xFFFFD700) : Colors.grey.shade100, width: 2),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: (widget.category['color'] as Color).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(widget.category['icon'], size: 40, color: widget.category['color']),
              ),
              const SizedBox(height: 24),
              Text(
                widget.category['title'],
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                widget.category['desc'],
                style: const TextStyle(fontSize: 14, color: Colors.black54),
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
