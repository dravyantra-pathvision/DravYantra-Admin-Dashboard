import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/profile_provider.dart';
import '../../../app/constants.dart';
import '../../../app/theme.dart';

class AdminProfileScreen extends StatefulWidget {
  const AdminProfileScreen({Key? key}) : super(key: key);

  @override
  _AdminProfileScreenState createState() => _AdminProfileScreenState();
}

class _AdminProfileScreenState extends State<AdminProfileScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileProvider>().fetchProfile();
      context.read<ProfileProvider>().fetchSessions();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AdminTheme.background,
      body: Consumer<ProfileProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.profile == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null && provider.profile == null) {
            return Center(child: Text('Error: ${provider.error}', style: const TextStyle(color: AdminTheme.danger)));
          }

          final profile = provider.profile;
          if (profile == null) return const Center(child: Text('Profile not found', style: TextStyle(color: AdminTheme.textSecondary)));

          return Column(
            children: [
              _buildHeader(profile),
              Container(
                color: AdminTheme.surface,
                child: TabBar(
                  controller: _tabController,
                  labelColor: AdminTheme.primary,
                  unselectedLabelColor: AdminTheme.textSecondary,
                  indicatorColor: AdminTheme.primary,
                  indicatorWeight: 3,
                  tabs: const [
                    Tab(text: 'Overview'),
                    Tab(text: 'Security & Active Sessions'),
                    Tab(text: 'Notifications'),
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _OverviewTab(provider: provider),
                    _SecurityTab(provider: provider),
                    _NotificationsTab(provider: provider),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader(profile) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AdminTheme.surface,
        border: Border(bottom: BorderSide(color: AdminTheme.border)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: AdminTheme.primary.withOpacity(0.12),
            backgroundImage: profile.profilePhoto != null
                ? NetworkImage('${AppConstants.apiBaseUrl}${profile.profilePhoto}')
                : null,
            child: profile.profilePhoto == null
                ? const Icon(Icons.person_rounded, size: 40, color: AdminTheme.primary)
                : null,
          ),
          const SizedBox(width: 24),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                profile.fullName,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AdminTheme.textPrimary),
              ),
              const SizedBox(height: 4),
              Text(
                profile.designation ?? 'Platform Administrator',
                style: const TextStyle(fontSize: 14, color: AdminTheme.textSecondary),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AdminTheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      profile.role.toUpperCase(),
                      style: const TextStyle(color: AdminTheme.primary, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AdminTheme.success.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'ACTIVE',
                      style: TextStyle(color: AdminTheme.success, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              )
            ],
          ),
        ],
      ),
    );
  }
}

class _OverviewTab extends StatefulWidget {
  final ProfileProvider provider;
  const _OverviewTab({Key? key, required this.provider}) : super(key: key);

  @override
  __OverviewTabState createState() => __OverviewTabState();
}

