import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'controllers/task_controller.dart';
import 'controllers/event_controller.dart';

import 'screens/home_screen.dart';
import 'screens/task_screen.dart';
import 'screens/event_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => TaskController()..loadTasks(),
        ),
        ChangeNotifierProvider(
          create: (_) => EventController()..loadEvents(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Personal Task Manager',
      initialRoute: '/',
      routes: {
        '/': (_) => const HomeScreen(),
        '/tasks': (_) => const TasksScreen(),
        '/events': (_) => const EventsScreen(),
      },
    );
  }
}
