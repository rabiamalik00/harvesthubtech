class MandiRate {
  final String cropName;
  final String unit;
  final double minPrice;
  final double maxPrice;
  final double avgPrice;
  final String trend; // 'up', 'down', 'stable'

  MandiRate({
    required this.cropName,
    required this.unit,
    required this.minPrice,
    required this.maxPrice,
    required this.avgPrice,
    required this.trend,
  });
}

class CropAdvisoryTip {
  final String title;
  final String crop;
  final String advisory;
  final String season;
  final String iconCode;

  CropAdvisoryTip({
    required this.title,
    required this.crop,
    required this.advisory,
    required this.season,
    required this.iconCode,
  });
}

class WeatherReport {
  final String city;
  final double temperature;
  final String condition;
  final int humidity;
  final double windSpeed;
  final int rainChance;
  final String irrigationWarning;

  WeatherReport({
    required this.city,
    required this.temperature,
    required this.condition,
    required this.humidity,
    required this.windSpeed,
    required this.rainChance,
    required this.irrigationWarning,
  });
}
