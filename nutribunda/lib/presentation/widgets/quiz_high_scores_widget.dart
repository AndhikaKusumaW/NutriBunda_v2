import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/quiz_provider.dart';
import '../../data/models/quiz_question.dart';
import '../../core/services/quiz_service.dart';

/// Widget untuk menampilkan high scores
/// Requirements: 10.6 - Display local scoreboard with top 5 high scores
class QuizHighScoresWidget extends StatelessWidget {
  final ScrollController? scrollController;

  const QuizHighScoresWidget({
    Key? key,
    this.scrollController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Header
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Icon(
                  Icons.leaderboard,
                  color: Colors.green[600],
                  size: 28,
                ),
                const SizedBox(width: 12),
                Text(
                  'Papan Skor',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.green[700],
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),
          
          const Divider(height: 1),
          
          // Content
          Expanded(
            child: Consumer<QuizProvider>(
              builder: (context, quizProvider, child) {
                if (quizProvider.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final highScores = quizProvider.highScores;
                final statistics = quizProvider.statistics;

                if (highScores.isEmpty) {
                  return _buildEmptyState(context);
                }

                return ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16.0),
                  children: [
                    // Statistics card
                    if (statistics != null)
                      _buildStatisticsCard(context, statistics),
                    
                    const SizedBox(height: 16),
                    
                    // High scores title
                    Text(
                      'Skor Tertinggi',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    // High scores list
                    ...highScores.asMap().entries.map((entry) {
                      final index = entry.key;
                      final score = entry.value;
                      return _buildScoreCard(context, index + 1, score);
                    }).toList(),
                    
                    const SizedBox(height: 16),
                    
                    // Clear scores button (for testing/reset)
                    if (highScores.isNotEmpty)
                      TextButton.icon(
                        onPressed: () => _showClearConfirmation(context),
                        icon: const Icon(Icons.delete_outline),
                        label: const Text('Hapus Semua Skor'),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.red[600],
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.emoji_events_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Belum Ada Skor',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.grey[600],
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Mainkan kuis pertama Anda untuk melihat skor di sini!',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsCard(BuildContext context, QuizStatistics stats) {
    return Card(
      elevation: 2,
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
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    context,
                    'Game Dimainkan',
                    '${stats.totalGamesPlayed}',
                    Icons.quiz,
                    Colors.blue[600]!,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    context,
                    'Skor Terbaik',
                    '${stats.bestScore}',
                    Icons.emoji_events,
                    Colors.amber[600]!,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    context,
                    'Rata-rata',
                    '${stats.averageScore.toStringAsFixed(1)}',
                    Icons.trending_up,
                    Colors.green[600]!,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildScoreCard(BuildContext context, int rank, HighScore score) {
    final dateFormat = DateFormat('dd MMM yyyy, HH:mm');
    final isTopThree = rank <= 3;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: isTopThree ? 3 : 1,
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          gradient: isTopThree
              ? LinearGradient(
                  colors: [
                    _getRankColor(rank).withOpacity(0.1),
                    _getRankColor(rank).withOpacity(0.05),
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                )
              : null,
        ),
        child: Row(
          children: [
            // Rank badge
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _getRankColor(rank),
              ),
              child: Center(
                child: isTopThree
                    ? Icon(
                        _getRankIcon(rank),
                        color: Colors.white,
                        size: 20,
                      )
                    : Text(
                        '$rank',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
            
            const SizedBox(width: 16),
            
            // Score info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        '${score.score} poin',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.green[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${score.percentage.toStringAsFixed(0)}%',
                          style: TextStyle(
                            color: Colors.green[700],
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${score.totalQuestions} pertanyaan • ${dateFormat.format(score.date)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return Colors.amber[600]!; // Gold
      case 2:
        return Colors.grey[600]!; // Silver
      case 3:
        return Colors.brown[600]!; // Bronze
      default:
        return Colors.blue[600]!;
    }
  }

  IconData _getRankIcon(int rank) {
    switch (rank) {
      case 1:
        return Icons.emoji_events;
      case 2:
        return Icons.military_tech;
      case 3:
        return Icons.workspace_premium;
      default:
        return Icons.star;
    }
  }

  void _showClearConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Semua Skor'),
        content: const Text(
          'Apakah Anda yakin ingin menghapus semua skor tertinggi? Tindakan ini tidak dapat dibatalkan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<QuizProvider>().clearHighScores();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}