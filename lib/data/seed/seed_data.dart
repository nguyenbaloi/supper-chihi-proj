/// Dữ liệu hạt giống — FR-1, FR-2, FR-3.
///
/// Nội dung lấy nguyên văn từ hai file `HÀNH ĐỘNG.pdf` và `Ý TƯỞNG.pdf`,
/// đối chiếu bảng ở `addendum.md` §1. Giữ nguyên chữ của người dùng, kể cả
/// lỗi chính tả, để còn đối chiếu về sau.
///
/// Nguyên tắc: người dùng **không bao giờ nhìn thấy một app trống**.
library;

import '../../domain/models/enums.dart';

final class SeedTopic {
  const SeedTopic(this.key, this.name, this.colorValue, this.iconKey,
      {this.isFallback = false});

  final String key;
  final String name;
  final int colorValue;
  final String iconKey;
  final bool isFallback;
}

/// FR-1: sáu Chủ đề dựng sẵn. `Khác` là Chủ đề hệ thống, không xoá được.
const List<SeedTopic> seedTopics = [
  SeedTopic('family', 'Gia đình', 0xFFE57373, 'family'),
  SeedTopic('income', 'Thu nhập', 0xFF4DB6AC, 'income'),
  SeedTopic('finance', 'Tài chính', 0xFF7986CB, 'finance'),
  SeedTopic('health', 'Sức khoẻ', 0xFF81C784, 'health'),
  SeedTopic('learning', 'Học tập', 0xFFFFB74D, 'learning'),
  SeedTopic('other', 'Khác', 0xFF90A4AE, 'other', isFallback: true),
];

final class SeedAction {
  const SeedAction(this.title, this.status);
  final String title;
  final ActionStatus status;
}

final class SeedNote {
  const SeedNote(this.title, this.body);
  final String title;
  final String body;
}

final class SeedLink {
  const SeedLink(this.label, this.url);
  final String label;
  final String url;
}

final class SeedProject {
  const SeedProject({
    required this.name,
    required this.topicKey,
    this.description = '',
    this.priority = Priority.medium,
    this.actions = const [],
    this.notes = const [],
    this.links = const [],
  });

  final String name;
  final String topicKey;
  final String description;
  final Priority priority;
  final List<SeedAction> actions;
  final List<SeedNote> notes;
  final List<SeedLink> links;
}

const String _debtNote = '''
## 1. Nợ tốt (Good Debt)

Nợ tốt là khoản vay được sử dụng để đầu tư vào một tài sản có khả năng gia tăng giá trị theo thời gian, tạo ra thu nhập, hoặc mang lại lợi ích tài chính lâu dài giúp cải thiện vị thế tài chính ròng của bạn.

**Đặc điểm của nợ tốt:**

- **Tạo ra tài sản tăng giá:** giúp bạn sở hữu thứ gì đó có tiềm năng tăng giá trị trong tương lai.
- **Tạo ra thu nhập:** khoản vay giúp bạn kiếm được nhiều tiền hơn so với chi phí lãi vay.
- **Chi phí lãi vay hợp lý:** lãi suất thường thấp hoặc có lợi thế về thuế.

**Ví dụ về nợ tốt:**

- Vay mua nhà / bất động sản có vị trí tốt và giá hợp lý.
- Vay vốn kinh doanh có kế hoạch và tiềm năng lợi nhuận rõ ràng.
- Vay đầu tư giáo dục — kiến thức và kỹ năng là tài sản vô giá.
- Vay mua tài sản tạo thu nhập: xe tải giao hàng, cho thuê, v.v.

## 2. Khi nào nên vay nợ?

**Bạn nên vay nợ khi:**

- **Mục đích vay là "nợ tốt"** — đầu tư vào tài sản tăng giá, tạo thu nhập hoặc nâng cao năng lực kiếm tiền.
- **Có kế hoạch trả nợ rõ ràng** — đã tính kỹ khả năng chi trả hằng tháng, có dòng tiền ổn định và lịch trình cụ thể.
- **Lãi suất vay hợp lý** — thấp hơn tỷ suất sinh lời dự kiến từ khoản đầu tư.
- **Đã có quỹ dự phòng khẩn cấp.**

**Bạn không nên vay nợ khi:**

- Mục đích vay là "nợ xấu" — chỉ để thoả mãn nhu cầu tiêu dùng nhất thời.
- Để trả nợ cũ (vay chồng vay) — vòng xoáy nguy hiểm, dấu hiệu mất kiểm soát tài chính.
- Dòng tiền không ổn định.
- Lãi suất quá cao, không cân xứng với lợi ích nhận được.
''';

const String _marketNote = '''
- Bài học về sự kiên nhẫn chờ tín hiệu rõ ràng — vội vàng hấp tấp là sai lầm.
- Tích sản dài hạn, quản lý vốn và cân bằng rủi ro.
- Cái khiến mình giàu có chỉ có tài sản tích luỹ là trong Bear market.
- Chuẩn bị cho cú đánh lớn khi thị trường sụp đổ.
- Tiếp tục phân bổ rủi ro. Tích USDT, tiền mặt đợi RSI tuần BTC và chứng khoán chạm đáy.
- Chuẩn bị cả khoản vay và đòi nợ. Đánh ít, đợi thời, đánh cú lớn.
- Không quan tâm giá — giá cao có thể mua vào, giá thấp có thể bán ra; tập trung phân tích tâm lý thị trường và tâm lý nhà đầu tư.
- Tập trung quản trị rủi ro và hiểu tình hình vĩ mô hiện tại.
- Khi nghèo hãy sống như người giàu, và khi giàu hãy sống như người nghèo — tích luỹ tiền mặt.
- Đầu tư như là không đầu tư: tận dụng thời gian, tận dụng lãi kép, tắt hết bảng điện, chỉ giữ tài sản tự tin trong vòng nhiều năm.
''';

