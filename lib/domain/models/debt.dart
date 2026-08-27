import 'package:meta/meta.dart';

import '../../core/money/money.dart';

/// Khoản nợ — mình cho ai vay, hoặc mình đang vay ai.
@immutable
class Debt {
  final int id;
  final String personName;

  /// Dương là mình cho vay, âm là mình đi vay.
  final Money amount;

  final DateTime date;
  final String? note;

  /// Ngày tất toán. `null` nghĩa là đang hiệu lực và còn tính vào tài sản.
  final DateTime? settledAt;

  const Debt({
    required this.id,
    required this.personName,
    required this.amount,
    required this.date,
    this.note,
    this.settledAt,
  });

  bool get isSettled => settledAt != null;
  bool get isActive => settledAt == null;

  /// Mình cho vay — người khác đang nợ mình.
  bool get isLent => amount.isPositive;

  /// Mình đi vay — mình đang nợ người khác.
  bool get isBorrowed => amount.isNegative;

  @override
  bool operator ==(Object other) =>
      other is Debt &&
      other.id == id &&
      other.personName == personName &&
      other.amount == amount &&
      other.date == date &&
      other.note == note &&
      other.settledAt == settledAt;

  @override
  int get hashCode =>
      Object.hash(id, personName, amount, date, note, settledAt);

  @override
  String toString() => 'Debt($id, $personName, $amount)';
}
