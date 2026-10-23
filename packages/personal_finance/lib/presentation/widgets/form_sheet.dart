import 'package:flutter/material.dart';

/// Mở một form dạng tấm trượt từ đáy, tự tránh bàn phím.
///
/// Gom vào đây vì hai cái bẫy dưới đây lặp lại ở mọi form, và cả hai đều hỏng
/// theo kiểu chỉ thấy trên máy thật:
///
///  1. Phần đệm phải đọc `viewInsets` từ context của **chính tấm trượt**.
///     Đọc từ context của màn hình gọi nó thì tấm trượt nằm ngoài cây đó, nên
///     bàn phím hiện lên mà tấm trượt không dựng lại — đệm mãi bằng 0 và bàn
///     phím che mất ô nhập cuối.
///
///  2. Nội dung phải cuộn được. Bàn phím chiếm gần nửa màn hình, một form
///     vài ô nhập sẽ tràn chứ không tự co lại.
Future<T?> showFormSheet<T>(
  BuildContext context, {
  required WidgetBuilder builder,
}) =>
    showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (sheetContext) => Padding(
        // `viewInsetsOf` tạo phụ thuộc đúng vào phần bàn phím chiếm chỗ, nên
        // tấm trượt dựng lại mỗi khi chiều cao bàn phím đổi.
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(sheetContext).bottom,
        ),
        child: SingleChildScrollView(child: builder(sheetContext)),
      ),
    );
