import 'package:flutter/material.dart';
import '../models/track.dart';

class PlaylistView extends StatelessWidget {
  final List<Track> tracks;
  final int currentIndex;
  final Function(int) onTrackTap;
  final Function(int) onTrackRemove;

  const PlaylistView({
    Key? key,
    required this.tracks,
    required this.currentIndex,
    required this.onTrackTap,
    required this.onTrackRemove,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: tracks.length,
      itemBuilder: (context, index) {
        final track = tracks[index];
        final isCurrentTrack = index == currentIndex;

        return ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
          title: Text(
            '${index + 1}',
            style: Theme.of(context).textTheme.labelSmall,
          ),
          subtitle: Text(
            track.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: isCurrentTrack ? Theme.of(context).colorScheme.primary : null,
            ),
          ),
          onTap: () => onTrackTap(index),
          trailing: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => onTrackRemove(index),
            iconSize: 18,
          ),
        );
      },
    );
  }
}
