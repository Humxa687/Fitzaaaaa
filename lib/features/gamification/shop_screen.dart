import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fitza/core/fitness_provider.dart';

class ShopScreen extends StatelessWidget {
  const ShopScreen({super.key});

  final List<Map<String, dynamic>> shopItems = const [
    {'id': 'streak_freeze', 'name': 'Streak Freeze', 'cost': 150, 'icon': '🛡️', 'desc': 'Protect 1 missed day'},
    {'id': 'pet_hoodie', 'name': 'Gym Hoodie Outfit', 'cost': 300, 'icon': '🥋', 'desc': 'Equip to your Fit Pet'},
    {'id': 'theme_cyber', 'name': 'Neon Cyber Theme', 'cost': 500, 'icon': '🎨', 'desc': 'Unlock futuristic UI accent'},
    {'id': 'voice_beast', 'name': 'Beast AI Voice', 'cost': 450, 'icon': '🎙️', 'desc': 'Hardcore workout voice pack'},
    {'id': 'avatar_golden_armor', 'name': 'Golden Armor Skin', 'cost': 800, 'icon': '👑', 'desc': 'Legendary character skin'},
  ];

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FitnessProvider>(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Fitza Coins Shop 💰"),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Text("💰 ", style: TextStyle(fontSize: 14)),
                Text(
                  "${provider.coins}",
                  style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(20),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.85,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: shopItems.length,
        itemBuilder: (context, idx) {
          final item = shopItems[idx];
          final bool owned = provider.ownedShopItems.contains(item['id']);

          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.amber.withValues(alpha: 0.25)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(item['icon']!, style: const TextStyle(fontSize: 42)),
                const SizedBox(height: 8),
                Text(
                  item['name']!,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  item['desc']!,
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
                  textAlign: TextAlign.center,
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: owned
                        ? null
                        : () {
                            bool success = provider.buyShopItem(item['id']!, item['cost'] as int);
                            if (success) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("🎉 Purchased ${item['name']}!")),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("⚠️ Not enough coins!")),
                              );
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: Text(owned ? "OWNED" : "💰 ${item['cost']}"),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
