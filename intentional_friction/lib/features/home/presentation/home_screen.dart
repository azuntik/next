import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/friction_providers.dart';
import '../../../core/utils/constants.dart';
import '../../friction_moment/presentation/friction_screen.dart';
import '../../insights/presentation/insights_screen.dart';
import '../../settings/presentation/settings_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _hasPermission = false;
  int _currentIndex = 0;
  bool _isIOS = false;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
    _detectPlatform();
  }

  void _detectPlatform() {
    final monitor = ref.read(usageMonitorServiceProvider);
    setState(() {
      _isIOS = monitor.isIOS;
    });
  }

  Future<void> _checkPermissions() async {
    final monitor = ref.read(usageMonitorServiceProvider);
    final hasPermission = await monitor.requestPermissions();

    if (mounted) {
      setState(() {
        _hasPermission = hasPermission;
      });
    }
  }

  Future<void> _startMonitoring() async {
    final monitor = ref.read(usageMonitorServiceProvider);
    final engine = ref.read(frictionDecisionEngineProvider);
    final storage = ref.read(storageServiceProvider);

    try {
      await monitor.startMonitoring();

      // Listen for app launches
      monitor.appLaunchStream.listen((appPackage) async {
        // Decide if we should show friction
        if (engine.shouldShowFriction(appPackage)) {
          // Generate friction moment
          final moment = engine.generateFrictionMoment(appPackage);

          // Save to storage
          await storage.saveFrictionMoment(moment);

          // Show friction screen
          if (mounted) {
            await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => FrictionScreen(moment: moment),
                fullscreenDialog: true,
              ),
            );

            // Refresh stats after friction screen closes
            ref.invalidate(todayFrictionMomentsProvider);
          }
        }
      });

      ref.read(isMonitoringProvider.notifier).state = true;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  void _stopMonitoring() {
    final monitor = ref.read(usageMonitorServiceProvider);
    monitor.stopMonitoring();
    ref.read(isMonitoringProvider.notifier).state = false;
  }

  /// iOS-specific: Manual friction trigger
  Future<void> _triggerManualFriction() async {
    final engine = ref.read(frictionDecisionEngineProvider);
    final storage = ref.read(storageServiceProvider);

    // Generate friction moment with generic app (user will specify in future)
    final moment = engine.generateFrictionMoment('manual_trigger');

    // Save to storage
    await storage.saveFrictionMoment(moment);

    // Show friction screen
    if (mounted) {
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => FrictionScreen(moment: moment),
          fullscreenDialog: true,
        ),
      );

      // Refresh stats
      ref.invalidate(todayFrictionMomentsProvider);
    }
  }

  @override
  Widget build(BuildContext context) {
    final stats = ref.watch(todayStatsProvider);
    final isMonitoring = ref.watch(isMonitoringProvider);

    return Scaffold(
      appBar: _currentIndex != 1 && _currentIndex != 2
          ? AppBar(
              title: const Text('Intentional Friction'),
              centerTitle: true,
            )
          : null,
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildDashboardTab(stats, isMonitoring),
          const InsightsScreen(),
          const SettingsScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);
        },
        selectedItemColor: const Color(AppConstants.primaryColorValue),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.insights),
            label: 'Insights',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardTab(
    Map<String, dynamic> stats,
    bool isMonitoring,
  ) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Status card
          _buildStatusCard(isMonitoring),

          const SizedBox(height: 32),

          // Stats
          Text(
            'Today\'s Choices',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),

          _buildStatRow('Friction Moments', stats['total'].toString()),
          _buildStatRow('Proceeded', stats['proceeded'].toString()),
          _buildStatRow('Chose to Close', stats['closed'].toString()),
          _buildStatRow(
            'Mindfulness Rate',
            '${stats['mindfulnessRate']}%',
          ),

          const SizedBox(height: 32),

          // Info card
          _buildInfoCard(),

          const Spacer(),

          // iOS: Manual friction trigger
          if (_isIOS) ...[
            ElevatedButton.icon(
              onPressed: _triggerManualFriction,
              icon: const Icon(Icons.pause_circle_outline, size: 28),
              label: const Text('Pause & Reflect'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 18),
                backgroundColor: const Color(AppConstants.primaryColorValue),
                foregroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Tap this before opening social apps',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ]
          // Android: Automatic monitoring
          else ...[
            if (!_hasPermission)
              ElevatedButton(
                onPressed: _checkPermissions,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Grant Permissions'),
              )
            else if (!isMonitoring)
              ElevatedButton(
                onPressed: _startMonitoring,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: const Color(AppConstants.primaryColorValue),
                ),
                child: const Text('Start Monitoring'),
              )
            else
              ElevatedButton(
                onPressed: _stopMonitoring,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.red,
                ),
                child: const Text('Stop Monitoring'),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusCard(bool isMonitoring) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Icon(
              _isIOS ? Icons.touch_app : (isMonitoring ? Icons.shield : Icons.shield_outlined),
              size: 48,
              color: _isIOS
                  ? const Color(AppConstants.primaryColorValue)
                  : (isMonitoring
                      ? const Color(AppConstants.primaryColorValue)
                      : Colors.grey),
            ),
            const SizedBox(height: 12),
            Text(
              _isIOS
                  ? 'Manual Mode (iOS)'
                  : (isMonitoring ? 'Monitoring Active' : 'Monitoring Inactive'),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _isIOS
                  ? 'Tap "Pause & Reflect" before opening social apps'
                  : (isMonitoring
                      ? 'Friction will appear when you open monitored apps'
                      : 'Start monitoring to begin your mindful journey'),
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 16),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(AppConstants.primaryColorValue),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      color: const Color(AppConstants.primaryColorValue).withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _isIOS ? Icons.phone_iphone : Icons.info_outline,
                  size: 20,
                  color: const Color(AppConstants.primaryColorValue),
                ),
                const SizedBox(width: 8),
                Text(
                  _isIOS ? 'iOS Manual Mode' : 'Phase 2 Features',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              _isIOS
                  ? 'iOS doesn\'t allow background app monitoring. Instead:\n\n'
                      '• Tap "Pause & Reflect" before opening social apps\n'
                      '• Get a mindful friction moment\n'
                      '• Choose to proceed or close the app\n'
                      '• Track your patterns over time\n\n'
                      'Future: Siri Shortcuts for quick access!'
                  : '• All 5 friction modes (mirror, question, trade-off, breath, alternative)\n'
                      '• Emotion tracking for deeper insights\n'
                      '• Adaptive friction based on your patterns\n'
                      '• Weekly insights and recommendations\n'
                      '• Customizable intensity settings',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
