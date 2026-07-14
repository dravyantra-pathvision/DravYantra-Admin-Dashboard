import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../../../app/theme.dart';
import '../providers/live_provider.dart';

class LiveMapView extends StatefulWidget {
  const LiveMapView({super.key});

  @override
  State<LiveMapView> createState() => _LiveMapViewState();
}

class _LiveMapViewState extends State<LiveMapView> {
  final MapController _mapController = MapController();

  Color _getMarkerColor(String status, bool hasAlert) {
    if (hasAlert) return AdminTheme.danger;
    
    switch (status.toLowerCase()) {
      case 'moving': return AdminTheme.success;
      case 'idle': return AdminTheme.warning;
      case 'parked': return AdminTheme.info;
      case 'offline':
      default:
        return AdminTheme.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LiveProvider>(
      builder: (context, provider, child) {
        final vehicles = provider.vehicles;

        // Determine center. Use India center if no vehicles, otherwise average or first vehicle.
        LatLng center = const LatLng(20.5937, 78.9629);
        if (vehicles.isNotEmpty && provider.selectedVehicle != null) {
          final sv = provider.selectedVehicle!;
          if (sv['lat'] != null && sv['lng'] != null) {
            center = LatLng(sv['lat'], sv['lng']);
            // _mapController.move(center, 14.0); // Don't move on every refresh, just when selected. Wait, doing it in build can be tricky with flutter_map. We'll leave it static center for now unless implemented via listener.
          }
        }

        return FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: center,
            initialZoom: 5.0,
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
            ),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.dravyantra.admin',
            ),
            MarkerLayer(
              markers: vehicles.map((v) {
                final lat = v['lat'];
                final lng = v['lng'];
                if (lat == null || lng == null) return null;

                final color = _getMarkerColor(v['status'] ?? 'offline', v['has_critical_alert'] == true);
                final isSelected = provider.selectedVehicle?['plate'] == v['plate'];

                return Marker(
                  point: LatLng(lat, lng),
                  width: isSelected ? 60 : 40,
                  height: isSelected ? 60 : 40,
                  child: GestureDetector(
                    onTap: () {
                      provider.selectVehicle(v['plate']);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.2),
                        shape: BoxShape.circle,
                        border: Border.all(color: color, width: isSelected ? 3 : 2),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.directions_car,
                          color: color,
                          size: isSelected ? 28 : 20,
                        ),
                      ),
                    ),
                  ),
                );
              }).whereType<Marker>().toList(),
            ),
          ],
        );
      },
    );
  }
}
