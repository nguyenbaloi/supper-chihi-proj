import 'package:flutter_test/flutter_test.dart';
import 'package:personal_finance/core/result/result.dart';

void main() {
  group('Result', () {
    test('Ok mang giá trị', () {
      const r = Result<int>.ok(42);
      expect(r.isOk, isTrue);
      expect(r.valueOrNull, 42);
      expect(r.valueOr(0), 42);
    });

    test('Failure không mang giá trị nhưng giữ lý do', () {
      const r = Result<int>.failure('mất mạng');
      expect(r.isFailure, isTrue);
      expect(r.valueOrNull, isNull);
      // Hành vi cốt lõi: lấy giá thất bại thì dùng giá lưu lần cuối, không bao
      // giờ chặn người dùng. Xem AD-11.
      expect(r.valueOr(-1), -1);
    });

    test('giữ được ngoại lệ gốc để gỡ lỗi', () {
      final cause = Exception('socket đóng');
      final r = Result<int>.failure('mất mạng', cause: cause);
      expect((r as Failure<int>).cause, same(cause));
    });

    test('fold rẽ nhánh đúng', () {
      const ok = Result<int>.ok(1);
      const fail = Result<int>.failure('lỗi');
      expect(ok.fold(ok: (v) => 'ok:$v', failure: (f) => 'fail'), 'ok:1');
      expect(
        fail.fold(ok: (v) => 'ok', failure: (f) => 'fail:${f.reason}'),
        'fail:lỗi',
      );
    });
  });
}
