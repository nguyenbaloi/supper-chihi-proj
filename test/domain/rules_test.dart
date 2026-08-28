import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:personal_projects/core/money/scaled_value.dart';
import 'package:personal_projects/domain/models/enums.dart';
import 'package:personal_projects/domain/models/goal.dart';
import 'package:personal_projects/domain/rules/completion.dart';
import 'package:personal_projects/domain/rules/day.dart';
import 'package:personal_projects/domain/rules/pace.dart';
import 'package:personal_projects/domain/rules/progress.dart';
import 'package:personal_projects/domain/rules/slugify.dart';
import 'package:personal_projects/domain/rules/stale.dart';

/// Mục tiêu 1 tỷ — lấy nguyên từ file HÀNH ĐỘNG.pdf.
Goal billionGoal({DateTime? dueDate}) => Goal(
      id: 1,
      name: 'Mục tiêu 1 tỷ',
      description: '',
      isNumeric: true,
      targetRaw: 1000000000,
      decimals: 0,
      unit: 'VND',
      dueDate: dueDate,
      createdAt: DateTime.utc(2026, 1, 1),
      updatedAt: DateTime.utc(2026, 1, 1),
    );

GoalUpdate mark(int id, DateTime date, int value, {DateTime? createdAt}) => GoalUpdate(
      id: id,
      goalId: 1,
      date: date,
      valueRaw: value,
      decimals: 0,
      note: '',
      createdAt: createdAt ?? date,
    );

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

  group('Story 3.3 — tiến độ suy ra (FR-22, AD-3)', () {
    final now = DateTime.utc(2026, 8, 28);

    test('chưa có Mốc nào thì trả null, không phải 0', () {
      expect(currentValue(const [], now), isNull);
      expect(progressRatio(billionGoal(), const [], now), isNull);
    });

    test('giá trị hiện tại là Mốc có ngày lớn nhất', () {
      final updates = [
        mark(1, DateTime.utc(2026, 3, 1), 200000000),
        mark(2, DateTime.utc(2026, 8, 1), 340000000),
        mark(3, DateTime.utc(2026, 5, 1), 280000000),
      ];
      expect(currentValue(updates, now), ScaledValue(340000000, 0));
      expect(progressRatio(billionGoal(), updates, now), Decimal.parse('0.34'));
    });

    test('Mốc có ngày trong tương lai không được tính', () {
      final updates = [
        mark(1, DateTime.utc(2026, 8, 1), 340000000),
        mark(2, DateTime.utc(2026, 12, 1), 900000000),
      ];
      expect(currentValue(updates, now), ScaledValue(340000000, 0));
    });

    test('nhiều Mốc trùng ngày thì Mốc nhập sau thắng', () {
      final updates = [
        mark(1, DateTime.utc(2026, 8, 1), 300000000,
            createdAt: DateTime.utc(2026, 8, 1, 9)),
        mark(2, DateTime.utc(2026, 8, 1), 340000000,
            createdAt: DateTime.utc(2026, 8, 1, 17)),
      ];
      expect(currentValue(updates, now), ScaledValue(340000000, 0));
    });

    test('vượt đích không bị chặn ở 100%', () {
      final updates = [mark(1, DateTime.utc(2026, 8, 1), 1200000000)];
      expect(progressRatio(billionGoal(), updates, now), Decimal.parse('1.2'));
    });

    test('mục tiêu định tính không có tiến độ', () {
      final qualitative = Goal(
        id: 2,
        name: 'Tìm thêm một nguồn thu nhập khác',
        description: '',
        isNumeric: false,
        decimals: 0,
        unit: '',
        createdAt: now,
        updatedAt: now,
      );
      expect(progressRatio(qualitative, const [], now), isNull);
    });

    test('KỊCH BẢN BẮT BUỘC 1 — sửa một Mốc ở giữa chuỗi', () {
      final before = [
        mark(1, DateTime.utc(2026, 3, 1), 200000000),
        mark(2, DateTime.utc(2026, 5, 1), 280000000),
        mark(3, DateTime.utc(2026, 8, 1), 340000000),
      ];
      expect(progressRatio(billionGoal(), before, now), Decimal.parse('0.34'));

      // Sửa Mốc giữa: không được ảnh hưởng giá trị hiện tại...
      final edited = [before[0], before[1].copyWith(valueRaw: 500000000), before[2]];
      expect(currentValue(edited, now), ScaledValue(340000000, 0));

      // ...nhưng phải ảnh hưởng nhịp, vì nhịp tính từ Mốc đầu tới Mốc cuối.
      final pace = computePace(
        goal: billionGoal(dueDate: DateTime.utc(2026, 12, 31)),
        updates: edited,
        now: now,
      );
      expect(pace.verdict, isNot(PaceVerdict.unknown));
    });

    test('KỊCH BẢN BẮT BUỘC 2 — đổi ngày một Mốc', () {
      final updates = [
        mark(1, DateTime.utc(2026, 3, 1), 200000000),
        mark(2, DateTime.utc(2026, 8, 1), 340000000),
      ];
      expect(currentValue(updates, now), ScaledValue(340000000, 0));

      // Đẩy Mốc mới nhất ra tương lai: giá trị hiện tại phải lùi về Mốc cũ.
      final moved = [updates[0], updates[1].copyWith(date: DateTime.utc(2026, 12, 1))];
      expect(currentValue(moved, now), ScaledValue(200000000, 0));
      expect(progressRatio(billionGoal(), moved, now), Decimal.parse('0.2'));
    });

    test('khoảng còn thiếu', () {
      final updates = [mark(1, DateTime.utc(2026, 8, 1), 340000000)];
      expect(remainingToTarget(billionGoal(), updates, now),
          ScaledValue(660000000, 0));
    });
  });

  group('Story 3.5 — nhịp và dự báo (FR-24)', () {
    final now = DateTime.utc(2026, 8, 28);

    test('KHÔNG hạn chót thì tuyệt đối không có nhịp và dự báo', () {
      final updates = [
        mark(1, DateTime.utc(2026, 3, 1), 200000000),
        mark(2, DateTime.utc(2026, 8, 1), 340000000),
      ];
      final pace = computePace(goal: billionGoal(), updates: updates, now: now);
      expect(pace.verdict, PaceVerdict.unknown);
      expect(pace.requiredPerMonth, isNull);
      expect(pace.actualPerMonth, isNull);
      expect(pace.hasForecast, isFalse);
    });

    test('dưới hai Mốc thì chưa tính được nhịp', () {
      final pace = computePace(
        goal: billionGoal(dueDate: DateTime.utc(2027, 8, 1)),
        updates: [mark(1, DateTime.utc(2026, 8, 1), 340000000)],
        now: now,
      );
      expect(pace.verdict, PaceVerdict.unknown);
    });

    test('có hạn chót và hai Mốc: tính đủ khoảng thiếu, thời gian, nhịp cần', () {
      final pace = computePace(
        goal: billionGoal(dueDate: DateTime.utc(2027, 8, 28)),
        updates: [
          mark(1, DateTime.utc(2026, 2, 28), 200000000),
          mark(2, DateTime.utc(2026, 8, 28), 340000000),
        ],
        now: now,
      );
      expect(pace.remaining, ScaledValue(660000000, 0));
      expect(pace.daysRemaining, 365);
      expect(pace.requiredPerMonth!.raw, closeTo(54246575, 100));
      // 140 triệu trong 181 ngày ≈ 23,2 triệu/tháng
      expect(pace.actualPerMonth!.raw, closeTo(23204420, 1000));
      expect(pace.verdict, PaceVerdict.behind);
      expect(pace.hasForecast, isTrue);
      expect(pace.forecastMonthsDelta, greaterThan(0)); // chậm
    });

    test('nhịp đủ nhanh cho verdict onTrack và dự báo sớm', () {
      final pace = computePace(
        goal: billionGoal(dueDate: DateTime.utc(2027, 8, 28)),
        updates: [
          mark(1, DateTime.utc(2026, 2, 28), 200000000),
          mark(2, DateTime.utc(2026, 8, 28), 800000000),
        ],
        now: now,
      );
      expect(pace.verdict, PaceVerdict.onTrack);
      expect(pace.forecastMonthsDelta, lessThan(0)); // sớm
    });

    test('nhịp âm được nói thẳng, không có dự báo dương', () {
      final pace = computePace(
        goal: billionGoal(dueDate: DateTime.utc(2027, 8, 28)),
        updates: [
          mark(1, DateTime.utc(2026, 2, 28), 400000000),
          mark(2, DateTime.utc(2026, 8, 28), 340000000),
        ],
        now: now,
      );
      expect(pace.verdict, PaceVerdict.goingBackwards);
      expect(pace.hasForecast, isFalse);
      expect(pace.actualPerMonth!.isNegative, isTrue);
    });

    test('đã vượt đích', () {
      final pace = computePace(
        goal: billionGoal(dueDate: DateTime.utc(2027, 8, 28)),
        updates: [
          mark(1, DateTime.utc(2026, 2, 28), 900000000),
          mark(2, DateTime.utc(2026, 8, 28), 1100000000),
        ],
        now: now,
      );
      expect(pace.verdict, PaceVerdict.reached);
    });

    test('đã qua hạn chót mà chưa đạt đích', () {
      final pace = computePace(
        goal: billionGoal(dueDate: DateTime.utc(2026, 6, 1)),
        updates: [
          mark(1, DateTime.utc(2026, 2, 28), 200000000),
          mark(2, DateTime.utc(2026, 8, 28), 340000000),
        ],
        now: now,
      );
      expect(pace.verdict, PaceVerdict.pastDue);
      expect(pace.hasForecast, isFalse);
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
