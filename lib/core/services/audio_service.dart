import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AudioService {
  final AudioPlayer _player = AudioPlayer();

  Future<void> playClick() async {
    try {
      await _player.play(
        AssetSource('sounds/click.mp3'),
        volume: 0.5,
      );
    } catch (_) {}
  }

  Future<void> playSuccess() async {
    try {
      await _player.play(
        AssetSource('sounds/success.mp3'),
        volume: 0.7,
      );
    } catch (_) {}
  }

  Future<void> playCorrect() async {
    try {
      await _player.play(
        AssetSource('sounds/correct.mp3'),
        volume: 0.7,
      );
    } catch (_) {}
  }

  Future<void> playWrong() async {
    try {
      await _player.play(
        AssetSource('sounds/wrong.mp3'),
        volume: 0.6,
      );
    } catch (_) {}
  }

  void dispose() {
    _player.dispose();
  }
}

final audioServiceProvider = Provider<AudioService>((ref) {
  final service = AudioService();
  ref.onDispose(() => service.dispose());
  return service;
});