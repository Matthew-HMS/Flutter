import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:audioplayers/audioplayers.dart';
import 'package:http/http.dart' as http;
import 'dart:io';

class LocalTTS {
  final FlutterTts flutterTts = FlutterTts();
  String _lastSpokenText = ""; // 儲存上次播放的文字

  Future<void> speak(String text) async {
    _lastSpokenText = text; // 儲存當前播放的文字
    await flutterTts.setLanguage("en-US"); // 設置語言為英文
    await flutterTts.setPitch(1.4); // 調整音調
    await flutterTts.setSpeechRate(0.4); // 語速設置為正常

    // 確保在平台執行緒上執行
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await flutterTts.speak(text);
    });
  }

  Future<void> pause() async {
    // 確保在平台執行緒上執行
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await flutterTts.pause(); // 暫停語音
    });
  }

  Future<void> resume() async {
    // 確保在平台執行緒上執行
    if (_lastSpokenText.isNotEmpty) {
      await speak(_lastSpokenText);
    }
  }

  Future<void> stop() async {
    // 確保在平台執行緒上執行
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await flutterTts.stop(); // 終止語音
    });
  }
}

class GptTTS {
  static String? secretKey = Platform.environment["OPENAI_API_KEY"];
  static const String inputModel = "tts-1";
  static const String inputVoice = "echo";
  static const String apiUrl = "https://api.openai.com/v1/audio/speech";
  static AudioPlayer? _audioPlayer; // 用來存儲 AudioPlayer 實例
  static Function? onAudioCompleteCallback; // 用來存儲回調函數

  

  // Function to convert text to speech and play it
  static Future<void> streamedAudio(String inputText,
      {String model = inputModel, String voice = inputVoice}) async {
    try {
      print("send tts request to openai ...");

      final headers = {
        "Authorization": "Bearer $secretKey",
        "Content-Type": "application/json",
      };

      final data = jsonEncode({
        "model": model,
        "input": inputText,
        "voice": voice,
        "response_format": "mp3",
      });

      final response = await http.post(Uri.parse(apiUrl),
          headers: headers, body: data);

      if (response.statusCode == 200) {
        final audioBytes = response.bodyBytes;

        _audioPlayer = AudioPlayer(); // 初始化 AudioPlayer
        await _audioPlayer!.play(BytesSource(audioBytes));

        // 監聽音頻播放完成事件
      _audioPlayer!.onPlayerComplete.listen((event) {
        _audioPlayer = null; // 釋放 AudioPlayer 資源
        print("finish playing audio");
        if (onAudioCompleteCallback != null) {
          onAudioCompleteCallback!(); // 調用回調函數
        }
      });

      } else {
        if (kDebugMode) {
          print('Error with HTTP request: ${response.statusCode} - ${response.reasonPhrase}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error in streamedAudio: $e');
      }
    }
  }

  // Function to stop the audio
  static Future<void> stopAudio() async {
    if (_audioPlayer != null) {
      await _audioPlayer!.stop(); // 停止音頻播放
      _audioPlayer = null; // 釋放 AudioPlayer 資源
      print("Audio stopped");
    } else {
      print("No audio playing");
    }
  }

  // 設置回調函數的靜態方法
  static void setAudioCompleteCallback(Function callback) {
    onAudioCompleteCallback = callback;
  }
}

