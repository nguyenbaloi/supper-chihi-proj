/// Bỏ dấu tiếng Việt để tìm kiếm không phân biệt dấu — AD-12, FR-30.
///
/// SQLite không có hàm bỏ dấu và `LIKE` mặc định không xử lý được tiếng Việt,
/// nên chuỗi chuẩn hoá được lưu sẵn vào cột `searchText` mỗi lần ghi.
library;

const Map<String, String> _foldings = {
  'a': 'àáạảãâầấậẩẫăằắặẳẵ',
  'e': 'èéẹẻẽêềếệểễ',
  'i': 'ìíịỉĩ',
  'o': 'òóọỏõôồốộổỗơờớợởỡ',
  'u': 'ùúụủũưừứựửữ',
  'y': 'ỳýỵỷỹ',
  'd': 'đ',
};

final Map<int, String> _map = () {
  final m = <int, String>{};
  for (final entry in _foldings.entries) {
    for (final ch in entry.value.split('')) {
      m[ch.codeUnitAt(0)] = entry.key;
      m[ch.toUpperCase().codeUnitAt(0)] = entry.key;
    }
  }
  return m;
}();

/// `Kế hoạch tài chính` → `ke hoach tai chinh`
///
/// Hạ chữ thường, bỏ dấu, gộp mọi khoảng trắng liên tiếp thành một dấu cách,
/// cắt khoảng trắng hai đầu.
String slugify(String input) {
  final lowered = input.toLowerCase();
  final buffer = StringBuffer();
  for (final unit in lowered.runes) {
    buffer.write(_map[unit] ?? String.fromCharCode(unit));
  }
  return buffer.toString().replaceAll(RegExp(r'\s+'), ' ').trim();
}

/// Gộp nhiều mảnh văn bản thành một chuỗi chỉ mục cho cột `searchText`.
String buildSearchText(Iterable<String?> parts) =>
    slugify(parts.where((p) => p != null && p.isNotEmpty).join(' '));
