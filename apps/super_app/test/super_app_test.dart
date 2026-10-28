import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mini_app_core/mini_app_core.dart';
import 'package:super_app/super_app.dart';

/// Khoá chỉ có trong mini app giả — dialog tra được nó nghĩa là dialog còn
/// nằm trong cây của mini app (đứng thay cho AppL10n của personal_finance).
class _MiniOnly extends InheritedWidget {
  const _MiniOnly({required super.child});

  @override
  bool updateShouldNotify(_MiniOnly oldWidget) => false;
}

final _labelProvider = Provider<String>((ref) => 'không có override');

class _FakeMiniApp implements MiniApp {
  _FakeMiniApp({this.fail = false});

  final bool fail;
  int created = 0;

  @override
  String get id => 'fake';
  @override
  String get title => 'Fake';
  @override
  IconData get icon => Icons.star;
  @override
  Color get color => Colors.blue;

  @override
  Future<ProviderContainer> createContainer() async {
    created++;
    if (fail) throw StateError('không mở được kho');
    return ProviderContainer(
      overrides: [_labelProvider.overrideWithValue('container riêng')],
    );
  }

  @override
  List<BackupSource> get backupSources => const [];

  @override
  Widget buildApp() => MaterialApp(
        builder: (_, child) => _MiniOnly(child: child!),
        home: Builder(
          builder: (context) => Scaffold(
            appBar: AppBar(
              title: const Text('mini-home'),
              leading: MiniAppScope.exitButtonOf(context),
            ),
            body: Column(
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const Scaffold(body: Text('mini-detail')),
                    ),
                  ),
                  child: const Text('open-detail'),
                ),
                TextButton(
                  onPressed: () => showDialog<void>(
                    context: context,
                    builder: (context) => Consumer(
                      builder: (context, ref, _) {
                        final inMiniTree = context
                                .dependOnInheritedWidgetOfExactType<_MiniOnly>() !=
                            null;
                        return AlertDialog(
                          content: Text(
                            '${ref.watch(_labelProvider)} / $inMiniTree',
                          ),
                        );
                      },
                    ),
                  ),
                  child: const Text('open-dialog'),
                ),
              ],
            ),
          ),
        ),
      );
}

Future<void> _openFake(WidgetTester tester, _FakeMiniApp app) async {
  await tester.pumpWidget(SuperApp(apps: [app]));
  await tester.tap(find.text('Fake'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('Back ở màn chi tiết chỉ pop bên trong mini app', (tester) async {
    await _openFake(tester, _FakeMiniApp());
    await tester.tap(find.text('open-detail'));
    await tester.pumpAndSettle();
    expect(find.text('mini-detail'), findsOneWidget);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('mini-home'), findsOneWidget);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('mini-home'), findsNothing);
    expect(find.text('Fake'), findsOneWidget);
  });

  testWidgets('Back khi đang mở dialog chỉ đóng dialog', (tester) async {
    await _openFake(tester, _FakeMiniApp());
    await tester.tap(find.text('open-dialog'));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsOneWidget);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);
    expect(find.text('mini-home'), findsOneWidget);
  });

  testWidgets('Dialog nằm trong container và cây widget của mini app',
      (tester) async {
    await _openFake(tester, _FakeMiniApp());
    await tester.tap(find.text('open-dialog'));
    await tester.pumpAndSettle();
    expect(find.text('container riêng / true'), findsOneWidget);
  });

  testWidgets('Nút thoát đưa về màn hình chính, mở lại dùng lại container',
      (tester) async {
    final app = _FakeMiniApp();
    await _openFake(tester, app);
    await tester.tap(find.byTooltip(MiniAppStrings.backToHome));
    await tester.pumpAndSettle();
    expect(find.text('mini-home'), findsNothing);

    await tester.tap(find.text('Fake'));
    await tester.pumpAndSettle();
    expect(find.text('mini-home'), findsOneWidget);
    expect(app.created, 1);
  });

  testWidgets('Khởi tạo lỗi thì ở lại màn hình chính và cho thử lại',
      (tester) async {
    final app = _FakeMiniApp(fail: true);
    await _openFake(tester, app);
    expect(find.text('mini-home'), findsNothing);
    expect(find.byType(SnackBar), findsOneWidget);

    await tester.tap(find.text('Fake'));
    await tester.pumpAndSettle();
    expect(app.created, 2);
  });
}
