import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mini_app_core/mini_app_core.dart';

Widget _screen() => MaterialApp(
      home: Builder(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: const Text('home'),
            leading: MiniAppScope.exitButtonOf(context),
          ),
          body: TextButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (context) => Scaffold(
                  appBar: AppBar(leading: MiniAppScope.exitButtonOf(context)),
                  body: const Text('detail'),
                ),
              ),
            ),
            child: const Text('open'),
          ),
        ),
      ),
    );

void main() {
  testWidgets('Chạy độc lập thì không có nút thoát', (tester) async {
    await tester.pumpWidget(_screen());
    expect(find.byTooltip(MiniAppStrings.backToHome), findsNothing);
  });

  testWidgets('Trong super app: nút thoát chỉ ở route đầu tiên',
      (tester) async {
    var exited = 0;
    await tester.pumpWidget(
      MiniAppScope(onExit: () => exited++, child: _screen()),
    );
    await tester.tap(find.byTooltip(MiniAppStrings.backToHome));
    expect(exited, 1);

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(find.byTooltip(MiniAppStrings.backToHome), findsNothing);
    expect(find.byType(BackButton), findsOneWidget);
  });
}
