import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../db/db_helper.dart';
import '../models/pomodoro_session.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  Map<String, int> studyData = {}; // date: minutes
  int streak = 0;

  @override
  void initState() {
    super.initState();
    loadAnalytics();
  }

  Future<void> loadAnalytics() async {
    final db = DBHelper();
    final sessions = await db.getSessions();
    final now = DateTime.now();
    final formatter = DateFormat('yyyy-MM-dd');

    Map<String, int> tempData = {};
    Set<String> streakDates = {};

    for (int i = 0; i < 7; i++) {
      final day = now.subtract(Duration(days: i));
      final key = formatter.format(day);
      tempData[key] = 0;
    }

    for (var session in sessions) {
      final key = formatter.format(session.startTime);
      if (tempData.containsKey(key)) {
        tempData[key] = tempData[key]! + session.sessionDuration;
        streakDates.add(key);
      }
    }

    int tempStreak = 0;
    for (int i = 0; i < 7; i++) {
      final day = now.subtract(Duration(days: i));
      final key = formatter.format(day);
      if (streakDates.contains(key)) {
        tempStreak++;
      } else {
        break;
      }
    }

    setState(() {
      studyData = tempData;
      streak = tempStreak;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Analytics')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Current Focus Streak: $streak days',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 20),
            const Text('Study Time (Last 7 Days)',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Expanded(
              child: ListView(
                children: studyData.entries.map((entry) {
                  return ListTile(
                    title: Text(entry.key),
                    trailing: Text('${entry.value} mins'),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
