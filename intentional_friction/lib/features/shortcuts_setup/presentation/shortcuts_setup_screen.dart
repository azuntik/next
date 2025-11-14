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
  String? _setupMode; // 'quick' or 'manual'

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

  // Pre-made shortcut links (to be populated with real iCloud links)
  final Map<String, String> _shortcutLinks = {
    'Instagram': 'https://www.icloud.com/shortcuts/[instagram-id]', // Placeholder
    'Facebook': 'https://www.icloud.com/shortcuts/[facebook-id]',
    'Twitter (X)': 'https://www.icloud.com/shortcuts/[twitter-id]',
    'TikTok': 'https://www.icloud.com/shortcuts/[tiktok-id]',
    'Reddit': 'https://www.icloud.com/shortcuts/[reddit-id]',
    'YouTube': 'https://www.icloud.com/shortcuts/[youtube-id]',
    'Snapchat': 'https://www.icloud.com/shortcuts/[snapchat-id]',
    'LinkedIn': 'https://www.icloud.com/shortcuts/[linkedin-id]',
  };

  int get _totalSteps {
    if (_setupMode == null) return 4; // Intro + 3 steps
    if (_setupMode == 'quick') return 3; // Intro + import + automation
    return 4; // Intro + manual shortcut + automation + completion
  }

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
            value: (_currentStep + 1) / _totalSteps,
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
    if (_setupMode == null) {
      return _buildModeSelectionStep();
    }

    if (_setupMode == 'quick') {
      switch (_currentStep) {
        case 0:
          return _buildModeSelectionStep();
        case 1:
          return _buildQuickImportStep();
        case 2:
          return _buildCompletionStep();
        default:
          return _buildModeSelectionStep();
      }
    } else {
      // Manual mode
      switch (_currentStep) {
        case 0:
          return _buildModeSelectionStep();
        case 1:
          return _buildSiriShortcutStep();
        case 2:
          return _buildAutomationStep();
        case 3:
          return _buildCompletionStep();
        default:
          return _buildModeSelectionStep();
      }
    }
  }

  Widget _buildModeSelectionStep() {
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
          'Choose Setup Method',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'How would you like to set up friction moments for $_selectedApp?',
          style: TextStyle(fontSize: 16, height: 1.5),
        ),
        const SizedBox(height: 32),

        // Quick Import Option (Recommended)
        _buildSetupModeCard(
          mode: 'quick',
          icon: Icons.bolt,
          title: 'Quick Import (Recommended)',
          subtitle: 'Import pre-made shortcut with one tap',
          duration: '2 minutes',
          steps: '2 simple steps',
          isRecommended: true,
          badge: 'EASIEST',
        ),
        const SizedBox(height: 16),

        // Manual Setup Option
        _buildSetupModeCard(
          mode: 'manual',
          icon: Icons.construction,
          title: 'Manual Setup',
          subtitle: 'Create shortcut yourself step-by-step',
          duration: '5 minutes',
          steps: '8 detailed steps',
          isRecommended: false,
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
                  'Both methods work equally well! Quick Import is faster, '
                  'but Manual Setup gives you more control.',
                  style: TextStyle(fontSize: 14),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSetupModeCard({
    required String mode,
    required IconData icon,
    required String title,
    required String subtitle,
    required String duration,
    required String steps,
    bool isRecommended = false,
    String? badge,
  }) {
    return InkWell(
      onTap: () {
        setState(() {
          _setupMode = mode;
          _currentStep = 1; // Move to next step
        });
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isRecommended
                ? const Color(AppConstants.primaryColorValue)
                : Colors.grey[300]!,
            width: isRecommended ? 2 : 1,
          ),
          boxShadow: isRecommended
              ? [
                  BoxShadow(
                    color: const Color(AppConstants.primaryColorValue)
                        .withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  )
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  size: 32,
                  color: isRecommended
                      ? const Color(AppConstants.primaryColorValue)
                      : Colors.grey[700],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isRecommended
                                  ? const Color(AppConstants.primaryColorValue)
                                  : Colors.black,
                            ),
                          ),
                          if (badge != null) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(AppConstants.primaryColorValue),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                badge,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 20,
                  color: isRecommended
                      ? const Color(AppConstants.primaryColorValue)
                      : Colors.grey,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.schedule, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  duration,
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
                const SizedBox(width: 20),
                Icon(Icons.list, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  steps,
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickImportStep() {
    final shortcutLink = _shortcutLinks[_selectedApp] ?? '';
    final isPlaceholder = shortcutLink.contains('[') && shortcutLink.contains(']');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Import Shortcut',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Import the pre-made shortcut for $_selectedApp, then create the automation.',
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 24),

        // Step 1: Import Shortcut
        _buildInstructionCard(
          number: 1,
          title: 'Import the Shortcut',
          description: isPlaceholder
              ? 'Pre-made shortcuts coming soon! Use manual setup for now.'
              : 'Tap the button below to open the shortcut in the Shortcuts app',
          icon: Icons.download,
          child: isPlaceholder
              ? Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.construction, color: Colors.orange[700]),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Pre-made shortcuts are being created. Use Manual Setup for now.',
                          style: TextStyle(fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                )
              : ElevatedButton.icon(
                  onPressed: () {
                    // TODO: Open shortcut link (requires url_launcher package)
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'This will open the Shortcuts app to import the shortcut',
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.download),
                  label: Text('Import $_selectedApp Shortcut'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    backgroundColor: const Color(AppConstants.primaryColorValue),
                    foregroundColor: Colors.white,
                  ),
                ),
        ),

        const SizedBox(height: 12),

        // Step 2: Create Automation
        _buildInstructionCard(
          number: 2,
          title: 'Create the Automation',
          description: 'Now set up when the shortcut should run',
          icon: Icons.auto_awesome,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSubStep('a', 'Open Shortcuts app → Automation tab'),
              const SizedBox(height: 8),
              _buildSubStep('b', 'Tap + → Create Personal Automation'),
              const SizedBox(height: 8),
              _buildSubStep('c', 'Choose "App" → Select $_selectedApp → "Is Opened"'),
              const SizedBox(height: 8),
              _buildSubStep('d', 'Search for "Check $_selectedApp" shortcut'),
              const SizedBox(height: 8),
              _buildSubStep(
                'e',
                'Turn OFF "Ask Before Running"',
                highlighted: true,
              ),
              const SizedBox(height: 8),
              _buildSubStep('f', 'Tap Done!'),
            ],
          ),
        ),

        const SizedBox(height: 24),
        Container(
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
                  Icon(Icons.check_circle, color: Colors.green[700]),
                  const SizedBox(width: 12),
                  const Text(
                    'That\'s it!',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Friction will now appear automatically when you open $_selectedApp. '
                'Test it by opening the app!',
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),

        if (isPlaceholder) ...[
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                _setupMode = 'manual';
                _currentStep = 1;
              });
            },
            icon: const Icon(Icons.construction),
            label: const Text('Switch to Manual Setup'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: Colors.orange[700],
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSubStep(String letter, String text, {bool highlighted = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: highlighted
                ? Colors.orange[700]
                : Colors.grey[300],
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              letter,
              style: TextStyle(
                color: highlighted ? Colors.white : Colors.black87,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              fontWeight: highlighted ? FontWeight.bold : FontWeight.normal,
              color: highlighted ? Colors.orange[900] : Colors.black87,
            ),
          ),
        ),
      ],
    );
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
    final maxStep = _totalSteps - 1;
    final isLastStep = _currentStep >= maxStep;
    final isFirstStep = _currentStep == 0;

    // Don't show navigation on mode selection step (handled by cards)
    if (_setupMode == null) {
      return Container(
        padding: const EdgeInsets.all(20),
        child: ElevatedButton(
          onPressed: () => Navigator.pop(context),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            backgroundColor: Colors.grey[600],
            foregroundColor: Colors.white,
          ),
          child: const Text('Cancel'),
        ),
      );
    }

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
          if (!isFirstStep)
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  setState(() {
                    if (_currentStep == 1) {
                      // Going back to mode selection - reset mode
                      _setupMode = null;
                      _currentStep = 0;
                    } else {
                      _currentStep--;
                    }
                  });
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Back'),
              ),
            ),
          if (!isFirstStep) const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: () {
                if (!isLastStep) {
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
              child: Text(isLastStep ? 'Done' : 'Next'),
            ),
          ),
        ],
      ),
    );
  }
}
