import '../models/action_note.dart';

/// Ghi chú kế hoạch.
abstract interface class ActionNoteRepository {
  /// Toàn bộ ghi chú, mới nhất lên trên. Xem FR-37.
  Future<List<ActionNote>> all();

  Stream<List<ActionNote>> watchAll();

  Future<ActionNote> add(String body);

  Future<ActionNote?> updateBody(int id, String body);

  Future<ActionNote?> setCompleted(int id, {required bool completed});

  Future<bool> remove(int id);
}
