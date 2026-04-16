import 'dart:async';
import 'package:flutter/material.dart';
import '../widgets/video_player_dialog.dart';

class SlideshowSection extends StatefulWidget {
  final String title;
  final List<String> imageUrls;
  final bool isReverse;

  const SlideshowSection({
    super.key,
    required this.title,
    required this.imageUrls,
    this.isReverse = false,
  });

  @override
  State<SlideshowSection> createState() => _SlideshowSectionState();
}

class _SlideshowSectionState extends State<SlideshowSection> {
  final ScrollController _scrollController = ScrollController();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.isReverse) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
      _startAutoScroll();
    });
  }

  void _startAutoScroll() {
    _timer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (_scrollController.hasClients) {
        double currentScroll = _scrollController.offset;
        double maxScroll = _scrollController.position.maxScrollExtent;
        double scrollAmount = 2.0;

        if (widget.isReverse) {
          if (currentScroll - scrollAmount <= 0) {
            _scrollController.jumpTo(maxScroll);
          } else {
            _scrollController.jumpTo(currentScroll - scrollAmount);
          }
        } else {
          if (currentScroll + scrollAmount >= maxScroll) {
            _scrollController.jumpTo(0);
          } else {
            _scrollController.jumpTo(currentScroll + scrollAmount);
          }
        }
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 10),
          child: Text(
            widget.title,
            style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 32),
          ),
        ),
        SizedBox(
          height: 250,
          child: ListView.builder(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            physics: const NeverScrollableScrollPhysics(), // User shouldn't drag an infinite marquee
            itemBuilder: (context, index) {
              // Creating an infinite loop effect by using modulo
              final image = widget.imageUrls[index % widget.imageUrls.length];
              return InkWell(
                onTap: () {
                  // Variety of relevant videos for slideshow
                  final ids = ["m_S_A6-c3Hk", "O1hF25Cowv8", "6m3p8Xf9-5A"];
                  VideoPlayerDialog.show(
                    context, 
                    "${widget.title} - Highlight ${index % widget.imageUrls.length + 1}",
                    thumbnailUrl: image,
                    videoId: ids[index % ids.length],
                  );
                },
                child: Container(
                  width: 350,
                  margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10)],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Stack(
                      children: [
                        Image.network(
                          image,
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                          cacheWidth: 600,
                          cacheHeight: 400,
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
                                  color: Colors.blueAccent,
                                ),
                              ),
                            );
                          },
                          errorBuilder: (c, e, s) => Container(
                            color: Colors.grey.shade100,
                            child: const Center(child: Icon(Icons.image_not_supported_outlined, color: Colors.grey)),
                          ),
                        ),
                        Center(
                          child: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.7),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.play_arrow, color: Colors.black),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
