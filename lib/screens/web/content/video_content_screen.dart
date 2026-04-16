import 'package:flutter/material.dart';
import '../widgets/custom_navbar.dart';
import '../widgets/floating_chatbot.dart';
import '../widgets/video_player_dialog.dart';
import '../components/footer.dart'; 

class VideoContentScreen extends StatelessWidget {
  final String category;
  final List<Map<String, String>> content;
  final String? backgroundImage;
  final bool isSupport;

  const VideoContentScreen({
    super.key,
    required this.category,
    required this.content,
    this.backgroundImage,
    this.isSupport = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image with Overlay
          if (backgroundImage != null)
            Positioned.fill(
              child: Image.network(
                backgroundImage!,
                fit: BoxFit.cover,
                color: Colors.black.withValues(alpha: 0.6),
                colorBlendMode: BlendMode.darken,
              ),
            ),
          SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 100),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 100),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category,
                        style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        isSupport 
                            ? "Get in touch with our team for immediate assistance." 
                            : "Guided tutorials and documents to help you maintain and fix your vehicle.",
                        style: const TextStyle(fontSize: 18, color: Colors.white70),
                      ),
                      const SizedBox(height: 50),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 30,
                          mainAxisSpacing: 30,
                          childAspectRatio: 1.2,
                        ),
                        itemCount: content.length,
                        itemBuilder: (context, index) {
                          final item = content[index];
                          return _buildContentCard(context, item);
                        },
                      ),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
                const Footer(),
              ],
            ),
          ),
          const CustomNavbar(isScrolled: true),
          const FloatingChatbot(),
        ],
      ),
    );
  }

  Widget _buildContentCard(BuildContext context, Map<String, String> item) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 20, offset: const Offset(0, 5))
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          // Mapping titles to professional, high-quality YouTube IDs
          String videoId = "6m3p8Xf9-5A"; // Default maintenance guide
          if (item["title"]?.toLowerCase().contains("inspection") ?? false) videoId = "6m3p8Xf9-5A";
          if (item["title"]?.toLowerCase().contains("tutorial") ?? false) videoId = "P2L-1_6t-t4";
          if (item["title"]?.toLowerCase().contains("oil change") ?? false) videoId = "O1hF25Cowv8";
          if (item["title"]?.toLowerCase().contains("chain") ?? false) videoId = "m_S_A6-c3Hk";
          if (item["title"]?.toLowerCase().contains("emergency") ?? false) videoId = "X6uP1v2TfS4";

          VideoPlayerDialog.show(
            context, 
            item["title"] ?? "Video Content",
            thumbnailUrl: item["image"] ?? backgroundImage,
            videoId: videoId,
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                color: Colors.grey.shade100,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(
                      isSupport ? Icons.contact_support_outlined : Icons.video_library_outlined, 
                      size: 50, 
                      color: Colors.grey
                    ),
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.redAccent.withValues(alpha: 0.9), 
                        shape: BoxShape.circle,
                        boxShadow: [BoxShadow(color: Colors.redAccent.withValues(alpha: 0.4), blurRadius: 15, spreadRadius: 2)],
                      ),
                      child: const Icon(Icons.play_arrow, color: Colors.white, size: 40),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item["title"] ?? "Untitled",
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item["description"] ?? "Information about this section.",
                    style: const TextStyle(color: Colors.black87, fontSize: 14),
                  ),
                  const SizedBox(height: 15),
                  if (item["contact"] != null)
                    Text(
                      item["contact"]!,
                      style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      const Icon(Icons.play_circle_fill, color: Colors.blue, size: 20),
                      const SizedBox(width: 8),
                      const Text("WATCH VIDEO", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
