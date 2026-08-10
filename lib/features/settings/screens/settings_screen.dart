import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../settings_provider.dart';
import '../models/system_settings_model.dart';
import '../../../app/theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _selectedCategory = 'general';
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Clean metadata dictionary mapping raw keys to human-readable titles, descriptions, icons, and units
  final Map<String, Map<String, dynamic>> _settingMeta = {
    // 1. General & Branding
    'platform_name': {
      'name': 'Platform Brand Name',
      'desc': 'Primary title displayed across mobile apps, admin portal, and emails',
      'icon': Icons.business_rounded,
      'unit': '',
    },
    'support_email': {
      'name': 'Customer Helpdesk Email',
      'desc': 'Official support email address rendered in mobile app help centers',
      'icon': Icons.mark_email_read_rounded,
      'unit': '',
    },
    'support_phone': {
      'name': 'Toll-Free Helpline Number',
      'desc': 'Emergency contact phone number rendered in mobile app help centers',
      'icon': Icons.phone_in_talk_rounded,
      'unit': '',
    },
    'default_timezone': {
      'name': 'Default System Timezone',
      'desc': 'Timezone used for calculating trip timelines and report dates',
      'icon': Icons.schedule_rounded,
      'unit': '',
    },
    'default_currency': {
      'name': 'Default Billing Currency',
      'desc': 'Base currency symbol for fuel cost calculations & subscription plans',
      'icon': Icons.currency_rupee_rounded,
      'unit': '',
    },
    'default_language': {
      'name': 'Default Interface Language',
      'desc': 'Primary language code for system notifications and UI text',
      'icon': Icons.translate_rounded,
      'unit': '',
    },

    // 2. Fleet Telemetry & Safety Rules
    'overspeed_threshold_kmh': {
      'name': 'Global Speed Limit Ceiling',
      'desc': 'Speed ceiling in km/h triggering real-time over-speed violation alerts',
      'icon': Icons.speed_rounded,
      'unit': 'km/h',
    },
    'telemetry_ping_interval_sec': {
      'name': 'IoT Telemetry Ping Rate',
      'desc': 'Frequency of GPS hardware telemetry transmission to backend',
      'icon': Icons.sensors_rounded,
      'unit': 'sec',
    },
    'offline_device_timeout_min': {
      'name': 'Device Disconnect Timeout',
      'desc': 'Inactivity duration without telemetry before marking vehicle offline',
      'icon': Icons.wifi_off_rounded,
      'unit': 'mins',
    },
    'auto_close_trip_min': {
      'name': 'Automatic Trip End Timeout',
      'desc': 'Stationary vehicle duration in minutes after which an ongoing trip auto-ends',
      'icon': Icons.auto_delete_rounded,
      'unit': 'mins',
    },

    // 3. Fuel Theft & Risk Intelligence
    'fuel_theft_threshold_pct': {
      'name': 'Fuel Theft Drop Sensitivity',
      'desc': 'Sudden fuel level drop percentage that flags a potential theft incident',
      'icon': Icons.local_gas_station_rounded,
      'unit': '%',
    },
    'idle_threshold_minutes': {
      'name': 'Idling Waste Alert Timeout',
      'desc': 'Duration of stationary engine operation to flag idle fuel waste',
      'icon': Icons.timer_off_rounded,
      'unit': 'mins',
    },
    'standard_fuel_price_per_liter': {
      'name': 'Benchmark Fuel Price (INR)',
      'desc': 'Default fuel cost per liter used for fleet financial calculations',
      'icon': Icons.payments_rounded,
      'unit': '₹/L',
    },
    'harsh_driving_gforce_threshold': {
      'name': 'Harsh Driving G-Force Threshold',
      'desc': 'Accelerometer G-force ceiling triggering harsh braking or acceleration alerts',
      'icon': Icons.warning_amber_rounded,
      'unit': 'g',
    },

    // 4. WhatsApp, SMS & Email Gateways
    'whatsapp_gateway_enabled': {
      'name': 'WhatsApp Alert Gateway',
      'desc': 'Enables real-time WhatsApp alert notifications dispatched to Fleet Owners',
      'icon': Icons.chat_rounded,
      'unit': '',
    },
    'sms_emergency_enabled': {
      'name': 'SMS Emergency Alert Gateway',
      'desc': 'Enables instant SMS dispatch for critical vehicle safety alerts',
      'icon': Icons.sms_rounded,
      'unit': '',
    },
    'smtp_host': {
      'name': 'SMTP Server Address',
      'desc': 'Host address of the outgoing mail server',
      'icon': Icons.dns_rounded,
      'unit': '',
    },
    'smtp_port': {
      'name': 'SMTP Server Port',
      'desc': 'Port number for email dispatch (e.g. 587 for TLS, 465 for SSL)',
      'icon': Icons.numbers_rounded,
      'unit': 'port',
    },
    'smtp_user': {
      'name': 'System Notification Email',
      'desc': 'Email account address used for sending platform notification emails',
      'icon': Icons.email_rounded,
      'unit': '',
    },
    'otp_expiry_minutes': {
      'name': 'OTP Validity Window',
      'desc': 'Expiration duration in minutes for login & verification OTP passcodes',
      'icon': Icons.timer_rounded,
      'unit': 'mins',
    },

    // 5. AWS S3, Maps & Integrations
    'cloud_storage_bucket': {
      'name': 'AWS S3 Storage Bucket',
      'desc': 'AWS S3 cloud bucket storing driver photos & vehicle documents',
      'icon': Icons.cloud_done_rounded,
      'unit': '',
    },
    'aws_region': {
      'name': 'AWS Data Center Region',
      'desc': 'Active AWS datacenter location hosting S3 cloud bucket',
      'icon': Icons.location_city_rounded,
      'unit': '',
    },
    'map_provider': {
      'name': 'GIS Mapping Engine',
      'desc': 'Map tile provider for vehicle live tracking & route playback',
      'icon': Icons.map_rounded,
      'unit': '',
    },
    'payment_gateway': {
      'name': 'Subscription Payment Processor',
      'desc': 'Primary payment gateway integration for fleet subscription renewals',
      'icon': Icons.credit_card_rounded,
      'unit': '',
    },

    // 6. Security, Sessions & Compliance
    'jwt_expiry_hours': {
      'name': 'Admin Token Validity',
      'desc': 'Expiration duration in hours for admin authentication JWT tokens',
      'icon': Icons.token_rounded,
      'unit': 'hours',
    },
    'session_timeout_minutes': {
      'name': 'Web Inactivity Timeout',
      'desc': 'Automatic logout duration for inactive admin sessions',
      'icon': Icons.hourglass_bottom_rounded,
      'unit': 'mins',
    },
    'password_min_length': {
      'name': 'Minimum Password Length',
      'desc': 'Minimum character length required for user and admin passwords',
      'icon': Icons.lock_clock_rounded,
      'unit': 'chars',
    },
    'password_require_uppercase': {
      'name': 'Enforce Uppercase Letter',
      'desc': 'Requires at least one uppercase letter (A-Z) in passwords',
      'icon': Icons.text_fields_rounded,
      'unit': '',
    },
    'password_require_special': {
      'name': 'Enforce Special Character',
      'desc': r'Requires at least one special symbol (!@#$) in passwords',
      'icon': Icons.code_rounded,
      'unit': '',
    },
    'api_rate_limit_per_minute': {
      'name': 'API Rate Limiting Ceiling',
      'desc': 'Maximum HTTP API requests permitted per minute per IP address',
      'icon': Icons.speed_rounded,
      'unit': 'req/min',
    },
    'audit_log_retention_days': {
      'name': 'Audit Log Retention Window',
      'desc': 'Duration in days to retain administrative activity logs in database',
      'icon': Icons.history_toggle_off_rounded,
      'unit': 'days',
    },

    // 7. System Maintenance & Backups
    'maintenance_mode': {
      'name': 'Platform Maintenance Mode',
      'desc': 'Restricts non-admin portal & mobile app logins during system upgrades',
      'icon': Icons.build_circle_rounded,
      'unit': '',
    },
    'maintenance_message': {
      'name': 'Maintenance Notice Text',
      'desc': 'Banner text displayed to users when maintenance mode is active',
      'icon': Icons.announcement_rounded,
      'unit': '',
    },
    'audit_logging_enabled': {
      'name': 'Global Audit Log Tracking',
      'desc': 'Records all administrative operations and security events in database',
      'icon': Icons.history_edu_rounded,
      'unit': '',
    },
    'backup_enabled': {
      'name': 'Automated DB Backups',
      'desc': 'Enables automated nightly database backups to AWS S3 storage',
      'icon': Icons.backup_rounded,
      'unit': '',
    },
    'backup_schedule': {
      'name': 'DB Backup Cron Schedule',
      'desc': 'Cron pattern defining execution time for database backups',
      'icon': Icons.calendar_today_rounded,
      'unit': '',
    },
  };

  final List<Map<String, dynamic>> _categories = [
    {
      'key': 'general',
      'label': 'Platform Identity & Branding',
      'icon': Icons.business_rounded,
      'desc': 'Platform name, helpline contacts, currency, timezone & language defaults',
    },
    {
      'key': 'telemetry',
      'label': 'Fleet Telemetry & Safety',
      'icon': Icons.speed_rounded,
      'desc': 'Global speed limit ceilings, IoT ping intervals & offline device timeouts',
    },
    {
      'key': 'fuel_risk',
      'label': 'Fuel Theft & Risk Intelligence',
      'icon': Icons.local_gas_station_rounded,
      'desc': 'Fuel drop theft sensitivity, idling waste limits & benchmark fuel prices',
    },
    {
      'key': 'communications',
      'label': 'WhatsApp, SMS & Mail Gateways',
      'icon': Icons.notifications_active_rounded,
      'desc': 'WhatsApp alert dispatcher, emergency SMS gateways & SMTP mail servers',
    },
    {
      'key': 'integrations',
      'label': 'Cloud Storage & Integrations',
      'icon': Icons.cloud_done_rounded,
      'desc': 'AWS S3 bucket configuration, GIS mapping engines & payment processors',
    },
    {
      'key': 'security',
      'label': 'Security & Access Control',
      'icon': Icons.security_rounded,
      'desc': 'Session token expirations, password policies & API rate limiters',
    },
    {
      'key': 'system',
      'label': 'System Maintenance & Backups',
      'icon': Icons.dns_rounded,
      'desc': 'Platform maintenance mode toggle, audit logging & automated backups',
    },
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SettingsProvider>().fetchSettings();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SettingsProvider>();

    return Scaffold(
      backgroundColor: AdminTheme.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Operational Health Banner
            _buildTopSystemNotice(),
            const SizedBox(height: 20),

            // Top Summary KPI Cards (Matching Fleet Owner App Palette)
            _buildTopKpiSummary(provider),
            const SizedBox(height: 24),

            // Main Settings Layout: Left Category Navigation + Right Active Panel
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left Column: Category Sidebar List
                SizedBox(
                  width: 290,
                  child: _buildCategorySidebar(provider),
                ),
                const SizedBox(width: 24),

                // Right Column: Active Settings Options Cards
                Expanded(
                  child: _buildSettingsContentPanel(provider),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Top Operational Notice ─────────────────────────────────────────────────
  Widget _buildTopSystemNotice() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: AdminTheme.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AdminTheme.primary.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.shield_outlined, color: AdminTheme.primary, size: 20),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'DravYantra System Administration: Parameters update live in PostgreSQL database and govern telemetry, mobile apps & gateways instantly.',
              style: TextStyle(color: AdminTheme.textPrimary, fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AdminTheme.primary,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text('ADMIN ACTIVE', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }

  // ── Top Summary KPI Cards ──────────────────────────────────────────────────
  Widget _buildTopKpiSummary(SettingsProvider provider) {
    int totalSettings = 0;
    provider.groupedSettings.forEach((_, list) => totalSettings += list.length);

    return LayoutBuilder(
      builder: (context, constraints) {
        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            _buildKpiCard('Total System Parameters', '$totalSettings Options', 'Configured across 7 Domains', AdminTheme.primary, Icons.tune_rounded),
            _buildKpiCard('AWS Cloud Storage', 'AWS S3 Active', 'Bucket: dravyantra-uploads', AdminTheme.success, Icons.cloud_done_rounded),
            _buildKpiCard('Database Connection', 'AWS RDS PostgreSQL', 'Encrypted TLS 1.3', AdminTheme.info, Icons.storage_rounded),
            _buildKpiCard('Platform Status', '100% Operational', 'Zero Outages Reported', AdminTheme.secondary, Icons.check_circle_rounded),
          ],
        );
      },
    );
  }

  Widget _buildKpiCard(String title, String mainValue, String subtitle, Color accentColor, IconData icon) {
    return Container(
      width: 250,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AdminTheme.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AdminTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(color: AdminTheme.textSecondary, fontSize: 12, fontWeight: FontWeight.w500)),
              Icon(icon, color: accentColor, size: 20),
            ],
          ),
          const SizedBox(height: 12),
          Text(mainValue, style: const TextStyle(color: AdminTheme.textPrimary, fontSize: 17, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(subtitle, style: const TextStyle(color: AdminTheme.textSecondary, fontSize: 11)),
          const SizedBox(height: 12),
          Container(
            height: 4,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AdminTheme.background,
              borderRadius: BorderRadius.circular(2),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: 0.8,
              child: Container(
                decoration: BoxDecoration(
                  color: accentColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Left Sidebar Category Navigation ───────────────────────────────────────
  Widget _buildCategorySidebar(SettingsProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AdminTheme.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AdminTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('SETTINGS DOMAINS', style: TextStyle(color: AdminTheme.textSecondary, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.1)),
          const SizedBox(height: 16),
          ..._categories.map((cat) {
            final key = cat['key'] as String;
            final isSelected = _selectedCategory == key;
            final count = (provider.groupedSettings[key] ?? []).length;

            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: InkWell(
                onTap: () => setState(() => _selectedCategory = key),
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? AdminTheme.primary.withOpacity(0.1) : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected ? AdminTheme.primary : Colors.transparent,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(cat['icon'] as IconData, size: 20, color: isSelected ? AdminTheme.primary : AdminTheme.textSecondary),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          cat['label'] as String,
                          style: TextStyle(
                            color: isSelected ? AdminTheme.primary : AdminTheme.textPrimary,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: isSelected ? AdminTheme.primary : AdminTheme.background,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '$count',
                          style: TextStyle(
                            color: isSelected ? Colors.white : AdminTheme.textSecondary,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  // ── Right Settings Options Content Panel ───────────────────────────────────
  Widget _buildSettingsContentPanel(SettingsProvider provider) {
    final catInfo = _categories.firstWhere((c) => c['key'] == _selectedCategory, orElse: () => _categories[0]);
    final List<SystemSetting> settingsList = provider.groupedSettings[_selectedCategory] ?? [];

    final filtered = settingsList.where((s) {
      if (_searchQuery.isEmpty) return true;
      final meta = _settingMeta[s.key];
      final neatName = meta?['name'] ?? s.key;
      return neatName.toLowerCase().contains(_searchQuery) ||
          s.key.toLowerCase().contains(_searchQuery) ||
          s.description.toLowerCase().contains(_searchQuery) ||
          (s.value != null && s.value.toString().toLowerCase().contains(_searchQuery));
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Category Header Bar & Search Input
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AdminTheme.card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AdminTheme.border),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(catInfo['icon'] as IconData, color: AdminTheme.primary, size: 22),
                        const SizedBox(width: 10),
                        Text(catInfo['label'] as String, style: const TextStyle(color: AdminTheme.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(catInfo['desc'] as String, style: const TextStyle(color: AdminTheme.textSecondary, fontSize: 12)),
                  ],
                ),
              ),
              SizedBox(
                width: 250,
                height: 40,
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) => setState(() => _searchQuery = val.trim().toLowerCase()),
                  style: const TextStyle(color: AdminTheme.textPrimary, fontSize: 13),
                  decoration: InputDecoration(
                    hintText: 'Search domain options...',
                    hintStyle: const TextStyle(color: AdminTheme.textSecondary, fontSize: 12),
                    prefixIcon: const Icon(Icons.search, size: 18, color: AdminTheme.textSecondary),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                    filled: true,
                    fillColor: AdminTheme.background,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AdminTheme.border)),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        if (provider.isLoading && provider.groupedSettings.isEmpty)
          const SizedBox(height: 200, child: Center(child: CircularProgressIndicator()))
        else if (filtered.isEmpty)
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(color: AdminTheme.card, borderRadius: BorderRadius.circular(12), border: Border.all(color: AdminTheme.border)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.search_off_rounded, size: 40, color: AdminTheme.textMuted),
                const SizedBox(height: 12),
                Text(
                  _searchQuery.isNotEmpty ? 'No options match "$_searchQuery"' : 'No parameters configured in this category yet.',
                  style: const TextStyle(color: AdminTheme.textSecondary, fontSize: 13),
                ),
              ],
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: filtered.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final setting = filtered[index];
              return _buildSettingOptionCard(setting);
            },
          ),
      ],
    );
  }

  // ── Option Card Component ─────────────────────────────────────────────────
  Widget _buildSettingOptionCard(SystemSetting setting) {
    final meta = _settingMeta[setting.key];
    final String neatTitle = meta?['name'] ?? _formatKeyName(setting.key);
    final String neatDesc = meta?['desc'] ?? setting.description;
    final IconData icon = meta?['icon'] ?? Icons.tune_rounded;
    final String unit = meta?['unit'] ?? '';

    final bool isBoolValue = setting.value is bool || setting.value.toString().toLowerCase() == 'true' || setting.value.toString().toLowerCase() == 'false';
    final bool boolVal = setting.value is bool ? setting.value : setting.value.toString().toLowerCase() == 'true';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AdminTheme.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AdminTheme.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left Icon Container
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AdminTheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AdminTheme.primary, size: 22),
          ),
          const SizedBox(width: 16),

          // Title, Description & Display Value
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  neatTitle,
                  style: const TextStyle(color: AdminTheme.textPrimary, fontSize: 15, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(neatDesc, style: const TextStyle(color: AdminTheme.textSecondary, fontSize: 12)),
                const SizedBox(height: 10),

                if (!isBoolValue)
                  Row(
                    children: [
                      const Text('Setting Value: ', style: TextStyle(color: AdminTheme.textSecondary, fontSize: 12)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AdminTheme.background,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: AdminTheme.border),
                        ),
                        child: Text(
                          setting.isSensitive ? '••••••••••••' : '${_formatValueDisplay(setting.value)}${unit.isNotEmpty ? ' $unit' : ''}',
                          style: TextStyle(
                            color: setting.isSensitive ? AdminTheme.warning : AdminTheme.success,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),

          // Right Controls (Interactive Switch for Booleans / Edit & History for Text)
          if (isBoolValue)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: boolVal ? AdminTheme.success.withOpacity(0.12) : AdminTheme.danger.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    boolVal ? 'ENABLED' : 'DISABLED',
                    style: TextStyle(color: boolVal ? AdminTheme.success : AdminTheme.danger, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 8),
                Switch(
                  value: boolVal,
                  activeColor: AdminTheme.primary,
                  onChanged: (newVal) => _quickToggleBoolean(setting, newVal),
                ),
                IconButton(
                  icon: const Icon(Icons.history_rounded, color: AdminTheme.textSecondary, size: 18),
                  tooltip: 'Audit Logs',
                  onPressed: () => _showHistoryDialog(setting),
                ),
              ],
            )
          else
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.history_rounded, color: AdminTheme.textSecondary, size: 18),
                  tooltip: 'Audit History',
                  onPressed: () => _showHistoryDialog(setting),
                ),
                const SizedBox(width: 6),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AdminTheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  ),
                  icon: const Icon(Icons.edit_outlined, size: 16, color: Colors.white),
                  label: const Text('Configure', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  onPressed: () => _showUpdateDialog(setting),
                ),
              ],
            ),
        ],
      ),
    );
  }

  // ── Live Switch Quick Toggle ────────────────────────────────────────────────
  Future<void> _quickToggleBoolean(SystemSetting setting, bool newVal) async {
    final meta = _settingMeta[setting.key];
    final neatTitle = meta?['name'] ?? _formatKeyName(setting.key);
    final provider = context.read<SettingsProvider>();

    final success = await provider.updateSetting(
      key: setting.key,
      value: newVal,
      category: setting.category,
      reason: 'Toggled via Admin Settings Panel to $newVal',
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ $neatTitle is now ${newVal ? "ENABLED" : "DISABLED"}'),
          backgroundColor: AdminTheme.success,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error updating $neatTitle: ${provider.error ?? "Failed to save"}'),
          backgroundColor: AdminTheme.danger,
        ),
      );
    }
  }

  // ── Formatted Update Dialog Modal ──────────────────────────────────────────
  void _showUpdateDialog(SystemSetting setting) {
    final meta = _settingMeta[setting.key];
    final neatTitle = meta?['name'] ?? _formatKeyName(setting.key);
    final neatDesc = meta?['desc'] ?? setting.description;

    final TextEditingController valueController = TextEditingController(
      text: setting.value is String ? setting.value : jsonEncode(setting.value),
    );
    final TextEditingController reasonController = TextEditingController();
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              backgroundColor: AdminTheme.card,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Row(
                children: [
                  const Icon(Icons.tune_rounded, color: AdminTheme.primary),
                  const SizedBox(width: 10),
                  Text('Configure $neatTitle', style: const TextStyle(color: AdminTheme.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
              content: SizedBox(
                width: 480,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(neatDesc, style: const TextStyle(color: AdminTheme.textSecondary, fontSize: 13)),
                    const SizedBox(height: 16),
                    TextField(
                      controller: valueController,
                      style: const TextStyle(color: AdminTheme.textPrimary, fontSize: 14),
                      decoration: InputDecoration(
                        labelText: 'Setting Parameter Value',
                        labelStyle: const TextStyle(color: AdminTheme.textSecondary),
                        filled: true,
                        fillColor: AdminTheme.background,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AdminTheme.border)),
                      ),
                      maxLines: setting.isSensitive ? 1 : 2,
                      obscureText: setting.isSensitive,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: reasonController,
                      style: const TextStyle(color: AdminTheme.textPrimary, fontSize: 14),
                      decoration: InputDecoration(
                        labelText: 'Audit Reason (Required for security log)',
                        labelStyle: const TextStyle(color: AdminTheme.textSecondary),
                        filled: true,
                        fillColor: AdminTheme.background,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AdminTheme.border)),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isLoading ? null : () => Navigator.pop(ctx),
                  child: const Text('Cancel', style: TextStyle(color: AdminTheme.textSecondary)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AdminTheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: isLoading
                      ? null
                      : () async {
                          if (reasonController.text.trim().isEmpty) {
                            ScaffoldMessenger.of(ctx).showSnackBar(
                              const SnackBar(content: Text('Please enter an audit reason.')),
                            );
                            return;
                          }

                          setStateDialog(() => isLoading = true);

                          dynamic finalValue;
                          try {
                            finalValue = jsonDecode(valueController.text);
                          } catch (e) {
                            finalValue = valueController.text;
                          }

                          final provider = Provider.of<SettingsProvider>(context, listen: false);
                          final success = await provider.updateSetting(
                            key: setting.key,
                            value: finalValue,
                            category: setting.category,
                            reason: reasonController.text,
                          );

                          setStateDialog(() => isLoading = false);

                          if (!mounted) return;

                          if (success) {
                            Navigator.pop(ctx);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('✅ Setting parameter updated successfully.')),
                            );
                          } else {
                            ScaffoldMessenger.of(ctx).showSnackBar(
                              SnackBar(content: Text('❌ Error: ${provider.error ?? "Failed to save"}')),
                            );
                          }
                        },
                  child: isLoading
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Save Parameter'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ── Audit History Timeline Modal ──────────────────────────────────────────
  void _showHistoryDialog(SystemSetting setting) {
    final meta = _settingMeta[setting.key];
    final neatTitle = meta?['name'] ?? _formatKeyName(setting.key);

    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          backgroundColor: AdminTheme.card,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            width: 650,
            height: 480,
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.history_rounded, color: AdminTheme.primary),
                        const SizedBox(width: 10),
                        Text('Audit Timeline: $neatTitle', style: const TextStyle(color: AdminTheme.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: AdminTheme.textSecondary),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(color: AdminTheme.border, height: 1),
                const SizedBox(height: 16),
                Expanded(
                  child: FutureBuilder<List<SettingHistory>>(
                    future: context.read<SettingsProvider>().getHistoryFor(setting.key),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Center(child: Text('Error loading history: ${snapshot.error}', style: const TextStyle(color: AdminTheme.danger)));
                      }
                      final history = snapshot.data ?? [];
                      if (history.isEmpty) {
                        return const Center(
                          child: Text('No previous audit logs recorded for this parameter.', style: TextStyle(color: AdminTheme.textSecondary)),
                        );
                      }
                      return ListView.separated(
                        itemCount: history.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final h = history[index];
                          return Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AdminTheme.background,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: AdminTheme.border),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Updated Value: ${h.newValue}',
                                      style: const TextStyle(color: AdminTheme.success, fontWeight: FontWeight.bold, fontSize: 13),
                                    ),
                                    Text(
                                      h.changedAt != null ? DateFormat('MMM dd, yyyy HH:mm').format(h.changedAt!) : '—',
                                      style: const TextStyle(color: AdminTheme.textSecondary, fontSize: 11),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Modified by: ${h.changedByEmail ?? h.changedBy ?? "System Admin"}',
                                  style: const TextStyle(color: AdminTheme.textPrimary, fontSize: 12),
                                ),
                                if (h.changeReason != null && h.changeReason!.isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    'Audit Reason: "${h.changeReason}"',
                                    style: const TextStyle(color: AdminTheme.textSecondary, fontSize: 12, fontStyle: FontStyle.italic),
                                  ),
                                ]
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── Formatting Helpers ────────────────────────────────────────────────────
  String _formatKeyName(String key) {
    return key
        .replaceAll('_', ' ')
        .replaceAll('.', ' ')
        .split(' ')
        .map((str) => str.isEmpty ? '' : '${str[0].toUpperCase()}${str.substring(1)}')
        .join(' ');
  }

  String _formatValueDisplay(dynamic val) {
    if (val == null) return 'Not Configured';
    if (val is Map || val is List) {
      return jsonEncode(val);
    }
    return val.toString();
  }
}
