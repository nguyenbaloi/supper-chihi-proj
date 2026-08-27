import '../models/snapshot.dart';

/// Bản chốt.
abstract interface class SnapshotRepository {
  /// Toàn bộ Bản chốt, cũ nhất trước — thứ tự vẽ biểu đồ đường.
  Future<List<Snapshot>> all();

  Stream<List<Snapshot>> watchAll();

  Future<Snapshot?> byId(int id);

  /// Bản chốt tự động của [day], `null` nếu hôm đó chưa có.
  Future<Snapshot?> automaticOn(DateTime day);

  /// Sinh Bản chốt tự động cho hôm nay nếu chưa có.
  ///
  /// Trả về `null` khi hôm nay đã có rồi. Không nội suy các ngày trống —
  /// người dùng không mở ứng dụng ba ngày thì ba ngày đó không có dữ liệu,
  /// và lấp bằng giá trị giả là nói dối. Xem FR-28.
  Future<Snapshot?> captureAutomatic(DateTime today);

  /// Chốt sổ thủ công kèm ghi chú. Xem FR-29.
  Future<Snapshot> captureManual(DateTime at, {String? note});

  /// Xoá một Bản chốt **thủ công**. Bản chốt tự động không xoá được.
  Future<bool> removeManual(int id);
}
