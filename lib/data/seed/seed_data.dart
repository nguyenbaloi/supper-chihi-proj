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
  const SeedAction(this.title, this.status, {this.priority = Priority.medium});
  final String title;
  final ActionStatus status;
  final Priority priority;
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

final class SeedReviewItem {
  const SeedReviewItem(this.label, this.verdict, {this.note = ''});
  final String label;
  final ReviewVerdict verdict;
  final String note;
}

final class SeedReview {
  const SeedReview({
    required this.date,
    required this.title,
    this.summary = '',
    this.nextReviewDate,
    this.items = const [],
  });

  final DateTime date;
  final String title;
  final String summary;
  final DateTime? nextReviewDate;
  final List<SeedReviewItem> items;
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
    this.reviews = const [],
  });

  final String name;
  final String topicKey;
  final String description;
  final Priority priority;
  final List<SeedAction> actions;
  final List<SeedNote> notes;
  final List<SeedLink> links;
  final List<SeedReview> reviews;
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

const String _huyParentNote = '''
Phân tích những việc cha mẹ đang làm sai — và cách làm đúng:

- **Hỏi nhiều quá.** Đúng: chỉ mô tả, hướng dẫn, làm mẫu, hỗ trợ và để Huy dẫn dắt cuộc chơi; không chen ngang hay hối thúc con nói hay làm.
- **Đóng bỉm chưa cai.** Đúng: ban ngày bỏ bỉm, dạy trẻ kỹ năng đòi đi tè.
- **Chiều quá.** Đúng: không làm giúp, giả vờ không biết để Huy tự làm mọi việc — xúc ăn, mặc quần, mặc áo, đòi lấy nước, uống sữa. Mẹ chỉ hướng dẫn và nói: *Sữa, Nước, uống, tè…* để trẻ chủ động giao tiếp.
- **Vẫn xem điện thoại.** Đúng: cai điện thoại khi ăn.
- **Dạy con bắt chước trước khi mình bắt chước con.** Đúng: bắt chước làm theo Huy trước để trẻ thấy mình là bạn, rồi mới hướng dẫn Huy bắt chước lại.
''';

const String _huyMethodNote = '''
Hướng thực hành hằng ngày:

- Tiếp tục tăng cường giao tiếp mắt.
- Tiếp tục chơi vận động.
- Cho đi chơi nhiều nơi để trẻ khám phá, kết nối với thiên nhiên, động vật, con người.
- Chơi hát, đọc thơ kết nối: hát hoặc đọc một đoạn rồi để con đọc đoạn tiếp theo.
- Hướng dẫn giao tiếp không lời: chỉ đồ vật, chỉ hiện tượng — chia sẻ chú ý chung.
- **Dừng hỗ trợ, dừng chiều con.** Không giúp đỡ, mà tạo môi trường buộc con cần tương tác: gây khó khăn cản trở, kích thích thèm muốn để con phải tương tác mới đạt được. Ban đầu là kéo tay, rồi nhìn mắt, rồi dạy nói từ đơn: *mẹ, giúp, mở…*

Địa điểm vận động: buổi sáng 8h–9h và buổi tối 21h–21h30 tìm khu có bóng mát, an toàn. Trong nhà thiết kế thêm trò chơi vận động.
''';

const String _channelNote = '''
**Đối tượng:** phụ nữ, trẻ em, gia đình có điều kiện sẵn sàng chi tiền.

**Chủ đề kênh:** phương pháp tự học toán tư duy và tiếng Anh kết hợp với AI, miễn phí.

**Sản phẩm liên kết:** sách, một số nguồn tài liệu, hoặc app của mình phát triển.

**Cách làm nội dung:** dùng AI tạo nội dung video đăng TikTok để tăng follow.
''';

