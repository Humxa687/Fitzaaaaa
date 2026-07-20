import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../../core/fitness_provider.dart';
import '../../core/theme.dart';
import '../auth/login_screen.dart';
import 'settings_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _ageController;
  late TextEditingController _heightController;
  late TextEditingController _weightController;
  late TextEditingController _stepGoalController;
  late TextEditingController _calorieGoalController;

  bool _isEditing = false;
  bool _notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<FitnessProvider>(context, listen: false);
    _nameController = TextEditingController(text: provider.userName);
    _ageController = TextEditingController(text: "${provider.age}");
    _heightController = TextEditingController(text: "${provider.height}");
    _weightController = TextEditingController(text: "${provider.weight}");
    _stepGoalController = TextEditingController(text: "${provider.stepGoal}");
    _calorieGoalController = TextEditingController(text: "${provider.calorieGoal}");
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _stepGoalController.dispose();
    _calorieGoalController.dispose();
    super.dispose();
  }

  void _saveProfile() {
    final provider = Provider.of<FitnessProvider>(context, listen: false);
    provider.updateProfile(
      name: _nameController.text,
      age: int.tryParse(_ageController.text) ?? provider.age,
      height: double.tryParse(_heightController.text) ?? provider.height,
      weight: double.tryParse(_weightController.text) ?? provider.weight,
    );

    provider.updateGoals(
      steps: int.tryParse(_stepGoalController.text),
      calories: int.tryParse(_calorieGoalController.text),
    );

    setState(() {
      _isEditing = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Profile details updated successfully!")),
    );
  }

  Future<void> _pickImage(FitnessProvider provider) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      provider.updateProfilePicture(image.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FitnessProvider>(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Profile", style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.check : Icons.edit),
            onPressed: () {
              if (_isEditing) {
                _saveProfile();
              } else {
                setState(() {
                  _isEditing = true;
                });
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Avatar summary
              Center(
                child: Column(
                  children: [
                    InkWell(
                      onTap: () => _pickImage(provider),
                      borderRadius: BorderRadius.circular(50),
                      child: Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                            backgroundImage: provider.profileImagePath != null
                                ? FileImage(File(provider.profileImagePath!))
                                : null,
                            child: provider.profileImagePath == null
                                ? Icon(Icons.person, size: 50, color: theme.colorScheme.primary)
                                : null,
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary,
                              shape: BoxShape.circle,
                            ),
                            padding: const EdgeInsets.all(6),
                            child: const Icon(Icons.camera_alt, color: Colors.white, size: 16),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      provider.userName,
                      style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      provider.userEmail,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Inputs / Static Fields
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Personal Info", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 16),
                      _buildTextField("Full Name", _nameController, _isEditing, TextInputType.name),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(child: _buildTextField("Age", _ageController, _isEditing, TextInputType.number)),
                          const SizedBox(width: 16),
                          Expanded(child: _buildTextField("Height (cm)", _heightController, _isEditing, TextInputType.number)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildTextField("Weight (kg)", _weightController, _isEditing, TextInputType.number),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Targets Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Daily Targets", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(child: _buildTextField("Step Goal", _stepGoalController, _isEditing, TextInputType.number)),
                          const SizedBox(width: 16),
                          Expanded(child: _buildTextField("Calorie Target (kcal)", _calorieGoalController, _isEditing, TextInputType.number)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Settings & Smart Settings
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    children: [

                      SwitchListTile(
                        title: const Text("Smart Reminders", style: TextStyle(fontWeight: FontWeight.w500)),
                        subtitle: const Text("Daily step, workout, water intake reminders"),
                        value: _notificationsEnabled,
                        onChanged: (val) {
                          setState(() {
                            _notificationsEnabled = val;
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(val ? "Reminders enabled" : "Reminders muted")),
                          );
                        },
                        secondary: const Icon(Icons.notifications_active_outlined),
                      ),

                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Connected Apps
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: Text("Connected Apps", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                      SwitchListTile(
                        title: const Text("Google Fit"),
                        subtitle: const Text("Sync steps & calories"),
                        value: provider.isGoogleFitConnected,
                        onChanged: (val) async {
                          if (val) {
                            bool success = await provider.connectGoogleFit();
                            if (success) {
                              final Uri url = Uri.parse('https://play.google.com/store/apps/details?id=com.google.android.apps.fitness');
                              if (await canLaunchUrl(url)) {
                                await launchUrl(url, mode: LaunchMode.externalApplication);
                              }
                            } else if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Failed to connect Google Fit")));
                            }
                          } else {
                            await provider.disconnectGoogleFit();
                            if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Google Fit Disconnected")));
                          }
                        },
                        secondary: Image.asset("assets/images/google_fit.png", width: 32, height: 32, errorBuilder: (_,__,___) => const Icon(Icons.fitness_center)),
                      ),
                      const Divider(height: 1),
                      SwitchListTile(
                        title: const Text("Apple Health"),
                        subtitle: const Text("Sync steps & calories"),
                        value: provider.isAppleHealthConnected,
                        onChanged: (val) async {
                          if (val) {
                            bool success = await provider.connectAppleHealth();
                            if (success) {
                              // On iOS this would be deep linked to health settings
                              if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Open Health app to sync data")));
                            } else if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Failed to connect Apple Health")));
                            }
                          } else {
                            await provider.disconnectAppleHealth();
                            if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Apple Health Disconnected")));
                          }
                        },
                        secondary: const Icon(Icons.favorite, color: Colors.red),
                      ),
                      const Divider(height: 1),
                      SwitchListTile(
                        title: const Text("Samsung Health"),
                        subtitle: const Text("Sync steps & calories"),
                        value: provider.isSamsungHealthConnected,
                        onChanged: (val) async {
                          if (val) {
                            bool success = await provider.connectSamsungHealth();
                            if (success) {
                              final Uri url = Uri.parse('https://play.google.com/store/apps/details?id=com.sec.android.app.shealth');
                              if (await canLaunchUrl(url)) {
                                await launchUrl(url, mode: LaunchMode.externalApplication);
                              }
                            } else if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Failed to connect Samsung Health")));
                            }
                          } else {
                            await provider.disconnectSamsungHealth();
                            if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Samsung Health Disconnected")));
                          }
                        },
                        secondary: const Icon(Icons.health_and_safety, color: Colors.blue),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Sign Out Button
              ElevatedButton(
                onPressed: () => provider.logout(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade50,
                  foregroundColor: Colors.red,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text("Sign Out", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, bool isEditing, TextInputType keyboardType) {
    return TextFormField(
      controller: controller,
      enabled: isEditing,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        disabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey.shade300)),
        contentPadding: const EdgeInsets.symmetric(vertical: 8),
      ),
    );
  }
}
