import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class VoiceInputScreen extends StatefulWidget {
  const VoiceInputScreen({super.key});

  @override
  State<VoiceInputScreen> createState() => _VoiceInputScreenState();
}

class _VoiceInputScreenState extends State<VoiceInputScreen> {
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _text = "Press the mic and start speaking";

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  // ✅ Only one listen function
  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (status) {
          if (status == 'done' || status == 'notListening') {
            if (mounted) {
              setState(() => _isListening = false);
            }
          }
        },
        onError: (errorNotification) {
          debugPrint('Speech error: $errorNotification');
          if (mounted) {
            setState(() => _isListening = false);
          }
        },
      );

      if (available) {
        setState(() => _isListening = true);

        // We remove localeId to allow it to pick the system default locale, 
        // which improves device support
        _speech.listen(
          onResult: (val) {
            setState(() {
              if (val.recognizedWords.isNotEmpty) {
                _text = val.recognizedWords;
              }
            });
          },
        );
      } else {
        setState(() {
          _isListening = false;
          _text = "Speech recognition not available on this device";
        });
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
      // We removed the auto Navigator.pop here to let the user review text and hit CONTINUE
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Voice Input"),
        backgroundColor: Colors.yellow,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 40),

            // Text Output
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                _text,
                style: const TextStyle(fontSize: 18),
              ),
            ),

            const SizedBox(height: 40),

            FloatingActionButton(
              backgroundColor:
                  _isListening ? Colors.red : Colors.yellow,
              onPressed: _listen,
              child: const Icon(
                Icons.mic,
                color: Colors.black,
              ),
            ),

            const SizedBox(height: 20),

            Text(
              _isListening ? "Listening..." : "Tap mic to speak",
              style: const TextStyle(fontSize: 16),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: (_text == "Press the mic and start speaking" || 
                            _text == "Speech recognition not available on this device" ||
                            _text.isEmpty || 
                            _isListening)
                    ? null 
                    : () => Navigator.pop(context, _text),
                icon: const Icon(Icons.send),
                label: const Text("CONTINUE", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.yellow,
                  foregroundColor: Colors.black,
                  disabledBackgroundColor: Colors.grey.shade300,
                  disabledForegroundColor: Colors.grey,
                  elevation: 5,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "Click continue to send transcribed text",
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}