import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/pattern_recognition_service.dart';
import '../../../providers/friction_providers.dart';
import '../../../core/utils/constants.dart';

class InsightsScreen extends ConsumerStatefulWidget {
  const InsightsScreen({super.key});

  @override
  ConsumerState<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends ConsumerState<InsightsScreen> {
  List<InsightData> _insights = [];
  Map<String, dynamic>? _trend;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInsights();
  }

  Future<void> _loadInsights() async {
    setState(() => _isLoading = true);

    final storage = ref.read(storageServiceProvider);
    final patternService = PatternRecognitionService(storage);

    final insights = patternService.generateWeeklyInsights();
    final trend = patternService.getMindfulnessTrend();

    setState(() {
      _insights = insights;
      _trend = trend;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Insights'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadInsights,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildInsightsContent(),
    );
  }

  Widget _buildInsightsContent() {
    if (_insights.isEmpty && (_trend?['trend'] == 'insufficient_data')) {
      return _buildInsufficientDataView();
    }

    return RefreshIndicator(
      onRefresh: _loadInsights,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Trend card
          if (_trend != null && _trend!['trend'] != 'insufficient_data')
            _buildTrendCard(),

          const SizedBox(height: 24),

          // Insights header
          if (_insights.isNotEmpty) ...[
            Row(
              children: [
                const Icon(
                  Icons.lightbulb_outline,
                  color: Color(AppConstants.primaryColorValue),
                ),
                const SizedBox(width: 8),
                Text(
                  'Your Patterns',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Based on ${_getTimeframeText()}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 16),
          ],

          // Insight cards
          ..._insights.map((insight) => _buildInsightCard(insight)).toList(),

          if (_insights.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Text(
                  'Keep using the app for a few more days to see insights!',
                  style: TextStyle(color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTrendCard() {
    final trend = _trend!['trend'] as String;
    final rate = _trend!['rate'] as double;

    IconData icon;
    Color color;
    String message;

    switch (trend) {
      case 'improving':
        icon = Icons.trending_up;
        color = Colors.green;
        message = 'Your mindfulness is improving!';
        break;
      case 'declining':
        icon = Icons.trending_down;
        color = Colors.orange;
        message = 'Your mindfulness has dipped recently';
        break;
      default:
        icon = Icons.trending_flat;
        color = Colors.blue;
        message = 'Your mindfulness is staying steady';
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              color.withOpacity(0.1),
              color.withOpacity(0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      icon,
                      color: color,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '30-Day Trend',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          message,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Current mindfulness rate',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    '${(rate * 100).round()}%',
                    style: TextStyle(
                      color: color,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInsightCard(InsightData insight) {
    IconData icon;
    Color color;

    switch (insight.type) {
      case 'emotional_trigger':
        icon = Icons.psychology;
        color = Colors.purple;
        break;
      case 'time_pattern':
        icon = Icons.access_time;
        color = Colors.blue;
        break;
      case 'progress':
        icon = Icons.celebration;
        color = Colors.green;
        break;
      case 'regression':
        icon = Icons.info_outline;
        color = Colors.orange;
        break;
      case 'app_specific':
        icon = Icons.star;
        color = Colors.amber;
        break;
      case 'behavior_change':
        icon = Icons.compare_arrows;
        color = Colors.teal;
        break;
      default:
        icon = Icons.lightbulb;
        color = const Color(AppConstants.primaryColorValue);
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    insight.message,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            if (insight.recommendations.isNotEmpty) ...[
              const SizedBox(height: 16),
              ...insight.recommendations.map((rec) => Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(top: 6, left: 4),
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            rec,
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInsufficientDataView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.analytics_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 24),
            Text(
              'Keep Going!',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            Text(
              'You need at least a week of data to see meaningful patterns and insights.',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Text(
              'Keep experiencing friction moments and we\'ll start showing you your patterns soon!',
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  String _getTimeframeText() {
    final storage = ref.read(storageServiceProvider);
    final allMoments = storage.getAllFrictionMoments();

    if (allMoments.isEmpty) return 'no data yet';

    final oldest = allMoments.last.timestamp;
    final daysSince = DateTime.now().difference(oldest).inDays;

    if (daysSince < 7) {
      return 'the last $daysSince days';
    } else {
      return 'the last 7 days';
    }
  }
}
