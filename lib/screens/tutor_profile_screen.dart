import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../utils/constants.dart';
import 'booking_screen.dart';
import 'chat_screen.dart';

class TutorProfileScreen extends StatelessWidget {
  final Map<String, dynamic> tutorData;

  const TutorProfileScreen({super.key, required this.tutorData});

  Future<void> _startChat(BuildContext context) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    final tutorEmail = tutorData['email'];

    // Check if chat already exists
    final existingChat = await FirebaseFirestore.instance
        .collection('chats')
        .where('participants', arrayContains: currentUser?.uid)
        .get();

    String? chatId;

    for (var doc in existingChat.docs) {
      final data = doc.data();
      if (data['tutorEmail'] == tutorEmail ||
          data['studentEmail'] == tutorEmail) {
        chatId = doc.id;
        break;
      }
    }

    // Create new chat if doesn't exist
    if (chatId == null) {
      final newChat = await FirebaseFirestore.instance
          .collection('chats')
          .add({
        'participants': [currentUser?.uid],
        'studentEmail': currentUser?.email,
        'studentName': currentUser?.email?.split('@')[0],
        'tutorEmail': tutorEmail,
        'tutorName': tutorData['name'],
        'lastMessage': '',
        'createdAt': FieldValue.serverTimestamp(),
      });
      chatId = newChat.id;
    }

    if (context.mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatRoomScreen(
            chatId: chatId!,
            otherPersonName: tutorData['name'] ?? 'Tutor',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
          'Tutor Profile',
          style: TextStyle(color: AppColors.textDark),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Header
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    backgroundColor: AppColors.primary,
                    radius: 50,
                    child: Text(
                      (tutorData['name'] ?? 'T')
                          .toString()
                          .substring(0, 1)
                          .toUpperCase(),
                      style: const TextStyle(
                        color: AppColors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 40,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    tutorData['name'] ?? 'Unknown',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  Text(
                    tutorData['subject'] ?? '',
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.star,
                          color: Colors.amber, size: 20),
                      const SizedBox(width: 4),
                      Text(
                        '${tutorData['rating'] ?? 0} Rating',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Availability Section
            const Text(
              'Availability',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today,
                      color: AppColors.primary, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Wrap(
                      spacing: 8,
                      children: ['Mon', 'Wed', 'Fri', 'Sat']
                          .map((day) => Chip(
                                label: Text(
                                  day,
                                  style: const TextStyle(
                                    color: AppColors.primary,
                                    fontSize: 12,
                                  ),
                                ),
                                backgroundColor:
                                    AppColors.primary.withOpacity(0.1),
                                side: BorderSide(
                                    color: AppColors.primary
                                        .withOpacity(0.3)),
                              ))
                          .toList(),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // About Section
            const Text(
              'About',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                tutorData['bio'] ?? 'No bio available',
                style: const TextStyle(
                  color: AppColors.textLight,
                  height: 1.5,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Skills Section
            const Text(
              'Skills',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: (tutorData['skills'] ?? '')
                    .toString()
                    .split(',')
                    .map((skill) => Chip(
                          label: Text(
                            skill.trim(),
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 12,
                            ),
                          ),
                          backgroundColor:
                              AppColors.primary.withOpacity(0.1),
                          side: BorderSide(
                              color:
                                  AppColors.primary.withOpacity(0.3)),
                        ))
                    .toList(),
              ),
            ),

            const SizedBox(height: 16),

            // Info Section
            const Text(
              'Details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _InfoRow(
                      icon: Icons.email_outlined,
                      label: 'Email',
                      value: tutorData['email'] ?? ''),
                  const Divider(),
                  _InfoRow(
                      icon: Icons.badge_outlined,
                      label: 'Student ID',
                      value: tutorData['studentId'] ?? ''),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Action Buttons
            Row(
              children: [
                // Send Message Button
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _startChat(context),
                    icon: const Icon(Icons.chat_outlined,
                        color: AppColors.primary),
                    label: const Text(
                      'Message',
                      style: TextStyle(color: AppColors.primary),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: AppColors.primary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // Book Session Button
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              BookingScreen(tutorData: tutorData),
                        ),
                      );
                    },
                    icon: const Icon(Icons.calendar_today,
                        color: AppColors.white),
                    label: const Text(
                      'Book Session',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textLight,
              fontSize: 13,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textDark,
              fontWeight: FontWeight.w500,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}