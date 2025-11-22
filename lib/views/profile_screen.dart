// lib/views/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../utils/app_constants.dart';
import '../utils/app_routes.dart';
import '../utils/navigation_utils.dart';
import '../services/auth_service.dart';
import '../services/settings_service.dart';
import '../widgets/bottom_nav_bar.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  static const routeName = AppRoutes.profile;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final SettingsService _settingsService = SettingsService();

  void _onTabSelected(BuildContext context, int index) {
    BottomNavNavigator.goTo(context, index);
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: kLightBackgroundColor,
      appBar: AppBar(
        backgroundColor: kLightBackgroundColor,
        elevation: 0,
        title: Row(
          children: [
            Image.asset(
              'assets/images/pomori_logo2.png',
              width: 40,
              height: 40,
            ),
            const SizedBox(width: 10),
            const Text(
              'Profile',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: kTextColor,
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              // Profile header
              Container(
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withValues(alpha: 0.1),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: kPrimaryRed.withValues(alpha: 0.1),
                      child: Icon(Icons.person, size: 50, color: kPrimaryRed),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      user?.displayName ?? 'User',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: kTextColor,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      user?.email ?? '',
                      style: TextStyle(
                        fontSize: 14,
                        color: kTextColor.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              // Settings section
              _SettingsSection(
                title: 'Settings',
                items: [
                  _SettingsItem(
                    icon: Icons.edit,
                    title: 'Edit Profile',
                    onTap: () {
                      _showEditProfileDialog(context, user);
                    },
                  ),
                  _SettingsItem(
                    icon: Icons.notifications,
                    title: 'Notifications',
                    onTap: () {
                      _showNotificationsSettings(context);
                    },
                  ),
                  _SettingsItem(
                    icon: Icons.settings,
                    title: 'App Settings',
                    onTap: () {
                      _showAppSettings(context);
                    },
                  ),
                  _SettingsItem(
                    icon: Icons.lock,
                    title: 'Change Password',
                    onTap: () {
                      _showChangePasswordDialog(context);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // About section
              _SettingsSection(
                title: 'About',
                items: [
                  _SettingsItem(
                    icon: Icons.info,
                    title: 'About Pomori',
                    onTap: () {
                      _showAboutDialog(context);
                    },
                  ),
                  _SettingsItem(
                    icon: Icons.help,
                    title: 'Help & Support',
                    onTap: () {
                      _showHelpDialog(context);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 30),
              // Logout button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    final authService = AuthService();
                    try {
                      await authService.signOut();
                      if (context.mounted) {
                        Navigator.of(context).pushNamedAndRemoveUntil(
                          AppRoutes.login,
                          (route) => false,
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Lỗi đăng xuất: $e'),
                            backgroundColor: Colors.redAccent,
                          ),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimaryRed,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: const Text(
                    'Log Out',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: 4,
        onTap: (index) => _onTabSelected(context, index),
      ),
    );
  }

  void _showEditProfileDialog(BuildContext context, User? user) {
    final nameController = TextEditingController(
      text: user?.displayName ?? '',
    );
    final emailController = TextEditingController(
      text: user?.email ?? '',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Profile'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Display Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: emailController,
                enabled: false,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await user?.updateDisplayName(nameController.text.trim());
                await user?.reload();
                if (context.mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Profile updated successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error updating profile: $e'),
                      backgroundColor: Colors.redAccent,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: kPrimaryRed,
              foregroundColor: Colors.white,
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _showNotificationsSettings(BuildContext context) async {
    if (!mounted) return;
    
    final notificationsEnabled = await _settingsService.getNotificationsEnabled();
    if (!mounted) return;
    final sessionComplete = await _settingsService.getSessionCompleteNotification();
    if (!mounted) return;
    final breakReminder = await _settingsService.getBreakReminderNotification();
    if (!mounted) return;
    final taskComplete = await _settingsService.getTaskCompleteNotification();

    if (!mounted) return;

    if (!context.mounted) return;
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          bool notificationsOn = notificationsEnabled;
          bool sessionOn = sessionComplete;
          bool breakOn = breakReminder;
          bool taskOn = taskComplete;

          return AlertDialog(
            title: const Text('Notification Settings'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SwitchListTile(
                    title: const Text('Enable Notifications'),
                    subtitle: const Text('Turn on/off all notifications'),
                    value: notificationsOn,
                    onChanged: (value) async {
                      setDialogState(() {
                        notificationsOn = value;
                        sessionOn = value;
                        breakOn = value;
                        taskOn = value;
                      });
                      await _settingsService.setNotificationsEnabled(value);
                      await _settingsService.setSessionCompleteNotification(value);
                      await _settingsService.setBreakReminderNotification(value);
                      await _settingsService.setTaskCompleteNotification(value);
                    },
                    activeThumbColor: kPrimaryRed,
                    activeTrackColor: kPrimaryRed.withValues(alpha: 0.5),
                  ),
                  const Divider(),
                  SwitchListTile(
                    title: const Text('Session Complete'),
                    subtitle: const Text('Notify when a focus session ends'),
                    value: sessionOn,
                    onChanged: notificationsOn
                        ? (value) async {
                            setDialogState(() => sessionOn = value);
                            await _settingsService.setSessionCompleteNotification(value);
                          }
                        : null,
                    activeThumbColor: kPrimaryRed,
                    activeTrackColor: kPrimaryRed.withValues(alpha: 0.5),
                  ),
                  SwitchListTile(
                    title: const Text('Break Reminder'),
                    subtitle: const Text('Remind you to take breaks'),
                    value: breakOn,
                    onChanged: notificationsOn
                        ? (value) async {
                            setDialogState(() => breakOn = value);
                            await _settingsService.setBreakReminderNotification(value);
                          }
                        : null,
                    activeThumbColor: kPrimaryRed,
                    activeTrackColor: kPrimaryRed.withValues(alpha: 0.5),
                  ),
                  SwitchListTile(
                    title: const Text('Task Complete'),
                    subtitle: const Text('Notify when a task is completed'),
                    value: taskOn,
                    onChanged: notificationsOn
                        ? (value) async {
                            setDialogState(() => taskOn = value);
                            await _settingsService.setTaskCompleteNotification(value);
                          }
                        : null,
                    activeThumbColor: kPrimaryRed,
                    activeTrackColor: kPrimaryRed.withValues(alpha: 0.5),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _showAppSettings(BuildContext context) async {
    if (!mounted) return;
    
    final themeMode = await _settingsService.getThemeMode();
    if (!mounted) return;
    final language = await _settingsService.getLanguage();
    if (!mounted) return;
    final autoStartBreak = await _settingsService.getAutoStartBreak();
    if (!mounted) return;
    final soundEnabled = await _settingsService.getSoundEnabled();
    if (!mounted) return;
    final vibrationEnabled = await _settingsService.getVibrationEnabled();

    if (!mounted) return;

    if (!context.mounted) return;
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          String currentTheme = themeMode;
          String currentLanguage = language;
          bool autoStart = autoStartBreak;
          bool sound = soundEnabled;
          bool vibration = vibrationEnabled;

          return AlertDialog(
            title: const Text('App Settings'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Theme',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(value: 'light', label: Text('Light')),
                      ButtonSegment(value: 'dark', label: Text('Dark')),
                      ButtonSegment(value: 'system', label: Text('System')),
                    ],
                    selected: {currentTheme},
                    onSelectionChanged: (Set<String> newSelection) async {
                      final value = newSelection.first;
                      setDialogState(() => currentTheme = value);
                      await _settingsService.setThemeMode(value);
                    },
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Language',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: currentLanguage,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'en', child: Text('English')),
                      DropdownMenuItem(value: 'vi', child: Text('Tiếng Việt')),
                    ],
                    onChanged: (value) async {
                      if (value != null) {
                        setDialogState(() => currentLanguage = value);
                        await _settingsService.setLanguage(value);
                      }
                    },
                  ),
                  const SizedBox(height: 20),
                  const Divider(),
                  SwitchListTile(
                    title: const Text('Auto Start Break'),
                    subtitle: const Text('Automatically start break timer after focus session'),
                    value: autoStart,
                    onChanged: (value) async {
                      setDialogState(() => autoStart = value);
                      await _settingsService.setAutoStartBreak(value);
                    },
                    activeThumbColor: kPrimaryRed,
                    activeTrackColor: kPrimaryRed.withValues(alpha: 0.5),
                  ),
                  SwitchListTile(
                    title: const Text('Sound Effects'),
                    subtitle: const Text('Play sounds for timer events'),
                    value: sound,
                    onChanged: (value) async {
                      setDialogState(() => sound = value);
                      await _settingsService.setSoundEnabled(value);
                    },
                    activeThumbColor: kPrimaryRed,
                    activeTrackColor: kPrimaryRed.withValues(alpha: 0.5),
                  ),
                  SwitchListTile(
                    title: const Text('Vibration'),
                    subtitle: const Text('Vibrate on timer events'),
                    value: vibration,
                    onChanged: (value) async {
                      setDialogState(() => vibration = value);
                      await _settingsService.setVibrationEnabled(value);
                    },
                    activeThumbColor: kPrimaryRed,
                    activeTrackColor: kPrimaryRed.withValues(alpha: 0.5),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _showChangePasswordDialog(BuildContext context) async {
    final oldPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Password'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: oldPasswordController,
                decoration: const InputDecoration(
                  labelText: 'Current Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: newPasswordController,
                decoration: const InputDecoration(
                  labelText: 'New Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: confirmPasswordController,
                decoration: const InputDecoration(
                  labelText: 'Confirm New Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final oldPassword = oldPasswordController.text.trim();
              final newPassword = newPasswordController.text.trim();
              final confirmPassword = confirmPasswordController.text.trim();

              if (oldPassword.isEmpty || newPassword.isEmpty || confirmPassword.isEmpty) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please fill in all fields'),
                      backgroundColor: Colors.redAccent,
                    ),
                  );
                }
                return;
              }

              if (newPassword != confirmPassword) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('New passwords do not match'),
                      backgroundColor: Colors.redAccent,
                    ),
                  );
                }
                return;
              }

              if (newPassword.length < 6) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Password must be at least 6 characters'),
                      backgroundColor: Colors.redAccent,
                    ),
                  );
                }
                return;
              }

              try {
                final user = FirebaseAuth.instance.currentUser;
                if (user != null && user.email != null) {
                  // Re-authenticate user
                  final credential = EmailAuthProvider.credential(
                    email: user.email!,
                    password: oldPassword,
                  );
                  await user.reauthenticateWithCredential(credential);

                  // Update password
                  await user.updatePassword(newPassword);

                  if (context.mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Password changed successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  }
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error changing password: ${e.toString()}'),
                      backgroundColor: Colors.redAccent,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: kPrimaryRed,
              foregroundColor: Colors.white,
            ),
            child: const Text('Change Password'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About Pomori'),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Pomori',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text('Version: 1.0.0'),
              SizedBox(height: 16),
              Text(
                'Pomori is a Pomodoro Technique timer app designed to help you stay focused and productive. Break your work into focused sessions with short breaks in between.',
                style: TextStyle(fontSize: 14),
              ),
              SizedBox(height: 16),
              Text(
                'Features:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text('• Pomodoro timer with focus and break sessions'),
              Text('• Task management and scheduling'),
              Text('• Statistics and progress tracking'),
              Text('• Daily goals and streaks'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Help & Support'),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'How to use Pomori:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 12),
              Text(
                '1. Create a Task:',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              Text('   Go to Tasks screen and tap the calendar icon to create a new task.'),
              SizedBox(height: 12),
              Text(
                '2. Start a Pomodoro:',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              Text('   Tap "New Pomori" or select a task to start a timer session.'),
              SizedBox(height: 12),
              Text(
                '3. Timer Controls:',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              Text('   • Play/Pause: Start or pause the timer'),
              Text('   • Skip: Move to next phase'),
              Text('   • Refill: Reset current phase time'),
              SizedBox(height: 12),
              Text(
                '4. Track Progress:',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              Text('   View your statistics and progress in the Stats screen.'),
              SizedBox(height: 16),
              Text(
                'Need more help?',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('Contact us at: support@pomori.app'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> items;

  const _SettingsSection({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 5, bottom: 10),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: kTextColor,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.1),
                spreadRadius: 1,
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(children: items),
        ),
      ],
    );
  }
}

class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _SettingsItem({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: kPrimaryRed),
      title: Text(
        title,
        style: const TextStyle(fontSize: 16, color: kTextColor),
      ),
      trailing: const Icon(Icons.chevron_right, color: kTextColor),
      onTap: onTap,
    );
  }
}

