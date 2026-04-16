import 'package:flutter/material.dart';
import '../widgets/custom_navbar.dart';
import '../widgets/floating_chatbot.dart';
import '../components/hero_section.dart';
import '../components/product_slider.dart';
import '../components/slideshow_section.dart';
import '../components/app_info_section.dart';
import '../components/footer.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  final ScrollController _controller = ScrollController();
  bool scrolled = false;

  @override
  void initState() {
    _controller.addListener(() {
      if (_controller.offset > 20 && !scrolled) {
        setState(() => scrolled = true);
      } else if (_controller.offset <= 20 && scrolled) {
        setState(() => scrolled = false);
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            controller: _controller,
            child: Column(
              children: [
                const SizedBox(height: 80),
                const HeroSection(),
                const SizedBox(height: 60),
                const _CategoryGrid(),
                const SizedBox(height: 80),
                const ProductSlider(),
                const SizedBox(height: 40),
                SlideshowSection(
                  title: "Our Success Stories",
                  imageUrls: const [
                    "https://images.unsplash.com/photo-1486006396880-6bc163ff34d7?auto=format&fit=crop&w=600&q=80",
                    "https://images.unsplash.com/photo-1613214150384-651951ca6071?auto=format&fit=crop&w=600&q=80",
                    "https://images.unsplash.com/photo-1530046339160-ce3e5b0c7a2f?auto=format&fit=crop&w=600&q=80",
                    "https://images.unsplash.com/photo-1517524008697-84bbe3c3fd98?auto=format&fit=crop&w=600&q=80",
                  ],
                ),
                const SizedBox(height: 40),
                SlideshowSection(
                  title: "Meet Our Expert Mechanics",
                  isReverse: true, // Slides in the opposite direction
                  imageUrls: const [
                    "https://images.unsplash.com/photo-1621905251189-08b45d6a269e?auto=format&fit=crop&w=600&q=80",
                    "https://images.unsplash.com/photo-1507702720993-f4c6e949ff1a?auto=format&fit=crop&w=600&q=80",
                    "https://images.unsplash.com/photo-1616423640778-28d1b53229bd?auto=format&fit=crop&w=600&q=80",
                    "https://images.unsplash.com/photo-1599256621730-535171e28f56?auto=format&fit=crop&w=600&q=80",
                  ],
                ),
                const SizedBox(height: 40),
                const AppInfoSection(),
                const SizedBox(height: 60),
                const Footer(),
              ],
            ),
          ),
          CustomNavbar(isScrolled: scrolled),
          const FloatingChatbot(),
        ],
      ),
    );
  }
}

class _CategoryGrid extends StatelessWidget {
  const _CategoryGrid();

  @override
  Widget build(BuildContext context) {
    final categories = [
      {"name": "Engine Oil", "icon": Icons.oil_barrel, "color": Colors.orange},
      {"name": "Brake Pads", "icon": Icons.stop_circle, "color": Colors.red},
      {"name": "Tyres", "icon": Icons.tire_repair, "color": Colors.blue},
      {"name": "Batteries", "icon": Icons.battery_charging_full, "color": Colors.green},
      {"name": "Helmets", "icon": Icons.sports_motorsports, "color": Colors.purple},
      {"name": "Lubricants", "icon": Icons.water_drop, "color": Colors.cyan},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 80),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Browse Categories",
            style: TextStyle(
              fontSize: 36, 
              fontWeight: FontWeight.w900, 
              letterSpacing: -1.2,
              color: Color(0xFF1A1D21),
            ),
          ),
          const SizedBox(height: 36),
          LayoutBuilder(
            builder: (context, constraints) {
              return Wrap(
                spacing: 24,
                runSpacing: 24,
                children: categories.map((cat) {
                  return Container(
                    width: (constraints.maxWidth - 120) / 6,
                    padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 30,
                          offset: const Offset(0, 15),
                        )
                      ],
                      border: Border.all(color: Colors.grey.shade50, width: 1.5),
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: (cat['color'] as Color).withValues(alpha: 0.08),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(cat['icon'] as IconData, size: 36, color: cat['color'] as Color),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          cat['name'] as String,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700, 
                            fontSize: 15,
                            color: Color(0xFF2D3238),
                            letterSpacing: -0.2,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}