class __OverviewTabState extends State<_OverviewTab> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _deptController;
  late TextEditingController _desigController;

  @override
  void initState() {
    super.initState();
    final profile = widget.provider.profile!;
    _nameController = TextEditingController(text: profile.fullName);
    _phoneController = TextEditingController(text: profile.phone != null && profile.phone!.isNotEmpty ? profile.phone! : '+91 ');
    _deptController = TextEditingController(text: profile.department ?? '');
    _desigController = TextEditingController(text: profile.designation ?? '');
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Card(
              color: AdminTheme.card,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: AdminTheme.border)),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Personal Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AdminTheme.textPrimary)),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: _nameController,
                        style: const TextStyle(color: AdminTheme.textPrimary),
                        decoration: const InputDecoration(labelText: 'Full Name', border: OutlineInputBorder()),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _phoneController,
                        style: const TextStyle(color: AdminTheme.textPrimary),
                        decoration: const InputDecoration(labelText: 'Mobile Number', border: OutlineInputBorder()),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Required';
                          if (!RegExp(r'^\+91 [6-9]\d{9}$').hasMatch(v)) return 'Must be +91 followed by 10 digits starting with 6-9';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _deptController,
                        style: const TextStyle(color: AdminTheme.textPrimary),
                        decoration: const InputDecoration(labelText: 'Department', border: OutlineInputBorder()),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _desigController,
                        style: const TextStyle(color: AdminTheme.textPrimary),
                        decoration: const InputDecoration(labelText: 'Designation', border: OutlineInputBorder()),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: AdminTheme.primary, foregroundColor: Colors.white),
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            try {
                              await widget.provider.updateProfile({
                                'full_name': _nameController.text,
                                'phone': _phoneController.text,
                                'department': _deptController.text,
                                'designation': _desigController.text,
                              });
                              if (!mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Profile updated successfully')));
                            } catch (e) {
                              if (!mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e')));
                            }
                          }
                        },
                        child: const Text('Save Changes'),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            flex: 1,
            child: Card(
              color: AdminTheme.card,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: AdminTheme.border)),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Account Info', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AdminTheme.textPrimary)),
                    const SizedBox(height: 24),
                    _buildInfoRow('Email', widget.provider.profile!.email),
                    const Divider(color: AdminTheme.border),
                    _buildInfoRow('Role', widget.provider.profile!.role),
                    const Divider(color: AdminTheme.border),
                    _buildInfoRow('Created At', widget.provider.profile!.createdAt != null ? DateFormat('MMM dd, yyyy').format(widget.provider.profile!.createdAt!.toLocal()) : 'N/A'),
                    const SizedBox(height: 16),
                    const Text('Note: Email and Role are managed by System Administrators.', style: TextStyle(color: AdminTheme.textSecondary, fontSize: 12)),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AdminTheme.textSecondary, fontSize: 13)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600, color: AdminTheme.textPrimary, fontSize: 13)),
        ],
      ),
    );
  }
}

class _SecurityTab extends StatefulWidget {
  final ProfileProvider provider;
  const _SecurityTab({Key? key, required this.provider}) : super(key: key);

  @override
  __SecurityTabState createState() => __SecurityTabState();
}

