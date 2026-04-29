# Pedometer Implementation

Dokumentasi implementasi pedometer dan accelerometer untuk step counting dan shake detection.

## 📚 Contents

- [UI Implementation](./ui-implementation.md) - Implementasi UI pedometer
- [Location Integration](./location.md) - Integrasi GPS location
- [Error Fix](./error-fix.md) - Perbaikan error pedometer

## 🎯 Overview

Pedometer implementation mencakup:

- Step counting dengan pedometer sensor
- Shake detection dengan accelerometer
- Calorie calculation berdasarkan steps
- GPS location tracking
- Real-time step updates

## 🔧 Key Features

### 1. Step Counting

```dart
// Listen to step count
final stepCountStream = Pedometer.stepCountStream;
stepCountStream.listen((StepCount event) {
  setState(() {
    _steps = event.steps;
  });
});
```

### 2. Shake Detection

```dart
// Listen to accelerometer
accelerometerEvents.listen((AccelerometerEvent event) {
  double magnitude = sqrt(
    event.x * event.x + 
    event.y * event.y + 
    event.z * event.z
  );
  
  if (magnitude > SHAKE_THRESHOLD) {
    onShakeDetected();
  }
});
```

### 3. Calorie Calculation

```dart
double calculateCalories(int steps) {
  // Average: 0.04 calories per step
  return steps * 0.04;
}
```

### 4. GPS Location

```dart
Position position = await Geolocator.getCurrentPosition(
  desiredAccuracy: LocationAccuracy.high,
);
```

## 📦 Dependencies

```yaml
dependencies:
  pedometer: ^4.0.0
  sensors_plus: ^3.0.0
  geolocator: ^10.0.0
```

## 🚀 Implementation Steps

### 1. Add Permissions

**Android** (`android/app/src/main/AndroidManifest.xml`):
```xml
<uses-permission android:name="android.permission.ACTIVITY_RECOGNITION" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
```

**iOS** (`ios/Runner/Info.plist`):
```xml
<key>NSMotionUsageDescription</key>
<string>We need access to your motion data to count steps</string>
<key>NSLocationWhenInUseUsageDescription</key>
<string>We need your location to track your activity</string>
```

### 2. Request Permissions

```dart
Future<void> requestPermissions() async {
  // Activity recognition
  if (Platform.isAndroid) {
    await Permission.activityRecognition.request();
  }
  
  // Location
  await Permission.location.request();
}
```

### 3. Initialize Pedometer

```dart
void initPedometer() {
  _stepCountStream = Pedometer.stepCountStream;
  _stepCountStream.listen(
    onStepCount,
    onError: onStepCountError,
  );
}
```

### 4. Handle Errors

```dart
void onStepCountError(error) {
  print('Pedometer error: $error');
  // Show error message to user
}
```

See: [Error Fix Guide](./error-fix.md)

## 🧪 Testing

### Unit Tests

```dart
test('should calculate calories correctly', () {
  final steps = 1000;
  final calories = calculateCalories(steps);
  expect(calories, 40.0);
});
```

### Property-Based Tests

```dart
test('calories should increase with more steps', () {
  for (int i = 0; i < 100; i++) {
    final steps1 = Random().nextInt(10000);
    final steps2 = steps1 + 1000;
    
    final calories1 = calculateCalories(steps1);
    final calories2 = calculateCalories(steps2);
    
    expect(calories2, greaterThan(calories1));
  }
});
```

## 🐛 Common Issues

### 1. Pedometer Not Working on Emulator

**Solution**: Test on physical device. Emulators don't have motion sensors.

### 2. Permission Denied

**Solution**: 
- Check permissions in manifest/Info.plist
- Request permissions at runtime
- Guide user to app settings if denied

### 3. Step Count Resets

**Solution**: 
- Save step count to local storage
- Calculate delta from last saved value
- Handle app restart

### 4. High Battery Usage

**Solution**:
- Use `SensorDelay.NORMAL` instead of `FASTEST`
- Stop listening when app is in background
- Batch updates instead of real-time

## 📊 Performance Optimization

### 1. Debounce Updates

```dart
Timer? _debounce;

void onStepCount(StepCount event) {
  if (_debounce?.isActive ?? false) _debounce!.cancel();
  
  _debounce = Timer(Duration(milliseconds: 500), () {
    setState(() {
      _steps = event.steps;
    });
  });
}
```

### 2. Background Handling

```dart
@override
void didChangeAppLifecycleState(AppLifecycleState state) {
  if (state == AppLifecycleState.paused) {
    // Stop listening to save battery
    _stepCountStream?.cancel();
  } else if (state == AppLifecycleState.resumed) {
    // Resume listening
    initPedometer();
  }
}
```

## 🔗 Related Documentation

- [Task 10: Pedometer Implementation](../../tasks/task-10/)
- [Frontend Documentation](../../frontend/)
- [Implementation Guides](../)

---

**Last Updated**: April 29, 2026
