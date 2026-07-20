import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../../core/fitness_provider.dart';

class WeightAiScreen extends StatefulWidget {
  const WeightAiScreen({super.key});

  @override
  State<WeightAiScreen> createState() => _WeightAiScreenState();
}

class _WeightAiScreenState extends State<WeightAiScreen> {
  final ImagePicker _picker = ImagePicker();
  File? _image;
  bool _isScanning = false;
  double? _detectedWeight;

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
          _isScanning = true;
          _detectedWeight = null;
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
Analyze this image of a weighing scale. Estimate the weight shown.
Respond ONLY with a valid JSON object matching exactly this format (no markdown formatting, no code blocks):
{
  "weight": 75.5
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
            _detectedWeight = (data["weight"] as num?)?.toDouble();
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
    if (_detectedWeight != null) {
      final provider = Provider.of<FitnessProvider>(context, listen: false);
      provider.logWeight(
        _detectedWeight!,
        imagePath: _image?.path,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Weight logged successfully!"),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context); // Go back to progress screen
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("AI Weight Scanner", style: TextStyle(fontWeight: FontWeight.bold)),
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
                height: 300,
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
                            Icon(Icons.monitor_weight_outlined, size: 64, color: Colors.grey.shade400),
                            const SizedBox(height: 12),
                            const Text("No photo selected yet", style: TextStyle(color: Colors.grey)),
                            const SizedBox(height: 8),
                            const Text("Take a photo of your scale to log weight", style: TextStyle(color: Colors.grey, fontSize: 12)),
                          ],
                        ),
                      if (_isScanning)
                        Container(
                          color: Colors.black45,
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(color: Colors.white),
                              SizedBox(height: 16),
                              Text(
                                "Analyzing scale reading...",
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
              if (_detectedWeight != null) ...[
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
                          "Estimated Weight: $_detectedWeight kg",
                          style: TextStyle(fontSize: 22, color: theme.colorScheme.primary, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {
                                  setState(() {
                                    _image = null;
                                    _detectedWeight = null;
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
                                child: const Text("Log Weight"),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
