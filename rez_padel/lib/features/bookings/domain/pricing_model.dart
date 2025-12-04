class PricingModel {
  final String id;
  final String name;
  final String dayType; // 'weekday' or 'weekend'
  final double durationHours; // 1.0, 1.5, 2.0
  final String startTime; // e.g., "09:00:00"
  final String endTime; // e.g., "15:00:00"
  final double price; // Price in RSD
  final bool isActive;
  final int displayOrder;

  PricingModel({
    required this.id,
    required this.name,
    required this.dayType,
    required this.durationHours,
    required this.startTime,
    required this.endTime,
    required this.price,
    required this.isActive,
    required this.displayOrder,
  });

  factory PricingModel.fromJson(Map<String, dynamic> json) {
    return PricingModel(
      id: json['id'] as String,
      name: json['name'] as String,
      dayType: json['day_type'] as String,
      durationHours: (json['duration_hours'] as num).toDouble(),
      startTime: json['start_time'] as String,
      endTime: json['end_time'] as String,
      price: (json['price'] as num).toDouble(),
      isActive: json['is_active'] as bool? ?? true,
      displayOrder: json['display_order'] as int? ?? 0,
    );
  }

  /// Check if this pricing rule matches the given day type
  bool matchesDayType(String dayType) {
    return this.dayType == dayType;
  }

  /// Check if this pricing rule matches the given duration
  /// durationMinutes: 60, 90, or 120
  bool matchesDuration(int durationMinutes) {
    final durationHours = durationMinutes / 60.0;
    return this.durationHours == durationHours;
  }

  /// Check if the given time falls within this pricing rule's time range
  /// time: e.g., "18:00:00"
  bool matchesTimeRange(String time) {
    return time.compareTo(startTime) >= 0 && time.compareTo(endTime) < 0;
  }

  /// Check if this pricing rule applies to the given booking parameters
  bool appliesTo({
    required String dayType,
    required int durationMinutes,
    required String startTime,
  }) {
    return matchesDayType(dayType) &&
        matchesDuration(durationMinutes) &&
        matchesTimeRange(startTime);
  }

  bool get isWeekday => dayType == 'weekday';
  bool get isWeekend => dayType == 'weekend';
}

