import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:flutter/material.dart';
import '../home/home_view.dart';

class SplashViewModel extends BaseViewModel {
  final NavigationService _navigationService = NavigationService();

  Future<void> initialize() async {
    // Wait for minimum splash duration
    await Future.delayed(const Duration(seconds: 2));

    // Navigate to home
    await _navigationService.clearStackAndShowView(
      const HomeView(),
    );
  }
}
