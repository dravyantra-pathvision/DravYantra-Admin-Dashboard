import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../models/recycled_item.dart';

class RecycleBinService {
  final _api = ApiClient.instance;

  Future<Map<String, dynamic>> getRecycledItems({
    String? type,
    String? search,
    int page = 1,
    int limit = 50,
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };
    if (type != null && type.isNotEmpty && type != 'all') queryParams['type'] = type;
    if (search != null && search.isNotEmpty) queryParams['search'] = search;

    final decoded = await _api.get(ApiEndpoints.recycleBin, queryParams: queryParams);
    final List<dynamic> data = decoded['data'] ?? [];
    final total = decoded['total'] ?? 0;

    return {
      'items': data.map((item) => RecycledItem.fromJson(item)).toList(),
      'total': total,
    };
  }

  Future<void> restoreItem(String entityType, String id) async {
    await _api.post(
      ApiEndpoints.recycleBinRestore,
      {
        'entity_type': entityType,
        'id': id,
      },
    );
  }

  Future<void> hardDeleteItem(String entityType, String id) async {
    await _api.post(
      ApiEndpoints.recycleBinPermanent,
      {
        'entity_type': entityType,
        'id': id,
      },
    );
  }
}
