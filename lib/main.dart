import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app/providers.dart';
import 'data/candle_store.dart';
import 'ui/home_shell.dart';
import 'ui/strings.dart';
import 'ui/theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('vi_VN');

  final store = await CandleStore.open();

  runApp(
    ProviderScope(
      overrides: [
        marketRepositoryProvider.overrideWithValue(buildRepository(store)),
      ],
      child: const RsiAlertApp(),
    ),
  );
}

class RsiAlertApp extends StatelessWidget {
  const RsiAlertApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: S.appTitle,
        debugShowCheckedModeBanner: false,
        theme: buildTheme(Brightness.light),
        darkTheme: buildTheme(Brightness.dark),
        home: const HomeShell(),
      );
}
