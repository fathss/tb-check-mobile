import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Gunakan Provider untuk halaman ini
import 'package:intl/intl.dart';
import '../notifications/providers/notification_provider.dart'; 

// Gunakan StatelessWidget saja jika hanya menggunakan Provider, 
// atau tetap pakai ConsumerStatefulWidget tapi perbaiki cara panggilnya.
class NotificationPage extends StatefulWidget {
  const NotificationPage({Key? key}) : super(key: key);

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Pastikan memanggil provider dengan benar
      Provider.of<NotificationProvider>(context, listen: false).fetchNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Notifikasi', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          TextButton(
            onPressed: () {
              // Panggil fungsi markAllAsRead yang akan kita tambahkan di Provider
              context.read<NotificationProvider>().markAllAsRead();
            },
            child: const Text('Tandai Dibaca', style: TextStyle(color: Color(0xFF1060EF), fontWeight: FontWeight.w600)),
          )
        ],
      ),
      // Gunakan Consumer dari package Provider secara spesifik
      body: Consumer<NotificationProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) return const Center(child: CircularProgressIndicator(color: Color(0xFF1060EF)));
          if (provider.notifications.isEmpty) return _buildEmptyState();

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: provider.notifications.length,
            itemBuilder: (context, index) {
              final notif = provider.notifications[index];
              return _buildNotificationCard(notif);
            },
          );
        },
      ),
    );
  }

  Widget _buildNotificationCard(dynamic notif) {
    Color iconColor;
    Color bgColor;
    IconData icon;

    switch (notif.type) {
      case 'alert':
        iconColor = Colors.red;
        bgColor = Colors.red.shade50;
        icon = Icons.warning_amber_rounded;
        break;
      case 'success':
        iconColor = Colors.green;
        bgColor = Colors.green.shade50;
        icon = Icons.emoji_events_rounded;
        break;
      default:
        iconColor = const Color(0xFF1060EF);
        bgColor = const Color(0xFFE9F0FF);
        icon = Icons.medication_rounded;
        break;
    }

    return InkWell(
      onTap: () {
        if (!notif.isRead) {
          context.read<NotificationProvider>().markAsRead(notif.id);
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 1),
        color: notif.isRead ? Colors.transparent : const Color(0xFF1060EF).withOpacity(0.05),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          notif.title, 
                          style: TextStyle(
                            fontWeight: notif.isRead ? FontWeight.w600 : FontWeight.bold, 
                            fontSize: 15, 
                            color: Colors.black87
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (!notif.isRead)
                        Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(notif.message, style: TextStyle(color: Colors.grey.shade700, fontSize: 13, height: 1.4)),
                  const SizedBox(height: 8),
                  Text(
                    DateFormat('HH:mm').format(notif.createdAt) + " WIB", 
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 11, fontWeight: FontWeight.w500)
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_off_rounded, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          const Text('Belum Ada Notifikasi', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
          const SizedBox(height: 8),
          Text('Pesan pengingat dan informasi\nakan muncul di sini.', 
            textAlign: TextAlign.center, 
            style: TextStyle(color: Colors.grey.shade500, fontSize: 14)),
        ],
      ),
    );
  }
}