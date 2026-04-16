import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';

class BlurDropdown extends StatefulWidget {
  final String title;
  final List<String> items;
  final Function(String)? onTap;

  const BlurDropdown({super.key, required this.title, required this.items, this.onTap});

  @override
  State<BlurDropdown> createState() => _BlurDropdownState();
}

class _BlurDropdownState extends State<BlurDropdown> {
  bool show = false;
  Timer? _debounce;

  void _hideDropdown() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (mounted) setState(() => show = false);
    });
  }

  void _showDropdown() {
    _debounce?.cancel();
    setState(() => show = true);
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _showDropdown(),
      onExit: (_) => _hideDropdown(),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Text(
                widget.title,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black),
              ),
            ),
          ),
          if (show)
            Positioned(
              top: 40,
              left: 0,
              child: Container(
                padding: const EdgeInsets.only(top: 10),
                color: Colors.transparent,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: widget.items
                            .map((e) => InkWell(
                                  onTap: () {
                                    if (widget.onTap != null) widget.onTap!(e);
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 8),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        if (e.startsWith("Watch:"))
                                          const Padding(
                                            padding: EdgeInsets.only(right: 8),
                                            child: Icon(Icons.play_circle_outline, size: 16, color: Colors.redAccent),
                                          ),
                                        Text(
                                          e,
                                          style: TextStyle(
                                            color: e.startsWith("Watch:") ? Colors.blueAccent : Colors.black87,
                                            fontWeight: e.startsWith("Watch:") ? FontWeight.bold : FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ))
                            .toList(),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}