import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'pages/checkin_page.dart';
import 'pages/summary_page.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await Hive.initFlutter();
  await Hive.openBox('prefs');
  runApp(const StackWorkApp());
}


class StackWorkApp extends StatelessWidget {
  const StackWorkApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StackWork',
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo)),
      home: const _Home(),
      routes: {
        '/checkin': (_) => const CheckinPage(),
        '/summary': (_) => const SummaryPage(),
      },
    );
  }
}


class _Home extends StatelessWidget {
  const _Home();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('StackWork MVP-01/02')),
      body: Center(
        child: Wrap(spacing: 12, runSpacing: 12, alignment: WrapAlignment.center, children: [
          ElevatedButton.icon(
            onPressed: () => Navigator.pushNamed(context, '/checkin'),
            icon: const Icon(Icons.check_circle_outline),
            label: const Text('セルフチェック（MVP-01）'),
          ),
          ElevatedButton.icon(
            onPressed: () => Navigator.pushNamed(context, '/summary'),
            icon: const Icon(Icons.insights_outlined),
            label: const Text('週報（MVP-02）'),
          ),
        ]),
      ),
    );
  }
}