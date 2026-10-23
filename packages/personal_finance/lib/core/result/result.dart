import 'package:meta/meta.dart';

/// Kết quả của một thao tác có thể thất bại — chủ yếu là các lời gọi mạng.
///
/// Tầng `data` trả về kiểu này thay vì ném ngoại lệ qua ranh giới tầng. Lý do:
/// lấy giá thất bại là chuyện bình thường, không phải sự cố, và tuyệt đối
/// không được chặn thao tác của người dùng. Xem AD-11.
@immutable
sealed class Result<T> {
  const Result();

  const factory Result.ok(T value) = Ok<T>;
  const factory Result.failure(String reason, {Object? cause}) = Failure<T>;

  bool get isOk => this is Ok<T>;
  bool get isFailure => this is Failure<T>;

  /// Giá trị nếu thành công, `null` nếu thất bại.
  T? get valueOrNull => switch (this) {
        Ok<T>(:final value) => value,
        Failure<T>() => null,
      };

  /// Giá trị nếu thành công, ngược lại [fallback].
  T valueOr(T fallback) => valueOrNull ?? fallback;

  R fold<R>({
    required R Function(T value) ok,
    required R Function(Failure<T> failure) failure,
  }) =>
      switch (this) {
        Ok<T>(value: final v) => ok(v),
        Failure<T>() => failure(this as Failure<T>),
      };
}

@immutable
final class Ok<T> extends Result<T> {
  final T value;
  const Ok(this.value);

  @override
  bool operator ==(Object other) => other is Ok<T> && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'Ok($value)';
}

@immutable
final class Failure<T> extends Result<T> {
  /// Lý do thất bại, viết cho người đọc log — không phải chuỗi hiển thị.
  final String reason;

  /// Ngoại lệ gốc nếu có, giữ lại để gỡ lỗi.
  final Object? cause;

  const Failure(this.reason, {this.cause});

  @override
  bool operator ==(Object other) =>
      other is Failure<T> && other.reason == reason && other.cause == cause;

  @override
  int get hashCode => Object.hash(reason, cause);

  @override
  String toString() => 'Failure($reason)';
}
