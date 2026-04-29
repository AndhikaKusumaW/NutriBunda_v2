import 'package:flutter/material.dart';
import '../../data/models/quiz_question.dart';

/// Widget untuk menampilkan pertanyaan quiz dengan pilihan ganda
/// Requirements: 10.1 - Present multiple choice trivia questions
class QuizQuestionWidget extends StatelessWidget {
  final QuizQuestion question;
  final String? selectedAnswer;
  final Function(String) onAnswerSelected;

  const QuizQuestionWidget({
    Key? key,
    required this.question,
    this.selectedAnswer,
    required this.onAnswerSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question text
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.help_outline,
                    color: Colors.green[600],
                    size: 28,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    question.question,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Answer options
          Expanded(
            child: ListView.builder(
              itemCount: question.options.length,
              itemBuilder: (context, index) {
                final option = question.options[index];
                final optionLetter = String.fromCharCode(65 + index); // A, B, C, D
                final isSelected = selectedAnswer == optionLetter;
                
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: _buildOptionCard(
                    context,
                    optionLetter,
                    option,
                    isSelected,
                    () => onAnswerSelected(optionLetter),
                  ),
                );
              },
            ),
          ),
          
          // Instructions
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue[200]!),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Colors.blue[600],
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Pilih salah satu jawaban untuk melanjutkan ke pertanyaan berikutnya',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.blue[700],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionCard(
    BuildContext context,
    String optionLetter,
    String optionText,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: isSelected ? 4 : 1,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? Colors.green[600]! : Colors.grey[300]!,
              width: isSelected ? 2 : 1,
            ),
            color: isSelected ? Colors.green[50] : null,
          ),
          child: Row(
            children: [
              // Option letter circle
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected ? Colors.green[600] : Colors.grey[200],
                ),
                child: Center(
                  child: Text(
                    optionLetter,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.grey[700],
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(width: 16),
              
              // Option text
              Expanded(
                child: Text(
                  optionText,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    color: isSelected ? Colors.green[700] : null,
                  ),
                ),
              ),
              
              // Selection indicator
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: Colors.green[600],
                  size: 24,
                ),
            ],
          ),
        ),
      ),
    );
  }
}