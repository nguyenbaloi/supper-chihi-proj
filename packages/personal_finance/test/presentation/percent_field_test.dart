import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:personal_finance/presentation/widgets/percent_field.dart';

void main() {
  group('Đọc chuỗi người dùng gõ thành phần vạn', () {
    test('phần trăm chẵn', () {
      expect(parseBp('40'), 4000);
      expect(parseBp('100'), 10000);
      expect(parseBp('5'), 500);
    });

    test('dấu phẩy là dấu thập phân, đúng kiểu Việt Nam', () {
      expect(parseBp('12,5'), 1250);
      expect(parseBp('33,33'), 3333);
      expect(parseBp('0,01'), 1);
    });

    test('ô trống nghĩa là bỏ mục tiêu, không phải mục tiêu 0%', () {
      // Phân biệt này quan trọng: `null` gỡ lớp khỏi danh sách mục tiêu, còn
      // 0 là một mục tiêu thật — "lớp này tôi không muốn giữ gì cả".
      expect(parseBp(''), isNull);
      expect(parseBp('0'), 0);
    });
  });

  group('Hiện lại phần vạn trong ô nhập', () {
    test('bỏ chữ số 0 thừa ở cuối', () {
      expect(formatBp(4000), '40');
      expect(formatBp(10000), '100');
      expect(formatBp(1250), '12,5');
    });

    test('giữ phần vạn lẻ', () {
      expect(formatBp(3333), '33,33');
      expect(formatBp(1), '0,01');
      expect(formatBp(0), '0');
    });

    test('chưa đặt mục tiêu thì để trống cho nhãn gợi ý hiện ra', () {
      expect(formatBp(null), '');
    });

    test('đi vòng qua lại không mất giá trị', () {
      for (final bp in [0, 1, 500, 1250, 3333, 10000]) {
        expect(parseBp(formatBp(bp)), bp);
      }
    });
  });

  group('Ràng buộc ngay lúc gõ', () {
    Future<TextEditingController> pump(WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PercentField(
              label: 'Tỷ trọng mục tiêu',
              initialBp: null,
              onChanged: (_) {},
            ),
          ),
        ),
      );
      return tester.widget<TextField>(find.byType(TextField)).controller!;
    }

    testWidgets('chữ cái không lọt vào ô', (tester) async {
      final controller = await pump(tester);
      await tester.enterText(find.byType(TextField), '4a0b');
      expect(controller.text, '40');
    });

    testWidgets('chỉ nhận một dấu thập phân và hai chữ số sau nó',
        (tester) async {
      final controller = await pump(tester);
      await tester.enterText(find.byType(TextField), '12,3456');
      expect(controller.text, '12,34');

      await tester.enterText(find.byType(TextField), '1,2,3');
      expect(controller.text, '1,23');
    });

    testWidgets('dấu chấm gõ vào cũng hiểu là dấu thập phân', (tester) async {
      // Bàn phím số của một số máy chỉ cho dấu chấm. Đây là ô phần trăm,
      // không có dấu ngăn nghìn nào để nhầm với.
      final controller = await pump(tester);
      await tester.enterText(find.byType(TextField), '12.5');
      expect(controller.text, '12,5');
    });

    testWidgets('không cho vượt 100%', (tester) async {
      final controller = await pump(tester);
      await tester.enterText(find.byType(TextField), '100');
      expect(controller.text, '100');

      // Phím vừa bấm bị từ chối, chuỗi cũ giữ nguyên.
      await tester.enterText(find.byType(TextField), '1000');
      expect(controller.text, '100');

      await tester.enterText(find.byType(TextField), '100,01');
      expect(controller.text, '100');
    });

    testWidgets('số 0 đứng đầu bị bỏ, nhưng 0 của 0,5 thì giữ',
        (tester) async {
      final controller = await pump(tester);
      await tester.enterText(find.byType(TextField), '040');
      expect(controller.text, '40');

      await tester.enterText(find.byType(TextField), '0,5');
      expect(controller.text, '0,5');
    });

    testWidgets('báo ra ngoài đúng phần vạn tương ứng', (tester) async {
      final reported = <int?>[];
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PercentField(
              label: 'Tỷ trọng mục tiêu',
              initialBp: 4000,
              onChanged: reported.add,
            ),
          ),
        ),
      );

      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        '40',
        reason: 'ô phải mở ra với giá trị đang lưu',
      );

      await tester.enterText(find.byType(TextField), '12,5');
      await tester.enterText(find.byType(TextField), '');
      expect(reported, [1250, null]);
    });
  });
}
