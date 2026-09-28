import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/mock_data.dart';
import '../../providers/locale_provider.dart';
import '../../utils/app_colors.dart';
import '../../utils/formatters.dart';

class WeatherAdvisoryScreen extends StatelessWidget {
  const WeatherAdvisoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final locale = Provider.of<LocaleProvider>(context);
    final weather = MockData.sampleWeather;
    final mandiRates = MockData.currentMandiRates;
    final cropTips = MockData.cropAdvisories;

    return Scaffold(
      appBar: AppBar(
        title: Text(locale.tr('crop_advisory')),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 850),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
            // Weather Card
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: Color(0xFFBAE6FD)),
              ),
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFF0F9FF), Color(0xFFE0F2FE)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              weather.city,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF0369A1)),
                            ),
                            Text(
                              weather.condition,
                              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                        const Icon(Icons.wb_sunny, color: Colors.orange, size: 44),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 16,
                      runSpacing: 10,
                      children: [
                        Text(
                          '${weather.temperature}°C',
                          style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w900, color: Color(0xFF0C4A6E)),
                        ),
                        Wrap(
                          spacing: 14,
                          runSpacing: 8,
                          children: [
                            _buildWeatherMeta(Icons.water_drop, '${weather.humidity}%', 'Humidity'),
                            _buildWeatherMeta(Icons.air, '${weather.windSpeed} km/h', 'Wind'),
                            _buildWeatherMeta(Icons.umbrella, '${weather.rainChance}%', 'Rain Chance'),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.tips_and_updates, color: AppColors.accent, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              weather.irrigationWarning,
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Mandi Market Rates Benchmark Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  locale.tr('mandi_rates'),
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.primarySurface,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text('Live Benchmark', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary)),
                ),
              ],
            ),
            const SizedBox(height: 10),

            Card(
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: mandiRates.length,
                separatorBuilder: (_, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final rate = mandiRates[index];
                  final isUp = rate.trend == 'up';
                  final isDown = rate.trend == 'down';

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(rate.cropName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                              Text(rate.unit, style: const TextStyle(fontSize: 11, color: AppColors.textLight)),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                Formatters.formatCurrency(rate.avgPrice),
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                              Text(
                                '${Formatters.formatCurrency(rate.minPrice)} - ${Formatters.formatCurrency(rate.maxPrice)}',
                                style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Icon(
                          isUp ? Icons.trending_up : (isDown ? Icons.trending_down : Icons.trending_flat),
                          color: isUp ? AppColors.success : (isDown ? AppColors.danger : AppColors.textLight),
                          size: 20,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),

            // Sowing & Advisory Tips
            Text(
              locale.tr('sowing_tips'),
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            ...cropTips.map((tip) {
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.organicBg,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.eco, color: AppColors.organicBadge, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    tip.title,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.primarySurface,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    tip.season,
                                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.primary),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              tip.advisory,
                              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.4),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    ),
  ),
);
}

  Widget _buildWeatherMeta(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF0284C7)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF0C4A6E))),
        Text(label, style: const TextStyle(fontSize: 9, color: AppColors.textLight)),
      ],
    );
  }
}
