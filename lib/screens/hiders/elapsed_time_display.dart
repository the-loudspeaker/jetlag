import 'dart:async';

import 'package:flutter/material.dart';

class ElapsedTimeDisplay extends StatefulWidget {
  final DateTime startTime;

  const ElapsedTimeDisplay({super.key, required this.startTime});

  @override
  State<ElapsedTimeDisplay> createState() => _ElapsedTimeDisplayState();
}

class _ElapsedTimeDisplayState extends State<ElapsedTimeDisplay> {
  late Timer _timer;
  late Duration _elapsedTime;

  @override
  void initState() {
    super.initState();
    _elapsedTime = DateTime.now().difference(widget.startTime);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _elapsedTime = DateTime.now().difference(widget.startTime);
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final durationTextStyle =
        (textTheme.displayMedium ??
                textTheme.headlineSmall ??
                const TextStyle(fontSize: 48))
            .copyWith(
              fontFamily: 'monospace',
              color: colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            );
    return Column(
      children: [
        Text(
          "Elapsed Time:",
          style:
              textTheme.bodyMedium?.copyWith(color: colorScheme.primary) ??
              TextStyle(fontSize: 16, color: colorScheme.primary),
        ),
        Text(_formatDuration(_elapsedTime), style: durationTextStyle),
      ],
    );
  }
}
