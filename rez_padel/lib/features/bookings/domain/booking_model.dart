class BookingModel {
  final String id;
  final String courtId;
  final String userId;
  final String bookingDate; // Format: "YYYY-MM-DD" (e.g., "2024-12-15")
  final String startTime; // Format: "HH:mm:ss" (e.g., "18:00:00")
  final String endTime; // Format: "HH:mm:ss" (e.g., "19:30:00")
  final int durationMinutes; // 60, 90, or 120
  final String status; // 'pending', 'confirmed', 'cancelled', 'completed', 'no_show'
  final String paymentMethod; // 'online' or 'onsite'
  final String paymentStatus; // 'unpaid', 'paid', 'refunded'
  final double totalPrice; // Total amount in RSD
  final int racketRentalCount; // 0-4
  final double racketRentalPrice; // Total racket rental cost
  final String? playerName; // If booking for someone else
  final String? playerPhone; // If booking for someone else
  final String? notes; // Special requests or comments
  final DateTime? cancelledAt; // When booking was cancelled
  final String? cancellationReason; // Why booking was cancelled
  final DateTime createdAt;
  final DateTime updatedAt;

  // Optional: Court name (when joined with courts table)
  final String? courtName;

  BookingModel({
    required this.id,
    required this.courtId,
    required this.userId,
    required this.bookingDate,
    required this.startTime,
    required this.endTime,
    required this.durationMinutes,
    required this.status,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.totalPrice,
    this.racketRentalCount = 0,
    this.racketRentalPrice = 0.0,
    this.playerName,
    this.playerPhone,
    this.notes,
    this.cancelledAt,
    this.cancellationReason,
    required this.createdAt,
    required this.updatedAt,
    this.courtName,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['id'] as String,
      courtId: json['court_id'] as String,
      userId: json['user_id'] as String,
      bookingDate: json['booking_date'] as String,
      startTime: json['start_time'] as String,
      endTime: json['end_time'] as String,
      durationMinutes: json['duration_minutes'] as int,
      status: json['status'] as String? ?? 'confirmed',
      paymentMethod: json['payment_method'] as String,
      paymentStatus: json['payment_status'] as String? ?? 'unpaid',
      totalPrice: (json['total_price'] as num).toDouble(),
      racketRentalCount: json['racket_rental_count'] as int? ?? 0,
      racketRentalPrice: (json['racket_rental_price'] as num?)?.toDouble() ?? 0.0,
      playerName: json['player_name'] as String?,
      playerPhone: json['player_phone'] as String?,
      notes: json['notes'] as String?,
      cancelledAt: json['cancelled_at'] != null
          ? DateTime.parse(json['cancelled_at'] as String)
          : null,
      cancellationReason: json['cancellation_reason'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      courtName: json['court_name'] as String?, // When joined with courts table
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'court_id': courtId,
      'user_id': userId,
      'booking_date': bookingDate,
      'start_time': startTime,
      'end_time': endTime,
      'duration_minutes': durationMinutes,
      'status': status,
      'payment_method': paymentMethod,
      'payment_status': paymentStatus,
      'total_price': totalPrice,
      'racket_rental_count': racketRentalCount,
      'racket_rental_price': racketRentalPrice,
      'player_name': playerName,
      'player_phone': playerPhone,
      'notes': notes,
      'cancelled_at': cancelledAt?.toIso8601String(),
      'cancellation_reason': cancellationReason,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Convert to JSON for database insertion (excludes id, timestamps)
  Map<String, dynamic> toInsertJson() {
    return {
      'court_id': courtId,
      'user_id': userId,
      'booking_date': bookingDate,
      'start_time': startTime,
      'end_time': endTime,
      'duration_minutes': durationMinutes,
      'status': status,
      'payment_method': paymentMethod,
      'payment_status': paymentStatus,
      'total_price': totalPrice,
      'racket_rental_count': racketRentalCount,
      'racket_rental_price': racketRentalPrice,
      'player_name': playerName,
      'player_phone': playerPhone,
      'notes': notes,
    };
  }

  BookingModel copyWith({
    String? id,
    String? courtId,
    String? userId,
    String? bookingDate,
    String? startTime,
    String? endTime,
    int? durationMinutes,
    String? status,
    String? paymentMethod,
    String? paymentStatus,
    double? totalPrice,
    int? racketRentalCount,
    double? racketRentalPrice,
    String? playerName,
    String? playerPhone,
    String? notes,
    DateTime? cancelledAt,
    String? cancellationReason,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? courtName,
  }) {
    return BookingModel(
      id: id ?? this.id,
      courtId: courtId ?? this.courtId,
      userId: userId ?? this.userId,
      bookingDate: bookingDate ?? this.bookingDate,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      status: status ?? this.status,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      totalPrice: totalPrice ?? this.totalPrice,
      racketRentalCount: racketRentalCount ?? this.racketRentalCount,
      racketRentalPrice: racketRentalPrice ?? this.racketRentalPrice,
      playerName: playerName ?? this.playerName,
      playerPhone: playerPhone ?? this.playerPhone,
      notes: notes ?? this.notes,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      cancellationReason: cancellationReason ?? this.cancellationReason,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      courtName: courtName ?? this.courtName,
    );
  }

  // Status getters
  bool get isPending => status == 'pending';
  bool get isConfirmed => status == 'confirmed';
  bool get isCancelled => status == 'cancelled';
  bool get isCompleted => status == 'completed';
  bool get isNoShow => status == 'no_show';
  bool get isActive => status == 'confirmed' || status == 'pending';

  // Payment status getters
  bool get isPaid => paymentStatus == 'paid';
  bool get isUnpaid => paymentStatus == 'unpaid';
  bool get isRefunded => paymentStatus == 'refunded';

  // Payment method getters
  bool get isOnlinePayment => paymentMethod == 'online';
  bool get isOnsitePayment => paymentMethod == 'onsite';

  // Helper methods
  /// Get formatted date string (e.g., "15. Dec 2024")
  String getFormattedDate() {
    final date = DateTime.parse(bookingDate);
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Maj',
      'Jun',
      'Jul',
      'Avg',
      'Sep',
      'Okt',
      'Nov',
      'Dec'
    ];
    return '${date.day}. ${months[date.month - 1]} ${date.year}';
  }

  /// Get formatted time string (e.g., "18:00")
  String getFormattedTime() {
    // Extract HH:mm from "HH:mm:ss"
    return startTime.substring(0, 5);
  }

  /// Get formatted duration string (e.g., "90 min")
  String getFormattedDuration() {
    return '$durationMinutes min';
  }

  /// Get formatted price string (e.g., "6.500 RSD")
  String getFormattedPrice() {
    return totalPrice.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }

  /// Check if booking is in the past
  bool get isPast {
    final bookingDateTime = DateTime.parse('$bookingDate $endTime');
    return bookingDateTime.isBefore(DateTime.now());
  }

  /// Check if booking is upcoming (not past and not cancelled)
  bool get isUpcoming {
    return !isPast && !isCancelled;
  }

  /// Get the booking start DateTime
  DateTime get startDateTime {
    return DateTime.parse('$bookingDate $startTime');
  }

  /// Get the booking end DateTime
  DateTime get endDateTime {
    return DateTime.parse('$bookingDate $endTime');
  }

  /// Check if booking can be cancelled (24+ hours before start)
  bool canBeCancelled(int cancellationHoursRequired) {
    if (isCancelled) return false;
    final now = DateTime.now();
    final hoursUntilStart = startDateTime.difference(now).inHours;
    return hoursUntilStart >= cancellationHoursRequired;
  }
}

