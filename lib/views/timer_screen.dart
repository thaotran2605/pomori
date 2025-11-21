import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../utils/app_routes.dart';
import '../utils/navigation_utils.dart';
import '../widgets/bottom_nav_bar.dart';
import '../models/pomodoro_task.dart';
import '../viewmodels/timer_view_model.dart';
import '../viewmodels/ui_message.dart';
import 'congrats_screen.dart';

class TimerScreen extends StatefulWidget {
  const TimerScreen({super.key});

  static const routeName = AppRoutes.timer;

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  late final TimerViewModel _viewModel;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _viewModel = TimerViewModel();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is PomodoroTask) {
      _viewModel.initialize(args);
      _initialized = true;
    }
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _handleStop() async {
    // Show confirmation dialog if timer is running
    if (_viewModel.isRunning && !_viewModel.isPaused) {
      final shouldStop = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Stop Timer?'),
          content: const Text(
            'Are you sure you want to stop the current timer session? Your progress will be saved.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF55856),
                foregroundColor: Colors.white,
              ),
              child: const Text('Stop'),
            ),
          ],
        ),
      );

      if (shouldStop != true || !mounted) {
        return;
      }
    }

    try {
      await _viewModel.stopTimer();
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error stopping timer: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  void _showMessage(UiMessage message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message.text),
        backgroundColor: message.isError ? Colors.redAccent : Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<TimerViewModel>.value(
      value: _viewModel,
      child: Consumer<TimerViewModel>(
        builder: (context, viewModel, _) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final message = viewModel.consumeMessage();
            if (message != null && mounted) {
              _showMessage(message);
            }
            final completedTask = viewModel.consumeCompletedTask();
            if (completedTask != null && mounted) {
              Navigator.of(context).pushReplacementNamed(
                CongratsScreen.routeName,
                arguments: completedTask,
              );
            }
          });

          final task = viewModel.task;
          final taskName = task?.title ?? 'Pomori Task';
          final totalTime = task == null
              ? '---'
              : '${(task.sessions * task.focusTime) + ((task.sessions - 1) * task.breakTime)} minutes';
          final focusMinutes = task?.focusTime ?? 25;
          final breakMinutes = task?.breakTime ?? 5;
          final statusText = viewModel.isFocusPhase
              ? 'Stay focus for $focusMinutes minutes'
              : 'Take a break for $breakMinutes minutes';
          final progressColor = viewModel.isFocusPhase
              ? const Color(0xFF81C784)
              : Colors.orange;

          return Scaffold(
            backgroundColor: const Color(0xFFFDEDE3),
            appBar: AppBar(
              backgroundColor: const Color(0xFFFDEDE3),
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: _handleStop,
              ),
              title: const Text(
                'Pomori Timer',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              centerTitle: true,
              actions: const [
                Padding(
                  padding: EdgeInsets.only(right: 8.0),
                  child: Icon(Icons.more_horiz, color: Colors.black),
                ),
              ],
            ),
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 15,
                        horizontal: 20,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withValues(alpha: 0.1),
                            spreadRadius: 1,
                            blurRadius: 3,
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Text(
                            taskName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            totalTime,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 50),
                    SizedBox(
                      width: 250,
                      height: 250,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 250,
                            height: 250,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.grey.shade200,
                                width: 10,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 250,
                            height: 250,
                            child: CircularProgressIndicator(
                              value: viewModel.progressValue,
                              strokeWidth: 10,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                progressColor,
                              ),
                              backgroundColor: Colors.transparent,
                            ),
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                viewModel.timeRemaining,
                                style: const TextStyle(
                                  fontSize: 48,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                '${viewModel.currentSession} of ${viewModel.totalSessions} sessions',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    Text(
                      statusText,
                      style: TextStyle(fontSize: 16, color: Colors.grey[800]),
                    ),
                    const SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Next Session button
                        _ControlCircleButton(
                          icon: Icons.skip_next,
                          color: Colors.grey.shade500,
                          onPressed: () => viewModel.skipPhase(),
                        ),
                        const SizedBox(width: 25),
                        // Pause/Resume button
                        _ControlCircleButton(
                          icon: viewModel.isPaused || !viewModel.isRunning
                              ? Icons.play_arrow
                              : Icons.pause,
                          color: const Color(0xFFF75F5C),
                          size: 80,
                          onPressed: () => viewModel.togglePause(),
                        ),
                        const SizedBox(width: 25),
                        // Refill button
                        _ControlCircleButton(
                          icon: Icons.refresh,
                          color: Colors.blue.shade400,
                          onPressed: () => viewModel.refillTime(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            bottomNavigationBar: BottomNavBar(
              currentIndex: 0,
              onTap: (index) => BottomNavNavigator.goTo(context, index),
            ),
          );
        },
      ),
    );
  }
}

class _ControlCircleButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;
  final VoidCallback onPressed;

  const _ControlCircleButton({
    required this.icon,
    required this.color,
    required this.onPressed,
    this.size = 50,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon, size: size * 0.45),
        color: color,
        onPressed: onPressed,
      ),
    );
  }
}
