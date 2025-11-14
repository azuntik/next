import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../providers/friction_providers.dart';
import '../../../core/utils/constants.dart';
import '../../../core/services/data_export_service.dart';
import '../../shortcuts_setup/presentation/shortcuts_setup_screen.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final storage = ref.watch(storageServiceProvider);

    final frictionEnabled = storage.getSetting<bool>(
      AppConstants.frictionEnabledKey,
      defaultValue: true,
    );

    final frictionIntensity = storage.getSetting<String>(
      'friction_intensity',
      defaultValue: 'medium',
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 8),

          // Friction Settings Section
          _buildSectionHeader(context, 'Friction Settings'),

          SwitchListTile(
            title: const Text('Enable Friction'),
            subtitle: const Text('Show friction moments when opening apps'),
            value: frictionEnabled ?? true,
            activeColor: const Color(AppConstants.primaryColorValue),
            onChanged: (value) {
              storage.setSetting(AppConstants.frictionEnabledKey, value);
              setState(() {});
            },
          ),

          const Divider(),

          ListTile(
            title: const Text('Friction Intensity'),
            subtitle: Text('Current: ${_capitalizeFirst(frictionIntensity!)}'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showIntensityDialog(context, storage, frictionIntensity),
          ),

          const Divider(),

          const SizedBox(height: 16),

          // Monitored Apps Section
          _buildSectionHeader(context, 'Monitored Apps'),

          ListTile(
            title: const Text('Manage Apps'),
            subtitle: const Text('Choose which apps trigger friction'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showMonitoredAppsDialog(context),
          ),

          const Divider(),

          const SizedBox(height: 16),

          // iOS Shortcuts Section (iOS only)
          if (Platform.isIOS) ...[
            _buildSectionHeader(context, 'iOS Shortcuts'),

            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.auto_awesome, color: Colors.blue[700], size: 20),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Make friction nearly automatic with iOS Shortcuts!',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),

            ListTile(
              leading: const Icon(Icons.bolt, color: Color(AppConstants.primaryColorValue)),
              title: const Text('Setup Shortcuts Automation'),
              subtitle: const Text('Step-by-step guide for automatic friction'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ShortcutsSetupScreen(),
                  ),
                );
              },
            ),

            const Divider(),

            const SizedBox(height: 16),
          ],

          // Data & Privacy Section
          _buildSectionHeader(context, 'Data & Privacy'),

          ListTile(
            title: const Text('Export Data'),
            subtitle: const Text('Download your friction moments as JSON'),
            trailing: const Icon(Icons.download),
            onTap: () => _exportData(context, storage),
          ),

          const Divider(),

          ListTile(
            title: const Text('Delete All Data'),
            subtitle: const Text('Permanently remove all friction moments'),
            trailing: const Icon(Icons.delete_outline, color: Colors.red),
            onTap: () => _confirmDeleteData(context, storage),
          ),

          const Divider(),

          const SizedBox(height: 16),

          // About Section
          _buildSectionHeader(context, 'About'),

          ListTile(
            title: const Text('App Version'),
            subtitle: const Text('1.0.0 (Phase 2)'),
          ),

          ListTile(
            title: const Text('Privacy Policy'),
            subtitle: const Text('All data stays on your device'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showPrivacyInfo(context),
          ),

          ListTile(
            title: const Text('How It Works'),
            subtitle: const Text('Learn about intentional friction'),
            trailing: const Icon(Icons.help_outline),
            onTap: () => _showHowItWorks(context),
          ),

          const SizedBox(height: 16),

          // Feedback & Support Section
          _buildSectionHeader(context, 'Feedback & Support'),

          ListTile(
            leading: const Icon(Icons.feedback_outlined, color: Color(AppConstants.primaryColorValue)),
            title: const Text('Send Feedback'),
            subtitle: const Text('Report bugs, request features, or share thoughts'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showFeedbackOptions(context),
          ),

          ListTile(
            leading: const Icon(Icons.star_outline, color: Color(AppConstants.primaryColorValue)),
            title: const Text('Rate This App'),
            subtitle: const Text('Help others discover Intentional Friction'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _promptRating(context),
          ),

          ListTile(
            leading: const Icon(Icons.code, color: Color(AppConstants.primaryColorValue)),
            title: const Text('GitHub Repository'),
            subtitle: const Text('View source code and contribute'),
            trailing: const Icon(Icons.open_in_new),
            onTap: () => _openGitHub(),
          ),

          const SizedBox(height: 32),

          // Footer
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Made with ❤️ for mindful technology use',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: const Color(AppConstants.primaryColorValue),
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  void _showIntensityDialog(
    BuildContext context,
    storage,
    String currentIntensity,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Friction Intensity'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'How often should friction moments appear?',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            RadioListTile<String>(
              title: const Text('Low'),
              subtitle: const Text('~30% of app opens'),
              value: 'low',
              groupValue: currentIntensity,
              activeColor: const Color(AppConstants.primaryColorValue),
              onChanged: (value) {
                storage.setSetting('friction_intensity', value);
                Navigator.pop(context);
                setState(() {});
              },
            ),
            RadioListTile<String>(
              title: const Text('Medium'),
              subtitle: const Text('~70% of app opens (recommended)'),
              value: 'medium',
              groupValue: currentIntensity,
              activeColor: const Color(AppConstants.primaryColorValue),
              onChanged: (value) {
                storage.setSetting('friction_intensity', value);
                Navigator.pop(context);
                setState(() {});
              },
            ),
            RadioListTile<String>(
              title: const Text('High'),
              subtitle: const Text('~95% of app opens'),
              value: 'high',
              groupValue: currentIntensity,
              activeColor: const Color(AppConstants.primaryColorValue),
              onChanged: (value) {
                storage.setSetting('friction_intensity', value);
                Navigator.pop(context);
                setState(() {});
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showMonitoredAppsDialog(BuildContext context) {
    final monitorService = ref.read(usageMonitorServiceProvider);
    final monitoredApps = monitorService.monitoredApps.toList();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Monitored Apps'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'These apps trigger friction moments:',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
            const SizedBox(height: 16),
            ...AppConstants.appNamesMap.entries
                .where((entry) => monitoredApps.contains(entry.key))
                .map((entry) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.check_circle,
                            color: Color(AppConstants.primaryColorValue),
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Text(entry.value),
                        ],
                      ),
                    )),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _exportData(BuildContext context, storage) async {
    final exportService = DataExportService(storage);
    final stats = await exportService.getExportStats();

    if (stats.totalMoments == 0) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No data to export yet')),
        );
      }
      return;
    }

    // Show export options dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Data'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Export ${stats.totalMoments} friction moments'),
            const SizedBox(height: 8),
            Text(
              stats.dateRange,
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
            ),
            const SizedBox(height: 8),
            Text(
              'Estimated size: ${stats.estimatedFileSize}',
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
            ),
            const SizedBox(height: 16),
            const Text('Choose format:', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _performExport(context, exportService, 'csv');
            },
            child: const Text('CSV (Spreadsheet)'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _performExport(context, exportService, 'json');
            },
            child: const Text('JSON (Full Data)'),
          ),
        ],
      ),
    );
  }

  Future<void> _performExport(BuildContext context, DataExportService exportService, String format) async {
    try {
      // Show loading
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Preparing export...')),
        );
      }

      final file = format == 'json'
          ? await exportService.exportAsJson()
          : await exportService.exportAsCsv();

      // Share the file
      await exportService.shareExport(
        file,
        mimeType: format == 'json' ? 'application/json' : 'text/csv',
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Export successful! Opening share sheet...')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export failed: $e')),
        );
      }
    }
  }

  void _confirmDeleteData(BuildContext context, storage) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete All Data?'),
        content: const Text(
          'This will permanently delete all your friction moments and insights. '
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await storage.deleteAllData();
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('All data deleted')),
                );
              }
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showPrivacyInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Privacy Policy'),
        content: const SingleChildScrollView(
          child: Text(
            'Your Privacy Matters\n\n'
            '• All data stays on YOUR device\n'
            '• We never track you\n'
            '• We never sell your data\n'
            '• We never send data to servers\n'
            '• No account required\n'
            '• Delete data anytime\n\n'
            'The app only accesses usage statistics to detect when you open monitored apps. '
            'This is stored locally using Hive database and never leaves your device.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showHowItWorks(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('How It Works'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'The Science',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'Your brain has two systems:\n'
                '• System 1: Fast, automatic (habits)\n'
                '• System 2: Slow, conscious (choices)\n\n'
                'Phone habits run on System 1 autopilot. '
                'Intentional Friction activates System 2.\n\n',
              ),
              Text(
                'The Process',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                '1. You try to open a social app\n'
                '2. We pause you with a question\n'
                '3. You reflect for 3 seconds\n'
                '4. You choose consciously\n\n'
                'That simple pause changes everything.',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got It'),
          ),
        ],
      ),
    );
  }

  void _showFeedbackOptions(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Send Feedback'),
        content: const Text(
          'How would you like to share your feedback?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _sendEmail(context,
                  subject: 'Intentional Friction - Bug Report');
            },
            child: const Text('Report Bug'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _sendEmail(context,
                  subject: 'Intentional Friction - Feature Request');
            },
            child: const Text('Request Feature'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _sendEmail(context,
                  subject: 'Intentional Friction - Feedback');
            },
            child: const Text('General Feedback'),
          ),
        ],
      ),
    );
  }

  Future<void> _sendEmail(BuildContext context, {required String subject}) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'feedback@intentionalfriction.app', // Replace with your email
      queryParameters: {
        'subject': subject,
        'body': '\n\n---\nApp Version: 1.0.0\nPlatform: ${Platform.isAndroid ? "Android" : "iOS"}\n',
      },
    );

    try {
      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri);
      } else {
        if (context.mounted) {
          _showContactInfo(context);
        }
      }
    } catch (e) {
      if (context.mounted) {
        _showContactInfo(context);
      }
    }
  }

  void _showContactInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Contact Information'),
        content: const SelectableText(
          'Please email us at:\nfeedback@intentionalfriction.app\n\n'
          'Or reach out on:\n'
          '• GitHub: github.com/[username]/intentional-friction\n'
          '• Twitter: @intentionalapp',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _promptRating(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rate Intentional Friction'),
        content: const Text(
          'Love the app? Your rating helps others discover mindful technology use!\n\n'
          'Would you like to rate us on the app store?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Maybe Later'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _openAppStore();
            },
            child: const Text('Rate Now'),
          ),
        ],
      ),
    );
  }

  Future<void> _openAppStore() async {
    // These URLs will need to be updated with actual app store links
    final appStoreUrl = Platform.isAndroid
        ? Uri.parse('https://play.google.com/store/apps/details?id=com.intentionalfriction.app')
        : Uri.parse('https://apps.apple.com/app/intentional-friction/id[your-app-id]');

    try {
      if (await canLaunchUrl(appStoreUrl)) {
        await launchUrl(appStoreUrl, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      // Silently fail - store not available yet
    }
  }

  Future<void> _openGitHub() async {
    final githubUrl = Uri.parse('https://github.com/[username]/intentional-friction');

    try {
      if (await canLaunchUrl(githubUrl)) {
        await launchUrl(githubUrl, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      // Silently fail
    }
  }

  String _capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }
}
