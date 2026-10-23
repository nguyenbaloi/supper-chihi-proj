import 'package:flutter/material.dart';

/// Ánh xạ điểm mã biểu tượng sang [IconData] **hằng**.
///
/// Bắt buộc phải tra bảng chứ không dựng `IconData(codePoint)` tại chỗ:
/// Flutter từ chối rút gọn phông biểu tượng khi gặp `IconData` không hằng, và
/// lỗi chỉ hiện ra lúc build bản phát hành chứ không phải lúc chạy thử.
class AssetClassIcon extends StatelessWidget {
  final int codePoint;
  final Color? color;
  final double? size;

  const AssetClassIcon({
    super.key,
    required this.codePoint,
    this.color,
    this.size,
  });

  static const Map<int, IconData> _icons = {
    0xe67f: Icons.trending_up,
    0xe553: Icons.savings,
    0xf06bc: Icons.currency_bitcoin,
    0xe041: Icons.account_balance_wallet,
    0xf06be: Icons.handshake,
  };

  static IconData resolve(int codePoint) =>
      _icons[codePoint] ?? Icons.pie_chart_outline;

  @override
  Widget build(BuildContext context) =>
      Icon(resolve(codePoint), color: color, size: size);
}
