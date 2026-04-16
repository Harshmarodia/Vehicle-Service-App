import 'package:flutter/material.dart';
import '../../booking/chatbot_screen.dart';
import '../../shop/shop_screen.dart';
import '../widgets/video_player_dialog.dart';

class HeroSection extends StatefulWidget {
  const HeroSection({super.key});

  @override
  State<HeroSection> createState() => _HeroSectionState();
}

class _HeroSectionState extends State<HeroSection> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(seconds: 1));
    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _animController, curve: Curves.easeIn));
    _slideAnim = Tween<Offset>(begin: const Offset(-0.2, 0.0), end: Offset.zero).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 768;
    final horizontalPadding = size.width * 0.08;

    return Container(
      width: double.infinity,
      constraints: BoxConstraints(minHeight: isMobile ? 500 : 700),
      decoration: BoxDecoration(
        color: const Color(0xFF0A0A0A),
        image: DecorationImage(
          image: const AssetImage("assets/images/motobuddy.png"),
          fit: BoxFit.cover,
          opacity: 0.4,
          colorFilter: ColorFilter.mode(Colors.black.withValues(alpha: 0.6), BlendMode.darken),
        ),
      ),
      child: Stack(
        children: [
          if (!isMobile)
            Positioned(
              top: -100,
              right: -100,
              child: Container(
                width: 400,
                height: 400,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFFFD700).withValues(alpha: 0.1),
                  boxShadow: [
                    BoxShadow(color: const Color(0xFFFFD700).withValues(alpha: 0.2), blurRadius: 100, spreadRadius: 50),
                  ],
                ),
              ),
            ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 60),
            child: Row(
              children: [
                Expanded(
                  flex: isMobile ? 1 : 3,
                  child: FadeTransition(
                    opacity: _fadeAnim,
                    child: SlideTransition(
                      position: _slideAnim,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFD700).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: const Color(0xFFFFD700).withValues(alpha: 0.3)),
                            ),
                            child: const Text(
                              "AUTO SERVICE REIMAGINED",
                              style: TextStyle(color: Color(0xFFFFD700), fontWeight: FontWeight.bold, fontSize: 10, letterSpacing: 1.5),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            "DRIVE BEYOND\nBOUNDARIES",
                            textAlign: isMobile ? TextAlign.center : TextAlign.start,
                            style: TextStyle(
                              fontSize: isMobile ? 48 : (size.width > 1200 ? 92 : 72),
                              height: 0.9,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: -2.0,
                            ),
                          ),
                          const SizedBox(height: 28),
                          Text(
                            "Experience elite vehicle care. From on-spot breakdown\nassistance to genuine parts marketplace.",
                            textAlign: isMobile ? TextAlign.center : TextAlign.start,
                            style: TextStyle(
                              fontSize: isMobile ? 18 : 20,
                              color: Colors.white.withValues(alpha: 0.8),
                              height: 1.6,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                          const SizedBox(height: 54),
                          Wrap(
                            alignment: WrapAlignment.center,
                            spacing: 24,
                            runSpacing: 24,
                            children: [
                              _HeroButton(
                                text: "Get Assistance",
                                isPrimary: true,
                                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatbotScreen())),
                              ),
                              _HeroButton(
                                text: "Explore Shop",
                                isPrimary: false,
                                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ShopScreen())),
                              ),
                              const SizedBox(width: 12),
                              TextButton.icon(
                                onPressed: () => VideoPlayerDialog.show(
                                  context, 
                                  "MotoBuddy: Auto Service Reimagined",
                                  thumbnailUrl: "https://images.unsplash.com/photo-1492144534655-ae79c964c9d7?auto=format&fit=crop&q=80&w=2000",
                                  videoId: "C2p-fCq4Yxw",
                                ),
                                icon: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.yellow.withValues(alpha: 0.1),
                                  ),
                                  child: const Icon(Icons.play_arrow_rounded, color: Colors.yellow, size: 28),
                                ),
                                label: const Text(
                                  "Watch Teaser", 
                                  style: TextStyle(
                                    color: Colors.white, 
                                    fontWeight: FontWeight.w600, 
                                    fontSize: 16,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (!isMobile)
                  Expanded(
                    flex: 2,
                    child: Container(),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroButton extends StatelessWidget {
  final String text;
  final bool isPrimary;
  final VoidCallback onTap;

  const _HeroButton({required this.text, required this.isPrimary, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 18),
        decoration: BoxDecoration(
          color: isPrimary ? const Color(0xFFFFD700) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: isPrimary ? null : Border.all(color: Colors.white, width: 2),
          boxShadow: isPrimary ? [BoxShadow(color: const Color(0xFFFFD700).withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 10))] : [],
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isPrimary ? Colors.black : Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}