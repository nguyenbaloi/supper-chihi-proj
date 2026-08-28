/// Trạng thái và độ ưu tiên — AD-9.
///
/// Lưu xuống cơ sở dữ liệu bằng **chuỗi định danh ổn định**, không bao giờ
/// bằng chỉ số enum: chèn một giá trị mới ở giữa sẽ làm lệch toàn bộ dữ liệu cũ.
///
/// Đọc lên gặp chuỗi lạ thì về giá trị mặc định và **không ném lỗi** — một
/// bản ghi hỏng không được phép làm chết cả màn hình.
library;

enum ProjectStatus {
  notStarted('not_started'),
  active('active'),
  paused('paused'),
  done('done'),
  dropped('dropped');

  const ProjectStatus(this.wire);
  final String wire;

  static const ProjectStatus fallback = ProjectStatus.notStarted;

  static ProjectStatus fromWire(String? value) {
    for (final s in ProjectStatus.values) {
      if (s.wire == value) return s;
    }
    return fallback;
  }

  /// Dự án còn sống — được tính vào danh sách mặc định và vào cảnh báo nguội.
  bool get isOpen => this == ProjectStatus.notStarted ||
      this == ProjectStatus.active ||
      this == ProjectStatus.paused;

  /// Chỉ trạng thái này mới có thể bị đánh dấu nguội — FR-13.
  bool get canGoStale => this == ProjectStatus.active;
}

enum ActionStatus {
  todo('todo'),
  doing('doing'),
  done('done'),
  dropped('dropped');

  const ActionStatus(this.wire);
  final String wire;

  static const ActionStatus fallback = ActionStatus.todo;

  static ActionStatus fromWire(String? value) {
    for (final s in ActionStatus.values) {
      if (s.wire == value) return s;
    }
    return fallback;
  }

  /// Hành động chưa xong và chưa bỏ — nguồn của "quá hạn" và của mẫu số
  /// trong tỷ lệ hoàn thành.
  bool get isOpen => this == ActionStatus.todo || this == ActionStatus.doing;

  /// `Bỏ` không được tính vào mẫu số tỷ lệ hoàn thành — FR-12.
  bool get countsTowardCompletion => this != ActionStatus.dropped;
}

enum Priority {
  high('high', 0),
  medium('medium', 1),
  low('low', 2);

  const Priority(this.wire, this.sortRank);
  final String wire;

  /// Thứ tự sắp xếp: `Cao` lên đầu.
  final int sortRank;

  static const Priority fallback = Priority.medium;

  static Priority fromWire(String? value) {
    for (final p in Priority.values) {
      if (p.wire == value) return p;
    }
    return fallback;
  }
}

/// Loại thực thể mà một [StatusEvent] nói về.
enum StatusEntityType {
  project('project'),
  action('action');

  const StatusEntityType(this.wire);
  final String wire;

  static StatusEntityType fromWire(String? value) =>
      value == 'action' ? StatusEntityType.action : StatusEntityType.project;
}

enum AppThemeMode {
  system('system'),
  light('light'),
  dark('dark');

  const AppThemeMode(this.wire);
  final String wire;

  static AppThemeMode fromWire(String? value) {
    for (final m in AppThemeMode.values) {
      if (m.wire == value) return m;
    }
    return AppThemeMode.system;
  }
}
