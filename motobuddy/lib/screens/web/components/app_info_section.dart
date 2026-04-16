import 'package:flutter/material.dart';
import '../widgets/video_player_dialog.dart';

class AppInfoSection extends StatelessWidget {
  const AppInfoSection({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 900;
    final horizontalPadding = size.width * 0.08;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: isMobile ? 60 : 120),
      color: Colors.white,
      child: Column(
        children: [
          if (isMobile) 
            Column(
              children: [
                _buildTextContent(context),
                const SizedBox(height: 60),
                _buildImageContent(context, size),
              ],
            )
          else
            Row(
              children: [
                Expanded(child: _buildTextContent(context)),
                const SizedBox(width: 60),
                Expanded(child: _buildImageContent(context, size)),
              ],
            ),
          const SizedBox(height: 80),
          LayoutBuilder(
            builder: (context, constraints) {
              return Wrap(
                spacing: 32,
                runSpacing: 32,
                alignment: WrapAlignment.center,
                children: [
                  _FeatureCard(
                    width: isMobile ? constraints.maxWidth : (constraints.maxWidth - 64) / 3,
                    icon: Icons.gps_fixed,
                    title: "Live GPS Tracking",
                    description: "Monitor your mechanic's arrival in real-time with precise ETA updates.",
                    color: Colors.orange,
                  ),
                  _FeatureCard(
                    width: isMobile ? constraints.maxWidth : (constraints.maxWidth - 64) / 3,
                    icon: Icons.record_voice_over,
                    title: "Voice Assistance",
                    description: "Book services effortlessly using our integrated AI voice recognition system.",
                    color: Colors.blue,
                  ),
                  _FeatureCard(
                    width: isMobile ? constraints.maxWidth : (constraints.maxWidth - 64) / 3,
                    icon: Icons.security,
                    title: "Verified Mechanics",
                    description: "Every mechanic is vetted and rated by our community for absolute trust.",
                    color: Colors.green,
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTextContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "INTELLIGENT ECOSYSTEM",
          style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 2),
        ),
        const SizedBox(height: 16),
        Text(
          "Next-Gen Vehicle Care\nPowered by MotoBuddy AI",
          style: Theme.of(context).textTheme.displayLarge?.copyWith(
            fontSize: MediaQuery.of(context).size.width < 600 ? 32 : 48, 
            height: 1.1,
          ),
        ),
        const SizedBox(height: 32),
        const Text(
          "Our ecosystem bridges the gap between vehicle owners and expert mechanics using a state-of-the-art AI dispatch engine.",
          style: TextStyle(fontSize: 18, color: Colors.black87, height: 1.6),
        ),
      ],
    );
  }

  Widget _buildImageContent(BuildContext context, Size size) {
    return InkWell(
      onTap: () => VideoPlayerDialog.show(
        context, 
        "MotoBuddy Intelligent Ecosystem",
        thumbnailUrl: "https://images.unsplash.com/photo-1485827404703-89b55fcc595e?auto=format&fit=crop&w=1200",
        videoId: "X6uP1v2TfS4",
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Image.network(
              "https://images.unsplash.com/photo-1485827404703-89b55fcc595e?auto=format&fit=crop&w=800&q=80",
              height: size.width < 900 ? 300 : 500,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
            Container(
              height: size.width < 900 ? 300 : 500,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withValues(alpha: 0.5)],
                ),
              ),
            ),
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.8),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.play_arrow, size: 50, color: Colors.blueAccent),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final double width;

  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color, size: 32),
          ),
          const SizedBox(height: 24),
          Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Text(description, style: const TextStyle(fontSize: 16, color: Colors.black54, height: 1.5)),
        ],
      ),
    );
  }
}
