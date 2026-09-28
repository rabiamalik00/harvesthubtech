import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../app_config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/order_provider.dart';
import '../../widgets/pressable_scale.dart';

class FarmerReportsScreen extends StatefulWidget {
  const FarmerReportsScreen({super.key});

  @override
  State<FarmerReportsScreen> createState() => _FarmerReportsScreenState();
}

class _FarmerReportsScreenState extends State<FarmerReportsScreen> {
  String _selectedTimeframe = 'Daily';
  final List<String> _timeframes = ['Daily', 'Weekly', 'Monthly'];

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final orderProvider = Provider.of<OrderProvider>(context);

    final farmerId = auth.currentUser?.uid ?? 'farmer_1';
    final reportData = orderProvider.generateFarmerReport(farmerId, _selectedTimeframe);
    final totalRevenue = (reportData['totalRevenue'] as double);
    final totalOrders = reportData['totalOrders'] as int;
    final totalUnits = reportData['totalUnitsSold'] as int;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Sales & Financial Reports', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17)),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                const Text(
                  'Generate Sales Report',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.textPrimary, letterSpacing: -0.4),
                ).animate().fadeIn(duration: 300.ms),
                const SizedBox(height: 4),
                const Text(
                  'Select a timeframe to view your sales summary and revenue analytics',
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ).animate().fadeIn(duration: 300.ms, delay: 50.ms),
                const SizedBox(height: 18),

                // Timeframe Selector
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F3),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: _timeframes.map((tf) {
                      final isSelected = _selectedTimeframe == tf;
                      return Expanded(
                        child: PressableScale(
                          onPressed: () => setState(() => _selectedTimeframe = tf),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 220),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.primary : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: isSelected
                                  ? [BoxShadow(color: AppColors.primary.withValues(alpha: 0.25), blurRadius: 8, offset: const Offset(0, 2))]
                                  : [],
                            ),
                            child: Text(
                              tf,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 13,
                                color: isSelected ? Colors.white : AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ).animate().fadeIn(duration: 300.ms, delay: 100.ms),
                const SizedBox(height: 22),

                // Metric Cards
                _ReportMetricCard(
                  title: 'Total Revenue',
                  value: 'Rs. ${totalRevenue.toStringAsFixed(0)}',
                  subtitle: '$_selectedTimeframe earnings from confirmed orders',
                  icon: Icons.payments_rounded,
                  color: AppColors.primary,
                  delay: 150,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _ReportMetricCard(
                        title: 'Total Orders',
                        value: '$totalOrders',
                        subtitle: 'Orders placed',
                        icon: Icons.shopping_bag_rounded,
                        color: AppColors.accent,
                        delay: 200,
                        compact: true,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _ReportMetricCard(
                        title: 'Units Sold',
                        value: '$totalUnits',
                        subtitle: 'Harvest items',
                        icon: Icons.eco_rounded,
                        color: AppColors.success,
                        delay: 250,
                        compact: true,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 22),

                // Report Summary Card
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.cardBorder, width: 1.2),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF1B4332).withValues(alpha: 0.04),
                        blurRadius: 14,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: AppColors.primarySurface,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.analytics_rounded, color: AppColors.primary, size: 20),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            '$_selectedTimeframe Report Overview',
                            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: AppColors.textPrimary),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'Your $_selectedTimeframe sales summary is calculated from confirmed and completed customer orders. Maintain stock in your inventory to maximize agricultural revenue. Check back regularly for updated insights.',
                        style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary, height: 1.6),
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 300.ms, delay: 300.ms).slideY(begin: 0.04, end: 0),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ReportMetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;
  final int delay;
  final bool compact;

  const _ReportMetricCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.delay,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(compact ? 14 : 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.cardBorder, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: compact
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, color: color, size: 22),
                const SizedBox(height: 8),
                Text(title, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: color)),
                Text(subtitle, style: const TextStyle(fontSize: 10, color: AppColors.textLight)),
              ],
            )
          : Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: color, size: 26),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 2),
                      Text(value, style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: color, letterSpacing: -0.5)),
                      Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.textLight)),
                    ],
                  ),
                ),
              ],
            ),
    ).animate().fadeIn(duration: 300.ms, delay: Duration(milliseconds: delay)).slideY(begin: 0.04, end: 0);
  }
}
