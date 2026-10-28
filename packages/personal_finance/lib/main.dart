import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'finance_mini_app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const app = FinanceMiniApp();
  final container = await app.createContainer();
  runApp(UncontrolledProviderScope(container: container, child: app.buildApp()));
}
