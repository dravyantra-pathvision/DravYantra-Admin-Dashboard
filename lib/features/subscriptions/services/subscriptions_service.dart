import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../models/subscription_models.dart';

class SubscriptionsService {
  final _api = ApiClient.instance;

  // ── Dashboard ─────────────────────────────────────────────────────────────
  Future<SubscriptionDashboardStats> getDashboard() async {
    final decoded = await _api.get(ApiEndpoints.subscriptionDashboard);
    return SubscriptionDashboardStats.fromJson(decoded['data']);
  }

  // ── Plans ─────────────────────────────────────────────────────────────────
  Future<List<SubscriptionPlan>> getAllPlans() async {
    final decoded = await _api.get(ApiEndpoints.subscriptionPlans);
    final List<dynamic> data = decoded['data'] ?? [];
    return data.map((p) => SubscriptionPlan.fromJson(p)).toList();
  }

  Future<SubscriptionPlan> createPlan(Map<String, dynamic> body) async {
    final decoded = await _api.post(ApiEndpoints.subscriptionPlans, body);
    return SubscriptionPlan.fromJson(decoded['data']);
  }

  Future<SubscriptionPlan> updatePlan(int id, Map<String, dynamic> body) async {
    final decoded = await _api.put(ApiEndpoints.subscriptionPlan(id), body);
    return SubscriptionPlan.fromJson(decoded['data']);
  }

  Future<void> deletePlan(int id) async {
    await _api.delete(ApiEndpoints.subscriptionPlan(id));
  }

  // ── Subscriptions ─────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> getAllSubscriptions({
    int page = 1,
    int limit = 50,
    String? status,
    String? search,
  }) async {
    final params = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };
    if (status != null && status.isNotEmpty) params['status'] = status;
    if (search != null && search.isNotEmpty) params['search'] = search;

    final decoded = await _api.get(ApiEndpoints.subscriptions, queryParams: params);
    final List<dynamic> data = decoded['data'] ?? [];
    return {
      'subscriptions': data.map((s) => OrganizationSubscription.fromJson(s)).toList(),
      'total': decoded['total'] ?? 0,
    };
  }

  Future<OrganizationSubscription> getSubscriptionByOrg(String uid) async {
    final decoded = await _api.get(ApiEndpoints.subscriptionByOrg(uid));
    return OrganizationSubscription.fromJson(decoded['data']);
  }

  Future<void> assignPlan({required String orgUid, required int planId, String? notes}) async {
    await _api.post(ApiEndpoints.subscriptionAssign, {
      'orgUid': orgUid,
      'planId': planId,
      if (notes != null) 'notes': notes,
    });
  }

  Future<void> activateSubscription(int id) async {
    await _api.post(ApiEndpoints.subscriptionAction(id, 'activate'), {});
  }

  Future<void> suspendSubscription(int id, {String? reason}) async {
    await _api.post(ApiEndpoints.subscriptionAction(id, 'suspend'), {
      if (reason != null) 'reason': reason,
    });
  }

  Future<void> renewSubscription(int id) async {
    await _api.post(ApiEndpoints.subscriptionAction(id, 'renew'), {});
  }

  Future<void> extendTrial(int id, {int extraDays = 7}) async {
    await _api.post(ApiEndpoints.subscriptionAction(id, 'extend-trial'), {
      'extraDays': extraDays,
    });
  }

  Future<void> cancelSubscription(int id, {String? reason}) async {
    await _api.post(ApiEndpoints.subscriptionAction(id, 'cancel'), {
      if (reason != null) 'reason': reason,
    });
  }

  // ── Invoices ──────────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> getAllInvoices({
    int page = 1,
    int limit = 50,
    String? status,
  }) async {
    final params = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };
    if (status != null && status.isNotEmpty) params['status'] = status;

    final decoded = await _api.get(ApiEndpoints.subscriptionInvoices, queryParams: params);
    final List<dynamic> data = decoded['data'] ?? [];
    return {
      'invoices': data.map((i) => SubscriptionInvoice.fromJson(i)).toList(),
      'total': decoded['total'] ?? 0,
    };
  }

  Future<void> generateInvoice({required int subscriptionId, String? orgUid, String? notes}) async {
    await _api.post(ApiEndpoints.subscriptionInvoiceGenerate, {
      'subscriptionId': subscriptionId,
      if (orgUid != null) 'orgUid': orgUid,
      if (notes != null) 'notes': notes,
    });
  }

  Future<void> markInvoicePaid(int id, {String? paymentMethod}) async {
    await _api.post(ApiEndpoints.subscriptionInvoicePay(id), {
      if (paymentMethod != null) 'paymentMethod': paymentMethod,
    });
  }
}
