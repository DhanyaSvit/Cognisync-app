import 'package:flutter/material.dart';
import 'meditation_page.dart';
import 'sleep_page.dart';
import '../services/goal_service.dart';
import 'journal_list_page.dart';


class GoalsPage extends StatefulWidget {
  const GoalsPage({super.key});

  @override
  State<GoalsPage> createState() => _GoalsPageState();
}

class _GoalsPageState extends State<GoalsPage> {
  void _onJournalComplete() async {
    await GoalService.setGoalCompleted('journaling');
  }

  void _onMeditationComplete() async {
    await GoalService.setGoalCompleted('meditation');
  }

  void _onSleepComplete() async {
    await GoalService.setGoalCompleted('sleep');
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final dateStr = "${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}";
    return StreamBuilder<Map<String, bool>>(
      stream: GoalService.todayGoalsStream(),
      builder: (context, snapshot) {
        final goals = snapshot.data ?? {'journaling': false, 'meditation': false, 'sleep': false};
        final journalingDone = goals['journaling'] ?? false;
        final meditationDone = goals['meditation'] ?? false;
        final sleepDone = goals['sleep'] ?? false;
        final completedCount = [journalingDone, meditationDone, sleepDone].where((v) => v).length;
        if (!snapshot.hasData) {
          return const Scaffold(
            backgroundColor: Colors.black,
            body: Center(child: CircularProgressIndicator(color: Colors.white)),
          );
        }
        return Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
            centerTitle: true,
            title: const Text('Cognisync', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            actions: [
              IconButton(
                icon: const Icon(Icons.more_vert, color: Colors.white),
                onPressed: () {},
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    dateStr,
                    style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: Text('Daily Goals', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24, letterSpacing: 1.2)),
                ),
                const SizedBox(height: 24),
                _GoalCard(
                  title: 'Journaling',
                  isCompleted: journalingDone,
                  onStart: () async {
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => JournalListPage(onComplete: _onJournalComplete),
                      ),
                    );
                  },
                  buttonText: 'Start Journaling',
                ),
                const SizedBox(height: 16),
                _GoalCard(
                  title: 'Meditation',
                  isCompleted: meditationDone,
                  onStart: () async {
                    await Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => MeditationPage(onComplete: _onMeditationComplete)),
                    );
                  },
                  buttonText: 'Start Meditation',
                ),
                const SizedBox(height: 16),
                _GoalCard(
                  title: 'Sleep',
                  isCompleted: sleepDone,
                  onStart: () async {
                    await Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => SleepPage(onComplete: _onSleepComplete)),
                    );
                  },
                  buttonText: 'Start Sleep',
                ),
                const SizedBox(height: 24),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    "Today's Progress\n$completedCount / 3 goals completed",
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _GoalCard extends StatelessWidget {
  final String title;
  final bool isCompleted;
  final VoidCallback onStart;
  final String buttonText;
  const _GoalCard({required this.title, required this.isCompleted, required this.onStart, required this.buttonText});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
              Checkbox(
                value: isCompleted,
                onChanged: null, // read-only
                activeColor: Colors.green,
                checkColor: Colors.black,
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: onStart,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.green),
                foregroundColor: Colors.green,
                backgroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(buttonText, style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}
