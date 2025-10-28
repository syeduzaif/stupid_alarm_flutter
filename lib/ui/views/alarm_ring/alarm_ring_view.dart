import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_constants.dart';
import '../../../models/alarm_model.dart';
import 'alarm_ring_viewmodel.dart';

class AlarmRingView extends StatelessWidget {
  final AlarmModel alarm;
  
  const AlarmRingView({super.key, required this.alarm});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<AlarmRingViewModel>.reactive(
      viewModelBuilder: () => AlarmRingViewModel(),
      onViewModelReady: (viewModel) => viewModel.initialize(alarm),
      builder: (context, viewModel, child) {
        return Scaffold(
          body: Container(
            decoration: BoxDecoration(
              gradient: AppColors.alarmRingGradient,
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.spacingLG),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Alarm Time Display
                    _buildAlarmTime(context, viewModel),
                    
                    // Smart Mode Instructions
                    if (viewModel.alarm?.isSmartMode == true) 
                      _buildSmartModeInstructions(context, viewModel),
                    
                    // Action Buttons
                    _buildActionButtons(context, viewModel),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAlarmTime(BuildContext context, AlarmRingViewModel viewModel) {
    return Column(
      children: [
        Text(
          'WAKE UP!',
          style: Theme.of(context).textTheme.displayLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: AppConstants.spacingMD),
        Text(
          viewModel.alarm?.formattedTime12Hour ?? '00:00',
          style: Theme.of(context).textTheme.displayLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppConstants.spacingSM),
        Text(
          viewModel.alarm?.label ?? 'Alarm',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: Colors.white.withOpacity(0.9),
          ),
        ),
      ],
    );
  }

  Widget _buildSmartModeInstructions(BuildContext context, AlarmRingViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingMD),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(AppConstants.radiusLG),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.smart_toy,
            size: 48,
            color: Colors.white,
          ),
          const SizedBox(height: AppConstants.spacingMD),
          Text(
            'SMART MODE ACTIVE',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppConstants.spacingSM),
          Text(
            'Sit up to turn off the alarm',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          if (viewModel.isDetectingMotion) ...[
            const SizedBox(height: AppConstants.spacingMD),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
            const SizedBox(height: AppConstants.spacingSM),
            Text(
              'Detecting motion...',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white.withOpacity(0.8),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, AlarmRingViewModel viewModel) {
    return Column(
      children: [
        // I'm Up Button
        SizedBox(
          width: double.infinity,
          height: 60,
          child: ElevatedButton(
            onPressed: viewModel.alarm?.isSmartMode == true 
                ? (viewModel.isMotionDetected ? viewModel.stopAlarm : null)
                : viewModel.stopAlarm,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.primaryRed,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppConstants.radiusLG),
              ),
              elevation: 8,
            ),
            child: Text(
              viewModel.alarm?.isSmartMode == true 
                  ? (viewModel.isMotionDetected ? 'I\'M UP!' : 'SIT UP FIRST')
                  : 'I\'M UP!',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        
        const SizedBox(height: AppConstants.spacingMD),
        
        // Snooze Button (disabled in smart mode)
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: viewModel.alarm?.isSmartMode == true ? null : viewModel.snoozeAlarm,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white.withOpacity(0.3),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppConstants.radiusLG),
              ),
              elevation: 4,
            ),
            child: Text(
              'Snooze ${viewModel.alarm?.snoozeDuration ?? 5} min',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        
        if (viewModel.alarm?.isSmartMode == true) ...[
          const SizedBox(height: AppConstants.spacingSM),
          Text(
            'Snooze disabled in Smart Mode',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.white.withOpacity(0.7),
            ),
          ),
        ],
      ],
    );
  }
}
