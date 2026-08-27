import '../models/target_group.dart';

/// Tỷ trọng mục tiêu và Nhóm mục tiêu.
abstract interface class TargetRepository {
  Future<List<TargetGroup>> groups();

  Stream<List<TargetGroup>> watchGroups();

  Future<TargetGroup> addGroup({
    required String name,
    required int targetWeightBp,
  });

  Future<TargetGroup?> updateGroup(
    int id, {
    String? name,
    int? targetWeightBp,
  });

  Future<bool> removeGroup(int id);

  /// Đặt Tỷ trọng mục tiêu riêng cho một Lớp tài sản. `null` để bỏ mục tiêu.
  Future<void> setClassTarget(int assetClassId, int? targetWeightBp);

  /// Xếp một Lớp tài sản vào Nhóm mục tiêu. `null` để tách khỏi nhóm.
  Future<void> setClassGroup(int assetClassId, int? targetGroupId);

  /// Đổi cấu hình Nhóm đầu tư — tập các Lớp tài sản tham gia tính Lãi lỗ.
  /// Xem FR-27.
  Future<void> setInvestmentGroup(Set<int> assetClassIds);
}