const String _channelNote = '''
**Đối tượng:** phụ nữ, trẻ em, gia đình có điều kiện sẵn sàng chi tiền.

**Chủ đề kênh:** phương pháp tự học toán tư duy và tiếng Anh kết hợp với AI, miễn phí.

**Sản phẩm liên kết:** sách, một số nguồn tài liệu, hoặc app của mình phát triển.

**Cách làm nội dung:** dùng AI tạo nội dung video đăng TikTok để tăng follow.
''';

/// FR-2, FR-3: bảy Dự án cùng Hành động, Ghi chú và Liên kết của chúng.
const List<SeedProject> seedProjects = [
  SeedProject(
    name: 'Học tiếng Anh của con',
    topicKey: 'family',
    description: 'Đồng hành cùng con học tiếng Anh.',
  ),
  SeedProject(
    name: 'Học toán của con',
    topicKey: 'family',
    description: 'Toán tư duy cho con.',
  ),
  SeedProject(
    name: 'Dạy Huy',
    topicKey: 'family',
  ),
  SeedProject(
    name: 'Kênh TikTok, YouTube tiếp thị liên kết',
    topicKey: 'income',
    priority: Priority.high,
    description: 'Nguồn thu nhập thụ động ngoài làm thuê.',
    notes: [SeedNote('Định hướng kênh và đối tượng', _channelNote)],
    links: [
      SeedLink('appbox.me — zfy7b1yh', 'https://appbox.me/zfy7b1yh'),
      SeedLink('appbox.me — grjhi4i5', 'https://appbox.me/grjhi4i5'),
      SeedLink('appbox.me — r068qu7f', 'https://appbox.me/r068qu7f'),
    ],
  ),
  SeedProject(
    name: 'Kế hoạch tài chính',
    topicKey: 'finance',
    priority: Priority.high,
    description:
        'Giai đoạn thắt lưng buộc bụng — tập trung mua tài sản. Hướng về gia đình, vợ con.',
    actions: [
      SeedAction('Chỉ mua 1 màn hình phục vụ công việc', ActionStatus.done),
      SeedAction('Sắp xếp lại góc làm việc riêng — Tầng 1', ActionStatus.done),
      SeedAction('Dồn tiền mua máy rửa bát', ActionStatus.todo),
      SeedAction(
          'Sắp xếp lại thời gian làm việc ở cty và cho cá nhân', ActionStatus.doing),
      SeedAction('Cân nhắc vay đầu tư với số vốn hợp lý khi cảm thấy có cơ hội đến',
          ActionStatus.todo),
      SeedAction('Cân bằng danh mục đầu tư — đã có ứng dụng tự làm', ActionStatus.done),
    ],
    notes: [
      SeedNote('Nợ tốt và khi nào nên vay', _debtNote),
      SeedNote('Nguyên tắc thị trường', _marketNote),
    ],
    links: [
      SeedLink(
        'Cơ cấu và quản trị rủi ro tài chính.xlsx',
        'https://docs.google.com/spreadsheets/d/1yt51gsccuOJ53uD9Nt9HIxAIwOOTx81a/edit?gid=1374568313',
      ),
    ],
  ),
  SeedProject(
    name: 'Viết app đẩy store kiếm thu nhập',
    topicKey: 'income',
    priority: Priority.high,
    description: 'Làm ứng dụng tài chính đẩy lên store.',
  ),
  SeedProject(
    name: 'Kiểm soát sức khoẻ bản thân',
    topicKey: 'health',
  ),
];

final class SeedGoal {
  const SeedGoal({
    required this.name,
    required this.isNumeric,
    this.description = '',
    this.targetRaw,
    this.unit = 'VND',
    this.linkedProjectNames = const [],
  });

  final String name;
  final bool isNumeric;
  final String description;
  final int? targetRaw;
  final String unit;
  final List<String> linkedProjectNames;
}

/// FR-3: hai Mục tiêu — một có số, một định tính. Cả hai đều **không có hạn
/// chót** trong tài liệu gốc, nên app sẽ không hiện nhịp cho tới khi người
/// dùng tự đặt hạn (FR-24).
const List<SeedGoal> seedGoals = [
  SeedGoal(
    name: 'Mục tiêu 1 tỷ',
    isNumeric: true,
    targetRaw: 1000000000,
    unit: 'VND',
    linkedProjectNames: ['Kế hoạch tài chính'],
  ),
  SeedGoal(
    name: 'Tìm thêm một nguồn thu nhập khác',
    isNumeric: false,
    description: 'Ưu tiên số 1: tạo ra dòng tiền, thu nhập thụ động ngoài làm thuê.',
    linkedProjectNames: [
      'Kênh TikTok, YouTube tiếp thị liên kết',
      'Viết app đẩy store kiếm thu nhập',
    ],
  ),
];
