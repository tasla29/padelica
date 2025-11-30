import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/home_repository.dart';
import '../../bookings/domain/court_model.dart';

final activeCourtsProvider = AsyncNotifierProvider<ActiveCourtsController, List<CourtModel>>(() {
  return ActiveCourtsController();
});

class ActiveCourtsController extends AsyncNotifier<List<CourtModel>> {
  @override
  FutureOr<List<CourtModel>> build() async {
    final repository = ref.read(homeRepositoryProvider);
    return repository.getActiveCourts();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(homeRepositoryProvider);
      return repository.getActiveCourts();
    });
  }
}

