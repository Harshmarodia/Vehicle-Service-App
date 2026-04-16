import 'package:flutter/material.dart';
import 'video_player_registry.dart' if (dart.library.js_interop) 'video_player_registry_web.dart' as registry;

class VideoPlayerDialog {
  static void show(BuildContext context, String title, {String? thumbnailUrl, String? videoId}) {
    // Register the YouTube Video View Factory if not already registered
    final String viewType = 'youtube-video-${videoId ?? "default"}';
    
    // Use platform-specific registry
    registry.registerVideoFactory(viewType, videoId);

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: _VideoPlayerBody(title: title, viewType: viewType),
      ),
    );
  }
}

class _VideoPlayerBody extends StatelessWidget {
  final String title;
  final String viewType;
  const _VideoPlayerBody({required this.title, required this.viewType});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Video Header
        Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title, 
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close, color: Colors.white),
              )
            ],
          ),
        ),
        // YouTube Embed (Real Playback)
        Expanded(
          child: Container(
            width: double.infinity,
            color: Colors.black,
            child: HtmlElementView(viewType: viewType),
          ),
        ),
        // Video Footer
        Container(
          padding: const EdgeInsets.all(30),
          width: double.infinity,
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Now Playing: YouTube Original", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
              const SizedBox(height: 10),
              const Text(
                "You are watching an official MotoBuddy guide. Follow along with the YouTube video for the most accurate vehicle care instructions.",
                style: TextStyle(color: Colors.black87, fontSize: 16),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.share),
                    label: const Text("Share"),
                    style: OutlinedButton.styleFrom(foregroundColor: Colors.black),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
