import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:personal_projects/domain/models/enums.dart';
import 'package:personal_projects/domain/rules/completion.dart';
import 'package:personal_projects/domain/rules/day.dart';
import 'package:personal_projects/domain/rules/slugify.dart';
import 'package:personal_projects/domain/rules/stale.dart';

void main() {
  group('Story 4.1 — bỏ dấu tiếng Việt (AD-12)', () {
    test('gõ không dấu tìm ra tên có dấu', () {
      expect(slugify('Kế hoạch tài chính'), 'ke hoach tai chinh');
    });

    test('xử lý đủ bộ dấu kể cả đ/Đ và nguyên âm ghép', () {
      expect(slugify('Đường Ưu Tiên'), 'duong uu tien');
      expect(slugify('Sức khoẻ bản thân'), 'suc khoe ban than');
      expect(slugify('viết app đẩy store'), 'viet app day store');
      expect(slugify('Kênh Tiktok, youtybe tiếp thị liên kết'),
          'kenh tiktok, youtybe tiep thi lien ket');
    });

    test('không phân biệt hoa thường và gộp khoảng trắng', () {
      expect(slugify('  KẾ   HOẠCH  '), 'ke hoach');
    });

    test('gộp nhiều mảnh thành một chuỗi chỉ mục', () {
      expect(buildSearchText(['Dồn tiền', null, '', 'mua máy rửa bát']),
          'don tien mua may rua bat');
    });
  });

  group('Story 2.7 — tỷ lệ hoàn thành (FR-12, AD-3)', () {
    test('Bỏ không được tính vào mẫu số', () {
      final tally = tallyCompletion([
        ActionStatus.done,
        ActionStatus.done,
        ActionStatus.todo,
        ActionStatus.dropped,
      ]);
      expect(tally.countedTotal, 3);
      expect(tally.doneCount, 2);
    });

    test('Dự án không có Hành động trả null, không phải 0', () {
      expect(tallyCompletion(const []).ratio, isNull);
      expect(tallyCompletion(const []).isEmpty, isTrue);
    });

    test('chỉ toàn Bỏ cũng trả null', () {
      expect(tallyCompletion([ActionStatus.dropped]).ratio, isNull);
    });

    test('sáu hành động hạt giống: 3 Xong / 6 → 50%', () {
      // Đúng bộ dữ liệu ở addendum §1.2.
      final tally = tallyCompletion([
        ActionStatus.done, // màn hình
        ActionStatus.done, // góc làm việc
        ActionStatus.todo, // máy rửa bát
        ActionStatus.doing, // sắp xếp thời gian
        ActionStatus.todo, // cân nhắc vay
        ActionStatus.done, // cân bằng danh mục
      ]);
      expect(tally.ratio, Decimal.parse('0.5'));
    });
  });

  group('Story 2.6 — ngày và quá hạn (FR-17)', () {
    final now = DateTime(2026, 8, 28, 14, 30);

    test('đến hạn hôm nay không phải quá hạn', () {
      expect(isOverdue(dueDate: DateTime(2026, 8, 28), now: now), isFalse);
    });

    test('quá hạn đếm đúng số ngày trễ', () {
      expect(overdueDays(dueDate: DateTime(2026, 8, 25), now: now), 3);
    });

    test('giờ trong ngày không ảnh hưởng kết quả', () {
      expect(isOverdue(dueDate: DateTime(2026, 8, 28, 23, 59), now: now), isFalse);
      expect(isOverdue(dueDate: DateTime(2026, 8, 27, 0, 1), now: now), isTrue);
    });

    test('đến hạn trong 7 ngày', () {
      expect(isDueSoon(dueDate: DateTime(2026, 9, 4), now: now), isTrue);
      expect(isDueSoon(dueDate: DateTime(2026, 9, 5), now: now), isFalse);
      expect(isDueSoon(dueDate: DateTime(2026, 8, 27), now: now), isFalse);
    });
  });

  group('Story 2.8 — Dự án nguội (FR-13)', () {
    final now = DateTime(2026, 8, 28);
    final created = DateTime(2026, 1, 1);

    test('chỉ Đang làm mới có thể nguội', () {
      for (final status in ProjectStatus.values) {
        final stale = isProjectStale(
          status: status,
          lastActivityAt: DateTime(2026, 6, 1),
          createdAt: created,
          now: now,
        );
        expect(stale, status == ProjectStatus.active,
            reason: 'trạng thái ${status.wire}');
      }
    });

    test('đúng ngưỡng thì tính là nguội', () {
      expect(
        isProjectStale(
          status: ProjectStatus.active,
          lastActivityAt: DateTime(2026, 8, 7),
          createdAt: created,
          now: now,
        ),
        isTrue,
      );
      expect(
        isProjectStale(
          status: ProjectStatus.active,
          lastActivityAt: DateTime(2026, 8, 8),
          createdAt: created,
          now: now,
        ),
        isFalse,
      );
    });

    test('chưa có hoạt động nào thì tính từ ngày tạo', () {
      expect(
        isProjectStale(
          status: ProjectStatus.active,
          lastActivityAt: null,
          createdAt: DateTime(2026, 8, 27),
          now: now,
        ),
        isFalse,
      );
      expect(idleDays(lastActivityAt: null, createdAt: created, now: now), 239);
    });

    test('ngưỡng hợp lệ trong khoảng 7..180', () {
      expect(isValidStaleDays(21), isTrue);
      expect(isValidStaleDays(6), isFalse);
      expect(isValidStaleDays(181), isFalse);
    });
  });

  group('AD-9 — trạng thái là tập đóng, đọc chuỗi lạ không ném lỗi', () {
    test('chuỗi lạ về mặc định', () {
      expect(ProjectStatus.fromWire('khong_ton_tai'), ProjectStatus.notStarted);
      expect(ActionStatus.fromWire(null), ActionStatus.todo);
      expect(Priority.fromWire('urgent'), Priority.medium);
    });

    test('chuỗi hợp lệ đọc đúng', () {
      expect(ProjectStatus.fromWire('paused'), ProjectStatus.paused);
      expect(ActionStatus.fromWire('doing'), ActionStatus.doing);
      expect(Priority.fromWire('high'), Priority.high);
    });
  });
}
