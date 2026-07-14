import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../app/theme.dart';
import '../models/trip_model.dart';
import '../providers/trips_provider.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:universal_html/html.dart' as html;

class TripDetailScreen extends StatefulWidget {
  final String id;
  const TripDetailScreen({super.key, required this.id});

  @override
  State<TripDetailScreen> createState() => _TripDetailScreenState();
}

class _TripDetailScreenState extends State<TripDetailScreen> {
  Trip? _trip;
  List<dynamic> _timeline = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final provider = context.read<TripsProvider>();
      final trip = await provider.getTripById(widget.id);
      final timeline = await provider.getTripTimeline(widget.id);
      if (mounted) {
        setState(() {
          _trip = trip;
          _timeline = timeline;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  void _exportCSV() async {
    try {
      final bytes = await context.read<TripsProvider>().exportTrips();
      if (bytes.isNotEmpty) {
        final blob = html.Blob([bytes]);
        final url = html.Url.createObjectUrlFromBlob(blob);
        html.AnchorElement(href: url)
          ..setAttribute('download', 'trip_${widget.id}_export.csv')
          ..click();
        html.Url.revokeObjectUrl(url);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Export failed: $e'), backgroundColor: AdminTheme.danger));
      }
    }
  }

  Widget _buildStatusBadge(String status) {
    Color bg, text;
    final s = status.toLowerCase();
    if (s == 'completed') {
      bg = Colors.green.withOpacity(0.1);
      text = Colors.green;
    } else if (s == 'running' || s == 'started') {
      bg = Colors.blue.withOpacity(0.1);
      text = Colors.blue;
    } else if (s == 'cancelled') {
      bg = Colors.red.withOpacity(0.1);
      text = Colors.red;
    } else {
      bg = Colors.grey.withOpacity(0.1);
      text = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(16)),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(color: text, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AdminTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AdminTheme.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AdminTheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AdminTheme.primary),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: AdminTheme.textSecondary, fontSize: 12)),
              const SizedBox(height: 4),
              Text(value, style: const TextStyle(color: AdminTheme.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMap() {
    List<LatLng> points = [];
    if (_trip?.waypoints != null) {
      for (var wp in _trip!.waypoints!) {
        if (wp['lat'] != null && wp['lng'] != null) {
          final lat = double.tryParse(wp['lat'].toString());
          final lng = double.tryParse(wp['lng'].toString());
          if (lat != null && lng != null) {
            points.add(LatLng(lat, lng));
          }
        }
      }
    }

    if (points.isEmpty) {
      return Container(
        height: 300,
        width: double.infinity,
        decoration: BoxDecoration(
          color: AdminTheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AdminTheme.border),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.map_outlined, size: 48, color: AdminTheme.textMuted),
              const SizedBox(height: 16),
              const Text('No GPS data for this trip', style: TextStyle(color: AdminTheme.textSecondary)),
            ],
          ),
        ),
      );
    }

    final bounds = LatLngBounds.fromPoints(points);

    return Container(
      height: 400,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AdminTheme.border),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: FlutterMap(
          options: MapOptions(
            initialCameraFit: CameraFit.bounds(
              bounds: bounds,
              padding: const EdgeInsets.all(32),
            ),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.dravyantra.admin',
            ),
            PolylineLayer(
              polylines: [
                Polyline(
                  points: points,
                  color: AdminTheme.primary,
                  strokeWidth: 4,
                ),
              ],
            ),
            MarkerLayer(
              markers: [
                Marker(
                  point: points.first,
                  width: 32,
                  height: 32,
                  child: const Icon(Icons.location_on, color: Colors.green, size: 32),
                ),
                Marker(
                  point: points.last,
                  width: 32,
                  height: 32,
                  child: const Icon(Icons.location_on, color: Colors.red, size: 32),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeline() {
    if (_timeline.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text('No timeline events recorded.', style: TextStyle(color: AdminTheme.textSecondary)),
      );
    }
    
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _timeline.length,
      itemBuilder: (context, index) {
        final event = _timeline[index];
        final isLast = index == _timeline.length - 1;
        final dateStr = event['detected_at'] != null 
            ? DateFormat('MMM dd, HH:mm:ss').format(DateTime.parse(event['detected_at'])) 
            : 'Unknown';
            
        IconData icon = Icons.info;
        Color color = Colors.blue;
        
        if (event['type'] == 'overspeed') {
          icon = Icons.speed;
          color = Colors.orange;
        } else if (event['type'] == 'fuel_drop' || event['type'] == 'fuel_theft') {
          icon = Icons.local_gas_station;
          color = Colors.red;
        } else if (event['type'] == 'harsh_braking') {
          icon = Icons.warning;
          color = Colors.orange;
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 16, color: color),
                ),
                if (!isLast)
                  Container(
                    width: 2,
                    height: 40,
                    color: AdminTheme.border,
                  ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(event['type'].toString().toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold, color: AdminTheme.textPrimary)),
                  const SizedBox(height: 4),
                  Text(event['message'] ?? '', style: const TextStyle(color: AdminTheme.textSecondary, fontSize: 13)),
                  const SizedBox(height: 4),
                  Text(dateStr, style: const TextStyle(color: AdminTheme.textSecondary, fontSize: 12)),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(child: Text('Error: $_error', style: const TextStyle(color: AdminTheme.danger)));
    }

    if (_trip == null) {
      return const Center(child: Text('Trip not found', style: TextStyle(color: AdminTheme.textSecondary)));
    }

    final t = _trip!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: AdminTheme.textPrimary),
                onPressed: () => context.go('/trips'),
              ),
              const SizedBox(width: 8),
              Text('Trip ${t.id}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AdminTheme.textPrimary)),
              const SizedBox(width: 16),
              _buildStatusBadge(t.status ?? 'Unknown'),
              const Spacer(),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AdminTheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
                icon: const Icon(Icons.download, size: 18),
                label: const Text('Export Trip Data'),
                onPressed: _exportCSV,
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Main content
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildMap(),
                    const SizedBox(height: 24),
                    const Text('Telemetry & Metrics', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AdminTheme.textPrimary)),
                    const SizedBox(height: 16),
                    GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      shrinkWrap: true,
                      childAspectRatio: 2.5,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        _buildStatCard('Distance', '${t.distance?.toStringAsFixed(1) ?? '0'} km', Icons.straighten),
                        _buildStatCard('Fuel Consumed', '${t.fuelUsed?.toStringAsFixed(1) ?? '0'} L', Icons.local_gas_station),
                        _buildStatCard('Idle Duration', '${t.idleDuration ?? 0} mins', Icons.timer),
                        _buildStatCard('Fuel Wasted', '${t.fuelWasted?.toStringAsFixed(1) ?? '0'} L', Icons.money_off),
                        _buildStatCard('Average Speed', '${t.liveSpeed?.toStringAsFixed(1) ?? '0'} km/h', Icons.speed),
                        _buildStatCard('Driving Score', '${t.score?.toStringAsFixed(1) ?? '0'} / 100', Icons.score),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Text('Trip Timeline', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AdminTheme.textPrimary)),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AdminTheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AdminTheme.border),
                      ),
                      child: _buildTimeline(),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              // Sidebar content
              Expanded(
                flex: 1,
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AdminTheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AdminTheme.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Trip Details', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AdminTheme.textPrimary)),
                          const Divider(height: 24, color: AdminTheme.border),
                          _DetailRow(label: 'Organization', value: t.organizationName ?? 'N/A'),
                          _DetailRow(label: 'Fleet Owner', value: t.fleetOwnerEmail ?? 'N/A'),
                          _DetailRow(label: 'Vehicle', value: t.vehicle ?? 'N/A'),
                          _DetailRow(label: 'Driver', value: t.driver ?? 'N/A'),
                          _DetailRow(label: 'From', value: t.fromLocation ?? 'N/A'),
                          _DetailRow(label: 'To', value: t.toLocation ?? 'N/A'),
                          if (t.createdAt != null)
                            _DetailRow(label: 'Started At', value: DateFormat('MMM dd, HH:mm').format(t.createdAt!)),
                          if (t.updatedAt != null)
                            _DetailRow(label: 'Last Update', value: DateFormat('MMM dd, HH:mm').format(t.updatedAt!)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  
  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: AdminTheme.textSecondary, fontSize: 12)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(color: AdminTheme.textPrimary, fontSize: 14)),
        ],
      ),
    );
  }
}
