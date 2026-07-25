import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:stupid_alarm/app/app.locator.dart';
import 'package:stupid_alarm/models/alarm_model.dart';
import 'package:stupid_alarm/ui/views/alarm_ring/alarm_ring_view.dart';
import 'package:stupid_alarm/ui/views/alarm_ring/alarm_ring_viewmodel.dart';

void main() {
  setUpAll(setupLocator);

  testWidgets('ring screen renders and unlocks dismissal for normal alarms',
      (tester) async {
    final alarm = AlarmModel(
      id: 'widget_test',
      label: 'Morning run',
      time: const TimeOfDay(hour: 6, minute: 30),
      vibrate: false, // keep the vibration timer out of the test
    );

    await tester.pumpWidget(MaterialApp(
      home: AlarmRingView(
        alarm: alarm,
        viewModelFactory: () => AlarmRingViewModel(enableAudio: false),
      ),
    ));
    await tester.pump();

    expect(find.text('WAKE UP!'), findsOneWidget);
    expect(find.text('Morning run'), findsOneWidget);
    expect(find.text('6:30 AM'), findsOneWidget);

    // Normal mode: dismiss is enabled, smart-mode UI is absent.
    final dismiss = tester.widget<ElevatedButton>(
      find.widgetWithText(ElevatedButton, 'I\'M UP!'),
    );
    expect(dismiss.onPressed, isNotNull);
    expect(find.text('SMART MODE ACTIVE'), findsNothing);

    // Unmount so the viewmodel disposes cleanly.
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('smart mode stays locked until a real sit-up is held',
      (tester) async {
    final alarm = AlarmModel(
      id: 'widget_test_smart',
      label: 'Smart wake',
      time: const TimeOfDay(hour: 7, minute: 0),
      isSmartMode: true,
      vibrate: false,
    );

    final sensor = StreamController<AccelerometerEvent>(sync: true);
    var fakeClockMs = 0;

    await tester.pumpWidget(MaterialApp(
      home: AlarmRingView(
        alarm: alarm,
        viewModelFactory: () => AlarmRingViewModel(
          enableAudio: false,
          accelerometerStream: sensor.stream,
          nowMs: () => fakeClockMs,
        ),
      ),
    ));
    await tester.pump();

    expect(find.text('SMART MODE ACTIVE'), findsOneWidget);
    expect(find.text('Snooze disabled in Smart Mode'), findsOneWidget);

    ElevatedButton dismissButton() => tester.widget<ElevatedButton>(
          find.widgetWithText(
            ElevatedButton,
            tester.any(find.text('SIT UP FIRST')) ? 'SIT UP FIRST' : 'I\'M UP!',
          ),
        );

    // Lying flat: locked, no matter how long.
    for (var i = 0; i < 100; i++) {
      fakeClockMs += 50;
      sensor.add(AccelerometerEvent(0, 0, 9.81));
    }
    await tester.pump();
    expect(find.text('SIT UP FIRST'), findsOneWidget);
    expect(dismissButton().onPressed, isNull);

    // Sitting up (phone upright) but only briefly: still locked.
    for (var i = 0; i < 20; i++) {
      fakeClockMs += 50; // 1 second upright
      sensor.add(AccelerometerEvent(0, 9.81, 0));
    }
    await tester.pump();
    expect(find.text('SIT UP FIRST'), findsOneWidget);

    // Holding upright past the 3-second requirement: unlocked. The
    // viewmodel cancels its subscription the moment verification completes,
    // so stop feeding events once nobody is listening (adding to a
    // listener-less single-subscription stream would make close() hang).
    for (var i = 0; i < 50 && sensor.hasListener; i++) {
      fakeClockMs += 50; // up to 2.5 more seconds upright
      sensor.add(AccelerometerEvent(0, 9.81, 0));
    }
    await tester.pump();
    expect(find.text('I\'M UP!'), findsOneWidget);
    expect(dismissButton().onPressed, isNotNull);
    expect(find.text('YOU\'RE UP!'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
    unawaited(sensor.close());
  });
}
