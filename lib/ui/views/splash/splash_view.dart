import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_constants.dart';
import 'splash_viewmodel.dart';

class SplashView extends StatelessWidget {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<SplashViewModel>.reactive(
      viewModelBuilder: () => SplashViewModel(),
      onViewModelReady: (viewModel) => viewModel.initialize(),
      builder: (context, viewModel, child) {
        return Scaffold(
          backgroundColor: AppColors.primaryRed,
          body: Container(
            decoration: BoxDecoration(
              gradient: AppColors.appBarGradient,
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // App Logo/Icon
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.alarm,
                      size: 70,
                      color: AppColors.primaryRed,
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacingXL),
                  // App Name
                  Text(
                    AppConstants.appName,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacingSM),
                  Text(
                    'Wake up for real!',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.9),
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacingXXL),
                  // Loading Indicator
                  const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
