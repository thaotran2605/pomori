// lib/widgets/task_item_card.dart
import 'package:flutter/material.dart';
import '../utils/app_constants.dart';

class TaskItemCard extends StatelessWidget {
  final String taskName;
  final int totalSessions;
  final int completedSessions;
  final int focusTime;
  final int breakTime;

  const TaskItemCard({
    super.key,
    required this.taskName,
    required this.totalSessions,
    required this.completedSessions,
    required this.focusTime,
    required this.breakTime,
  });

  @override
  Widget build(BuildContext context) {
    final progress = totalSessions > 0
        ? completedSessions / totalSessions
        : 0.0;
    final isCompleted = completedSessions >= totalSessions;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  taskName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: kTextColor,
                  ),
                ),
              ),
              if (isCompleted)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    'Completed',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.green,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Icon(Icons.timer, size: 16, color: kTextColor.withOpacity(0.6)),
              const SizedBox(width: 5),
              Text(
                '$focusTime min focus',
                style: TextStyle(
                  fontSize: 14,
                  color: kTextColor.withOpacity(0.6),
                ),
              ),
              const SizedBox(width: 15),
              Icon(Icons.coffee, size: 16, color: kTextColor.withOpacity(0.6)),
              const SizedBox(width: 5),
              Text(
                '$breakTime min break',
                style: TextStyle(
                  fontSize: 14,
                  color: kTextColor.withOpacity(0.6),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Progress',
                      style: TextStyle(
                        fontSize: 12,
                        color: kTextColor.withOpacity(0.6),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Stack(
                      children: [
                        Container(
                          height: 8,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        FractionallySizedBox(
                          widthFactor: progress,
                          child: Container(
                            height: 8,
                            decoration: BoxDecoration(
                              color: isCompleted ? Colors.green : kPrimaryRed,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 15),
              Text(
                '$completedSessions/$totalSessions',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: kTextColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
