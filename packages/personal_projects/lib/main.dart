import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'projects_mini_app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const app = ProjectsMiniApp();
  final container = await app.createContainer();
  runApp(UncontrolledProviderScope(container: container, child: app.buildApp()));
}
