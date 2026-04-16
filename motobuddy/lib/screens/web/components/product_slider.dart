import 'dart:async';
import 'package:flutter/material.dart';
import '../widgets/video_player_dialog.dart';

class ProductSlider extends StatefulWidget {
  const ProductSlider({super.key});

  @override
  State<ProductSlider> createState() => _ProductSliderState();
}

class _ProductSliderState extends State<ProductSlider> {
  final ScrollController _scrollController = ScrollController();
  Timer? _timer;
  
  final List<Map<String, dynamic>> products = [
    {
      "name": "Synthetic Engine Oil",
      "price": "₹1,200",
      "image": "https://images.unsplash.com/photo-1631501679070-dfd354890bf8?q=80&w=600&auto=format&fit=crop",
      "desc": "High performance fully synthetic engine oil for peak performance."
    },
    {
      "name": "Smart HD Dashcam",
      "price": "₹4,500",
      "image": "https://images.unsplash.com/photo-1557022204-7497d391f1c7?q=80&w=600&auto=format&fit=crop",
      "desc": "1080p recording with night vision and loop recording."
    },
    {
      "name": "All-Terrain Tyre",
      "price": "₹3,800",
      "image": "https://images.unsplash.com/photo-1582266255765-fa5cf1a1d501?q=80&w=600&auto=format&fit=crop",
      "desc": "Durable tyre with superior grip for all weather conditions."
    },
    {
      "name": "High-Performance Battery",
      "price": "₹5,200",
      "image": "https://images.unsplash.com/photo-1621259182978-f09e5e2ca09a?q=80&w=600&auto=format&fit=crop",
      "desc": "Long lasting maintenance free battery with 48 months warranty."
    },
    {
      "name": "Premium Coolant",
      "price": "₹450",
      "image": "https://images.unsplash.com/photo-1486006920555-c77dcf18193c?q=80&w=600&auto=format&fit=crop",
      "desc": "Pre-mixed antifreeze engine coolant for optimal temperature control."
    }
  ];

  @override
  void initState() {
    super.initState();
    // Auto scroll logic (showing 3 products at a time)
    _startAutoScroll();
  }

  void _startAutoScroll() {
    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_scrollController.hasClients) {
        double maxScroll = _scrollController.position.maxScrollExtent;
        double currentScroll = _scrollController.offset;
        double nextScroll = currentScroll + 400.0; // approximate width of one card + margin
        
        if (nextScroll >= maxScroll) {
          _scrollController.animateTo(0, duration: const Duration(seconds: 1), curve: Curves.easeInOut);
        } else {
          _scrollController.animateTo(nextScroll, duration: const Duration(seconds: 1), curve: Curves.easeInOut);
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
          padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 20),
          child: Text(
            "Recommended Products",
            style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 32),
          ),
        ),
        SizedBox(
          height: 480,
          child: ListView.builder(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 70),
            itemCount: products.length,
            itemBuilder: (context, index) {
              return _ProductCard(product: products[index]);
            },
          ),
        ),
      ],
    );
  }
}

class _ProductCard extends StatefulWidget {
  final Map<String, dynamic> product;

  const _ProductCard({required this.product});

  @override
  State<_ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<_ProductCard> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 350,
        margin: const EdgeInsets.all(10),
        transform: Matrix4.translationValues(0, isHovered ? -10 : 0, 0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: isHovered ? Colors.black26 : Colors.black12,
              blurRadius: isHovered ? 20 : 10,
              offset: Offset(0, isHovered ? 10 : 5),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Image.network(
                    widget.product['image'],
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        height: 200,
                        width: double.infinity,
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
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 200,
                      color: Colors.grey.shade100,
                      child: const Icon(Icons.broken_image_outlined, size: 50, color: Colors.grey),
                    ),
                  ),
                  if (isHovered)
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.8),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.play_arrow, color: Colors.blueAccent),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.product['name'],
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    widget.product['desc'],
                    style: const TextStyle(fontSize: 14, color: Colors.black54),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 15),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.product['price'],
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.black87),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: TextButton(
                              onPressed: () => VideoPlayerDialog.show(
                                context, 
                                "Product Spotlight: ${widget.product['name']}",
                                thumbnailUrl: widget.product['image'],
                                videoId: "O1hF25Cowv8",
                              ),
                              style: TextButton.styleFrom(padding: EdgeInsets.zero),
                              child: const Text("Know More", style: TextStyle(color: Colors.black, fontSize: 13)),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context).primaryColor,
                                foregroundColor: Colors.black,
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                minimumSize: const Size(0, 36),
                              ),
                              child: const Text("Buy Now", style: TextStyle(fontSize: 13)),
                            ),
                          )
                        ],
                      )
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}