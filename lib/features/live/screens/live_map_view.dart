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

  void _centerMapOnVehicle(double lat, double lng) {
    _mapController.move(LatLng(lat, lng), 15.0);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LiveProvider>(
      builder: (context, provider, child) {
        final vehicles = provider.vehicles;
        final selectedVehicle = provider.selectedVehicle;

        // Default center on India if no vehicle selected
        LatLng center = const LatLng(20.5937, 78.9629);
        if (selectedVehicle != null && selectedVehicle['lat'] != null && selectedVehicle['lng'] != null) {
          center = LatLng(selectedVehicle['lat'], selectedVehicle['lng']);
        }

        return Stack(
          children: [
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: center,
                initialZoom: selectedVehicle != null ? 14.0 : 5.0,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                ),
              ),
              children: [
                // English-only CARTO Voyager Map Tiles (latin labels only)
                TileLayer(
                  urlTemplate: 'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png',
                  subdomains: const ['a', 'b', 'c', 'd'],
                  userAgentPackageName: 'com.dravyantra.admin',
                ),

                // Vehicle Trackers & Custom Labels
                MarkerLayer(
                  markers: vehicles.map((v) {
                    final lat = v['lat'];
                    final lng = v['lng'];
                    if (lat == null || lng == null) return null;

                    final String plate = v['plate'] ?? v['registration_number'] ?? 'Vehicle';
                    final String status = (v['status'] ?? 'offline').toString().toUpperCase();
                    final double speed = double.tryParse((v['speed'] ?? 0).toString()) ?? 0.0;
                    final bool isSelected = selectedVehicle?['plate'] == plate;
                    final Color color = _getMarkerColor(v['status'] ?? 'offline', v['has_critical_alert'] == true);

                    return Marker(
                      point: LatLng(lat, lng),
                      width: 140,
                      height: 70,
                      alignment: Alignment.topCenter,
                      child: GestureDetector(
                        onTap: () {
                          provider.selectVehicle(plate);
                          _centerMapOnVehicle(lat, lng);
                        },
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Plate & Speed Chip Header
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: isSelected ? AdminTheme.primary : AdminTheme.textPrimary,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 6,
                                    height: 6,
                                    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    plate,
                                    style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                  ),
                                  if (speed > 0) ...[
                                    const SizedBox(width: 4),
                                    Text(
                                      '• ${speed.toInt()} km/h',
                                      style: const TextStyle(color: AdminTheme.primaryLight, fontSize: 9, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            const SizedBox(height: 2),

                            // Vehicle Pulse Circle Icon
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: isSelected ? 36 : 28,
                              height: isSelected ? 36 : 28,
                              decoration: BoxDecoration(
                                color: color.withOpacity(0.25),
                                shape: BoxShape.circle,
                                border: Border.all(color: color, width: isSelected ? 3 : 2),
                              ),
                              child: Icon(
                                Icons.directions_car_rounded,
                                color: color,
                                size: isSelected ? 20 : 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).whereType<Marker>().toList(),
                ),
              ],
            ),

            // Live Selected Vehicle Detailed Info Overlay Card
            if (selectedVehicle != null)
              Positioned(
                top: 80,
                left: 20,
                child: Container(
                  width: 320,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AdminTheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AdminTheme.border),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.directions_car_rounded, color: AdminTheme.primary, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                selectedVehicle['plate'] ?? 'Selected Vehicle',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AdminTheme.textPrimary),
                              ),
                            ],
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, size: 18, color: AdminTheme.textSecondary),
                            onPressed: () => provider.selectVehicle(null),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Divider(color: AdminTheme.border, height: 1),
                      const SizedBox(height: 12),
                      _buildInfoRow('Driver Name', selectedVehicle['driver_name'] ?? 'Assigned Driver'),
                      _buildInfoRow('Current Speed', '${selectedVehicle['speed'] ?? 0} km/h'),
                      _buildInfoRow('Ignition Status', (selectedVehicle['ignition'] == true || selectedVehicle['status'] == 'moving') ? 'ON 🟢' : 'OFF 🔴'),
                      _buildInfoRow('Fuel Tank Level', '${selectedVehicle['fuel'] ?? 75} %'),
                      _buildInfoRow('Vehicle Status', (selectedVehicle['status'] ?? 'Active').toString().toUpperCase()),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AdminTheme.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                          icon: const Icon(Icons.center_focus_strong, size: 16),
                          label: const Text('Center Camera on Vehicle'),
                          onPressed: () {
                            if (selectedVehicle['lat'] != null && selectedVehicle['lng'] != null) {
                              _centerMapOnVehicle(selectedVehicle['lat'], selectedVehicle['lng']);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AdminTheme.textSecondary, fontSize: 12)),
          Text(value, style: const TextStyle(color: AdminTheme.textPrimary, fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
