import 'package:flutter/material.dart';
import '../../../core/services/notification_service_ref.dart';

class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  State<NotificationSettingsPage> createState() =>
      _NotificationSettingsPageState();
}

class _NotificationSettingsPageState
    extends State<NotificationSettingsPage> {
  // ── Enabled states ──────────────────────────────────────────────────────
  bool _sarapanEnabled = true;
  bool _makanSiangEnabled = true;
  bool _snackBayiEnabled = false;
  bool _makanMalamEnabled = true;
  bool _vitaminEnabled = true;

  // ── Default times ───────────────────────────────────────────────────────
  TimeOfDay _sarapanTime = const TimeOfDay(hour: 7, minute: 0);
  TimeOfDay _siangTime = const TimeOfDay(hour: 12, minute: 0);
  TimeOfDay _snackBayiTime = const TimeOfDay(hour: 15, minute: 0);
  TimeOfDay _malamTime = const TimeOfDay(hour: 18, minute: 0);
  TimeOfDay _vitaminTime = const TimeOfDay(hour: 20, minute: 0);

  // ── Notification IDs ────────────────────────────────────────────────────
  // Sarapan    → 1
  // Makan Siang → 2
  // Snack Bayi  → 3
  // Makan Malam → 4
  // Vitamin     → 999

  @override
  void initState() {
    super.initState();
    final svc = NotificationServiceRef();
    svc.initialize();
  }

  Future<void> _pickTime(
      TimeOfDay current, ValueChanged<TimeOfDay> onPicked) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: current,
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: Color(0xFFE91E8C)),
        ),
        child: child!,
      ),
    );
    if (picked != null) onPicked(picked);
  }

  Future<void> _saveAll() async {
    final svc = NotificationServiceRef();
    await svc.requestPermission();

    // Sarapan – ID 1
    if (_sarapanEnabled) {
      await svc.scheduleDaily(
        id: 1,
        title: '🌅 Sarapan Yuk Bunda!',
        body: 'Jangan lupa sarapan untuk energi seharian.',
        hour: _sarapanTime.hour,
        minute: _sarapanTime.minute,
      );
    } else {
      await svc.cancelNotification(1);
    }

    // Makan Siang – ID 2
    if (_makanSiangEnabled) {
      await svc.scheduleDaily(
        id: 2,
        title: '☀️ Waktunya Makan Siang!',
        body: 'Pastikan asupan nutrisi siang hari tercukupi.',
        hour: _siangTime.hour,
        minute: _siangTime.minute,
      );
    } else {
      await svc.cancelNotification(2);
    }

    // Snack Bayi – ID 3
    if (_snackBayiEnabled) {
      await svc.scheduleDaily(
        id: 3,
        title: '🍪 Snack Bayi!',
        body: 'Waktunya snack bergizi untuk si kecil.',
        hour: _snackBayiTime.hour,
        minute: _snackBayiTime.minute,
      );
    } else {
      await svc.cancelNotification(3);
    }

    // Makan Malam – ID 4
    if (_makanMalamEnabled) {
      await svc.scheduleDaily(
        id: 4,
        title: '🌙 Makan Malam Bunda',
        body: 'Atur porsi makan malam agar tidak berlebihan.',
        hour: _malamTime.hour,
        minute: _malamTime.minute,
      );
    } else {
      await svc.cancelNotification(4);
    }

    // Vitamin – ID 999
    if (_vitaminEnabled) {
      await svc.scheduleDaily(
        id: 999,
        title: '💊 Jangan Lupa Vitamin!',
        body: 'Konsumsi vitamin harian untuk Bunda dan bayi.',
        hour: _vitaminTime.hour,
        minute: _vitaminTime.minute,
      );
    } else {
      await svc.cancelNotification(999);
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pengingat berhasil disimpan ✅'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Widget _reminderTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required bool enabled,
    required TimeOfDay time,
    required ValueChanged<bool> onToggle,
    required VoidCallback onTimeTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 14)),
                const SizedBox(height: 2),
                GestureDetector(
                  onTap: enabled ? onTimeTap : null,
                  child: Text(
                    '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')} • Ketuk untuk ubah',
                    style: TextStyle(
                        fontSize: 12,
                        color: enabled ? color : Colors.grey.shade400),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: enabled,
            onChanged: onToggle,
            activeColor: color,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengingat Makan & Vitamin',
            style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Sarapan – ID 1
          _reminderTile(
            title: 'Sarapan',
            subtitle: 'Setiap pagi',
            icon: Icons.wb_sunny_outlined,
            color: const Color(0xFFE91E8C),
            enabled: _sarapanEnabled,
            time: _sarapanTime,
            onToggle: (v) => setState(() => _sarapanEnabled = v),
            onTimeTap: () => _pickTime(
                _sarapanTime, (t) => setState(() => _sarapanTime = t)),
          ),

          // Makan Siang – ID 2
          _reminderTile(
            title: 'Makan Siang',
            subtitle: 'Setiap siang',
            icon: Icons.lunch_dining_outlined,
            color: const Color(0xFFFF9800),
            enabled: _makanSiangEnabled,
            time: _siangTime,
            onToggle: (v) => setState(() => _makanSiangEnabled = v),
            onTimeTap: () =>
                _pickTime(_siangTime, (t) => setState(() => _siangTime = t)),
          ),

          // Snack Bayi – ID 3 (NEW)
          _reminderTile(
            title: 'Snack Bayi',
            subtitle: 'Snack bergizi si kecil',
            icon: Icons.cookie_outlined,
            color: const Color(0xFF4CAF50),
            enabled: _snackBayiEnabled,
            time: _snackBayiTime,
            onToggle: (v) => setState(() => _snackBayiEnabled = v),
            onTimeTap: () => _pickTime(
                _snackBayiTime, (t) => setState(() => _snackBayiTime = t)),
          ),

          // Makan Malam – ID 4 (was 3)
          _reminderTile(
            title: 'Makan Malam',
            subtitle: 'Setiap malam',
            icon: Icons.dinner_dining_outlined,
            color: const Color(0xFF9C27B0),
            enabled: _makanMalamEnabled,
            time: _malamTime,
            onToggle: (v) => setState(() => _makanMalamEnabled = v),
            onTimeTap: () =>
                _pickTime(_malamTime, (t) => setState(() => _malamTime = t)),
          ),

          // Vitamin – ID 999 (was 4)
          _reminderTile(
            title: 'Minum Vitamin',
            subtitle: 'Setiap hari',
            icon: Icons.medication_outlined,
            color: const Color(0xFF2196F3),
            enabled: _vitaminEnabled,
            time: _vitaminTime,
            onToggle: (v) => setState(() => _vitaminEnabled = v),
            onTimeTap: () => _pickTime(
                _vitaminTime, (t) => setState(() => _vitaminTime = t)),
          ),

          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: _saveAll,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE91E8C),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: const Text('Simpan Pengaturan',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}