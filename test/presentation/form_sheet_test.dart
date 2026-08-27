import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:personal_finance/presentation/widgets/form_sheet.dart';

/// Trang tối giản có nút mở form.
Widget _host() => MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () => showFormSheet<void>(
              context,
              builder: (_) => Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (var i = 0; i < 8; i++)
                    TextField(
                      decoration: InputDecoration(labelText: 'Ô nhập $i'),
                    ),
                  const Text('ô cuối cùng'),
                ],
              ),
            ),
            child: const Text('mở'),
          ),
        ),
      ),
    );

/// Phần đệm đáy mà tấm trượt đang áp dụng.
double _bottomInsetPadding(WidgetTester tester) {
  final padding = tester.widget<Padding>(
    find
        .ancestor(
          of: find.byType(SingleChildScrollView),
          matching: find.byType(Padding),
        )
        .first,
  );
  return (padding.padding as EdgeInsets).bottom;
}

void main() {
  group('Form dạng tấm trượt tránh bàn phím', () {
    testWidgets('bàn phím hiện lên thì phần đệm đáy tăng theo', (tester) async {
      final view = tester.view;
      view.devicePixelRatio = 1.0;
      view.physicalSize = const Size(400, 800);
      addTearDown(() {
        view.resetPhysicalSize();
        view.resetDevicePixelRatio();
        view.resetViewInsets();
      });

      await tester.pumpWidget(_host());
      await tester.tap(find.text('mở'));
      await tester.pumpAndSettle();

      expect(_bottomInsetPadding(tester), 0);

      // Bàn phím chiếm 300 điểm ở đáy.
      view.viewInsets = const FakeViewPadding(bottom: 300);
      await tester.pumpAndSettle();

      // Đây chính là chỗ đã hỏng: builder đọc `viewInsets` từ context của
      // màn hình gọi nó, nên tấm trượt không bao giờ dựng lại và phần đệm
      // đứng yên ở 0 trong khi bàn phím che mất ô nhập cuối.
      expect(_bottomInsetPadding(tester), 300);
    });

    testWidgets('bàn phím đóng lại thì phần đệm trở về 0', (tester) async {
      final view = tester.view;
      view.devicePixelRatio = 1.0;
      view.physicalSize = const Size(400, 800);
      addTearDown(() {
        view.resetPhysicalSize();
        view.resetDevicePixelRatio();
        view.resetViewInsets();
      });

      await tester.pumpWidget(_host());
      await tester.tap(find.text('mở'));
      await tester.pumpAndSettle();

      view.viewInsets = const FakeViewPadding(bottom: 300);
      await tester.pumpAndSettle();
      view.viewInsets = FakeViewPadding.zero;
      await tester.pumpAndSettle();

      expect(_bottomInsetPadding(tester), 0);
    });

    testWidgets('nội dung cuộn được khi chỗ trống bị thu hẹp', (tester) async {
      // Không cuộn được thì bàn phím ăn mất chỗ là form tràn, và ô cuối
      // không có cách nào chạm tới.
      final view = tester.view;
      view.devicePixelRatio = 1.0;
      view.physicalSize = const Size(400, 800);
      addTearDown(() {
        view.resetPhysicalSize();
        view.resetDevicePixelRatio();
        view.resetViewInsets();
      });

      await tester.pumpWidget(_host());
      await tester.tap(find.text('mở'));
      await tester.pumpAndSettle();

      view.viewInsets = const FakeViewPadding(bottom: 500);
      await tester.pumpAndSettle();

      expect(find.byType(SingleChildScrollView), findsOneWidget);
      expect(tester.takeException(), isNull);

      await tester.drag(
        find.byType(SingleChildScrollView),
        const Offset(0, -200),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  });
}
