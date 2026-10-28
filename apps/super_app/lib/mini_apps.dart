import 'package:mini_app_core/mini_app_core.dart';
import 'package:personal_finance/finance_mini_app.dart';
import 'package:personal_projects/projects_mini_app.dart';
import 'package:rsi_alert/rsi_mini_app.dart';

/// Danh sách mini app trên màn hình chính, theo đúng thứ tự hiển thị.
const List<MiniApp> miniApps = [
  FinanceMiniApp(),
  ProjectsMiniApp(),
  RsiMiniApp(),
];
