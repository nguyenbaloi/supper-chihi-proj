import 'package:flutter/material.dart';

import 'mini_apps.dart';
import 'super_app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SuperApp(apps: miniApps));
}
