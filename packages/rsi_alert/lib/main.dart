import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'rsi_mini_app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const app = RsiMiniApp();
  final container = await app.createContainer();
  runApp(UncontrolledProviderScope(container: container, child: app.buildApp()));
}
