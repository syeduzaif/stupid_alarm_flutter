import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_constants.dart';
import '../../../models/alarm_model.dart';
import 'alarm_ring_viewmodel.dart';

class AlarmRingView extends StatelessWidget {
  final AlarmModel alarm;

  /// Overridable so widget tests can inject a viewmodel with fake sensors
  /// and no audio. Production callers rely on the default.
  final AlarmRingViewModel Function() viewModelFactory;

  const AlarmRingView({
    super.key,
    required this.alarm,
    this.viewModelFactory = AlarmRingViewModel.new,
  });

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<AlarmRingViewModel>.reactive(
      viewModelBuilder: viewModelFactory,
      onViewModelReady: (viewModel) => viewModel.initialize(alarm),
      builder: (context, viewModel, child) {
        return PopScope(
          canPop: false, // no backing out of an alarm
          child: Scaffold(
            body: Container(
              decoration: BoxDecoration(
                gradient: AppColors.alarmRingGradient,
              ),
              // Scrolls instead of overflowing on short screens; on tall
              // screens the min-height constraint keeps spaceEvenly intact.
              child: SafeArea(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      child: ConstrainedBox(
                        constraints:
                            BoxConstraints(minHeight: constraints.maxHeight),
                        child: Padding(
                          padding:
                              const EdgeInsets.all(AppConstants.spacingLG),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              // Alarm Time Display
                              _buildAlarmTime(context, viewModel),

                              const SizedBox(height: AppConstants.spacingMD),

                              // Smart Mode Instructions
                              if (viewModel.alarm?.isSmartMode == true) ...[
                                _buildSmartModeInstructions(
                                    context, viewModel),
                                const SizedBox(
                                    height: AppConstants.spacingMD),
                              ],

                              // Action Buttons
                              _buildActionButtons(context, viewModel),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
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
                color: Colors.white.withValues(alpha: 0.9),
              ),
        ),
      ],
    );
  }

  Widget _buildSmartModeInstructions(
      BuildContext context, AlarmRingViewModel viewModel) {
    final verified = viewModel.isMotionDetected;

    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingMD),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(AppConstants.radiusLG),
        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(
            verified ? Icons.check_circle : Icons.accessibility_new,
            size: 48,
            color: Colors.white,
          ),
          const SizedBox(height: AppConstants.spacingMD),
          Text(
            verified ? 'YOU\'RE UP!' : 'SMART MODE ACTIVE',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: AppConstants.spacingSM),
          Text(
            verified
                ? 'Verified. Go make some coffee.'
                : 'Sit up and hold your phone upright\nfor ${AppConstants.tiltCheckDuration} seconds',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.white,
                ),
            textAlign: TextAlign.center,
          ),
          if (!verified) ...[
            const SizedBox(height: AppConstants.spacingMD),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppConstants.radiusFull),
              child: LinearProgressIndicator(
                value: viewModel.sitUpProgress,
                minHeight: 10,
                backgroundColor: Colors.white.withValues(alpha: 0.25),
                valueColor:
                    const AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            const SizedBox(height: AppConstants.spacingSM),
            Text(
              viewModel.sitUpProgress > 0
                  ? 'Keep holding… ${(viewModel.sitUpProgress * 100).round()}%'
                  : 'Waiting for you to sit up…',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButtons(
      BuildContext context, AlarmRingViewModel viewModel) {
    final isSmartMode = viewModel.alarm?.isSmartMode == true;

    return Column(
      children: [
        // I'm Up Button
        SizedBox(
          width: double.infinity,
          height: 60,
          child: ElevatedButton(
            onPressed: isSmartMode
                ? (viewModel.isMotionDetected ? viewModel.stopAlarm : null)
                : viewModel.stopAlarm,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.primaryRed,
              disabledBackgroundColor: Colors.white.withValues(alpha: 0.4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppConstants.radiusLG),
              ),
              elevation: 8,
            ),
            child: Text(
              isSmartMode
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

        // Snooze Button (disabled in smart mode, limited otherwise)
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: viewModel.canSnooze ? viewModel.snoozeAlarm : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white.withValues(alpha: 0.3),
              foregroundColor: Colors.white,
              disabledBackgroundColor: Colors.white.withValues(alpha: 0.15),
              disabledForegroundColor: Colors.white.withValues(alpha: 0.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppConstants.radiusLG),
              ),
              elevation: 4,
            ),
            child: Text(
              viewModel.canSnooze
                  ? 'Snooze ${viewModel.alarm?.snoozeDuration ?? 5} min '
                      '(${viewModel.snoozesLeft} left)'
                  : 'Snooze ${viewModel.alarm?.snoozeDuration ?? 5} min',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),

        if (isSmartMode) ...[
          const SizedBox(height: AppConstants.spacingSM),
          Text(
            'Snooze disabled in Smart Mode',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white.withValues(alpha: 0.7),
                ),
          ),
        ] else if (!viewModel.canSnooze) ...[
          const SizedBox(height: AppConstants.spacingSM),
          Text(
            'No snoozes left — time to get up!',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white.withValues(alpha: 0.7),
                ),
          ),
        ],
      ],
    );
  }
}
