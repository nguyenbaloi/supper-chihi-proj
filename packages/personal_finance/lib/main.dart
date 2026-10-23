import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Không ghi đè databaseProvider ở đây nữa: cơ sở dữ liệu do
  // `databaseHostProvider` mở, để khôi phục dữ liệu đóng và mở lại được tệp
  // mà không cần dựng lại cây widget.
  runApp(const ProviderScope(child: PersonalFinanceApp()));
}
