import 'package:flutter/material.dart';

class Footer extends StatelessWidget {
  const Footer({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 800;
    final horizontalPadding = size.width * 0.08;

    return Container(
      color: Colors.black,
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 60),
      child: Column(
        children: [
          if (isMobile)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCompanyInfo(),
                const SizedBox(height: 40),
                _buildServices(),
                const SizedBox(height: 40),
                _buildLinks(),
                const SizedBox(height: 40),
                _buildSocialLinks(),
              ],
            )
          else
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(flex: 2, child: _buildCompanyInfo()),
                const SizedBox(width: 20),
                Flexible(child: _buildServices()),
                const SizedBox(width: 20),
                Flexible(child: _buildLinks()),
                const SizedBox(width: 20),
                Flexible(child: _buildSocialLinks()),
              ],
            ),
          const SizedBox(height: 40),
          const Divider(color: Colors.white24, thickness: 1),
          const SizedBox(height: 20),
          const Text("© 2026 MotoBuddy. All rights reserved.", style: TextStyle(color: Colors.white54)),
        ],
      ),
    );
  }

  Widget _buildCompanyInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          children: const [
            Icon(Icons.motorcycle, size: 30, color: Colors.yellow),
            SizedBox(width: 10),
            Text("MotoBuddy", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 20),
        const Text("Your 24/7 trusted vehicle companion.", style: TextStyle(color: Colors.white70, fontSize: 16)),
        const SizedBox(height: 20),
        const Text("123 Mechanic Street, Auto City\nsupport@motobuddy.com\n+91 98765 43210", 
          style: TextStyle(color: Colors.white54, height: 1.5)),
      ],
    );
  }

  Widget _buildServices() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text("Services", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        SizedBox(height: 15),
        Text("Emergency Breakdown\nOn-Demand Service\nGarage Products\nEV Solutions", 
          style: TextStyle(color: Colors.white54, height: 2.0)),
      ],
    );
  }

  Widget _buildLinks() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text("Company", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        SizedBox(height: 15),
        Text("About Us\nContact Us\nPrivacy Policy\nTerms & Conditions", 
          style: TextStyle(color: Colors.white54, height: 2.0)),
      ],
    );
  }

  Widget _buildSocialLinks() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Follow Us", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 15),
        Wrap(
          spacing: 15,
          runSpacing: 10,
          children: [
            _socialIcon(Icons.facebook),
            _socialIcon(Icons.camera_alt),
            _socialIcon(Icons.video_library),
          ],
        ),
      ],
    );
  }

  Widget _socialIcon(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: const BoxDecoration(
        color: Colors.white10,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: Colors.white, size: 20),
    );
  }
}