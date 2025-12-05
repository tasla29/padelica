class CenterSettingsModel {
  final String id;
  final String centerName;
  final String? address;
  final String city;
  final String? phone;
  final String? email;
  final String? logoUrl;
  final String? coverImageUrl;
  final String openingTime; // e.g., "09:00:00"
  final String closingTime; // e.g., "24:00:00"
  final int timeSlotInterval; // in minutes (e.g., 30)
  final int minBookingDuration; // in minutes (e.g., 60)
  final int maxBookingDuration; // in minutes (e.g., 120)
  final int advanceBookingDays; // how many days ahead users can book
  final int playerCancellationHours; // hours before booking players can cancel
  final double racketRentalPrice; // price per racket in RSD
  final String currency; // e.g., "RSD"
  final String timezone; // e.g., "Europe/Belgrade"
  final String? termsAndConditions;

  CenterSettingsModel({
    required this.id,
    required this.centerName,
    this.address,
    required this.city,
    this.phone,
    this.email,
    this.logoUrl,
    this.coverImageUrl,
    required this.openingTime,
    required this.closingTime,
    required this.timeSlotInterval,
    required this.minBookingDuration,
    required this.maxBookingDuration,
    required this.advanceBookingDays,
    required this.playerCancellationHours,
    required this.racketRentalPrice,
    required this.currency,
    required this.timezone,
    this.termsAndConditions,
  });

  factory CenterSettingsModel.fromJson(Map<String, dynamic> json) {
    return CenterSettingsModel(
      id: json['id'] as String,
      centerName: json['center_name'] as String? ?? 'Padel Space',
      address: json['address'] as String?,
      city: json['city'] as String? ?? 'Beograd',
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      logoUrl: json['logo_url'] as String?,
      coverImageUrl: json['cover_image_url'] as String?,
      openingTime: json['opening_time'] as String? ?? '09:00:00',
      closingTime: json['closing_time'] as String? ?? '24:00:00',
      timeSlotInterval: json['time_slot_interval'] as int? ?? 30,
      minBookingDuration: json['min_booking_duration'] as int? ?? 60,
      maxBookingDuration: json['max_booking_duration'] as int? ?? 120,
      advanceBookingDays: json['advance_booking_days'] as int? ?? 30,
      playerCancellationHours: json['player_cancellation_hours'] as int? ?? 24,
      racketRentalPrice: (json['racket_rental_price'] as num?)?.toDouble() ?? 500.0,
      currency: json['currency'] as String? ?? 'RSD',
      timezone: json['timezone'] as String? ?? 'Europe/Belgrade',
      termsAndConditions: json['terms_and_conditions'] as String?,
    );
  }

  /// Generate list of available time slots based on opening/closing times and interval
  /// Returns list of time strings in format "HH:mm" (e.g., ["09:00", "09:30", "10:00", ...])
  List<String> generateTimeSlots() {
    final slots = <String>[];
    
    // Parse opening time (e.g., "09:00:00" -> 9 hours, 0 minutes)
    final openingParts = openingTime.split(':');
    final openingHour = int.parse(openingParts[0]);
    final openingMinute = int.parse(openingParts[1]);
    
    // Parse closing time (e.g., "24:00:00" -> 24 hours = midnight next day)
    final closingParts = closingTime.split(':');
    final closingHourRaw = int.parse(closingParts[0]);
    final closingMinute = int.parse(closingParts[1]);
    final isClosingAtMidnight = closingHourRaw == 24;

    // Use 24 to represent midnight to avoid early break conditions
    final closingHour = isClosingAtMidnight ? 24 : closingHourRaw;

    var currentHour = openingHour;
    var currentMinute = openingMinute;

    while (true) {
      // Format time slot
      final timeSlot = '${currentHour.toString().padLeft(2, '0')}:${currentMinute.toString().padLeft(2, '0')}';
      slots.add(timeSlot);

      // If we've reached or passed the closing time, stop generating
      final reachedClosing = currentHour > closingHour ||
          (currentHour == closingHour && currentMinute >= closingMinute);
      if (reachedClosing) {
        break;
      }

      // Advance to next slot
      currentMinute += timeSlotInterval;
      if (currentMinute >= 60) {
        currentHour += 1;
        currentMinute -= 60;
      }

      // Prevent going past midnight when closing is 24:00
      if (isClosingAtMidnight && currentHour == 24 && currentMinute > 0) {
        break;
      }
    }

    // If closing is exactly at midnight (24:00) and we stopped on :00, ensure final marker
    if (isClosingAtMidnight && slots.isNotEmpty && slots.last != '24:00') {
      final last = slots.last.split(':');
      final lastHour = int.parse(last[0]);
      final lastMinute = int.parse(last[1]);
      if (lastHour == 23 && lastMinute + timeSlotInterval == 60) {
        slots.add('24:00');
      }
    }

    return slots;
  }

  /// Get list of valid booking durations based on min/max duration
  /// Returns list of durations in minutes (e.g., [60, 90, 120])
  List<int> getValidDurations() {
    final durations = <int>[];
    for (int duration = minBookingDuration; 
         duration <= maxBookingDuration; 
         duration += timeSlotInterval) {
      durations.add(duration);
    }
    return durations;
  }

  /// Generate list of dates available for booking
  /// Returns list of DateTime objects from today up to advanceBookingDays ahead
  List<DateTime> generateAvailableDates() {
    final now = DateTime.now();
    return List.generate(
      advanceBookingDays,
      (index) => now.add(Duration(days: index)),
    );
  }
}

