/// Kiểu kết quả tường minh ở ranh giới tầng `data`.
///
/// Quy tắc: không `throw` để truyền lỗi nghiệp vụ. Lỗi là một giá trị,
/// buộc nơi gọi phải xử lý.
sealed class Result<T> {
  const Result();

  bool get isOk => this is Ok<T>;
  bool get isErr => this is Err<T>;

  /// Giá trị nếu thành công, `null` nếu lỗi.
  T? get valueOrNull => switch (this) {
        Ok<T>(:final value) => value,
        Err<T>() => null,
      };

  R fold<R>(R Function(T value) onOk, R Function(AppFailure failure) onErr) =>
      switch (this) {
        Ok<T>(:final value) => onOk(value),
        Err<T>(:final failure) => onErr(failure),
      };
}

final class Ok<T> extends Result<T> {
  const Ok(this.value);
  final T value;
}

final class Err<T> extends Result<T> {
  const Err(this.failure);
  final AppFailure failure;
}

/// Lý do một thao tác không thành. Mã lỗi là hằng số ổn định; câu chữ
/// hiển thị nằm ở lớp l10n, không nằm ở đây.
final class AppFailure {
  const AppFailure(this.code, {this.detail});

  final FailureCode code;

  /// Chi tiết kỹ thuật để ghi log — không dùng để hiển thị cho người dùng.
  final String? detail;

  @override
  String toString() => 'AppFailure(${code.name}${detail == null ? '' : ': $detail'})';
}

enum FailureCode {
  /// Dữ liệu người dùng nhập không hợp lệ.
  invalidInput,

  /// Bản ghi được yêu cầu không tồn tại.
  notFound,

  /// Vi phạm ràng buộc dữ liệu (khoá ngoại, trùng lặp).
  constraint,

  /// File sao lưu sai định dạng hoặc thiếu trường.
  malformedBackup,

  /// File sao lưu thuộc phiên bản schema mới hơn ứng dụng.
  backupTooNew,

  /// Lỗi không lường trước từ tầng lưu trữ.
  storage,
}
