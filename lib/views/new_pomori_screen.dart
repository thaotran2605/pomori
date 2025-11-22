import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../utils/app_routes.dart';
import '../utils/navigation_utils.dart';
import '../widgets/bottom_nav_bar.dart';
import '../viewmodels/new_pomori_view_model.dart';
import '../viewmodels/ui_message.dart';
import '../models/pomodoro_task.dart';
import 'timer_screen.dart';

class NewPomoriScreen extends StatefulWidget {
  const NewPomoriScreen({super.key});

  static const routeName = AppRoutes.newPomori;

  @override
  State<NewPomoriScreen> createState() => _NewPomoriScreenState();
}

class _NewPomoriScreenState extends State<NewPomoriScreen> {
  final _formKey = GlobalKey<FormState>();
  final _taskNameController = TextEditingController();
  late final NewPomoriViewModel _viewModel;
  bool _hasCheckedActiveTask = false;
  bool _hasCheckedSelectedTask = false;

  @override
  void initState() {
    super.initState();
    _viewModel = NewPomoriViewModel();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_hasCheckedSelectedTask) {
      _hasCheckedSelectedTask = true;
      _checkForSelectedTask();
    }
    if (!_hasCheckedActiveTask) {
      _hasCheckedActiveTask = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _checkActiveTask();
      });
    }
  }

  @override
  void dispose() {
    _taskNameController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  void _checkForSelectedTask() {
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is PomodoroTask) {
      // Tự động chuyển đến TimerScreen với task được chọn
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.of(context).pushReplacementNamed(
            TimerScreen.routeName,
            arguments: args,
          );
        }
      });
    }
  }

  Future<void> _checkActiveTask() async {
    // Kiểm tra xem có task được chọn từ home screen không
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is PomodoroTask) {
      // Nếu đã có task được chọn, không cần check active task
      return;
    }
    
    final activeTask = await _viewModel.fetchActiveTask();
    if (!mounted) return;

    final message = _viewModel.consumeMessage();
    if (message != null) {
      _showMessage(message);
    }

    if (activeTask != null) {
      Navigator.of(context).pushReplacementNamed(
        TimerScreen.routeName,
        arguments: activeTask,
      );
    }
  }

  Future<void> _handleStart() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final result = await _viewModel.startPomodoro(
      _taskNameController.text.trim(),
    );

    if (!mounted) return;

    final message = _viewModel.consumeMessage();
    if (message != null) {
      _showMessage(message);
    }

    if (result != null) {
      Navigator.of(
        context,
      ).pushReplacementNamed(TimerScreen.routeName, arguments: result.task);
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
    return ChangeNotifierProvider<NewPomoriViewModel>.value(
      value: _viewModel,
      child: Consumer<NewPomoriViewModel>(
        builder: (context, viewModel, _) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final message = viewModel.consumeMessage();
            if (message != null && mounted) {
              _showMessage(message);
            }
          });

          return Scaffold(
            backgroundColor: const Color(0xFFFDEDE3),
            body: SafeArea(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Image.asset(
                            'assets/images/pomori_logo2.png',
                            width: 40,
                            height: 40,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'New Pomori',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
                      Container(
                        padding: const EdgeInsets.all(25.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withValues(alpha: 0.1),
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Task name',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _taskNameController,
                              decoration: InputDecoration(
                                hintText: 'e.g. Study Math',
                                hintStyle: TextStyle(color: Colors.grey[400]),
                                filled: true,
                                fillColor: const Color(0xFFFFF0F0),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 15,
                                  vertical: 15,
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Tên task không được để trống';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 25),
                            const Text(
                              'Session',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 15,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF0F0),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                      Icons.remove,
                                      color: Colors.grey,
                                    ),
                                    onPressed: viewModel.sessions > 1
                                        ? viewModel.decreaseSessions
                                        : null,
                                  ),
                                  Text(
                                    '${viewModel.sessions}',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Color.fromRGBO(80, 80, 80, 1),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.add,
                                      color: Colors.grey,
                                    ),
                                    onPressed: viewModel.sessions < 8
                                        ? viewModel.increaseSessions
                                        : null,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 25),
                            const _TimeDisplay(
                              label: 'Focus time',
                              icon: Icons.access_time,
                              time: '25 minutes',
                            ),
                            const SizedBox(height: 15),
                            const _TimeDisplay(
                              label: 'Break time',
                              icon: Icons.coffee_rounded,
                              time: '5 minutes',
                            ),
                            const SizedBox(height: 40),
                            SizedBox(
                              width: double.infinity,
                              height: 60,
                              child: ElevatedButton(
                                onPressed: viewModel.isLoading
                                    ? null
                                    : () => _handleStart(),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFF75F5C),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  elevation: 0,
                                ),
                                child: viewModel.isLoading
                                    ? const SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 3,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                Colors.white,
                                              ),
                                        ),
                                      )
                                    : const Text(
                                        'Start',
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            bottomNavigationBar: BottomNavBar(
              currentIndex: 2,
              onTap: (index) => BottomNavNavigator.goTo(context, index),
            ),
          );
        },
      ),
    );
  }
}

class _TimeDisplay extends StatelessWidget {
  final String label;
  final IconData icon;
  final String time;

  const _TimeDisplay({
    required this.label,
    required this.icon,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF0F0),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Row(
            children: [
              Icon(icon, color: Colors.grey[700]),
              const SizedBox(width: 10),
              Text(
                time,
                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
