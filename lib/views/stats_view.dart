import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:noteleaf/viewmodels/stats_viewmodel.dart';

class StatsView extends StatefulWidget {
  final String projectId;
  final String projectTitle;

  const StatsView({
    super.key,
    required this.projectId,
    required this.projectTitle,
  });

  @override
  State<StatsView> createState() => _StatsViewState();
}

class _StatsViewState extends State<StatsView> {
  late StatsViewModel _statsViewModel;

  @override
  void initState() {
    super.initState();
    _statsViewModel = StatsViewModel();
    _statsViewModel.loadStats(widget.projectId);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _statsViewModel,
      child: Scaffold(
        appBar: AppBar(
          title: Text('${widget.projectTitle} - Statistics'),
          actions: [
            IconButton(
              icon: const Icon(Icons.flag),
              onPressed: () => _showGoalDialog(context),
              tooltip: 'Set Writing Goal',
            ),
          ],
        ),
        body: Consumer<StatsViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (viewModel.errorMessage != null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      viewModel.errorMessage!,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => viewModel.loadStats(widget.projectId),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Overall Progress Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Overall Progress',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Total Words',
                                    style: Theme.of(context).textTheme.bodyMedium,
                                  ),
                                  Text(
                                    '${viewModel.totalWords}',
                                    style: Theme.of(context).textTheme.headlineMedium,
                                  ),
                                ],
                              ),
                            ),
                            if (viewModel.writingGoal != null)
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Goal',
                                      style: Theme.of(context).textTheme.bodyMedium,
                                    ),
                                    Text(
                                      '${viewModel.writingGoal!.totalWordGoal}',
                                      style: Theme.of(context).textTheme.headlineMedium,
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                        if (viewModel.writingGoal != null) ...[
                          const SizedBox(height: 16),
                          LinearProgressIndicator(
                            value: viewModel.progressPercentage,
                            backgroundColor: Colors.grey[300],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${(viewModel.progressPercentage * 100).toStringAsFixed(1)}% complete',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Daily Progress Card
                if (viewModel.writingGoal != null)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Today\'s Progress',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Words Today',
                                      style: Theme.of(context).textTheme.bodyMedium,
                                    ),
                                    Text(
                                      '${viewModel.todayWords}',
                                      style: Theme.of(context).textTheme.headlineMedium,
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Daily Goal',
                                      style: Theme.of(context).textTheme.bodyMedium,
                                    ),
                                    Text(
                                      '${viewModel.writingGoal!.dailyWordGoal}',
                                      style: Theme.of(context).textTheme.headlineMedium,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          LinearProgressIndicator(
                            value: viewModel.dailyProgressPercentage,
                            backgroundColor: Colors.grey[300],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${(viewModel.dailyProgressPercentage * 100).toStringAsFixed(1)}% of daily goal',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 16),

                // Chapter Breakdown Card
                if (viewModel.chapterWordCounts.isNotEmpty)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Chapter Breakdown',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 16),
                          ...viewModel.chapterWordCounts.entries.map(
                            (entry) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      entry.key,
                                      style: Theme.of(context).textTheme.bodyMedium,
                                    ),
                                  ),
                                  Text(
                                    '${entry.value} words',
                                    style: Theme.of(context).textTheme.bodyMedium,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _showGoalDialog(BuildContext context) {
    final dailyController = TextEditingController(
      text: _statsViewModel.writingGoal?.dailyWordGoal.toString() ?? '',
    );
    final totalController = TextEditingController(
      text: _statsViewModel.writingGoal?.totalWordGoal.toString() ?? '',
    );
    DateTime selectedDate = _statsViewModel.writingGoal?.deadline ?? 
        DateTime.now().add(const Duration(days: 30));

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Set Writing Goal'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: dailyController,
                decoration: const InputDecoration(
                  labelText: 'Daily Word Goal',
                  hintText: 'e.g., 500',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: totalController,
                decoration: const InputDecoration(
                  labelText: 'Total Word Goal',
                  hintText: 'e.g., 50000',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('Deadline'),
                subtitle: Text('${selectedDate.day}/${selectedDate.month}/${selectedDate.year}'),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (date != null) {
                    setState(() {
                      selectedDate = date;
                    });
                  }
                },
                contentPadding: EdgeInsets.zero,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final dailyGoal = int.tryParse(dailyController.text) ?? 0;
                final totalGoal = int.tryParse(totalController.text) ?? 0;
                
                if (dailyGoal > 0 && totalGoal > 0) {
                  _statsViewModel.setWritingGoal(
                    widget.projectId,
                    dailyGoal,
                    totalGoal,
                    selectedDate,
                  );
                  Navigator.pop(context);
                }
              },
              child: const Text('Set Goal'),
            ),
          ],
        ),
      ),
    );
  }
}

