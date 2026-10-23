import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Tiêu đề một khối nội dung. Chữ nhỏ, đậm, giãn ký tự — đủ để mắt bắt được
/// ranh giới giữa hai khối mà không cạnh tranh với tên việc bên dưới.
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
    this.color,
    this.padding = const EdgeInsets.fromLTRB(
      AppSpacing.gutter,
      AppSpacing.xl,
      AppSpacing.gutter,
      AppSpacing.sm,
    ),
  });

  final String title;
  final String? subtitle;
  final Widget? trailing;
  final Color? color;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tint = color ?? theme.colorScheme.primary;
    return Padding(
      padding: padding,
      child: Row(
        // Có nút bên phải thì canh giữa để nhãn và nút nằm cùng một đường;
        // không có thì canh trên để nhãn sát khối nội dung bên dưới.
        crossAxisAlignment:
            trailing == null ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title.toUpperCase(),
                  style: theme.textTheme.labelSmall
                      ?.copyWith(color: tint, letterSpacing: 0.9),
                ),
                if (subtitle != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(subtitle!, style: theme.textTheme.bodySmall),
                  ),
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

/// Một nhóm dòng nằm chung trong thẻ, ngăn nhau bằng vạch thụt vào.
///
/// Đây là hình dáng chủ đạo của app: các danh sách phẳng trôi trên nền xám
/// khiến mọi dòng trông ngang nhau, còn gom thành thẻ thì mắt đọc được ngay
/// "đây là một nhóm, hết nhóm là sang chuyện khác".
class GroupedCard extends StatelessWidget {
  const GroupedCard({
    super.key,
    required this.children,
    this.margin = const EdgeInsets.fromLTRB(
      AppSpacing.gutter,
      0,
      AppSpacing.gutter,
      AppSpacing.md,
    ),
    this.dividerIndent = 56,
  });

  final List<Widget> children;
  final EdgeInsets margin;
  final double dividerIndent;

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: margin,
      child: Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < children.length; i++) ...[
              if (i > 0) Divider(height: 1, indent: dividerIndent),
              children[i],
            ],
          ],
        ),
      ),
    );
  }
}

/// Thẻ nội dung thường — có sẵn lề trong, dùng cho khối không phải danh sách.
class SectionCard extends StatelessWidget {
  const SectionCard({
    super.key,
    required this.child,
    this.margin = const EdgeInsets.fromLTRB(
      AppSpacing.gutter,
      0,
      AppSpacing.gutter,
      AppSpacing.md,
    ),
    this.padding = const EdgeInsets.all(AppSpacing.lg),
    this.onTap,
  });

  final Widget child;
  final EdgeInsets margin;
  final EdgeInsets padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Padding(
        padding: margin,
        child: Card(
          child: InkWell(
            onTap: onTap,
            child: Padding(padding: padding, child: child),
          ),
        ),
      );
}

/// Màn hình rỗng. Một biểu tượng nhạt, một câu nói rõ chuyện gì, một câu gợi
/// việc kế tiếp — không hơn.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.message,
    this.action,
  });

  final IconData icon;
  final String title;
  final String? message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl * 1.5),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 30, color: theme.colorScheme.primary),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              title,
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            if (message != null) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                message!,
                style: theme.textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
            if (action != null) ...[
              const SizedBox(height: AppSpacing.lg),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}

/// Gợi ý cho một khối đang rỗng nhưng **không** phải lỗi — ví dụ chưa ghim
/// việc nào. Viền nhạt, nền trong suốt: đủ để thấy khối tồn tại, không đủ để
/// trông như một dòng dữ liệu thật.
class DottedHint extends StatelessWidget {
  const DottedHint({super.key, required this.text, required this.icon});

  final String text;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg, vertical: AppSpacing.lg),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: theme.colorScheme.outline),
          const SizedBox(width: AppSpacing.md),
          Expanded(child: Text(text, style: theme.textTheme.bodySmall)),
        ],
      ),
    );
  }
}

/// Thanh tiến độ kèm con số. Thanh để liếc, con số để chắc — FR-12 cấm thay
/// con số bằng hình vẽ.
class ProgressRow extends StatelessWidget {
  const ProgressRow({
    super.key,
    required this.ratio,
    required this.label,
    this.color,
  });

  /// `null` nghĩa là chưa xác định — thanh để trống, không vẽ 0%.
  final double? ratio;
  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.pill),
            child: LinearProgressIndicator(
              value: ratio ?? 0,
              minHeight: 7,
              color: color ?? theme.colorScheme.primary,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Text(label, style: theme.textTheme.labelMedium),
      ],
    );
  }
}
