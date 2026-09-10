import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../models/track.dart';

class AudioService extends ChangeNotifier {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final List<Track> _tracks = [];
  int _currentIndex = -1;
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  String? _errorMessage;

  AudioPlayer get audioPlayer => _audioPlayer;
  List<Track> get tracks => _tracks;
  int get currentIndex => _currentIndex;
  bool get isPlaying => _isPlaying;
  Duration get duration => _duration;
  Duration get position => _position;
  String? get errorMessage => _errorMessage;
  Track? get currentTrack => _currentIndex >= 0 && _currentIndex < _tracks.length ? _tracks[_currentIndex] : null;

  AudioService() {
    _setupAudioListeners();
  }

  void _setupAudioListeners() {
    _audioPlayer.playerStateStream.listen((state) {
      _isPlaying = state.playing;
      notifyListeners();
    });

    _audioPlayer.durationStream.listen((duration) {
      _duration = duration ?? Duration.zero;
      notifyListeners();
    });

    _audioPlayer.positionStream.listen((position) {
      _position = position;
      notifyListeners();
    });

    _audioPlayer.playerEventStream.listen((event) {
      if (event.processingState == ProcessingState.completed) {
        _playNext();
      }
    });
  }

  Future<void> addTracks(List<Track> newTracks) async {
    _tracks.addAll(newTracks);
    _errorMessage = null;
    if (_currentIndex == -1 && _tracks.isNotEmpty) {
      loadTrack(0, autoplay: false);
    }
    notifyListeners();
  }

  Future<void> loadTrack(int index, {required bool autoplay}) async {
    if (index < 0 || index >= _tracks.length) return;
    try {
      _currentIndex = index;
      await _audioPlayer.setFilePath(_tracks[index].path);
      _errorMessage = null;
      if (autoplay) {
        await _audioPlayer.play();
      }
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Could not load track: ${e.toString()}';
      notifyListeners();
    }
  }

  Future<void> play() async {
    if (_currentIndex == -1) {
      _errorMessage = 'Select a song from the playlist first.';
      notifyListeners();
      return;
    }
    try {
      await _audioPlayer.play();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Play failed: ${e.toString()}';
      notifyListeners();
    }
  }

  Future<void> pause() async {
    try {
      await _audioPlayer.pause();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Pause failed: ${e.toString()}';
      notifyListeners();
    }
  }

  Future<void> togglePlayPause() async {
    if (_isPlaying) {
      await pause();
    } else {
      await play();
    }
  }

  void _playNext() async {
    if (_tracks.isNotEmpty) {
      await loadTrack((_currentIndex + 1) % _tracks.length, autoplay: true);
    }
  }

  Future<void> playNext() async {
    _playNext();
  }

  Future<void> playPrevious() async {
    if (_tracks.isNotEmpty) {
      await loadTrack((_currentIndex - 1 + _tracks.length) % _tracks.length, autoplay: true);
    }
  }

  Future<void> seek(Duration position) async {
    try {
      await _audioPlayer.seek(position);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Seek failed: ${e.toString()}';
      notifyListeners();
    }
  }

  Future<void> removeTrack(int index) async {
    if (index < 0 || index >= _tracks.length) return;
    _tracks.removeAt(index);
    if (_currentIndex == index) {
      if (_tracks.isNotEmpty) {
        await loadTrack(0, autoplay: _isPlaying);
      } else {
        _currentIndex = -1;
        await _audioPlayer.stop();
      }
    } else if (_currentIndex > index) {
      _currentIndex--;
    }
    notifyListeners();
  }

  void clearTracks() async {
    _tracks.clear();
    _currentIndex = -1;
    await _audioPlayer.stop();
    notifyListeners();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}
