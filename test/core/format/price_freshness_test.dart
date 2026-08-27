import 'package:flutter_test/flutter_test.dart';
import 'package:personal_finance/core/format/price_freshness.dart';
import 'package:personal_finance/core/format/vn_date.dart';

void main() {
  final now = DateTime.utc(2026, 8, 27, 12);

  PriceFreshness at(Duration ago) =>
      PriceFreshness.since(now.subtract(ago), now: now);

  group('Độ mới của giá', () {
    test('vừa lấy xong', () {
      expect(at(const Duration(seconds: 20)).unit, FreshnessUnit.justNow);
    });

    test('5 phút trước', () {
      final freshness = at(const Duration(minutes: 5));
      expect(freshness.unit, FreshnessUnit.minutes);
      expect(freshness.count, 5);
    });

    test('59 phút vẫn tính bằng phút, 60 phút chuyển sang giờ', () {
      expect(at(const Duration(minutes: 59)).unit, FreshnessUnit.minutes);
      expect(at(const Duration(minutes: 60)).unit, FreshnessUnit.hours);
    });

    test('23 giờ chưa cũ, 24 giờ là cũ', () {
      expect(at(const Duration(hours: 23)).isStale, isFalse);
      expect(at(const Duration(hours: 24)).isStale, isTrue);
      expect(at(const Duration(hours: 24)).unit, FreshnessUnit.days);
    });

    test('ba ngày trước', () {
      final freshness = at(const Duration(days: 3));
      expect(freshness.unit, FreshnessUnit.days);
      expect(freshness.count, 3);
    });

    test('chưa từng lấy được thì là cũ', () {
      expect(PriceFreshness.since(null, now: now), PriceFreshness.never);
      expect(PriceFreshness.never.isStale, isTrue);
    });

    test('thời điểm trong tương lai coi như vừa xong, không âm', () {
      final future = PriceFreshness.since(
        now.add(const Duration(hours: 2)),
        now: now,
      );
      expect(future.unit, FreshnessUnit.justNow);
      expect(future.count, 0);
    });
  });

  group('Ngày kiểu Việt Nam', () {
    test('ngày và tháng luôn hai chữ số', () {
      expect(VnDate.full(DateTime(2026, 8, 7)), '07/08/2026');
      expect(VnDate.short(DateTime(2026, 12, 25)), '25/12');
    });

    test('có giờ phút khi cần', () {
      expect(VnDate.withTime(DateTime(2026, 8, 27, 9, 5)), '27/08/2026 09:05');
    });
  });
}
