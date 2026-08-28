import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Định dạng ngày kiểu Việt Nam cần dữ liệu locale được nạp trước.
  await initializeDateFormatting('vi_VN');
  runApp(const ProviderScope(child: PersonalProjectsApp()));
}
