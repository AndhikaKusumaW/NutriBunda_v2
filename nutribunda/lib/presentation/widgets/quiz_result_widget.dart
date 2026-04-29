import 'package:flutter/material.dart';
import '../../data/models/quiz_question.dart';

/// Widget untuk menampilkan hasil quiz
/// Requirements: 10.4, 10.5 - Show correct answers with explanations, display final score
class QuizResultWidget extends StatelessWidget {
  final QuizResult result;
  final VoidCallback onPlayAgain;
  final VoidCallback onViewHighScores;

  const QuizResultWidget({
    Key? key,
    required this.result,
    required this.onPlayAgain,
    required this.onViewHighScores,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final percentage = result.percentage;
    final isHighScore = percentage >= 80; // Consider 80%+ as high score
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Score card
          Card(
            elevation: 4,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                gradient: LinearGradient(
                  colors: isHighScore
                      ? [Colors.green[400]!, Colors.green[600]!]
                      : [Colors.blue[400]!, Colors.blue[600]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    isHighScore ? Icons.emoji_events : Icons.quiz,
                    size: 64,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    isHighScore ? 'Selamat!' : 'Quiz Selesai!',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Skor Anda',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${result.score} / ${result.totalPoints}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${percentage.toStringAsFixed(1)}%',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Performance message
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Icon(
                    _getPerformanceIcon(percentage),
                    color: _getPerformanceColor(percentage),
                    size: 32,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _getPerformanceMessage(percentage),
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Action buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onPlayAgain,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Main Lagi'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[600],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onViewHighScores,
                  icon: const Icon(Icons.leaderboard),
                  label: const Text('Papan Skor'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.green[600],
                    side: BorderSide(color: Colors.green[600]!),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Question results
          Text(
            'Review Jawaban',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          ...result.results.asMap().entries.map((entry) {
            final index = entry.key;
            final questionResult = entry.value;
            return _buildQuestionResultCard(context, index + 1, questionResult);
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildQuestionResultCard(BuildContext context, int questionNumber, QuestionResult result) {
    final isCorrect = result.isCorrect;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Question header
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isCorrect ? Colors.green[100] : Colors.red[100],
                  ),
                  child: Center(
                    child: Text(
                      '$questionNumber',
                      style: TextStyle(
                        color: isCorrect ? Colors.green[700] : Colors.red[700],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    result.question,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Icon(
                  isCorrect ? Icons.check_circle : Icons.cancel,
                  color: isCorrect ? Colors.green[600] : Colors.red[600],
                  size: 24,
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Answer information
            if (!isCorrect) ...[
              _buildAnswerRow(
                context,
                'Jawaban Anda',
                result.userAnswer,
                Colors.red[600]!,
                Icons.close,
              ),
              const SizedBox(height: 8),
            ],
            
            _buildAnswerRow(
              context,
              isCorrect ? 'Jawaban Anda' : 'Jawaban Benar',
              result.correctAnswer,
              Colors.green[600]!,
              Icons.check,
            ),
            
            // Explanation
            if (result.explanation != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.lightbulb_outline,
                      color: Colors.blue[600],
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        result.explanation!,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.blue[700],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAnswerRow(BuildContext context, String label, String answer, Color color, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          answer,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  IconData _getPerformanceIcon(double percentage) {
    if (percentage >= 90) return Icons.emoji_events;
    if (percentage >= 80) return Icons.thumb_up;
    if (percentage >= 60) return Icons.sentiment_satisfied;
    return Icons.sentiment_dissatisfied;
  }

  Color _getPerformanceColor(double percentage) {
    if (percentage >= 80) return Colors.green[600]!;
    if (percentage >= 60) return Colors.orange[600]!;
    return Colors.red[600]!;
  }

  String _getPerformanceMessage(double percentage) {
    if (percentage >= 90) {
      return 'Luar biasa! Anda memiliki pengetahuan gizi yang sangat baik!';
    } else if (percentage >= 80) {
      return 'Bagus sekali! Pengetahuan gizi Anda sudah cukup baik.';
    } else if (percentage >= 60) {
      return 'Tidak buruk! Terus belajar untuk meningkatkan pengetahuan gizi Anda.';
    } else {
      return 'Jangan menyerah! Pelajari lebih lanjut tentang gizi untuk kesehatan keluarga.';
    }
  }
}