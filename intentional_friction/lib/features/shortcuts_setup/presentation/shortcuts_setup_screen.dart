import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/services/shortcuts_service.dart';
import '../../../core/utils/constants.dart';

/// Comprehensive guide for setting up iOS Shortcuts automations
class ShortcutsSetupScreen extends StatefulWidget {
  const ShortcutsSetupScreen({super.key});

  @override
  State<ShortcutsSetupScreen> createState() => _ShortcutsSetupScreenState();
}

class _ShortcutsSetupScreenState extends State<ShortcutsSetupScreen> {
  int _currentStep = 0;
  String _selectedApp = 'Instagram';

  final List<String> _commonApps = [
    'Instagram',
    'Facebook',
    'Twitter (X)',
    'TikTok',
    'Reddit',
    'YouTube',
    'Snapchat',
    'LinkedIn',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('iOS Shortcuts Setup'),
        backgroundColor: const Color(AppConstants.primaryColorValue),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Progress indicator
          LinearProgressIndicator(
            value: (_currentStep + 1) / 4,
            backgroundColor: Colors.grey[200],
            valueColor: const AlwaysStoppedAnimation<Color>(
              Color(AppConstants.primaryColorValue),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: _buildCurrentStep(),
            ),
          ),
          _buildNavigationButtons(),
        ],
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _buildIntroStep();
      case 1:
        return _buildSiriShortcutStep();
      case 2:
        return _buildAutomationStep();
      case 3:
        return _buildCompletionStep();
      default:
        return _buildIntroStep();
    }
  }

  Widget _buildIntroStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(
          Icons.auto_awesome,
          size: 64,
          color: Color(AppConstants.primaryColorValue),
        ),
        const SizedBox(height: 20),
        const Text(
          'Make iOS Friction Nearly Automatic',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'iOS doesn\'t allow apps to monitor what you open. But with iOS Shortcuts, '
          'you can set up automations that trigger friction moments automatically!',
          style: TextStyle(fontSize: 16, height: 1.5),
        ),
        const SizedBox(height: 24),
        _buildBenefitCard(
          icon: Icons.bolt,
          title: 'Nearly Automatic',
          description:
              'Once set up, friction appears when you open social apps',
        ),
        const SizedBox(height: 12),
        _buildBenefitCard(
          icon: Icons.apps,
          title: 'Per-App Control',
          description: 'Set up automation for each app you want to monitor',
        ),
        const SizedBox(height: 12),
        _buildBenefitCard(
          icon: Icons.timer,
          title: '5 Minutes Setup',
          description: 'Quick one-time setup per app, works forever',
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue[200]!),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue[700]),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'This guide will walk you through setting up one app. '
                  'You can return anytime to add more apps!',
                  style: TextStyle(fontSize: 14),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSiriShortcutStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Step 1: Add Siri Shortcut',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'First, let\'s add the "Pause & Reflect" action to Siri Shortcuts:',
          style: TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 24),
        _buildInstructionCard(
          number: 1,
          title: 'Open the Shortcuts app',
          description: 'This is Apple\'s built-in app (blue icon with white squares)',
          icon: Icons.grid_view_rounded,
        ),
        const SizedBox(height: 12),
        _buildInstructionCard(
          number: 2,
          title: 'Tap the + button',
          description: 'Located in the top right corner to create a new shortcut',
          icon: Icons.add_circle_outline,
        ),
        const SizedBox(height: 12),
        _buildInstructionCard(
          number: 3,
          title: 'Tap "Add Action"',
          description: 'This opens the actions library',
          icon: Icons.touch_app,
        ),
        const SizedBox(height: 12),
        _buildInstructionCard(
          number: 4,
          title: 'Search for "URL"',
          description: 'Select the "Open URL" action',
          icon: Icons.search,
        ),
        const SizedBox(height: 12),
        _buildInstructionCard(
          number: 5,
          title: 'Paste this URL',
          description: '',
          icon: Icons.link,
          child: _buildCopyableUrl(),
        ),
        const SizedBox(height: 12),
        _buildInstructionCard(
          number: 6,
          title: 'Name your shortcut',
          description: 'Tap the name and change it to something like "Check Instagram"',
          icon: Icons.edit,
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.green[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.green[200]!),
          ),
          child: Row(
            children: [
              Icon(Icons.check_circle_outline, color: Colors.green[700]),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Great! Now you can say "Hey Siri, Check Instagram" to trigger friction.',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAutomationStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Step 2: Create Automation',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Now let\'s make it automatic when you open the app:',
          style: TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 24),
        _buildInstructionCard(
          number: 1,
          title: 'Open Shortcuts app',
          description: 'Go to the "Automation" tab at the bottom',
          icon: Icons.bolt,
        ),
        const SizedBox(height: 12),
        _buildInstructionCard(
          number: 2,
          title: 'Tap + (top right)',
          description: 'Select "Create Personal Automation"',
          icon: Icons.add_circle_outline,
        ),
        const SizedBox(height: 12),
        _buildInstructionCard(
          number: 3,
          title: 'Select "App"',
          description: 'Choose "App" as the trigger type',
          icon: Icons.apps,
        ),
        const SizedBox(height: 12),
        _buildInstructionCard(
          number: 4,
          title: 'Choose "$_selectedApp"',
          description: 'Select "Is Opened" (not closed)',
          icon: Icons.check_box_outlined,
        ),
        const SizedBox(height: 12),
        _buildInstructionCard(
          number: 5,
          title: 'Tap "Next"',
          description: 'Now add the action',
          icon: Icons.arrow_forward,
        ),
        const SizedBox(height: 12),
        _buildInstructionCard(
          number: 6,
          title: 'Search for your shortcut',
          description: 'Find and select the shortcut you created in Step 1',
          icon: Icons.search,
        ),
        const SizedBox(height: 12),
        _buildInstructionCard(
          number: 7,
          title: 'Disable "Ask Before Running"',
          description: 'IMPORTANT: Turn this OFF for automatic friction',
          icon: Icons.toggle_off,
          highlighted: true,
        ),
        const SizedBox(height: 12),
        _buildInstructionCard(
          number: 8,
          title: 'Tap "Done"',
          description: 'Your automation is now active!',
          icon: Icons.check_circle,
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.orange[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.orange[200]!),
          ),
          child: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.orange[700]),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Step 7 is crucial! If "Ask Before Running" is ON, you\'ll get a notification '
                  'instead of automatic friction.',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCompletionStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(
          Icons.celebration,
          size: 64,
          color: Color(AppConstants.primaryColorValue),
        ),
        const SizedBox(height: 20),
        const Text(
          'You\'re All Set!',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Friction will now appear automatically when you open $_selectedApp!',
          style: const TextStyle(fontSize: 16, height: 1.5),
        ),
        const SizedBox(height: 24),
        _buildTestCard(),
        const SizedBox(height: 24),
        const Text(
          'Want to Add More Apps?',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'You can repeat this process for each social app you want to monitor. '
          'Return to Settings > iOS Shortcuts Setup anytime!',
          style: TextStyle(fontSize: 14, height: 1.5),
        ),
        const SizedBox(height: 24),
        ..._commonApps.where((app) => app != _selectedApp).map((app) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: _buildAppSetupCard(app),
          );
        }),
        const SizedBox(height: 24),
        const Text(
          'Tips for Success',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        _buildTipCard(
          icon: Icons.bolt_outlined,
          title: 'Test Your Automations',
          description: 'Try opening the app to make sure friction appears',
        ),
        const SizedBox(height: 8),
        _buildTipCard(
          icon: Icons.edit_notifications_outlined,
          title: 'Disable Notifications',
          description:
              'If you get notifications instead of friction, double-check that '
              '"Ask Before Running" is OFF',
        ),
        const SizedBox(height: 8),
        _buildTipCard(
          icon: Icons.settings_outlined,
          title: 'Manage Automations',
          description:
              'You can edit or disable automations anytime in the Shortcuts app',
        ),
      ],
    );
  }

  Widget _buildBenefitCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 32,
            color: const Color(AppConstants.primaryColorValue),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionCard({
    required int number,
    required String title,
    required String description,
    required IconData icon,
    Widget? child,
    bool highlighted = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: highlighted ? Colors.orange[50] : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: highlighted
              ? Colors.orange[300]!
              : Colors.grey[300]!,
          width: highlighted ? 2 : 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: highlighted
                  ? Colors.orange[700]
                  : const Color(AppConstants.primaryColorValue),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$number',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(icon, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                if (description.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
                if (child != null) ...[
                  const SizedBox(height: 12),
                  child,
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCopyableUrl() {
    final url = ShortcutsService.getUrlScheme(appName: _selectedApp);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              url,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 12,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.copy),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: url));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('URL copied to clipboard!'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            tooltip: 'Copy URL',
          ),
        ],
      ),
    );
  }

  Widget _buildTestCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.science_outlined, color: Colors.green[700]),
              const SizedBox(width: 12),
              const Text(
                'Test It Now!',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Try opening $_selectedApp to see if friction appears automatically. '
            'If it doesn\'t work, go back and check that "Ask Before Running" is OFF.',
            style: const TextStyle(fontSize: 14, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildAppSetupCard(String appName) {
    return InkWell(
      onTap: () {
        setState(() {
          _selectedApp = appName;
          _currentStep = 1; // Go back to Siri Shortcut step
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Row(
          children: [
            const Icon(Icons.add_circle_outline, size: 24),
            const SizedBox(width: 12),
            Text(
              'Set up $appName',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            const Icon(Icons.arrow_forward_ios, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildTipCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: const Color(AppConstants.primaryColorValue)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  setState(() {
                    _currentStep--;
                  });
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Back'),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: () {
                if (_currentStep < 3) {
                  setState(() {
                    _currentStep++;
                  });
                } else {
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: const Color(AppConstants.primaryColorValue),
                foregroundColor: Colors.white,
              ),
              child: Text(_currentStep < 3 ? 'Next' : 'Done'),
            ),
          ),
        ],
      ),
    );
  }
}
