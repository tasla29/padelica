import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/booking_repository.dart';
import '../domain/court_model.dart';
import '../domain/pricing_model.dart';
import '../domain/center_settings_model.dart';

/// Provider for active courts
final courtsProvider = AsyncNotifierProvider<CourtsController, List<CourtModel>>(() {
  return CourtsController();
});

/// Controller for managing courts data
class CourtsController extends AsyncNotifier<List<CourtModel>> {
  @override
  FutureOr<List<CourtModel>> build() async {
    final repository = ref.read(bookingRepositoryProvider);
    return repository.getActiveCourts();
  }

  /// Refresh courts data
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(bookingRepositoryProvider);
      return repository.getActiveCourts();
    });
  }
}

/// Provider for active pricing rules
final pricingRulesProvider = AsyncNotifierProvider<PricingRulesController, List<PricingModel>>(() {
  return PricingRulesController();
});

/// Controller for managing pricing rules data
class PricingRulesController extends AsyncNotifier<List<PricingModel>> {
  @override
  FutureOr<List<PricingModel>> build() async {
    final repository = ref.read(bookingRepositoryProvider);
    return repository.getActivePricingRules();
  }

  /// Refresh pricing rules data
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(bookingRepositoryProvider);
      return repository.getActivePricingRules();
    });
  }
}

/// Provider for center settings
final centerSettingsProvider = AsyncNotifierProvider<CenterSettingsController, CenterSettingsModel?>(() {
  return CenterSettingsController();
});

/// Controller for managing center settings data
class CenterSettingsController extends AsyncNotifier<CenterSettingsModel?> {
  @override
  FutureOr<CenterSettingsModel?> build() async {
    final repository = ref.read(bookingRepositoryProvider);
    return repository.getCenterSettings();
  }

  /// Refresh center settings data
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(bookingRepositoryProvider);
      return repository.getCenterSettings();
    });
  }
}

