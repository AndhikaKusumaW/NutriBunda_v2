import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/notification_provider.dart';
import 'package:intl/intl.dart';

class NotificationCenterScreen extends StatefulWidget {
  const NotificationCenterScreen({super.key});

  @override
  State<NotificationCenterScreen> createState() => _NotificationCenterScreenState();
}

class _NotificationCenterScreenState extends State<NotificationCenterScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifikasi'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Consumer<NotificationProvider>(
        builder: (context, provider, child) {
          final isVitaminEnabled = provider.vitaminEnabled;
          final isMpasiEnabled = provider.mpasiEnabled;
          final vitaminTimeStr = provider.vitaminTime; // String like "08:00"

          final List<Map<String, dynamic>> notifications = [];

          if (isVitaminEnabled && vitaminTimeStr.isNotEmpty) {
            notifications.add({
              'title': 'Pengingat Vitamin',
              'body': 'Jangan lupa minum vitamin Anda hari ini!',
              'time': vitaminTimeStr,
              'icon': Icons.medical_services,
              'color': Colors.blue,
            });
          }

          if (isMpasiEnabled) {
            final activeMeals = <String>[];
            for (int i = 0; i < provider.mpasiMeals.length; i++) {
              if (provider.mpasiMeals[i]) {
                activeMeals.add(provider.mealNames[i]);
              }
            }

            for (var meal in activeMeals) {
              // Extract time from "Makan Siang (12:00)"
              final match = RegExp(r'\((.*?)\)').firstMatch(meal);
              final time = match != null ? match.group(1) ?? '' : '';
              final name = meal.split(' (')[0];
              
              notifications.add({
                'title': 'Pengingat $name',
                'body': 'Waktunya makan untuk si kecil!',
                'time': time,
                'icon': Icons.restaurant,
                'color': Colors.orange,
              });
            }
          }

          if (notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_off,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Tidak ada notifikasi aktif',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/settings');
                    },
                    child: const Text('Atur di Pengaturan'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notif = notifications[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: notif['color'].withOpacity(0.2),
                    child: Icon(
                      notif['icon'],
                      color: notif['color'],
                    ),
                  ),
                  title: Text(
                    notif['title'],
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(notif['body']),
                  trailing: Text(
                    notif['time'],
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
