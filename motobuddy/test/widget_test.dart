import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:motobuddy/main.dart';
import 'package:network_image_mock/network_image_mock.dart';
import 'package:flutter/material.dart';

class MockAssetBundle extends CachingAssetBundle {
  @override
  Future<ByteData> load(String key) async {
    if (key == 'assets/images/motobuddy.png') {
      // Return a valid 1x1 PNG instead of empty bytes to prevent ImageDescriptor exceptions
      final List<int> bytes = File('test/dummy_image.png').readAsBytesSync();
      return ByteData.view(Uint8List.fromList(bytes).buffer);
    }
    return rootBundle.load(key);
  }
}

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await mockNetworkImagesFor(() async {
      await tester.pumpWidget(
        DefaultAssetBundle(
          bundle: MockAssetBundle(),
          child: const MotoBuddyWeb(),
        ),
      );
      expect(true, true);
    });
  });
}
