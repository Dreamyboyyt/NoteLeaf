import 'package:flutter/material.dart';
import 'package:noteleaf/services/readability_analyzer.dart';

class ReadabilityStatsWidget extends StatelessWidget {
  final String text;

  const ReadabilityStatsWidget({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    final stats = ReadabilityAnalyzer.analyzeText(text);
    
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.analytics, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Readability Statistics',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildStatRow(
              context,
              'Reading Level',
              stats['readabilityLevel'],
              _getReadabilityColor(stats['fleschReadingEase']),
            ),
            const SizedBox(height: 8),
            _buildStatRow(
              context,
              'Flesch Reading Ease',
              '${stats['fleschReadingEase'].toStringAsFixed(1)}',
              _getReadabilityColor(stats['fleschReadingEase']),
            ),
            const SizedBox(height: 8),
            _buildStatRow(
              context,
              'Grade Level',
              '${stats['fleschKincaidGrade'].toStringAsFixed(1)}',
              null,
            ),
            const SizedBox(height: 8),
            _buildStatRow(
              context,
              'Avg. Sentence Length',
              '${stats['averageSentenceLength'].toStringAsFixed(1)} words',
              null,
            ),
            const SizedBox(height: 8),
            _buildStatRow(
              context,
              'Avg. Syllables/Word',
              '${stats['averageSyllablesPerWord'].toStringAsFixed(1)}',
              null,
            ),
            const SizedBox(height: 8),
            _buildStatRow(
              context,
              'Sentences',
              '${stats['sentenceCount']}',
              null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(BuildContext context, String label, String value, Color? valueColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  Color _getReadabilityColor(double fleschScore) {
    if (fleschScore >= 70) return Colors.green;
    if (fleschScore >= 50) return Colors.orange;
    return Colors.red;
  }
}

