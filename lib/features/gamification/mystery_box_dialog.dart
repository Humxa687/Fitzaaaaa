import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fitza/core/fitness_provider.dart';

class MysteryBoxDialog extends StatefulWidget {
  const MysteryBoxDialog({super.key});

  @override
  State<MysteryBoxDialog> createState() => _MysteryBoxDialogState();
}

class _MysteryBoxDialogState extends State<MysteryBoxDialog> {
  bool _isOpened = false;
  Map<String, dynamic>? _reward;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FitnessProvider>(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: const LinearGradient(
            colors: [Color(0xFF2E1C4B), Color(0xFF130924)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Daily Mystery Box 🎁",
              style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              _isOpened ? "Congratulations on your reward!" : "Tap the mystery box to unlock your daily reward!",
              style: const TextStyle(color: Colors.white70, fontSize: 13),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Animated Mystery Box Icon
            InkWell(
              onTap: _isOpened
                  ? null
                  : () {
                      setState(() {
                        _reward = provider.claimMysteryBox();
                        _isOpened = true;
                      });
                    },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.amber.withValues(alpha: 0.2),
                  border: Border.all(color: Colors.amber, width: 3),
                ),
                child: Center(
                  child: Text(
                    _isOpened ? (_reward?['icon'] ?? '🎁') : "🎁",
                    style: const TextStyle(fontSize: 60),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),
            if (_isOpened && _reward != null) ...[
              Text(
                "You Unlocked:",
                style: TextStyle(color: Colors.amber.shade200, fontSize: 12, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Text(
                _reward!['title']!,
                style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 20),
            ],

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Text(_isOpened ? "Claim Reward" : "Close"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
