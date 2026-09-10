import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../services/audio_service.dart';
import '../models/track.dart';
import '../widgets/player_controls.dart';
import '../widgets/playlist_view.dart';

class MusicPlayerScreen extends StatefulWidget {
  const MusicPlayerScreen({Key? key}) : super(key: key);

  @override
  State<MusicPlayerScreen> createState() => _MusicPlayerScreenState();
}

class _MusicPlayerScreenState extends State<MusicPlayerScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Local Music Player'),
        elevation: 0,
        centerTitle: true,
      ),
      body: Consumer<AudioService>(
        builder: (context, audioService, _) {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Add Files Button
                  GestureDetector(
                    onTap: _pickAudioFiles,
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Theme.of(context).dividerColor,
                          width: 1.5,
                          style: BorderStyle.solid,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add,
                            size: 20,
                            color: Theme.of(context).hintColor,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Tap to add audio files',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).hintColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Player Card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Now playing',
                            style: Theme.of(context).textTheme.labelSmall,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            audioService.currentTrack?.name ?? 'Nothing selected',
                            style: Theme.of(context).textTheme.titleMedium,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 14),
                          // Progress Bar
                          Row(
                            children: [
                              Text(
                                _formatDuration(audioService.position),
                                style: Theme.of(context).textTheme.labelSmall,
                              ),
                              Expanded(
                                child: Slider(
                                  value: audioService.duration.inMilliseconds > 0
                                      ? audioService.position.inMilliseconds / audioService.duration.inMilliseconds * 100
                                      : 0,
                                  min: 0,
                                  max: 100,
                                  onChanged: (value) {
                                    if (audioService.duration.inMilliseconds > 0) {
                                      audioService.seek(
                                        Duration(
                                          milliseconds: (value / 100 * audioService.duration.inMilliseconds).toInt(),
                                        ),
                                      );
                                    }
                                  },
                                ),
                              ),
                              Text(
                                _formatDuration(audioService.duration),
                                style: Theme.of(context).textTheme.labelSmall,
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          // Player Controls
                          PlayerControls(
                            onPlayPause: audioService.togglePlayPause,
                            onNext: audioService.playNext,
                            onPrevious: audioService.playPrevious,
                            isPlaying: audioService.isPlaying,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Error Message
                  if (audioService.errorMessage != null)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.errorContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        audioService.errorMessage!,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),
                  // Playlist
                  if (audioService.tracks.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        'No songs added yet.',
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    )
                  else
                    PlaylistView(
                      tracks: audioService.tracks,
                      currentIndex: audioService.currentIndex,
                      onTrackTap: (index) => audioService.loadTrack(index, autoplay: true),
                      onTrackRemove: (index) => audioService.removeTrack(index),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _pickAudioFiles() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.audio,
        allowMultiple: true,
      );

      if (result != null && result.files.isNotEmpty) {
        final audioService = context.read<AudioService>();
        final tracks = result.files
            .map(
              (file) => Track(
                name: file.name.replaceAll(RegExp(r'\.[^/.]+$'), ''),
                path: file.path ?? '',
                id: file.name,
              ),
            )
            .toList();
        await audioService.addTracks(tracks);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking files: $e')),
        );
      }
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return '${duration.inHours > 0 ? '${duration.inHours}:' : ''}$twoDigitMinutes:$twoDigitSeconds';
  }
}
