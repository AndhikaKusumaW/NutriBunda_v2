import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/quiz_provider.dart';
import '../widgets/quiz_question_widget.dart';
import '../widgets/quiz_progress_widget.dart';
import '../widgets/quiz_result_widget.dart';
import '../widgets/quiz_high_scores_widget.dart';
import '../../core/services/quiz_service.dart';

/// Main Quiz Screen
/// Requirements: 10.1-10.7 - Complete quiz game implementation
class QuizScreen extends StatefulWidget {
  const QuizScreen({Key? key}) : super(key: key);

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  @override
  void initState() {
    super.initState();
    // Load high scores when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<QuizProvider>().loadHighScores();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kuis Gizi Bunda'),
        backgroundColor: Colors.green[600],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Consumer<QuizProvider>(
        builder: (context, quizProvider, child) {
          if (quizProvider.isLoading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Memuat kuis...'),
                ],
              ),
            );
          }

          if (quizProvider.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Terjadi Kesalahan',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      quizProvider.errorMessage ?? 'Unknown error',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {
                        quizProvider.resetQuiz();
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Coba Lagi'),
                    ),
                  ],
                ),
              ),
            );
          }

          // Show quiz result screen
          if (quizProvider.isQuizCompleted && quizProvider.quizResult != null) {
            return QuizResultWidget(
              result: quizProvider.quizResult!,
              onPlayAgain: () => _startNewQuiz(context),
              onViewHighScores: () => _showHighScores(context),
            );
          }

          // Show active quiz
          if (quizProvider.isQuizActive && quizProvider.currentQuestion != null) {
            return Column(
              children: [
                // Progress indicator
                QuizProgressWidget(
                  currentQuestion: quizProvider.currentQuestionIndex + 1,
                  totalQuestions: quizProvider.totalQuestions,
                  progress: (quizProvider.currentQuestionIndex + 1) / quizProvider.totalQuestions,
                ),
                
                // Question content
                Expanded(
                  child: QuizQuestionWidget(
                    question: quizProvider.currentQuestion!,
                    selectedAnswer: quizProvider.getAnswerForQuestion(
                      quizProvider.currentQuestion!.id,
                    ),
                    onAnswerSelected: (answer) {
                      quizProvider.answerQuestion(answer);
                    },
                  ),
                ),
              ],
            );
          }

          // Show welcome screen
          return _buildWelcomeScreen(context, quizProvider);
        },
      ),
    );
  }

  Widget _buildWelcomeScreen(BuildContext context, QuizProvider quizProvider) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Quiz icon
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.green[100],
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.quiz,
              size: 60,
              color: Colors.green[600],
            ),
          ),
          const SizedBox(height: 24),
          
          // Title
          Text(
            'Kuis Gizi Bunda',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.green[700],
            ),
          ),
          const SizedBox(height: 16),
          
          // Description
          Text(
            'Uji pengetahuan Anda tentang kandungan gizi makanan dengan kuis interaktif ini. Setiap jawaban benar bernilai 10 poin!',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 32),
          
          // Start quiz button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _startNewQuiz(context),
              icon: const Icon(Icons.play_arrow),
              label: const Text('Mulai Kuis'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[600],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // High scores button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _showHighScores(context),
              icon: const Icon(Icons.leaderboard),
              label: const Text('Papan Skor'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.green[600],
                side: BorderSide(color: Colors.green[600]!),
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          
          // Statistics (if available)
          if (quizProvider.statistics != null && quizProvider.statistics!.totalGamesPlayed > 0) ...[
            const SizedBox(height: 32),
            _buildStatisticsCard(context, quizProvider.statistics!),
          ],
        ],
      ),
    );
  }

  Widget _buildStatisticsCard(BuildContext context, QuizStatistics stats) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Statistik Anda',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatItem(context, 'Game Dimainkan', '${stats.totalGamesPlayed}'),
                _buildStatItem(context, 'Skor Terbaik', '${stats.bestScore}'),
                _buildStatItem(context, 'Rata-rata', '${stats.averageScore.toStringAsFixed(1)}'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.green[600],
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  void _startNewQuiz(BuildContext context) {
    context.read<QuizProvider>().startQuiz(questionCount: 10);
  }

  void _showHighScores(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) => QuizHighScoresWidget(
          scrollController: scrollController,
        ),
      ),
    );
  }
}