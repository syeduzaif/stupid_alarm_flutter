import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_constants.dart';
import 'home_viewmodel.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<HomeViewModel>.reactive(
      viewModelBuilder: () => HomeViewModel(),
      onViewModelReady: (viewModel) => viewModel.initialize(),
      onDispose: (viewModel) => viewModel.dispose(),
      builder: (context, viewModel, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Stupid Alarm'),
            actions: [
              IconButton(
                icon: const Icon(Icons.alarm),
                onPressed: viewModel.testAlarm,
                tooltip: 'Test Alarm',
              ),
              IconButton(
                icon: const Icon(Icons.settings),
                onPressed: viewModel.navigateToSettings,
              ),
            ],
          ),
          body: viewModel.isBusy
              ? const Center(child: CircularProgressIndicator())
              : viewModel.alarms.isEmpty
                  ? _buildEmptyState(context)
                  : _buildAlarmsList(context, viewModel),
          floatingActionButton: FloatingActionButton(
            onPressed: viewModel.addAlarm,
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.alarm_off,
            size: 100,
            color: AppColors.textSecondary.withOpacity(0.3),
          ),
          const SizedBox(height: AppConstants.spacingMD),
          Text(
            'No alarms set',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
          const SizedBox(height: AppConstants.spacingSM),
          Text(
            'Tap the + button to create one',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlarmsList(BuildContext context, HomeViewModel viewModel) {
    return ListView.builder(
      padding: const EdgeInsets.all(AppConstants.spacingMD),
      itemCount: viewModel.alarms.length,
      itemBuilder: (context, index) {
        final alarm = viewModel.alarms[index];
        return Card(
          margin: const EdgeInsets.only(bottom: AppConstants.spacingMD),
          child: ListTile(
            leading: Switch(
              value: alarm.isEnabled,
              onChanged: (value) => viewModel.toggleAlarm(alarm.id),
            ),
            title: Text(
              alarm.formattedTime12Hour,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            subtitle: Text(alarm.label),
            trailing: alarm.isSmartMode
                ? Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.accentBlue,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'SMART',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                : null,
            onTap: () => viewModel.editAlarm(alarm.id),
            onLongPress: () => viewModel.deleteAlarm(alarm.id),
          ),
        );
      },
    );
  }
}
