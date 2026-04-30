import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../utils/constants.dart';

class TutorBookingsScreen extends StatelessWidget {
  const TutorBookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Received Bookings',
          style: TextStyle(color: AppColors.textDark),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('bookings')
            .where('tutorEmail', isEqualTo: user?.email)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                  color: AppColors.primary),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 64,
                    color: AppColors.textLight.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No booking requests yet',
                    style: TextStyle(
                      fontSize: 18,
                      color: AppColors.textLight,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Text(
                    'Students will book sessions with you here',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textLight,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(24),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final doc = snapshot.data!.docs[index];
              final data = doc.data() as Map<String, dynamic>;
              return _BookingRequestCard(
                data: data,
                docId: doc.id,
              );
            },
          );
        },
      ),
    );
  }
}

class _BookingRequestCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final String docId;

  const _BookingRequestCard({
    required this.data,
    required this.docId,
  });

  Future<void> _updateStatus(
      BuildContext context, String status) async {
    await FirebaseFirestore.instance
        .collection('bookings')
        .doc(docId)
        .update({'status': status});

    // Send notification to student
    await FirebaseFirestore.instance
        .collection('notifications')
        .add({
      'userId': data['studentId'],
      'title': status == 'confirmed'
          ? 'Booking Confirmed! ✅'
          : 'Booking Rejected ❌',
      'message': status == 'confirmed'
          ? 'Your session with ${data['tutorName']} has been confirmed!'
          : 'Your session with ${data['tutorName']} was not accepted.',
      'type': status == 'confirmed'
          ? 'booking_confirmed'
          : 'booking_rejected',
      'createdAt': FieldValue.serverTimestamp(),
    });

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(status == 'confirmed'
              ? 'Booking confirmed! ✅'
              : 'Booking rejected'),
          backgroundColor:
              status == 'confirmed' ? Colors.green : Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = data['status'] ?? 'pending';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Student Info
          Row(
            children: [
              CircleAvatar(
                backgroundColor: AppColors.primary,
                radius: 20,
                child: Text(
                  (data['studentEmail'] ?? 'S')
                      .substring(0, 1)
                      .toUpperCase(),
                  style: const TextStyle(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data['studentEmail'] ?? 'Unknown',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                    Text(
                      data['subject'] ?? '',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              // Status Badge
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: status == 'confirmed'
                      ? Colors.green.withOpacity(0.1)
                      : status == 'rejected'
                          ? Colors.red.withOpacity(0.1)
                          : Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status.toUpperCase(),
                  style: TextStyle(
                    color: status == 'confirmed'
                        ? Colors.green
                        : status == 'rejected'
                            ? Colors.red
                            : Colors.orange,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 8),

          // Date Time Duration
          Row(
            children: [
              const Icon(Icons.calendar_today,
                  size: 14, color: AppColors.textLight),
              const SizedBox(width: 6),
              Text(
                data['date'] != null
                    ? data['date'].toString().substring(0, 10)
                    : 'No date',
                style: const TextStyle(
                    color: AppColors.textLight, fontSize: 13),
              ),
              const SizedBox(width: 16),
              const Icon(Icons.access_time,
                  size: 14, color: AppColors.textLight),
              const SizedBox(width: 6),
              Text(
                data['time'] ?? 'No time',
                style: const TextStyle(
                    color: AppColors.textLight, fontSize: 13),
              ),
              const SizedBox(width: 16),
              const Icon(Icons.timer_outlined,
                  size: 14, color: AppColors.textLight),
              const SizedBox(width: 6),
              Text(
                data['duration'] ?? '1 Hour',
                style: const TextStyle(
                    color: AppColors.textLight, fontSize: 13),
              ),
            ],
          ),

          // Action Buttons (only show for pending)
          if (status == 'pending') ...[
            const SizedBox(height: 12),
            Row(
              children: [
                // Reject Button
                Expanded(
                  child: OutlinedButton(
                    onPressed: () =>
                        _updateStatus(context, 'rejected'),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Reject',
                        style: TextStyle(color: Colors.red)),
                  ),
                ),
                const SizedBox(width: 12),
                // Confirm Button
                Expanded(
                  child: ElevatedButton(
                    onPressed: () =>
                        _updateStatus(context, 'confirmed'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: AppColors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Confirm'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}