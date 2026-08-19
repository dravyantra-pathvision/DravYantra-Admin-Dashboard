class RecycledItem {
  final String id;
  final String entityType; // 'fleet_owner', 'organization', 'vehicle', 'driver', 'trip'
  final String title;
  final String subtitle;
  final String organization;
  final DateTime deletedAt;

  RecycledItem({
    required this.id,
    required this.entityType,
    required this.title,
    required this.subtitle,
    required this.organization,
    required this.deletedAt,
  });

  factory RecycledItem.fromJson(Map<String, dynamic> json) {
    return RecycledItem(
      id: json['id']?.toString() ?? '',
      entityType: json['entity_type'] ?? 'unknown',
      title: json['title'] ?? 'N/A',
      subtitle: json['subtitle'] ?? '',
      organization: json['organization'] ?? 'N/A',
      deletedAt: json['deleted_at'] != null 
          ? DateTime.tryParse(json['deleted_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  String get entityTypeLabel {
    switch (entityType) {
      case 'fleet_owner':  return 'Fleet Owner';
      case 'organization': return 'Organization';
      case 'vehicle':      return 'Vehicle';
      case 'driver':       return 'Driver';
      case 'trip':         return 'Trip';
      default:             return entityType.toUpperCase();
    }
  }
}
