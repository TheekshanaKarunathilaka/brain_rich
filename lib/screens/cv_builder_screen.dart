import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../services/ai_service.dart';

class CVBuilderScreen extends StatefulWidget {
  const CVBuilderScreen({super.key});

  @override
  State<CVBuilderScreen> createState() => _CVBuilderScreenState();
}

class _CVBuilderScreenState extends State<CVBuilderScreen> {
  final _nameController = TextEditingController();
  final _studentIdController = TextEditingController();
  final _emailController = TextEditingController();
  final _skillsController = TextEditingController();
  final _subjectsController = TextEditingController();
  final _experienceController = TextEditingController();
  final _achievementsController = TextEditingController();
  final _aiService = AIService();

  bool _isLoading = false;
  String _generatedCV = '';

  Future<void> _generateCV() async {
    if (_nameController.text.isEmpty ||
        _skillsController.text.isEmpty ||
        _subjectsController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in Name, Skills and Subjects')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _generatedCV = '';
    });

    try {
      final cv = await _aiService.generateCV(
        name: _nameController.text.trim(),
        studentId: _studentIdController.text.trim(),
        email: _emailController.text.trim(),
        skills: _skillsController.text.trim(),
        subjects: _subjectsController.text.trim(),
        experience: _experienceController.text.trim(),
        achievements: _achievementsController.text.trim(),
      );
      setState(() => _generatedCV = cv);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
          'AI CV Builder',
          style: TextStyle(color: AppColors.textDark),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '🤖 AI CV Generator',
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Fill in your details and let AI create a professional CV for you!',
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Form Fields
            _buildField('Full Name *', 'Enter your full name', _nameController),
            _buildField('Student ID', 'Enter your student ID', _studentIdController),
            _buildField('Email', 'Enter your email', _emailController),
            _buildField('Skills *', 'e.g. Flutter, Python, Mathematics', _skillsController),
            _buildField('Subjects *', 'e.g. Computer Science, Mathematics', _subjectsController),
            _buildField('Experience', 'Any work or volunteer experience', _experienceController, maxLines: 3),
            _buildField('Achievements', 'Awards, certifications, projects', _achievementsController, maxLines: 3),

            const SizedBox(height: 24),

            // Generate Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _generateCV,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: AppColors.white,
                              strokeWidth: 2,
                            ),
                          ),
                          SizedBox(width: 12),
                          Text('Generating CV...'),
                        ],
                      )
                    : const Text(
                        '✨ Generate CV with AI',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),

            // Generated CV Output
            if (_generatedCV.isNotEmpty) ...[
              const SizedBox(height: 24),
              const Text(
                '📄 Your Generated CV',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.3),
                  ),
                ),
                child: SelectableText(
                  _generatedCV,
                  style: const TextStyle(
                    color: AppColors.textDark,
                    height: 1.6,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: _generatedCV));
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('CV copied to clipboard! ✅'),
      backgroundColor: Colors.green,
                      ),
                    );
                  },
                  icon: const Icon(Icons.copy, color: AppColors.primary),
                  label: const Text(
                    'Copy CV',
                    style: TextStyle(color: AppColors.primary),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildField(String label, String hint, TextEditingController controller,
      {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: AppColors.white,
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}