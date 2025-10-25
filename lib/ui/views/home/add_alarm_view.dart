import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_constants.dart';
import '../../../models/alarm_model.dart';
import 'add_alarm_viewmodel.dart';

class AddAlarmView extends StatelessWidget {
  final AlarmModel? existingAlarm;
  
  const AddAlarmView({super.key, this.existingAlarm});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<AddAlarmViewModel>.reactive(
      viewModelBuilder: () => AddAlarmViewModel(),
      onViewModelReady: (viewModel) => viewModel.initialize(existingAlarm),
      builder: (context, viewModel, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text(existingAlarm != null ? 'Edit Alarm' : 'Add Alarm'),
            actions: [
              TextButton(
                onPressed: viewModel.saveAlarm,
                child: Text(
                  'Save',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(AppConstants.spacingMD),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Time Picker Section
                _buildTimePicker(context, viewModel),
                const SizedBox(height: AppConstants.spacingXL),
                
                // Alarm Label Section
                _buildLabelSection(context, viewModel),
                const SizedBox(height: AppConstants.spacingXL),
                
                // Sound Selection Section
                _buildSoundSection(context, viewModel),
                const SizedBox(height: AppConstants.spacingXL),
                
                // Smart Mode Section
                _buildSmartModeSection(context, viewModel),
                const SizedBox(height: AppConstants.spacingXL),
                
                // Repeat Days Section
                _buildRepeatDaysSection(context, viewModel),
                const SizedBox(height: AppConstants.spacingXL),
                
                // Snooze Duration Section
                _buildSnoozeSection(context, viewModel),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTimePicker(BuildContext context, AddAlarmViewModel viewModel) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingMD),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Alarm Time',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: AppConstants.spacingMD),
            InkWell(
              onTap: () => viewModel.selectTime(context),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppConstants.spacingMD),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.borderLight),
                  borderRadius: BorderRadius.circular(AppConstants.radiusMD),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      viewModel.selectedTime.format(context),
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: AppColors.primaryRed,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Icon(
                      Icons.access_time,
                      color: AppColors.primaryRed,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabelSection(BuildContext context, AddAlarmViewModel viewModel) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingMD),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Alarm Label',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: AppConstants.spacingMD),
            TextField(
              controller: viewModel.labelController,
              decoration: const InputDecoration(
                hintText: 'Enter alarm label (optional)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSoundSection(BuildContext context, AddAlarmViewModel viewModel) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingMD),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Alarm Sound',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: AppConstants.spacingMD),
            ...AppConstants.alarmSounds.map((sound) {
              return RadioListTile<String>(
                title: Text('${sound['icon']} ${sound['name']}'),
                value: sound['id'],
                groupValue: viewModel.selectedSound,
                onChanged: (value) => viewModel.setSelectedSound(value!),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildSmartModeSection(BuildContext context, AddAlarmViewModel viewModel) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingMD),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.smart_toy,
                  color: AppColors.accentBlue,
                ),
                const SizedBox(width: AppConstants.spacingSM),
                Text(
                  'Smart Mode',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ],
            ),
            const SizedBox(height: AppConstants.spacingSM),
            Text(
              'Requires you to sit up to turn off the alarm',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppConstants.spacingMD),
            SwitchListTile(
              title: const Text('Enable Smart Mode'),
              subtitle: const Text('Motion detection required'),
              value: viewModel.isSmartMode,
              onChanged: viewModel.setSmartMode,
              activeColor: AppColors.accentBlue,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRepeatDaysSection(BuildContext context, AddAlarmViewModel viewModel) {
    final days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingMD),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Repeat Days',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: AppConstants.spacingMD),
            Wrap(
              spacing: AppConstants.spacingSM,
              children: List.generate(7, (index) {
                final isSelected = viewModel.repeatDays.contains(index);
                return FilterChip(
                  label: Text(days[index]),
                  selected: isSelected,
                  onSelected: (selected) => viewModel.toggleRepeatDay(index),
                  selectedColor: AppColors.primaryRed.withOpacity(0.2),
                  checkmarkColor: AppColors.primaryRed,
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSnoozeSection(BuildContext context, AddAlarmViewModel viewModel) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingMD),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Snooze Duration',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: AppConstants.spacingMD),
            Slider(
              value: viewModel.snoozeDuration.toDouble(),
              min: 1,
              max: 30,
              divisions: 29,
              label: '${viewModel.snoozeDuration} minutes',
              onChanged: (value) => viewModel.setSnoozeDuration(value.round()),
              activeColor: AppColors.primaryRed,
            ),
            Center(
              child: Text(
                '${viewModel.snoozeDuration} minutes',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.primaryRed,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
