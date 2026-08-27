import '../../core/money/money.dart';
import '../models/debt.dart';

/// Sổ nợ.
abstract interface class DebtRepository {
  /// Khoản đang hiệu lực — tập tạo nên Giá trị lớp Cho vay.
  Future<List<Debt>> active();

  /// Khoản đã tất toán, xem lại được nhưng không tính vào tài sản.
  Future<List<Debt>> settled();

  Future<List<Debt>> all();

  Stream<List<Debt>> watchAll();

  Future<Debt?> byId(int id);

  Future<Debt> add({
    required String personName,
    required Money amount,
    required DateTime date,
    String? note,
  });

  Future<Debt?> update(
    int id, {
    String? personName,
    Money? amount,
    DateTime? date,
    String? note,
  });

  /// Đánh dấu đã tất toán. Không hỏi tiền thu về đi đâu, không tự tạo thao
  /// tác nào khác. Xem FR-33.
  Future<Debt?> settle(int id, DateTime settledAt);

  /// Bỏ đánh dấu tất toán, khoản quay lại danh sách đang hiệu lực.
  Future<Debt?> unsettle(int id);

  Future<bool> remove(int id);
}
