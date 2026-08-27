import '../../core/money/money.dart';
import '../models/cash_flow.dart';

/// Sổ Dòng vốn.
///
/// Không có phương thức nào trả về Vốn góp lũy kế đã lưu sẵn — lũy kế luôn
/// tính từ chuỗi này bằng `Contribution`. Xem AD-4.
abstract interface class CashFlowRepository {
  /// Toàn bộ Dòng vốn, sắp theo ngày tăng dần.
  Future<List<CashFlow>> all();

  Stream<List<CashFlow>> watchAll();

  Future<CashFlow?> byId(int id);

  Future<CashFlow> add({
    required DateTime date,
    required Money amount,
    String? note,
  });

  /// Sửa một Dòng vốn, kể cả dòng cũ nhất. Tham số bỏ trống là giữ nguyên.
  Future<CashFlow?> update(
    int id, {
    DateTime? date,
    Money? amount,
    String? note,
  });

  Future<bool> remove(int id);
}
