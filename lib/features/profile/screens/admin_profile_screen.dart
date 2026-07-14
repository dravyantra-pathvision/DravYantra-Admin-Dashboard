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
            return Center(child: Text('Error: ${provider.error}'));
          }

          final profile = provider.profile;
          if (profile == null) return const Center(child: Text('Profile not found'));

          return Column(
            children: [
              _buildHeader(profile),
              TabBar(
                controller: _tabController,
                labelColor: AdminTheme.primary,
                unselectedLabelColor: Colors.grey,
                indicatorColor: AdminTheme.primary,
                tabs: const [
                  Tab(text: 'Overview'),
                  Tab(text: 'Security'),
                  Tab(text: 'Notifications'),
                ],
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
            backgroundImage: profile.profilePhoto != null
                ? NetworkImage('${AppConstants.apiBaseUrl}${profile.profilePhoto}')
                : null,
            child: profile.profilePhoto == null
                ? const Icon(Icons.person, size: 40)
                : null,
          ),
          const SizedBox(width: 24),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                profile.fullName,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                profile.designation ?? 'Administrator',
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AdminTheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      profile.role.toUpperCase(),
                      style: const TextStyle(color: AdminTheme.primary, fontSize: 12),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'ACTIVE',
                      style: TextStyle(color: Colors.green, fontSize: 12),
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
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: const BorderSide(color: Colors.black12)),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Personal Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(labelText: 'Full Name', border: OutlineInputBorder()),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _phoneController,
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
                        decoration: const InputDecoration(labelText: 'Department', border: OutlineInputBorder()),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _desigController,
                        decoration: const InputDecoration(labelText: 'Designation', border: OutlineInputBorder()),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            try {
                              await widget.provider.updateProfile({
                                'full_name': _nameController.text,
                                'phone': _phoneController.text,
                                'department': _deptController.text,
                                'designation': _desigController.text,
                              });
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile updated successfully')));
                            } catch (e) {
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
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: const BorderSide(color: Colors.black12)),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Account Info', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 24),
                    _buildInfoRow('Email', widget.provider.profile!.email),
                    const Divider(),
                    _buildInfoRow('Role', widget.provider.profile!.role),
                    const Divider(),
                    _buildInfoRow('Created At', widget.provider.profile!.createdAt != null ? DateFormat('MMM dd, yyyy').format(widget.provider.profile!.createdAt!.toLocal()) : 'N/A'),
                    const SizedBox(height: 16),
                    const Text('Note: Email and Role can only be changed by a Super Admin.', style: TextStyle(color: Colors.grey, fontSize: 12)),
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
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: const BorderSide(color: Colors.black12)),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Change Password', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _newPassController,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: 'New Password', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _confirmPassController,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: 'Confirm Password', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () async {
                      try {
                        await widget.provider.changePassword(_newPassController.text, _confirmPassController.text);
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password changed successfully')));
                        _newPassController.clear();
                        _confirmPassController.clear();
                      } catch (e) {
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
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: const BorderSide(color: Colors.black12)),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Active Sessions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: widget.provider.sessions.length,
                    itemBuilder: (context, index) {
                      final session = widget.provider.sessions[index];
                      return ListTile(
                        leading: const Icon(Icons.computer),
                        title: Text('${session.os} - ${session.browser}'),
                        subtitle: Text('IP: ${session.ipAddress} • Last active: ${session.lastActiveTime != null ? DateFormat('MMM dd, yyyy HH:mm').format(session.lastActiveTime!.toLocal()) : 'N/A'}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.exit_to_app, color: Colors.red),
                          onPressed: () async {
                            try {
                              await widget.provider.terminateSession(session.id.toString());
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e')));
                            }
                          },
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          )
        ],
      ),
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
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: const BorderSide(color: Colors.black12)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Notification Preferences', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Email Notifications'),
                value: prefs['emailNotifications'] ?? true,
                onChanged: (val) => _updatePref(context, 'emailNotifications', val, prefs),
              ),
              SwitchListTile(
                title: const Text('Critical Alerts'),
                value: prefs['criticalAlerts'] ?? true,
                onChanged: (val) => _updatePref(context, 'criticalAlerts', val, prefs),
              ),
              SwitchListTile(
                title: const Text('Support Ticket Updates'),
                value: prefs['supportTicketNotifications'] ?? true,
                onChanged: (val) => _updatePref(context, 'supportTicketNotifications', val, prefs),
              ),
              SwitchListTile(
                title: const Text('Platform Announcements'),
                value: prefs['platformAnnouncements'] ?? true,
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
