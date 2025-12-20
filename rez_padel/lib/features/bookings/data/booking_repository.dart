import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/supabase_client.dart';
import '../domain/court_model.dart';
import '../domain/pricing_model.dart';
import '../domain/center_settings_model.dart';
import '../domain/booking_model.dart';

final bookingRepositoryProvider = Provider<BookingRepository>((ref) {
  return BookingRepository(ref.read(supabaseClientProvider));
});

final userBookingsProvider = FutureProvider<List<BookingModel>>((ref) async {
  final repository = ref.watch(bookingRepositoryProvider);
  return repository.getUserBookings();
});

class BookingRepository {
  final SupabaseClient _supabase;

  BookingRepository(this._supabase);

  /// Fetch all active courts from the database
  Future<List<CourtModel>> getActiveCourts() async {
    try {
      final response = await _supabase
          .from('courts')
          .select()
          .eq('status', 'active')
          .order('display_order', ascending: true);

      return (response as List<dynamic>)
          .map((json) => CourtModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Greška pri učitavanju terena: $e');
    }
  }

  /// Fetch all active pricing rules from the database
  Future<List<PricingModel>> getActivePricingRules() async {
    try {
      final response = await _supabase
          .from('pricing')
          .select()
          .eq('is_active', true)
          .order('display_order', ascending: true);

      return (response as List<dynamic>)
          .map((json) => PricingModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Greška pri učitavanju cenovnika: $e');
    }
  }

  /// Fetch center settings from the database (single row)
  Future<CenterSettingsModel?> getCenterSettings() async {
    try {
      final response = await _supabase
          .from('center_settings')
          .select()
          .single();

      return CenterSettingsModel.fromJson(response);
    } catch (e) {
      // If settings don't exist, return null (will use defaults)
      throw Exception('Greška pri učitavanju podešavanja centra: $e');
    }
  }

  /// Calculate price for a booking based on date, time, and duration
  /// Returns the price in RSD
  Future<double> calculatePrice({
    required String bookingDate, // Format: "YYYY-MM-DD"
    required String startTime, // Format: "HH:mm:ss"
    required int durationMinutes, // 60, 90, or 120
    double racketRentalPrice = 0.0, // Additional racket rental cost
  }) async {
    try {
      // Get pricing rules
      final pricingRules = await getActivePricingRules();
      if (pricingRules.isEmpty) {
        throw Exception('Nema dostupnih cenovnih pravila');
      }

      // Determine day type (weekday or weekend)
      final dayType = _getDayType(bookingDate);

      // Find matching pricing rule
      final matchingRule = pricingRules.firstWhere(
        (rule) => rule.appliesTo(
          dayType: dayType,
          durationMinutes: durationMinutes,
          startTime: startTime,
        ),
        orElse: () => throw Exception(
          'Nema odgovarajuće cene za izabrano vreme i trajanje',
        ),
      );

      // Return base price + racket rental
      return matchingRule.price + racketRentalPrice;
    } catch (e) {
      throw Exception('Greška pri izračunavanju cene: $e');
    }
  }

  /// Determine if a date is weekday or weekend
  String _getDayType(String dateString) {
    final date = DateTime.parse(dateString);
    // 1 = Monday, 7 = Sunday
    final weekday = date.weekday;
    return (weekday >= 1 && weekday <= 5) ? 'weekday' : 'weekend';
  }

  /// Check if a time slot is available for a court on a specific date
  /// Returns true if slot is available, false if occupied
  Future<bool> checkSlotAvailability({
    required String courtId,
    required String bookingDate, // Format: "YYYY-MM-DD"
    required String startTime, // Format: "HH:mm:ss"
    required String endTime, // Format: "HH:mm:ss"
  }) async {
    try {
      // Use RPC to bypass RLS while returning only minimal, non-PII fields
      final response = await _supabase
          .rpc('get_booked_intervals', params: {'p_date': bookingDate});

      bool hasOverlap = false;
      for (final raw in (response as List<dynamic>)) {
        final map = raw as Map<String, dynamic>;
        if (map['court_id'] != courtId) continue;

        final existingStart = map['start_time'] as String;
        final existingEnd = map['end_time'] as String;

        // Overlap condition: existing.start < requested.end AND existing.end > requested.start
        if (existingStart.compareTo(endTime) < 0 && existingEnd.compareTo(startTime) > 0) {
          hasOverlap = true;
          break;
        }
      }

      return !hasOverlap;
    } catch (e) {
      throw Exception('Greška pri proveri dostupnosti termina: $e');
    }
  }

  /// Get all bookings for a specific court and date
  Future<List<BookingModel>> getBookingsForDate({
    required String courtId,
    required String bookingDate, // Format: "YYYY-MM-DD"
  }) async {
    try {
      final response = await _supabase
          .from('bookings')
          .select()
          .eq('court_id', courtId)
          .eq('booking_date', bookingDate)
          .or('status.eq.confirmed,status.eq.pending')
          .order('start_time', ascending: true);

      return (response as List<dynamic>)
          .map((json) => BookingModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Greška pri učitavanju rezervacija: $e');
    }
  }

  /// Get all bookings for a specific date across all courts (confirmed or pending)
  Future<List<BookingModel>> getAllBookingsForDate({
    required String bookingDate, // Format: "YYYY-MM-DD"
  }) async {
    try {
      // Fetch minimal booked intervals via RPC (bypasses RLS, no PII)
      final response = await _supabase
          .rpc('get_booked_intervals', params: {'p_date': bookingDate});

      return (response as List<dynamic>).map((raw) {
        final map = raw as Map<String, dynamic>;
        final start = map['start_time'] as String;
        final end = map['end_time'] as String;
        final durationMinutes = _diffMinutes(start, end);

        return BookingModel(
          id: map['id']?.toString() ??
              'rpc-${map['court_id']}-${map['start_time']}-${map['end_time']}',
          courtId: map['court_id'] as String,
          userId: '',
          bookingDate: bookingDate,
          startTime: start,
          endTime: end,
          durationMinutes: durationMinutes,
          status: map['status'] as String? ?? 'confirmed',
          paymentMethod: 'onsite',
          paymentStatus: 'unpaid',
          totalPrice: 0,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          racketRentalCount: 0,
          racketRentalPrice: 0,
          playerName: null,
          playerPhone: null,
          notes: null,
          cancelledAt: null,
          cancellationReason: null,
          courtName: null,
        );
      }).toList();
    } catch (e) {
      throw Exception('Greška pri učitavanju rezervacija: $e');
    }
  }

  int _diffMinutes(String startTime, String endTime) {
    final startParts = startTime.split(':');
    final endParts = endTime.split(':');
    final startMinutes = int.parse(startParts[0]) * 60 + int.parse(startParts[1]);
    final endMinutes = int.parse(endParts[0]) * 60 + int.parse(endParts[1]);
    return endMinutes - startMinutes;
  }

  /// Create a new booking
  /// Returns the created booking
  Future<BookingModel> createBooking({
    required String courtId,
    required String bookingDate, // Format: "YYYY-MM-DD"
    required String startTime, // Format: "HH:mm:ss"
    required String endTime, // Format: "HH:mm:ss"
    required int durationMinutes,
    required String paymentMethod, // 'online' or 'onsite'
    required double totalPrice,
    int racketRentalCount = 0,
    double racketRentalPrice = 0.0,
    String? playerName,
    String? playerPhone,
    String? notes,
  }) async {
    try {
      // Get current user ID
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('Korisnik nije prijavljen');
      }

      // Check if the booking is in the past
      final now = DateTime.now();
      final bookingDateTime = DateTime.parse('$bookingDate $startTime');
      // 30 minute buffer
      if (bookingDateTime.isBefore(now.add(const Duration(minutes: 30)))) {
        throw Exception('Termin više nije dostupan');
      }

      // Final availability check before creating booking
      final isAvailable = await checkSlotAvailability(
        courtId: courtId,
        bookingDate: bookingDate,
        startTime: startTime,
        endTime: endTime,
      );

      if (!isAvailable) {
        throw Exception('Termin više nije dostupan');
      }

      // Determine payment status based on payment method
      final paymentStatus = paymentMethod == 'online' ? 'paid' : 'unpaid';

      // Create booking data
      final bookingData = {
        'court_id': courtId,
        'user_id': userId,
        'booking_date': bookingDate,
        'start_time': startTime,
        'end_time': endTime,
        'duration_minutes': durationMinutes,
        'status': 'confirmed',
        'payment_method': paymentMethod,
        'payment_status': paymentStatus,
        'total_price': totalPrice,
        'racket_rental_count': racketRentalCount,
        'racket_rental_price': racketRentalPrice,
        if (playerName != null) 'player_name': playerName,
        if (playerPhone != null) 'player_phone': playerPhone,
        if (notes != null) 'notes': notes,
      };

      // Insert booking
      final response = await _supabase
          .from('bookings')
          .insert(bookingData)
          .select()
          .single();

      return BookingModel.fromJson(response);
    } catch (e) {
      if (e.toString().contains('duplicate') ||
          e.toString().contains('unique') ||
          e.toString().contains('overlap')) {
        throw Exception('Termin više nije dostupan');
      }
      throw Exception('Greška pri kreiranju rezervacije: $e');
    }
  }

  /// Get user's bookings
  /// Returns list of bookings for the current user
  Future<List<BookingModel>> getUserBookings({
    String? status, // Optional filter by status
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('Korisnik nije prijavljen');
      }

      var query = _supabase
          .from('bookings')
          .select('*, courts(name)') // Join with courts to get court name
          .eq('user_id', userId);

      // Apply status filter if provided
      if (status != null) {
        query = query.eq('status', status);
      }

      final response = await query
          .order('booking_date', ascending: false)
          .order('start_time', ascending: false);

      return (response as List).map((json) {
        final bookingJson = json;
        // Extract court name from joined data
        if (bookingJson['courts'] != null) {
          final courtsData = bookingJson['courts'] as Map<String, dynamic>;
          bookingJson['court_name'] = courtsData['name'] as String?;
        }
        return BookingModel.fromJson(bookingJson);
      }).toList();
    } catch (e) {
      throw Exception('Greška pri učitavanju rezervacija: $e');
    }
  }
}

