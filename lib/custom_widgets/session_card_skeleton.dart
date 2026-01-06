import 'package:flutter/material.dart';

class SessionCardSkeleton extends StatelessWidget {
  const SessionCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        color: Colors.grey.shade200,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _line(width: 160),
          const SizedBox(height: 8),
          _line(width: double.infinity),
          const SizedBox(height: 6),
          _line(width: 220),
          const SizedBox(height: 12),
          _line(width: 120),
        ],
      ),
    );
  }

  Widget _line({double? width}) {
    return Container(
      height: 14,
      width: width,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(6),
      ),
    );
  }
}
