import 'package:flutter/material.dart';

class DeathScreen extends StatelessWidget {
  const DeathScreen({
    super.key,
    required this.lostEssence,
    required this.targetStreak,
  });

  final int lostEssence;
  final int targetStreak;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF120909),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'YOU DIED',
                style: TextStyle(
                  color: Color(0xFFF05B5B),
                  fontSize: 52,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  // ignore: deprecated_member_use
                  color: Colors.black.withOpacity(0.25),
                  border:
                      Border.all(color: const Color(0xFF8E2A2A), width: 0.8),
                ),
                child: Column(
                  children: [
                    Text(
                      'Lost Essence: $lostEssence',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Target streak: $targetStreak',
                      style: const TextStyle(
                        color: Color(0xFFCFD3D9),
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Rise again and reclaim your lost Essence by reaching the target streak.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFFE3E7EC),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
