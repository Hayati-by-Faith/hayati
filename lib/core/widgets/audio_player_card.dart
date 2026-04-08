import 'package:flutter/material.dart';

class AudioPlayerCard extends StatelessWidget {
  const AudioPlayerCard({
    super.key,
    required this.title,
    required this.subtitle,
    this.onPlay,
  });

  final String title;
  final String subtitle;
  final VoidCallback? onPlay;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.play_circle_outline),
        title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text(subtitle, maxLines: 2, overflow: TextOverflow.ellipsis),
        trailing: IconButton(
          onPressed: onPlay,
          icon: const Icon(Icons.play_arrow),
        ),
      ),
    );
  }
}