/// FR-2, FR-3: bảy Dự án cùng Hành động, Ghi chú và Liên kết của chúng.
final List<SeedProject> seedProjects = [
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
    priority: Priority.high,
    description:
        'Lập kế hoạch và theo dõi tiến bộ của con theo mốc thời gian. '
        'Hai điểm trọng tâm: nâng cao thể chất và sức mạnh cơ bắp; '
        'tăng cường tương tác xã hội và chú ý chung.',
    actions: [
      // Nhóm 1 — Vận động thể chất, dinh dưỡng và nếp sinh hoạt
      SeedAction('Ngủ sớm trước 11 giờ đêm', ActionStatus.doing),
      SeedAction('Ăn uống tốt, ít ốm, giảm mồ hôi trộm', ActionStatus.doing),
      SeedAction(
          'Ưu tiên thời gian ra ngoài đi chơi, khám phá thế giới xung quanh',
          ActionStatus.doing),
      // Nhóm 2 — Tương tác xã hội và can thiệp chuyên sâu
      SeedAction(
          'Tăng trò chơi tương tác với anh chị em trong nhà, bố mẹ và bạn nhỏ khác',
          ActionStatus.doing),
      SeedAction(
          'Phối hợp cô giáo can thiệp 1-1: chơi tương tác, chơi chờ lượt, chú ý chung',
          ActionStatus.doing,
          priority: Priority.high),
      // Nhóm 3 — Kỹ năng tự phục vụ và vệ sinh
      SeedAction('Tập đòi đi vệ sinh (tè, ị), tiến tới cai bỉm', ActionStatus.todo,
          priority: Priority.high),
      SeedAction('Rèn thói quen ngồi bô đúng giờ cố định trong ngày', ActionStatus.todo),
      SeedAction('Luyện tự xúc ăn và tuyệt đối cai tivi, điện thoại khi ăn',
          ActionStatus.doing),
      // Nhóm 4 — Phát triển ngôn ngữ
      SeedAction('Dạy con cách trả lời câu hỏi', ActionStatus.doing),
      SeedAction('Mở rộng vốn từ vựng hằng ngày', ActionStatus.doing),
      SeedAction('Hướng dẫn con bắt chước cách đặt câu hỏi', ActionStatus.todo),
    ],
    notes: [
      SeedNote('Những việc cha mẹ đang làm sai', _huyParentNote),
      SeedNote('Hướng thực hành hằng ngày', _huyMethodNote),
    ],
    reviews: [
      SeedReview(
        date: _d(2026, 5, 15),
        title: 'Đánh giá 28 tháng',
        summary: 'Tổng kết: 2 đạt, 3 chưa đạt. Tiếp tục cải thiện những cái chưa đạt.',
        nextReviewDate: _d(2026, 8, 7),
        items: [
          SeedReviewItem('Giấc ngủ', ReviewVerdict.met),
          SeedReviewItem('Ăn uống đa dạng', ReviewVerdict.met),
          SeedReviewItem('Thời lượng vận động trong nhà và ngoài trời',
              ReviewVerdict.notMet,
              note: 'Chưa đủ, cần tăng thời gian chơi.'),
          SeedReviewItem('Tạo tình huống giao tiếp', ReviewVerdict.notMet,
              note: 'Quá ít. Phải tạo nhiều hơn: cố tình không hiểu, không biết, không giúp đỡ.'),
          SeedReviewItem(
              'Chơi giao tiếp mắt, ú oà, cốc cốc, chia sẻ cảm xúc và chơi chờ lượt',
              ReviewVerdict.notMet,
              note: 'Chưa tập trung đều.'),
        ],
      ),
      SeedReview(
        date: _d(2026, 8, 7),
        title: 'Đánh giá 2 tuổi rưỡi + 1 tuần',
        summary:
            'Hai điểm trọng tâm cần xử lý: nâng cao thể chất và sức mạnh cơ bắp; '
            'tăng cường tương tác xã hội và chú ý chung.',
        nextReviewDate: _d(2026, 11, 7),
        items: [
          SeedReviewItem('Tăng cường thể chất vận động', ReviewVerdict.met,
              note: 'Vẫn duy trì. Sắp đến mùa mưa và lạnh, cần phương án chơi ngoài trời thay thế.'),
          SeedReviewItem(
              'Chơi tương tác, chờ lượt, chơi với trẻ khác kèm chú ý chung',
              ReviewVerdict.notMet,
              note: 'Chưa chơi nhiều. Cần tiếp tục dạy và thuê giáo viên hỗ trợ.'),
          SeedReviewItem('Cai bỉm và biết nói mong muốn cơ bản: ăn uống, ị, tè',
              ReviewVerdict.met,
              note: 'Chưa cai được bỉm, chưa biết đòi đi vệ sinh, nhưng tiến bộ ở chỗ biết nói cảm xúc và nhu cầu. Tổng quan là đạt.'),
          SeedReviewItem(
              'Tạo trò chơi và tình huống hằng ngày để trẻ chủ động nói',
              ReviewVerdict.met),
          SeedReviewItem('Ra ngoài đi chơi khám phá điều mới', ReviewVerdict.notMet,
              note: 'Có nhưng chưa nhiều. Cần dành nhiều thời gian hơn khi Huy biết nhiều hơn.'),
        ],
      ),
    ],
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
      SeedAction('Sắp xếp lại thời gian làm việc ở cty và cho cá nhân',
          ActionStatus.doing, priority: Priority.high),
      SeedAction('Cân nhắc vay đầu tư với số vốn hợp lý khi cảm thấy có cơ hội đến',
          ActionStatus.todo, priority: Priority.high),
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

/// Ngày thuần, không giờ. Lưu ở mốc đầu ngày giờ địa phương.
DateTime _d(int y, int m, int d) => DateTime(y, m, d);

