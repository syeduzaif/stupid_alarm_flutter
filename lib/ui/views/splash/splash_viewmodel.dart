import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import '../../../services/notification_service.dart';
import '../alarm_ring/alarm_ring_view.dart';
import '../home/home_view.dart';

class SplashViewModel extends BaseViewModel {
  final NavigationService _navigationService = NavigationService();

  Future<void> initialize() async {
    // If the process was cold-started by an alarm notification (tap or
    // full-screen intent over the lock screen), skip the splash delay and
    // ring immediately.
    final launchAlarm = await NotificationService().getLaunchAlarm();
    if (launchAlarm != null) {
      await _navigationService.clearStackAndShowView(
        AlarmRingView(alarm: launchAlarm),
      );
      return;
    }

    // Wait for minimum splash duration
    await Future.delayed(const Duration(seconds: 2));

    // Navigate to home
    await _navigationService.clearStackAndShowView(
      const HomeView(),
    );
  }
}
