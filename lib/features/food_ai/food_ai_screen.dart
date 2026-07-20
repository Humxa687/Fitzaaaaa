import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../../core/fitness_provider.dart';
import '../../core/theme.dart';

class FoodAiScreen extends StatefulWidget {
  const FoodAiScreen({super.key});

  @override
  State<FoodAiScreen> createState() => _FoodAiScreenState();
}

class _FoodAiScreenState extends State<FoodAiScreen> {
  final ImagePicker _picker = ImagePicker();
  File? _image;
  bool _isScanning = false;
  String? _detectedFood;
  int? _calories;
  double? _protein;
  double? _carbs;
  double? _fat;

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
          _isScanning = true;
          _detectedFood = null;
        });

        // Call Gemini API
        final provider = Provider.of<FitnessProvider>(context, listen: false);
        final apiKey = provider.geminiApiKey;
        if (apiKey == null || apiKey.isEmpty) {
          setState(() {
            _isScanning = false;
            _image = null;
          });
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Please set your Gemini API Key in the Dashboard Settings first.")),
            );
          }
          return;
        }

        final model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: apiKey);
        final imageBytes = await _image!.readAsBytes();
        
        final prompt = TextPart('''
Analyze this food image. Estimate its nutritional value.
Respond ONLY with a valid JSON object matching exactly this format (no markdown formatting, no code blocks):
{
  "name": "Food Name",
  "calories": 400,
  "protein": 20.5,
  "carbs": 45.0,
  "fat": 15.0
}
''');
        final imageParts = [
          DataPart('image/jpeg', imageBytes),
        ];
        
        final response = await model.generateContent([
          Content.multi([prompt, ...imageParts])
        ]);
        
        final responseText = response.text?.trim() ?? '{}';
        String jsonStr = responseText;
        if (jsonStr.startsWith('```json')) {
           jsonStr = jsonStr.replaceAll('```json', '').replaceAll('```', '').trim();
        } else if (jsonStr.startsWith('```')) {
           jsonStr = jsonStr.replaceAll('```', '').trim();
        }

        try {
          final data = jsonDecode(jsonStr);
          setState(() {
            _isScanning = false;
            _detectedFood = data["name"] ?? "Unknown Food";
            _calories = (data["calories"] as num?)?.toInt() ?? 0;
            _protein = (data["protein"] as num?)?.toDouble() ?? 0.0;
            _carbs = (data["carbs"] as num?)?.toDouble() ?? 0.0;
            _fat = (data["fat"] as num?)?.toDouble() ?? 0.0;
          });
        } catch (e) {
          setState(() {
            _isScanning = false;
          });
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Could not parse AI response. Try again.")),
            );
          }
        }
      }
    } catch (e) {
      setState(() {
        _isScanning = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
    }
  }

  void _saveLog() {
    if (_detectedFood != null && _calories != null) {
      final provider = Provider.of<FitnessProvider>(context, listen: false);
      provider.logFood(
        _detectedFood!,
        _calories!,
        _protein ?? 0.0,
        _carbs ?? 0.0,
        _fat ?? 0.0,
        imagePath: _image?.path,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Calorie log saved successfully!"),
          backgroundColor: Colors.green,
        ),
      );

      setState(() {
        _image = null;
        _detectedFood = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = Provider.of<FitnessProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("AI Calorie Scanner", style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Scanner container / view
              Container(
                height: 280,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: _isScanning ? theme.colorScheme.primary : Colors.grey.withValues(alpha: 0.2),
                    width: 2,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      if (_image != null)
                        Image.file(_image!, fit: BoxFit.cover, width: double.infinity, height: double.infinity)
                      else
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.camera_alt_outlined, size: 64, color: Colors.grey.shade400),
                            const SizedBox(height: 12),
                            const Text("No food photo selected yet", style: TextStyle(color: Colors.grey)),
                            const SizedBox(height: 8),
                            const Text("Take a photo of your dish to estimate calories", style: TextStyle(color: Colors.grey, fontSize: 12)),
                          ],
                        ),
                      if (_isScanning)
                        Container(
                          color: Colors.black45,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const CircularProgressIndicator(color: Colors.white),
                              const SizedBox(height: 16),
                              const Text(
                                "Analyzing food nutrients using AI...",
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Estimating calories & macros",
                                style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Scanner Actions
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _pickImage(ImageSource.camera),
                      icon: const Icon(Icons.camera_alt),
                      label: const Text("Take Photo"),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _pickImage(ImageSource.gallery),
                      icon: const Icon(Icons.photo_library),
                      label: const Text("Gallery"),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Recognition Results
              if (_detectedFood != null) ...[
                Card(
                  color: theme.colorScheme.primary.withValues(alpha: 0.06),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("AI Estimation Results", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                            const Icon(Icons.check_circle, color: Colors.green),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _detectedFood!,
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Estimated Calories: $_calories kcal",
                          style: TextStyle(fontSize: 18, color: theme.colorScheme.primary, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        const Text("Macronutrients:", style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildMacroBadge("Protein", "${_protein}g", Colors.redAccent),
                            _buildMacroBadge("Carbs", "${_carbs}g", Colors.orange),
                            _buildMacroBadge("Fat", "${_fat}g", Colors.blue),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {
                                  setState(() {
                                    _image = null;
                                    _detectedFood = null;
                                  });
                                },
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                child: const Text("Cancel"),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: _saveLog,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: theme.colorScheme.primary,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                child: const Text("Save Log"),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // History list
              Text("Calorie logs history", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              if (provider.foodLogs.isEmpty)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Center(
                      child: Text(
                        "No food logs added today",
                        style: TextStyle(color: Colors.grey.shade500),
                      ),
                    ),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: provider.foodLogs.length,
                  itemBuilder: (context, index) {
                    final log = provider.foodLogs[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.restaurant, color: FitzaTheme.primaryDark),
                        ),
                        title: Text(log.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text("P: ${log.protein}g  C: ${log.carbs}g  F: ${log.fat}g"),
                        trailing: Text(
                          "${log.calories} kcal",
                          style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.primary, fontSize: 16),
                        ),
                      ),
                    );
                  },
                ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMacroBadge(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
