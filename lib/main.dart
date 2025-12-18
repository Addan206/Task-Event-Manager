import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'models/task.dart';
import 'models/event.dart';
import 'screens/home_screen.dart';
import 'screens/task_screen.dart';
import 'screens/event_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();


  if (!Hive.isAdapterRegistered(TaskAdapter().typeId)) {
    Hive.registerAdapter(TaskAdapter());
  }
  if (!Hive.isAdapterRegistered(EventAdapter().typeId)) {
    Hive.registerAdapter(EventAdapter());
  }


  await Hive.openBox<Task>('tasks');
  await Hive.openBox<Event>('events');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Personal Task Manager',
      theme: ThemeData(useMaterial3: true),
      initialRoute: '/',
      routes: {
        '/': (_) => const HomeScreen(),
        '/tasks': (_) => const TasksScreen(),
        '/events': (_) => const EventsScreen(),
      },
    );
  }
}
