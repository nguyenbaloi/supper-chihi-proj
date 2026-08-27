import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'data/db/database.dart';
import 'presentation/providers/repository_providers.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(AppDatabase.open()),
      ],
      child: const PersonalFinanceApp(),
    ),
  );
}
