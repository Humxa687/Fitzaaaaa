import 'package:flutter/material.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  final List<Map<String, dynamic>> leaderboard = const [
    {'rank': 1, 'name': 'Alex Fit', 'score': '1,450 Reps', 'avatar': '👑', 'isUser': true},
    {'rank': 2, 'name': 'Marcus Vance', 'score': '1,320 Reps', 'avatar': '🔥', 'isUser': false},
    {'rank': 3, 'name': 'Elena Rostova', 'score': '1,180 Reps', 'avatar': '⚡', 'isUser': false},
    {'rank': 4, 'name': 'David Chen', 'score': '950 Reps', 'avatar': '💪', 'isUser': false},
    {'rank': 5, 'name': 'Sarah Connor', 'score': '890 Reps', 'avatar': '🌟', 'isUser': false},
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Weekly Leaderboard 🏆"),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          bottom: const TabBar(
            tabs: [
              Tab(text: "Most Reps"),
              Tab(text: "Calories Burned"),
              Tab(text: "Streak Kings"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildLeaderboardList(context, isDark),
            _buildLeaderboardList(context, isDark),
            _buildLeaderboardList(context, isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildLeaderboardList(BuildContext context, bool isDark) {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: leaderboard.length,
      itemBuilder: (context, idx) {
        final user = leaderboard[idx];
        final bool isUser = user['isUser'] as bool;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: isUser ? const BorderSide(color: Colors.amber, width: 2) : BorderSide.none,
          ),
          color: isUser
              ? (isDark ? const Color(0xFF2A2338) : Colors.amber.shade50)
              : (isDark ? const Color(0xFF1E1E2E) : Colors.white),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: CircleAvatar(
              backgroundColor: idx == 0
                  ? Colors.amber
                  : idx == 1
                      ? Colors.grey.shade400
                      : idx == 2
                          ? Colors.brown.shade300
                          : Colors.grey.shade700,
              child: Text(
                "#${user['rank']}",
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            title: Row(
              children: [
                Text(user['name'] as String, style: const TextStyle(fontWeight: FontWeight.bold)),
                if (isUser)
                  Container(
                    margin: const EdgeInsets.only(left: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.amber,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text("YOU", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black)),
                  ),
              ],
            ),
            subtitle: Text(user['avatar'] as String),
            trailing: Text(
              user['score'] as String,
              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: Colors.deepOrange),
            ),
          ),
        );
      },
    );
  }
}
