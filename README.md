# 🚨 Stupid Alarm

> "You can't snooze the alarm until you actually wake up and sit up!"

A Flutter alarm app that refuses to be dismissed until you physically sit up —
verified by the phone's accelerometer. Built with Stacked (MVVM) for the
**"Let's Create Stupid Apps with Me"** YouTube series.

## 📱 What it does

- ⏰ **Real alarms** — exact, full-screen notifications that fire even when the
  app is closed and take over the lock screen (Android)
- 🧠 **Smart Mode** — the dismiss button stays locked until you sit up and hold
  the phone upright for 3 seconds; a progress bar tracks the hold, and flopping
  back down resets it
- 😴 **Snooze rules** — normal alarms get 3 snoozes max; Smart Mode gets none
- 🔁 **Repeat days** — weekly repeating alarms per weekday
- 🔊 **4 alarm sounds** — synthesized tones (classic, gentle, energetic,
  bird-ish "nature") looped through the ring screen
- ✅ **One-time alarms switch themselves off after ringing**, like a stock
  alarm clock
- 🌙 **Light / dark / system theme**, persisted, switchable from the home
  screen
- 🧪 **Test Alarm button** — rings in 5 seconds so you can try the whole flow

## 🏗️ How it works

```
lib/
├── app/              # DI locator & theme
├── constants/        # Colors, text styles, app constants
├── models/           # AlarmModel, theme mode
├── services/         # AlarmService (storage), NotificationService,
│                     # AlarmSchedulerService
├── utils/            # SitUpDetector, notification id hashing,
│                     # next-occurrence date math
└── ui/views/         # splash / home / add_alarm / alarm_ring (MVVM pairs)
```

The interesting parts:

- **Scheduling** — `flutter_local_notifications` `zonedSchedule` with
  `exactAllowWhileIdle`; repeating alarms use `dayOfWeekAndTime` matching (one
  weekly notification per selected weekday). Notification ids are FNV-1a
  hashes of the alarm id (Android needs 32-bit ids; the alarm ids are
  millisecond timestamps, which don't fit).
- **Ring flow** — every notification carries the full alarm as a JSON payload.
  Tapping it (or the full-screen intent launching the app from the lock
  screen) decodes the payload and jumps straight to the ring screen, which
  loops the chosen sound via `audioplayers` and vibrates until dismissed.
- **Sit-up detection** (`utils/sit_up_detector.dart`) — the accelerometer is
  low-pass filtered to isolate gravity. Lying down puts gravity on the phone's
  Z axis; sitting up and holding the phone in front of you rotates it onto +Y.
  The upright pose must be held continuously for 3 seconds — no shortcuts, and
  shaking the phone doesn't fool it.

## 🚀 Getting started

```bash
flutter pub get
flutter run
```

Regenerate the bundled sounds (optional):

```bash
python3 tool/generate_sounds.py
```

Run the tests:

```bash
flutter test
```

## 📦 Key packages

- **stacked / stacked_services** — MVVM + navigation
- **flutter_local_notifications** + **timezone** — exact alarm scheduling
- **audioplayers** — looped alarm sound on the ring screen
- **sensors_plus** — accelerometer for sit-up verification
- **shared_preferences** — alarm & settings persistence
- **google_fonts** — Poppins headings, Lato body

## ⚠️ Honest limitations

- **Android-first.** iOS gets basic notification support, but no full-screen
  lock-screen takeover and it hasn't been tested on a device.
- The notification itself plays the system default sound; your chosen sound
  starts when the ring screen opens.
- The bundled sounds are procedurally generated placeholders (see
  `tool/generate_sounds.py`) — swap in real recordings if you want nicer ones.
- Battery-optimization settings on some OEMs (Xiaomi, Huawei…) can still delay
  exact alarms; that's Android life.

## 🎥 YouTube series

Part of the "Let's Create Stupid Apps with Me" series — funny apps that solve
real problems. This one solves the snooze button.

## 📄 License

MIT — fork it, break it, wake up with it.
