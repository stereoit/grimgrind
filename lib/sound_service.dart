import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

import 'theme_package.dart';

/// Abstraction over audio playback so [SoundService] can be tested without
/// platform audio channels.
abstract class SoundBackend {
  Future<void> playEffect(String assetPath, {double volume = 1.0});
  Future<void> playLoop(String assetPath, {double volume = 0.45});
  Future<void> stopLoop();
  Future<void> dispose();
}

/// Default [SoundBackend] backed by `audioplayers`.
class AudioPlayersSoundBackend implements SoundBackend {
  AudioPlayersSoundBackend({int sfxPoolSize = 3}) : _sfxPoolSize = sfxPoolSize;

  final int _sfxPoolSize;
  final List<AudioPlayer> _sfxPool = <AudioPlayer>[];
  int _sfxCursor = 0;
  AudioPlayer? _musicPlayer;

  String _toAssetSourcePath(String assetPath) =>
      assetPath.startsWith('assets/')
          ? assetPath.substring('assets/'.length)
          : assetPath;

  AudioPlayer _nextSfxPlayer() {
    if (_sfxPool.length < _sfxPoolSize) {
      final player = AudioPlayer();
      _sfxPool.add(player);
      return player;
    }
    final player = _sfxPool[_sfxCursor % _sfxPool.length];
    _sfxCursor = (_sfxCursor + 1) % _sfxPool.length;
    return player;
  }

  @override
  Future<void> playEffect(String assetPath, {double volume = 1.0}) async {
    try {
      final player = _nextSfxPlayer();
      await player.stop();
      await player.play(
        AssetSource(_toAssetSourcePath(assetPath)),
        volume: volume,
      );
    } catch (_) {
      // Ignore audio errors in headless/test environments without audio plugins.
    }
  }

  @override
  Future<void> playLoop(String assetPath, {double volume = 0.45}) async {
    try {
      _musicPlayer ??= AudioPlayer();
      await _musicPlayer!.setReleaseMode(ReleaseMode.loop);
      await _musicPlayer!.play(
        AssetSource(_toAssetSourcePath(assetPath)),
        volume: volume,
      );
    } catch (_) {
      // Ignore audio errors in headless/test environments without audio plugins.
    }
  }

  @override
  Future<void> stopLoop() async {
    try {
      await _musicPlayer?.stop();
    } catch (_) {
      // Ignore audio errors in headless/test environments without audio plugins.
    }
  }

  @override
  Future<void> dispose() async {
    try {
      await _musicPlayer?.dispose();
      _musicPlayer = null;
      for (final player in _sfxPool) {
        await player.dispose();
      }
      _sfxPool.clear();
    } catch (_) {
      // Ignore audio errors during disposal.
    }
  }
}

/// Centralized game audio controller whose sound assets come from the active
/// [GameThemePackage].
class SoundService {
  SoundService({
    SoundBackend? backend,
    GameThemePackage? initialTheme,
  })  : _backend = backend ?? AudioPlayersSoundBackend(),
        _theme = initialTheme ?? ThemeRegistry.gothicMansion;

  static final SoundService instance = SoundService();

  SoundBackend _backend;
  GameThemePackage _theme;
  bool _isMuted = false;
  bool _isIntroPlaying = false;
  String? _activeIntroAsset;

  GameThemePackage get theme => _theme;
  bool get isMuted => _isMuted;
  bool get isIntroPlaying => _isIntroPlaying;

  @visibleForTesting
  void setBackendForTesting(SoundBackend backend) {
    _backend = backend;
  }

  @visibleForTesting
  void resetForTesting() {
    _backend = AudioPlayersSoundBackend();
    _theme = ThemeRegistry.gothicMansion;
    _isMuted = false;
    _isIntroPlaying = false;
    _activeIntroAsset = null;
  }

  /// Updates the active theme package; if intro music is playing and the new
  /// theme uses a different intro track, switches to it seamlessly.
  Future<void> updateTheme(GameThemePackage newTheme) async {
    _theme = newTheme;
    if (_isIntroPlaying &&
        !_isMuted &&
        _activeIntroAsset != newTheme.soundPack.introMusic) {
      _activeIntroAsset = newTheme.soundPack.introMusic;
      await _backend.playLoop(_activeIntroAsset!, volume: 0.45);
    }
  }

  Future<void> setMuted(bool muted) async {
    _isMuted = muted;
    if (muted && _isIntroPlaying) {
      await stopIntroMusic();
    }
  }

  Future<void> startIntroMusic() async {
    if (_isMuted) return;
    final asset = _theme.soundPack.introMusic;
    if (_isIntroPlaying && _activeIntroAsset == asset) return;
    _isIntroPlaying = true;
    _activeIntroAsset = asset;
    await _backend.playLoop(asset, volume: 0.45);
  }

  Future<void> stopIntroMusic() async {
    if (!_isIntroPlaying) return;
    _isIntroPlaying = false;
    _activeIntroAsset = null;
    await _backend.stopLoop();
  }

  Future<void> playOpenDeck() async {
    if (_isMuted) return;
    await _backend.playEffect(_theme.soundPack.openDeck, volume: 0.85);
  }

  Future<void> playCard() async {
    if (_isMuted) return;
    await _backend.playEffect(_theme.soundPack.playCard, volume: 0.95);
  }

  Future<void> playConvertCoins() async {
    if (_isMuted) return;
    await _backend.playEffect(_theme.soundPack.convertCoins, volume: 0.95);
  }

  Future<void> playButtonTap() async {
    if (_isMuted) return;
    await _backend.playEffect(_theme.soundPack.buttonTap, volume: 0.55);
  }

  Future<void> dispose() => _backend.dispose();
}

/// Wraps a button callback so touching it plays the theme's button tap sound.
VoidCallback? withButtonSound(VoidCallback? onPressed) {
  if (onPressed == null) return null;
  return () {
    SoundService.instance.playButtonTap();
    onPressed();
  };
}

/// Wraps a value-callback (e.g. [FilterChip.onSelected] or
/// [NavigationBar.onDestinationSelected]) with the theme's button tap sound.
ValueChanged<T>? withButtonSound1<T>(ValueChanged<T>? onChanged) {
  if (onChanged == null) return null;
  return (value) {
    SoundService.instance.playButtonTap();
    onChanged(value);
  };
}
