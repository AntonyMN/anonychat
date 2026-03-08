import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DemoBanner extends StatefulWidget {
  final String nextResetAt;

  const DemoBanner({super.key, required this.nextResetAt});

  @override
  State<DemoBanner> createState() => _DemoBannerState();
}

class _DemoBannerState extends State<DemoBanner> {
  String _countdown = '';
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _updateCountdown();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateCountdown();
    });
  }

  void _updateCountdown() {
    if (widget.nextResetAt.isEmpty) return;

    final now = DateTime.now();
    final target = DateTime.parse(widget.nextResetAt).toLocal();
    final diff = target.difference(now);

    if (diff.isNegative) {
      setState(() => _countdown = 'Refreshing...');
      return;
    }

    final hours = diff.inHours;
    final minutes = diff.inMinutes.remainder(60);
    final seconds = diff.inSeconds.remainder(60);

    setState(() {
      _countdown = '${hours}h ${minutes}m ${seconds}s';
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.amber.shade100.withOpacity(0.9),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.info_outline, size: 16, color: Colors.amber.shade900),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              'Demo: Resets in $_countdown',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.amber.shade900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
