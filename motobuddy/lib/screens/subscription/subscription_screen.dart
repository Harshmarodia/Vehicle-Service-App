import 'package:flutter/material.dart';
import '../web/widgets/floating_chatbot.dart';
import '../web/widgets/custom_navbar.dart';
import '../web/components/footer.dart';
import '../web/widgets/video_player_dialog.dart';

class SubscriptionScreen extends StatelessWidget {
  const SubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 1200;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 80),
                // Top Hero Section
                _buildHero(context),
                const SizedBox(height: 60),
                // Plan Cards
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: size.width * 0.08),
                  child: Column(
                    children: [
                      const Text(
                        "Choose Your MotoBuddy Plan",
                        style: TextStyle(fontSize: 48, fontWeight: FontWeight.w900, letterSpacing: -1.5),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 15),
                      const Text(
                        "Select the perfect plan for your vehicle care and enjoy priority assistance.",
                        style: TextStyle(fontSize: 18, color: Colors.black54),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 60),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          return Wrap(
                            spacing: 24,
                            runSpacing: 24,
                            alignment: WrapAlignment.center,
                            children: [
                              _PlanCard(
                                width: isDesktop ? (constraints.maxWidth - 72) / 4 : (size.width > 800 ? (constraints.maxWidth - 24) / 2 : constraints.maxWidth),
                                name: "Free Plan",
                                price: "₹0",
                                period: "/month",
                                features: ["Basic service access", "Limited emergency requests", "Basic support"],
                                color: Colors.grey,
                              ),
                              _PlanCard(
                                width: isDesktop ? (constraints.maxWidth - 72) / 4 : (size.width > 800 ? (constraints.maxWidth - 24) / 2 : constraints.maxWidth),
                                name: "Basic Plan",
                                price: "₹199",
                                period: "/month",
                                features: ["Priority service booking", "2 free checkups per month", "Faster support response"],
                                color: Colors.blue,
                              ),
                              _PlanCard(
                                width: isDesktop ? (constraints.maxWidth - 72) / 4 : (size.width > 800 ? (constraints.maxWidth - 24) / 2 : constraints.maxWidth),
                                name: "Pro Plan",
                                price: "₹399",
                                period: "/month",
                                features: ["Unlimited emergency assistance", "Free diagnostic service", "Priority mechanic assignment", "Discount on spare parts"],
                                color: const Color(0xFFFFD700),
                                isPopular: true,
                              ),
                              _PlanCard(
                                width: isDesktop ? (constraints.maxWidth - 72) / 4 : (size.width > 800 ? (constraints.maxWidth - 24) / 2 : constraints.maxWidth),
                                name: "Premium Plan",
                                price: "₹699",
                                period: "/month",
                                features: ["All Pro features", "Free home pickup", "Dedicated support agent", "Free annual vehicle inspection"],
                                color: Colors.black,
                                isDark: true,
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 100),
                // Video Section
                _buildVideoSection(context),
                const SizedBox(height: 100),
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

  Widget _buildHero(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 300,
      decoration: const BoxDecoration(
        color: Colors.black,
        image: DecorationImage(
          image: NetworkImage("https://images.unsplash.com/photo-1503376780353-7e6692767b70?auto=format&fit=crop&w=1200&q=80"),
          fit: BoxFit.cover,
          opacity: 0.4,
        ),
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("PREMIUM SUBSCRIPTION", style: TextStyle(color: Color(0xFFFFD700), fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 2)),
          SizedBox(height: 10),
          Text("Drive Worry-Free", style: TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.w900, letterSpacing: -1)),
        ],
      ),
    );
  }

  Widget _buildVideoSection(BuildContext context) {
    return Container(
       padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 40),
       color: Colors.white,
       child: Column(
         children: [
           const Text("Understand Your Benefits", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
           const SizedBox(height: 15),
           const Text("Watch our quick guide on how subscriptions save you time and money.", style: TextStyle(fontSize: 18, color: Colors.black54)),
           const SizedBox(height: 60),
           InkWell(
             onTap: () => VideoPlayerDialog.show(
                context, 
                "MotoBuddy Subscription Guide",
                videoId: "6m3p8Xf9-5A",
             ),
             child: ClipRRect(
               borderRadius: BorderRadius.circular(30),
               child: Stack(
                 alignment: Alignment.center,
                 children: [
                   Image.network(
                     "https://images.unsplash.com/photo-1542385151-efd9000785a0?auto=format&fit=crop&w=1200",
                     height: 400,
                     width: 800,
                     fit: BoxFit.cover,
                   ),
                   Container(
                     height: 400,
                     width: 800,
                     color: Colors.black.withValues(alpha: 0.3),
                   ),
                   const Column(
                     children: [
                        Icon(Icons.play_circle_fill, size: 80, color: Color(0xFFFFD700)),
                        SizedBox(height: 20),
                        Text("Watch Plan Details", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                     ],
                   ),
                 ],
               ),
             ),
           ),
         ],
       ),
    );
  }
}

class _PlanCard extends StatefulWidget {
  final String name;
  final String price;
  final String period;
  final List<String> features;
  final Color color;
  final double width;
  final bool isPopular;
  final bool isDark;

  const _PlanCard({
    required this.name,
    required this.price,
    required this.period,
    required this.features,
    required this.color,
    required this.width,
    this.isPopular = false,
    this.isDark = false,
  });

  @override
  State<_PlanCard> createState() => _PlanCardState();
}

class _PlanCardState extends State<_PlanCard> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: widget.width,
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: widget.isDark ? Colors.black : Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: isHovered ? Colors.black26 : Colors.black.withValues(alpha: 0.03),
              blurRadius: 30,
              offset: const Offset(0, 15),
            )
          ],
          border: Border.all(
            color: widget.isPopular ? const Color(0xFFFFD700) : Colors.grey.shade100,
            width: 2,
          ),
        ),
        transform: Matrix4.translationValues(0, isHovered ? -10 : 0, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.isPopular)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(color: const Color(0xFFFFD700), borderRadius: BorderRadius.circular(20)),
                child: const Text("MOST POPULAR", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            Text(widget.name, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: widget.isDark ? Colors.white : Colors.black)),
            const SizedBox(height: 20),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(widget.price, style: TextStyle(fontSize: 42, fontWeight: FontWeight.w900, color: widget.isDark ? const Color(0xFFFFD700) : Colors.black)),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8, left: 4),
                  child: Text(widget.period, style: TextStyle(color: widget.isDark ? Colors.white60 : Colors.black54, fontSize: 16)),
                ),
              ],
            ),
            const SizedBox(height: 40),
            ...widget.features.map((f) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: const Color(0xFFFFD700), size: 20),
                  const SizedBox(width: 12),
                  Expanded(child: Text(f, style: TextStyle(color: widget.isDark ? Colors.white70 : Colors.black87, fontSize: 15))),
                ],
              ),
            )),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Processing payment for ${widget.name}...")));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.isDark ? const Color(0xFFFFD700) : Colors.black,
                  foregroundColor: widget.isDark ? Colors.black : const Color(0xFFFFD700),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: const Text("Buy Plan", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
