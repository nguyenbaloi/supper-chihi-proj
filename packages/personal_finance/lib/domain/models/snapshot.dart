import 'package:meta/meta.dart';

import '../../core/money/money.dart';
import 'enums.dart';

/// Giá trị một Lớp tài sản bên trong một Bản chốt.
@immutable
class SnapshotDetail {
  final int id;
  final int snapshotId;

  /// `null` nếu Lớp tài sản đã bị xoá sau ngày chốt.
  final int? assetClassId;

  /// Tên Lớp tài sản **tại thời điểm chốt** — đổi tên ở hiện tại không làm
  /// biến dạng cách đọc lịch sử.
  final String assetClassName;

  final Money valueAmount;

  const SnapshotDetail({
    required this.id,
    required this.snapshotId,
    required this.assetClassName,
    required this.valueAmount,
    this.assetClassId,
  });

  @override
  bool operator ==(Object other) =>
      other is SnapshotDetail &&
      other.id == id &&
      other.snapshotId == snapshotId &&
      other.assetClassId == assetClassId &&
      other.assetClassName == assetClassName &&
      other.valueAmount == valueAmount;

  @override
  int get hashCode =>
      Object.hash(id, snapshotId, assetClassId, assetClassName, valueAmount);
}

/// Bản chốt — ảnh chụp bất biến giá trị Danh mục tại một ngày.
///
/// Không mang Vốn góp lũy kế và Lãi lỗ: hai con số đó tính lại từ chuỗi Dòng
/// vốn mỗi lần đọc, vì sửa một Dòng vốn quá khứ chính là sửa lịch sử.
/// Xem AD-12.
@immutable
class Snapshot {
  final int id;
  final DateTime date;
  final Money totalAssetsAmount;
  final Money investmentGroupAmount;
  final SnapshotKind kind;
  final String? note;
  final List<SnapshotDetail> details;

  const Snapshot({
    required this.id,
    required this.date,
    required this.totalAssetsAmount,
    required this.investmentGroupAmount,
    required this.kind,
    this.note,
    this.details = const [],
  });

  bool get isAutomatic => kind == SnapshotKind.auto;

  @override
  bool operator ==(Object other) =>
      other is Snapshot &&
      other.id == id &&
      other.date == date &&
      other.totalAssetsAmount == totalAssetsAmount &&
      other.investmentGroupAmount == investmentGroupAmount &&
      other.kind == kind &&
      other.note == note;

  @override
  int get hashCode => Object.hash(
        id,
        date,
        totalAssetsAmount,
        investmentGroupAmount,
        kind,
        note,
      );

  @override
  String toString() => 'Snapshot($id, $date, $kind)';
}

/// Một Bản chốt kèm hai con số được **tính lại lúc đọc**: Vốn góp lũy kế và
/// Lãi lỗ tại ngày chốt.
///
/// Hai con số này không nằm trong bảng. Sửa một Dòng vốn có ngày trước Bản
/// chốt chính là sửa lịch sử, nên chúng phải chạy lại theo. Đây là ngoại lệ
/// có chủ đích của tính bất biến, xem AD-12.
@immutable
class SnapshotPoint {
  final Snapshot snapshot;
  final Money cumulativeContribution;

  const SnapshotPoint({
    required this.snapshot,
    required this.cumulativeContribution,
  });

  DateTime get date => snapshot.date;

  Money get totalAssets => snapshot.totalAssetsAmount;

  /// Lãi lỗ tại ngày chốt.
  Money get profitLoss =>
      snapshot.investmentGroupAmount - cumulativeContribution;

  @override
  String toString() => 'SnapshotPoint($date, $profitLoss)';
}
