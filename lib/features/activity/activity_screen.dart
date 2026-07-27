import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/fitness_provider.dart';
import '../../core/theme.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'walking_avatar_widget.dart';


class ActivityScreen extends StatefulWidget {
  const ActivityScreen({super.key});

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  final MapController _mapController = MapController();
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<FitnessProvider>(context, listen: false).fetchCurrentLocation();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = Provider.of<FitnessProvider>(context);

    // Auto-pan map to current location if available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (provider.activityPath.isNotEmpty) {
        _mapController.move(LatLng(provider.activityPath.last.latitude, provider.activityPath.last.longitude), 16.0);
      } else if (provider.currentLocation != null) {
        _mapController.move(LatLng(provider.currentLocation!.latitude, provider.currentLocation!.longitude), 16.0);
      }
    });

    // Format timer
    final int minutes = provider.activitySeconds ~/ 60;
    final int seconds = provider.activitySeconds % 60;
    final String timeStr = "${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";

    // Calculate Pace (min/km)
    double pace = 0.0;
    if (provider.activityDistance > 0) {
       pace = (provider.activitySeconds / 60) / provider.activityDistance;
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),
            // Lock icon on the right
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 48), // Spacer
                  Text(
                    timeStr,
                    style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: theme.brightness == Brightness.dark ? Colors.grey.shade800 : Colors.black87,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(24),
                        bottomLeft: Radius.circular(24),
                      ),
                    ),
                    child: const Icon(Icons.lock_outline, color: Colors.white),
                  )
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Animated Walking Avatar & Steps Circle
            Container(
              width: 170,
              height: 170,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.colorScheme.surface,
                border: Border.all(
                  color: provider.isTrackingActivity ? FitzaTheme.energyOrange : theme.colorScheme.primary.withValues(alpha: 0.3),
                  width: 6,
                ),
                boxShadow: [
                  if (provider.isTrackingActivity)
                    BoxShadow(
                      color: FitzaTheme.energyOrange.withValues(alpha: 0.35),
                      blurRadius: 20,
                      spreadRadius: 2,
                    )
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  WalkingAvatarWidget(
                    isWalking: provider.isTrackingActivity,
                    size: 130,
                  ),
                  Positioned(
                    bottom: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.75),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        "${provider.todaySteps} steps",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ).animate().scale(duration: 500.ms, curve: Curves.easeOutBack),
            ),
            const SizedBox(height: 12),
            Text(
              provider.isTrackingActivity ? "🚶 Walking Active..." : "Goal: ${provider.stepGoal} steps",
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: provider.isTrackingActivity ? FitzaTheme.energyOrange : Colors.grey,
              ),
            ),

            const SizedBox(height: 32),
            
            // Distance & Pace Row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("DISTANCE", style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text("${provider.activityDistance.toStringAsFixed(2)}", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                          const Text(" km", style: TextStyle(fontSize: 14, color: Colors.grey)),
                        ],
                      )
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text("AVG. PACE", style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(pace.toStringAsFixed(1), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                          const Text(" min/km", style: TextStyle(fontSize: 14, color: Colors.grey)),
                        ],
                      )
                    ],
                  ),
                ],
              ).animate().fade(duration: 500.ms, delay: 200.ms),
            ),
            const SizedBox(height: 24),
            
            // Live Map
            Expanded(
              child: Stack(
                children: [
                  if (provider.activityPath.isNotEmpty || provider.currentLocation != null)
                    FlutterMap(
                      mapController: _mapController,
                      options: MapOptions(
                        initialCenter: provider.activityPath.isNotEmpty 
                            ? LatLng(provider.activityPath.last.latitude, provider.activityPath.last.longitude)
                            : LatLng(provider.currentLocation!.latitude, provider.currentLocation!.longitude),
                        initialZoom: 16.0,
                        interactionOptions: const InteractionOptions(flags: InteractiveFlag.all & ~InteractiveFlag.rotate),
                      ),
                      children: [
                        TileLayer(
                          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.example.fitza',
                        ),
                        PolylineLayer(
                          polylines: [
                            Polyline(
                              points: provider.activityPath
                                  .map((p) => LatLng(p.latitude, p.longitude))
                                  .toList(),
                              color: FitzaTheme.energyOrange,
                              strokeWidth: 4.0,
                            ),
                          ],
                        ),
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: provider.activityPath.isNotEmpty
                                  ? LatLng(provider.activityPath.last.latitude, provider.activityPath.last.longitude)
                                  : LatLng(provider.currentLocation!.latitude, provider.currentLocation!.longitude),
                              width: 20,
                              height: 20,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 3),
                                  boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0,2))]
                                ),
                              ),
                            )
                          ],
                        ),
                      ],
                    )
                  else
                    Container(
                      width: double.infinity,
                      color: theme.brightness == Brightness.dark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                      child: const Center(child: Text("Location not available", style: TextStyle(color: Colors.grey))),
                    ),
                  // Top Fade
                  Positioned(
                    top: 0, left: 0, right: 0,
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter, end: Alignment.bottomCenter,
                          colors: [theme.scaffoldBackgroundColor, theme.scaffoldBackgroundColor.withValues(alpha: 0.0)],
                        )
                      ),
                    ),
                  ),
                  // Bottom Fade
                  Positioned(
                    bottom: 0, left: 0, right: 0,
                    child: Container(
                      height: 80,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter, end: Alignment.topCenter,
                          colors: [theme.scaffoldBackgroundColor, theme.scaffoldBackgroundColor.withValues(alpha: 0.0)],
                        )
                      ),
                    ),
                  )
                ],
              ),
            ),
            
            // Bottom Action Buttons
            Container(
              padding: const EdgeInsets.only(bottom: 40, top: 20),
              color: theme.scaffoldBackgroundColor,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildSideButton(Icons.directions_run, () {
                    if (!provider.isTrackingActivity) provider.startActivity("Running");
                  }, theme),
                  
                  // STOP Button
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      if (provider.isTrackingActivity) provider.stopActivity();
                    },
                    child: Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: provider.isTrackingActivity ? Colors.black : Colors.grey.shade400,
                        border: Border.all(
                          color: Colors.grey.withValues(alpha: 0.2),
                          width: 8,
                        )
                      ),
                      child: Center(
                        child: Text(
                          provider.isTrackingActivity ? "STOP" : "START",
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
                    ),
                  ),
                  
                  _buildSideButton(Icons.refresh, () {
                     provider.resetActivity();
                  }, theme, isSecondary: true),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildSideButton(IconData icon, VoidCallback onTap, ThemeData theme, {bool isSecondary = false}) {
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      borderRadius: BorderRadius.circular(30),
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
          color: theme.scaffoldBackgroundColor,
        ),
        child: Icon(
          icon,
          color: isSecondary ? FitzaTheme.energyOrange : Colors.grey.shade600,
        ),
      ),
    );
  }
}
