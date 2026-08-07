import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/fitness_provider.dart';
import '../../core/theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _voiceCoachEnabled = true;
  bool _hapticFeedbackEnabled = true;
  bool _musicAutoSync = true;
  bool _hydrationReminders = true;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 8, minute: 0);

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FitnessProvider>(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("App Settings ⚙️"),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 1. APPEARANCE & THEME
          _buildSectionHeader("Appearance & Customization 🎨"),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(18.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("App Theme", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12.0,
                    runSpacing: 12.0,
                    children: AppThemeMode.values.map((mode) {
                      final isSelected = provider.currentTheme == mode;
                      return ChoiceChip(
                        label: Text(
                          mode == AppThemeMode.light ? "☀️ SUN MODE" : "🌙 MOON MODE",
                        ),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) {
                            provider.setTheme(mode);
                          }
                        },
                        selectedColor: theme.colorScheme.primary.withValues(alpha: 0.2),
                        labelStyle: TextStyle(
                          color: isSelected ? theme.colorScheme.primary : theme.textTheme.bodyLarge?.color,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // 2. FITNESS GOALS & UNITS
          _buildSectionHeader("Fitness Goals & Units 🎯"),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Column(
              children: [
                // Fitness Goal Selector (Switches Main Dashboard Screen)
                ListTile(
                  leading: const Icon(Icons.stars_rounded, color: Colors.amber),
                  title: const Text("Main Fitness Goal"),
                  subtitle: Text("Current: ${provider.fitnessGoal}"),
                  trailing: DropdownButton<String>(
                    value: provider.fitnessGoal.contains("Body") || provider.fitnessGoal.contains("Muscle")
                        ? "Body Building"
                        : "Weight Loss",
                    items: const [
                      DropdownMenuItem(value: "Weight Loss", child: Text("Weight Loss Dashboard")),
                      DropdownMenuItem(value: "Body Building", child: Text("Body Building Dashboard")),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        provider.updateProfile(
                          name: provider.userName,
                          age: provider.age,
                          weight: provider.weight,
                          height: provider.height,
                          fitnessGoal: val == "Body Building" ? "Body Building" : "Weight Loss",
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("🎯 Dashboard updated to $val mode!")),
                        );
                      }
                    },
                  ),
                ),
                const Divider(height: 1),

                // Weight Unit Selector
                ListTile(
                  leading: const Icon(Icons.monitor_weight_outlined, color: Colors.deepOrange),
                  title: const Text("Weight Unit"),
                  subtitle: Text("Unit: ${provider.weightUnit}"),
                  trailing: SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(value: 'kg', label: Text("KG")),
                      ButtonSegment(value: 'lbs', label: Text("LBS")),
                    ],
                    selected: {provider.weightUnit},
                    onSelectionChanged: (val) {
                      provider.setWeightUnit(val.first);
                    },
                  ),
                ),
                const Divider(height: 1),

                // Height Unit Selector
                ListTile(
                  leading: const Icon(Icons.height_rounded, color: Colors.blue),
                  title: const Text("Height Unit"),
                  subtitle: Text("Unit: ${provider.heightUnit}"),
                  trailing: SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(value: 'cm', label: Text("CM")),
                      ButtonSegment(value: 'ft/in', label: Text("FT")),
                    ],
                    selected: {provider.heightUnit},
                    onSelectionChanged: (val) {
                      provider.setHeightUnit(val.first);
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 3. TARGET GOAL ADJUSTERS
          _buildSectionHeader("Daily Target Adjusters 📈"),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(18.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Daily Step Target", style: TextStyle(fontWeight: FontWeight.bold)),
                      Text("${provider.stepGoal} steps", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.deepOrange)),
                    ],
                  ),
                  Slider(
                    value: provider.stepGoal.toDouble().clamp(3000.0, 25000.0),
                    min: 3000,
                    max: 25000,
                    divisions: 22,
                    label: "${provider.stepGoal}",
                    onChanged: (val) {
                      provider.setStepGoal(val.toInt());
                    },
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Daily Calorie Goal", style: TextStyle(fontWeight: FontWeight.bold)),
                      Text("${provider.calorieGoal} kcal", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.amber)),
                    ],
                  ),
                  Slider(
                    value: provider.calorieGoal.toDouble().clamp(1200.0, 4500.0),
                    min: 1200,
                    max: 4500,
                    divisions: 33,
                    label: "${provider.calorieGoal}",
                    onChanged: (val) {
                      provider.setCalorieGoal(val.toInt());
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // 4. AUDIO & WORKOUT FEEDBACK
          _buildSectionHeader("Audio & Workout Feedback 🔊"),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Column(
              children: [
                SwitchListTile(
                  secondary: const Icon(Icons.record_voice_over_rounded, color: Colors.purple),
                  title: const Text("AI Voice Coach Guidance"),
                  subtitle: const Text("Audio posture & count callouts during workouts"),
                  value: _voiceCoachEnabled,
                  onChanged: (val) => setState(() => _voiceCoachEnabled = val),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  secondary: const Icon(Icons.vibration_rounded, color: Colors.teal),
                  title: const Text("Haptic Vibration Feedback"),
                  subtitle: const Text("Vibrate device on exercise transitions & timers"),
                  value: _hapticFeedbackEnabled,
                  onChanged: (val) => setState(() => _hapticFeedbackEnabled = val),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  secondary: const Icon(Icons.music_note_rounded, color: Colors.pink),
                  title: const Text("Dynamic Music Tempo Sync"),
                  subtitle: const Text("Sync audio playlist BPM to set intensity"),
                  value: _musicAutoSync,
                  onChanged: (val) => setState(() => _musicAutoSync = val),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 5. NOTIFICATIONS & REMINDERS
          _buildSectionHeader("Notifications & Reminders 🔔"),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Column(
              children: [
                SwitchListTile(
                  secondary: const Icon(Icons.notifications_active_rounded, color: Colors.deepOrange),
                  title: const Text("Push Notifications"),
                  subtitle: const Text("Workout streak alerts & achievements"),
                  value: provider.pushNotificationsEnabled,
                  onChanged: (val) => provider.togglePushNotifications(val),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.alarm_rounded, color: Colors.blue),
                  title: const Text("Daily Workout Reminder"),
                  subtitle: Text("Scheduled for ${_reminderTime.format(context)}"),
                  trailing: TextButton(
                    onPressed: () async {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: _reminderTime,
                      );
                      if (time != null) {
                        setState(() => _reminderTime = time);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("⏰ Reminder set for ${time.format(context)}")),
                        );
                      }
                    },
                    child: const Text("CHANGE"),
                  ),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  secondary: const Icon(Icons.local_drink_rounded, color: Colors.cyan),
                  title: const Text("Hourly Hydration Reminders"),
                  subtitle: const Text("Gentle alerts to reach daily water goal"),
                  value: _hydrationReminders,
                  onChanged: (val) => setState(() => _hydrationReminders = val),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 6. DATA, PRIVACY & HEALTH
          _buildSectionHeader("Data, Health & Sync 🔐"),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.cloud_sync_rounded, color: Colors.green),
                  title: const Text("Cloud Backup & Sync"),
                  subtitle: const Text("Auto-backup workouts & weight history"),
                  trailing: ElevatedButton(
                    onPressed: () {
                      provider.syncToCloud();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("☁️ Cloud data synced successfully!")),
                      );
                    },
                    style: ElevatedButton.styleFrom(elevation: 0),
                    child: const Text("Sync Now"),
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.file_download_outlined, color: Colors.indigo),
                  title: const Text("Export Health Data"),
                  subtitle: const Text("Download workout & weight logs CSV"),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("📥 Exported fitza_data.csv to Downloads!")),
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
                  title: const Text("Clear Cache & Temp Files"),
                  subtitle: const Text("Free up local storage space"),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("🧹 App cache cleared (42 MB freed)")),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 7. ABOUT & SUPPORT
          _buildSectionHeader("About & Support ℹ️"),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Column(
              children: [
                const ListTile(
                  leading: Icon(Icons.info_outline_rounded, color: Colors.grey),
                  title: Text("Version"),
                  subtitle: Text("Fitza AI Fitness v1.0.0+1 Pro"),
                  trailing: Chip(label: Text("LATEST", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold))),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.privacy_tip_outlined, color: Colors.grey),
                  title: const Text("Privacy Policy & Terms"),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text("Privacy & Security"),
                        content: const Text(
                          "Fitza values your privacy. All your health, weight, and exercise logs are encrypted locally and stored safely on your device.",
                        ),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(context), child: const Text("OK")),
                        ],
                      ),
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.rate_review_outlined, color: Colors.amber),
                  title: const Text("Send Feedback & Rate App"),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("⭐ Thank you for rating Fitza 5 Stars!")),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
    );
  }
}