class __SecurityTabState extends State<_SecurityTab> {
  final _newPassController = TextEditingController();
  final _confirmPassController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final sessions = widget.provider.sessions;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Change Password Card
          Card(
            color: AdminTheme.card,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: AdminTheme.border)),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Change Password', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AdminTheme.textPrimary)),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _newPassController,
                    obscureText: true,
                    style: const TextStyle(color: AdminTheme.textPrimary),
                    decoration: const InputDecoration(labelText: 'New Password', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _confirmPassController,
                    obscureText: true,
                    style: const TextStyle(color: AdminTheme.textPrimary),
                    decoration: const InputDecoration(labelText: 'Confirm Password', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: AdminTheme.primary, foregroundColor: Colors.white),
                    onPressed: () async {
                      try {
                        await widget.provider.changePassword(_newPassController.text, _confirmPassController.text);
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Password changed successfully')));
                        _newPassController.clear();
                        _confirmPassController.clear();
                      } catch (e) {
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e')));
                      }
                    },
                    child: const Text('Update Password'),
                  )
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Active Sessions Card (Ref: Active Sessions Screenshot with Red Revoke Icons)
          Card(
            color: AdminTheme.card,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: AdminTheme.border)),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Active Sessions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AdminTheme.textPrimary)),
                      Text('${sessions.length} Logged In Devices', style: const TextStyle(fontSize: 12, color: AdminTheme.textSecondary, fontWeight: FontWeight.w500)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (sessions.isEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      width: double.infinity,
                      child: const Center(
                        child: Text('No active sessions found.', style: TextStyle(color: AdminTheme.textSecondary)),
                      ),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: sessions.length,
                      separatorBuilder: (_, __) => const Divider(color: AdminTheme.border, height: 1),
                      itemBuilder: (context, index) {
                        final session = sessions[index];
                        final String deviceTitle = (session.os != null && session.os!.isNotEmpty)
                            ? '${session.os} - ${session.browser ?? "Browser"}'
                            : 'Windows - Chrome';
                        final String ipText = session.ipAddress ?? '127.0.0.1';
                        final String activeTimeText = session.lastActiveTime != null
                            ? DateFormat('MMM dd, yyyy HH:mm').format(session.lastActiveTime!.toLocal())
                            : DateFormat('MMM dd, yyyy HH:mm').format(DateTime.now());

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: AdminTheme.background,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.laptop_mac_outlined, size: 22, color: AdminTheme.textPrimary),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      deviceTitle,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AdminTheme.textPrimary),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'IP: $ipText • Last active: $activeTimeText',
                                      style: const TextStyle(fontSize: 12, color: AdminTheme.textSecondary),
                                    ),
                                  ],
                                ),
                              ),

                              // Red Logout/Revoke Session Button (Matching screenshot)
                              IconButton(
                                icon: const Icon(Icons.exit_to_app_rounded, color: Color(0xFFFF3B30), size: 22),
                                tooltip: 'Revoke Session',
                                onPressed: () => _confirmTerminateSession(context, session),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Confirmation Modal when clicking red exit icon
  void _confirmTerminateSession(BuildContext context, dynamic session) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: AdminTheme.card,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: AdminTheme.danger),
              SizedBox(width: 10),
              Text('Revoke Active Session', style: TextStyle(color: AdminTheme.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          content: const SizedBox(
            width: 420,
            child: Text(
              'Are you sure you want to remove account access from this device and log out this session?',
              style: TextStyle(color: AdminTheme.textSecondary, fontSize: 14),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel', style: TextStyle(color: AdminTheme.textSecondary)),
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AdminTheme.danger,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              icon: const Icon(Icons.logout_rounded, size: 18),
              label: const Text('Logout Session'),
              onPressed: () async {
                Navigator.pop(ctx);
                try {
                  await widget.provider.terminateSession(session.id.toString());
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('✅ Active session revoked successfully.')),
                  );
                } catch (e) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed: $e')),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }
}

class _NotificationsTab extends StatelessWidget {
  final ProfileProvider provider;
  const _NotificationsTab({Key? key, required this.provider}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final prefs = provider.profile?.notificationPreferences ?? {};
    
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Card(
        color: AdminTheme.card,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: AdminTheme.border)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Notification Preferences', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AdminTheme.textPrimary)),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Email Notifications', style: TextStyle(color: AdminTheme.textPrimary)),
                value: prefs['emailNotifications'] ?? true,
                activeColor: AdminTheme.primary,
                onChanged: (val) => _updatePref(context, 'emailNotifications', val, prefs),
              ),
              SwitchListTile(
                title: const Text('Critical Safety Alerts', style: TextStyle(color: AdminTheme.textPrimary)),
                value: prefs['criticalAlerts'] ?? true,
                activeColor: AdminTheme.primary,
                onChanged: (val) => _updatePref(context, 'criticalAlerts', val, prefs),
              ),
              SwitchListTile(
                title: const Text('Support Ticket Updates', style: TextStyle(color: AdminTheme.textPrimary)),
                value: prefs['supportTicketNotifications'] ?? true,
                activeColor: AdminTheme.primary,
                onChanged: (val) => _updatePref(context, 'supportTicketNotifications', val, prefs),
              ),
              SwitchListTile(
                title: const Text('Platform Announcements', style: TextStyle(color: AdminTheme.textPrimary)),
                value: prefs['platformAnnouncements'] ?? true,
                activeColor: AdminTheme.primary,
                onChanged: (val) => _updatePref(context, 'platformAnnouncements', val, prefs),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _updatePref(BuildContext context, String key, bool value, Map<String, dynamic> currentPrefs) {
    final newPrefs = Map<String, dynamic>.from(currentPrefs);
    newPrefs[key] = value;
    provider.updateNotificationPreferences(newPrefs).catchError((e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e')));
    });
  }
}
