import 'package:flutter/material.dart';

class PlayerControls extends StatelessWidget {
  final VoidCallback onPlayPause;
  final VoidCallback onNext;
  final VoidCallback onPrevious;
  final bool isPlaying;

  const PlayerControls({
    Key? key,
    required this.onPlayPause,
    required this.onNext,
    required this.onPrevious,
    required this.isPlaying,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed: onPrevious,
          icon: const Icon(Icons.skip_previous),
          iconSize: 24,
        ),
        const SizedBox(width: 16),
        FloatingActionButton(
          onPressed: onPlayPause,
          child: Icon(
            isPlaying ? Icons.pause : Icons.play_arrow,
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        IconButton(
          onPressed: onNext,
          icon: const Icon(Icons.skip_next),
          iconSize: 24,
        ),
      ],
    );
  }
}
