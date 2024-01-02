import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_gemini/flutter_gemini.dart';

void main() {
  // Generation Configuration
  final config = GenerationConfig(
      temperature: 0.1,
      maxOutputTokens: 150,
      topP: 1.0,
      topK: 40,
      stopSequences: ['enough']);
  Gemini.init(
      apiKey: 'AIzaSyAvAA9dTX_1A-2PBShsTqQKcPvD7e0QLzM',
      generationConfig: config);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: Colors.green,
        colorScheme: ColorScheme.fromSwatch().copyWith(secondary: Colors.white),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Talk2Me'),
        ),
        body: const SpeechScreen(),
      ),
    );
  }
}

class SpeechScreen extends StatefulWidget {
  const SpeechScreen({Key? key}) : super(key: key);

  @override
  _SpeechScreenState createState() => _SpeechScreenState();
}

class _SpeechScreenState extends State<SpeechScreen> {
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _text = '';
  String _response = '';

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  Future<void> generateResponse(String prompt) async {
    final gemini = Gemini.instance;
    final response = await gemini.text("Context:" +
        "Role:Leo, a friendly and encouraging AI Assistant: Designed to help spoken English learners improve their conversation skills.Leo is a personalized English practice partner, offering gentle corrections, engaging conversation prompts, and motivating feedback." +
        "Prompt:" +
        prompt);
    setState(() {
      _response = response?.output ?? '';
    });
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) {
          print('onStatus: $val');
          if (val == 'notListening') {
            generateResponse(_text);
          }
        },
        onError: (val) => print('onError: $val'),
      );
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) {
            setState(() {
              _text = val.recognizedWords;
            });
          },
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            reverse: true,
            child: Container(
              padding: const EdgeInsets.fromLTRB(30.0, 30.0, 30.0, 150.0),
              child: Text(_text,
                  style: const TextStyle(fontSize: 32.0, color: Colors.black)),
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          color: Colors.green,
          child: Row(
            children: <Widget>[
              Expanded(
                child: Text(_response,
                    style:
                        const TextStyle(fontSize: 20.0, color: Colors.white)),
              ),
              IconButton(
                icon: Icon(Icons.mic,
                    color: _isListening ? Colors.orange : Colors.blue),
                onPressed: _listen,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
