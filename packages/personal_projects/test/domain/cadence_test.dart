import 'package:flutter_test/flutter_test.dart';
import 'package:personal_projects/domain/rules/cadence.dart';
import 'package:personal_projects/domain/rules/day.dart';

/// FR-48, AD-3. Nhịp xem lại của Lĩnh vực **luôn tính, không bao giờ lưu**.
///
/// Kỳ vọng viết qua [startOfDay] chứ không phải `DateTime.utc` thuần: quy ước
/// của project là ngày thuần lưu ở mốc 00:00 **giờ địa phương** quy về UTC.
/// So thẳng với nửa đêm UTC sẽ đúng ở London và sai ở Hà Nội.
void main() {
  final created = DateTime.utc(2026, 1, 1);
  DateTime day(int y, int m, int d) => startOfDay(DateTime(y, m, d));

  group('FR-48 — không đặt nhịp thì tuyệt đối không nhắc', () {
    test('nhịp null trả null, không phải một ngày mặc định nào đó', () {
      expect(
        nextAreaReviewDate(
            cadenceDays: null, lastReviewDate: null, areaCreatedAt: created),
        isNull,
      );
    });

    test('nhịp null thì không bao giờ đến hạn, dù đã bao lâu', () {
      expect(
        isAreaReviewDue(
          cadenceDays: null,
          lastReviewDate: null,
          areaCreatedAt: created,
          now: DateTime.utc(2030),
        ),
        isFalse,
      );
    });

    test('nhịp null thì không có số ngày còn lại để hiển thị', () {
      expect(
        daysUntilAreaReview(
          cadenceDays: null,
          lastReviewDate: null,
          areaCreatedAt: created,
          now: DateTime.utc(2026, 6),
        ),
        isNull,
      );
    });

    test('nhịp <= 0 coi như không đặt, không chia cho không hay lặp vô hạn', () {
      expect(
        nextAreaReviewDate(
            cadenceDays: 0, lastReviewDate: null, areaCreatedAt: created),
        isNull,
      );
    });
  });

  group('FR-48 — mốc đếm', () {
    test('chưa có Đợt nào thì đếm từ ngày tạo Lĩnh vực', () {
      expect(
        nextAreaReviewDate(
            cadenceDays: 30, lastReviewDate: null, areaCreatedAt: created),
        day(2026, 1, 31),
      );
    });

    test('có Đợt rồi thì đếm từ Đợt gần nhất, không phải từ ngày tạo', () {
      expect(
        nextAreaReviewDate(
          cadenceDays: 30,
          lastReviewDate: DateTime.utc(2026, 5, 15),
          areaCreatedAt: created,
        ),
        day(2026, 6, 14),
      );
    });

    // AD-3: đây là lý do không được có cột `nextReviewDate` trên `areas`.
    // Người dùng xoá Đợt gần nhất thì ngày đến hạn phải tự lùi về theo Đợt
    // trước đó — một cột lưu cứng sẽ đứng yên và nói dối.
    test('xoá Đợt gần nhất thì hạn lùi về theo Đợt trước đó', () {
      final withLatest = nextAreaReviewDate(
        cadenceDays: 30,
        lastReviewDate: DateTime.utc(2026, 5, 15),
        areaCreatedAt: created,
      );
      final afterDelete = nextAreaReviewDate(
        cadenceDays: 30,
        lastReviewDate: DateTime.utc(2026, 3, 1),
        areaCreatedAt: created,
      );
      expect(withLatest, day(2026, 6, 14));
      expect(afterDelete, day(2026, 3, 31));
      expect(afterDelete!.isBefore(withLatest!), isTrue);
    });

    test('xoá hết Đợt thì quay về đếm từ ngày tạo', () {
      expect(
        nextAreaReviewDate(
            cadenceDays: 30, lastReviewDate: null, areaCreatedAt: created),
        day(2026, 1, 31),
      );
    });
  });

  group('FR-48 — đến hạn', () {
    test('trước hạn một ngày thì chưa đến hạn', () {
      expect(
        isAreaReviewDue(
          cadenceDays: 30,
          lastReviewDate: null,
          areaCreatedAt: created,
          now: DateTime.utc(2026, 1, 30),
        ),
        isFalse,
      );
    });

    test('đúng ngày hạn đã tính là đến hạn', () {
      expect(
        isAreaReviewDue(
          cadenceDays: 30,
          lastReviewDate: null,
          areaCreatedAt: created,
          now: DateTime.utc(2026, 1, 31),
        ),
        isTrue,
      );
    });

    test('quá hạn thì số ngày còn lại là số âm', () {
      expect(
        daysUntilAreaReview(
          cadenceDays: 30,
          lastReviewDate: null,
          areaCreatedAt: created,
          now: DateTime.utc(2026, 2, 10),
        ),
        -10,
      );
    });

    // "Bây giờ" viết theo giờ địa phương vì đó là cái người dùng nhìn thấy:
    // ranh giới đến hạn phải là nửa đêm ở chỗ họ đứng, không phải ở London.
    test('giờ trong ngày không ảnh hưởng kết quả', () {
      bool dueAt(DateTime localNow) => isAreaReviewDue(
            cadenceDays: 7,
            lastReviewDate: null,
            areaCreatedAt: created,
            now: localNow,
          );
      expect(dueAt(DateTime(2026, 1, 8, 0, 1)), isTrue);
      expect(dueAt(DateTime(2026, 1, 8, 23, 59)), isTrue);
      expect(dueAt(DateTime(2026, 1, 7, 23, 59)), isFalse);
    });
  });

  test('nhịp hợp lệ trong khoảng 1..365', () {
    expect(isValidCadenceDays(0), isFalse);
    expect(isValidCadenceDays(1), isTrue);
    expect(isValidCadenceDays(365), isTrue);
    expect(isValidCadenceDays(366), isFalse);
    for (final d in suggestedCadenceDays) {
      expect(isValidCadenceDays(d), isTrue);
    }
  });
}
