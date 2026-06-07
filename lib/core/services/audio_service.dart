import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/app_settings_provider.dart';

class AudioService {
  final AudioPlayer _player = AudioPlayer();
  bool enabled = true;

  Future<void> playClick() async {
    if (!enabled) return;
    try {
      await _player.play(AssetSource('sounds/click.mp3'), volume: 0.5);
    } catch (_) {}
  }

  Future<void> playSuccess() async {
    if (!enabled) return;
    try {
      await _player.play(AssetSource('sounds/success.mp3'), volume: 0.7);
    } catch (_) {}
  }

  Future<void> playCorrect() async {
    if (!enabled) return;
    try {
      await _player.play(AssetSource('sounds/correct.mp3'), volume: 0.7);
    } catch (_) {}
  }

  Future<void> playWrong() async {
    if (!enabled) return;
    try {
      await _player.play(AssetSource('sounds/wrong.mp3'), volume: 0.6);
    } catch (_) {}
  }

  void dispose() {
    _player.dispose();
  }
}

final audioServiceProvider = Provider<AudioService>((ref) {
  final service = AudioService();
  ref.onDispose(() => service.dispose());

  // Đồng bộ cờ enabled mỗi khi settings thay đổi
  ref.listen(appSettingsProvider, (_, next) {
    service.enabled = next.valueOrNull?.soundEnabled ?? true;
  });

  return service;
});
