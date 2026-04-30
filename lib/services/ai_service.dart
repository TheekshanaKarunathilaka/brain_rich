class AIService {
  Future<String> generateCV({
    required String name,
    required String studentId,
    required String email,
    required String skills,
    required String subjects,
    required String experience,
    required String achievements,
  }) async {
    await Future.delayed(const Duration(seconds: 2));

    return '''
╔══════════════════════════════════════╗
         CURRICULUM VITAE
╚══════════════════════════════════════╝

PERSONAL INFORMATION
━━━━━━━━━━━━━━━━━━━━
Name:       $name
Student ID: $studentId
Email:      $email

PROFESSIONAL SUMMARY
━━━━━━━━━━━━━━━━━━━━
A motivated and dedicated university student with strong academic 
background in $subjects. Passionate about continuous learning and 
applying theoretical knowledge to real-world challenges. 
Demonstrated expertise in $skills with a commitment to excellence.

EDUCATION
━━━━━━━━━━━━━━━━━━━━
Bachelor's Degree
University (Current)
Relevant Subjects: $subjects

TECHNICAL SKILLS
━━━━━━━━━━━━━━━━━━━━
${skills.split(',').map((s) => '• ${s.trim()}').join('\n')}

EXPERIENCE
━━━━━━━━━━━━━━━━━━━━
${experience.isEmpty ? '• Available upon request' : experience}

ACHIEVEMENTS & CERTIFICATIONS
━━━━━━━━━━━━━━━━━━━━
${achievements.isEmpty ? '• Available upon request' : achievements.split(',').map((a) => '• ${a.trim()}').join('\n')}

PEER TUTORING
━━━━━━━━━━━━━━━━━━━━
- Active peer tutor on brainRich platform
- Subjects: $subjects
- Committed to helping fellow students succeed

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
References available upon request
''';
  }

  Future<String> generateProfileDescription({
    required String name,
    required String skills,
    required String subjects,
  }) async {
    await Future.delayed(const Duration(seconds: 1));

    return '''$name is a dedicated university student specializing in $subjects. With expertise in $skills, they bring strong academic knowledge and practical skills to every tutoring session. Known for their clear communication style and patient teaching approach, they are committed to helping fellow students achieve their academic goals through personalized peer learning support.''';
  }
}