import 'package:flutter/material.dart';

class DownloadOverlay extends StatelessWidget {
  const DownloadOverlay({super.key, this.progress = 1});

  final double progress;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        CircularProgressIndicator(
          value: progress,
          strokeWidth: 2.5,
          color: Colors.white,
          backgroundColor: Colors.white24,
        ),
        Text(
          '${(progress * 100).toInt()}%',
          style: const TextStyle(color: Colors.white, fontSize: 14),
        )
      ],
    );
  }
}
