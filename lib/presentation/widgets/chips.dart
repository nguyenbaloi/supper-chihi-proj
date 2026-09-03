import 'package:flutter/material.dart';

import '../../core/l10n/strings.dart';
import '../../domain/models/enums.dart';

/// NFR-7: trạng thái và độ ưu tiên **không bao giờ** chỉ phân biệt bằng màu —
/// mỗi mức luôn kèm nhãn chữ.
class StatusChip extends StatelessWidget {
  const StatusChip.project(ProjectStatus this.projectStatus, {super.key})
      : actionStatus = null;
  const StatusChip.action(ActionStatus this.actionStatus, {super.key})
      : projectStatus = null;

  final ProjectStatus? projectStatus;
  final ActionStatus? actionStatus;

  @override
  Widget build(BuildContext context) {
    final (label, color) = projectStatus != null
        ? (S.projectStatus(projectStatus!), _projectColor(projectStatus!))
        : (S.actionStatus(actionStatus!), _actionColor(actionStatus!));
    return _Pill(label: label, color: color);
  }

  static Color _projectColor(ProjectStatus s) => switch (s) {
        ProjectStatus.notStarted => const Color(0xFF90A4AE),
        ProjectStatus.active => const Color(0xFF2E7D32),
        ProjectStatus.paused => const Color(0xFFEF6C00),
        ProjectStatus.done => const Color(0xFF1565C0),
        ProjectStatus.dropped => const Color(0xFF757575),
      };

  static Color _actionColor(ActionStatus s) => switch (s) {
        ActionStatus.todo => const Color(0xFF90A4AE),
        ActionStatus.doing => const Color(0xFF2E7D32),
        ActionStatus.done => const Color(0xFF1565C0),
        ActionStatus.dropped => const Color(0xFF757575),
      };
}

/// NFR-7: ba kết quả phân biệt bằng cả màu lẫn nhãn chữ.
class VerdictChip extends StatelessWidget {
  const VerdictChip(this.verdict, {super.key});

  final ReviewVerdict verdict;

  @override
  Widget build(BuildContext context) => _Pill(
        label: S.reviewVerdict(verdict),
        color: switch (verdict) {
          ReviewVerdict.met => const Color(0xFF2E7D32),
          ReviewVerdict.partial => const Color(0xFFEF6C00),
          ReviewVerdict.notMet => const Color(0xFFC62828),
        },
        icon: switch (verdict) {
          ReviewVerdict.met => Icons.check_circle_outline,
          ReviewVerdict.partial => Icons.adjust,
          ReviewVerdict.notMet => Icons.radio_button_unchecked,
        },
      );
}

class PriorityChip extends StatelessWidget {
  const PriorityChip(this.priority, {super.key});

  final Priority priority;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = switch (priority) {
      Priority.high => isDark ? const Color(0xFFFF5252) : const Color(0xFFC62828),
      Priority.medium => isDark ? const Color(0xFFFFB74D) : const Color(0xFFE65100),
      Priority.low => isDark ? const Color(0xFF90A4AE) : const Color(0xFF546E7A),
    };
    return _Pill(
      label: S.priority(priority),
      color: color,
      icon: switch (priority) {
        Priority.high => Icons.keyboard_double_arrow_up,
        Priority.medium => Icons.drag_handle,
        Priority.low => Icons.keyboard_double_arrow_down,
      },
    );
  }
}

class AreaChip extends StatelessWidget {
  const AreaChip({super.key, required this.name, required this.colorValue});

  final String name;
  final int colorValue;

  @override
  Widget build(BuildContext context) => _Pill(label: name, color: Color(colorValue));
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label, required this.color, this.icon});

  final String label;
  final Color color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.20 : 0.11),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 3),
          ],
          Text(
            label,
            // `height: 1.1` giữ viên thuốc thấp; thang chữ chung để 1.3 cho
            // dấu tiếng Việt, nhưng ở đây chữ chỉ một dòng và không có dấu bị
            // cắt vì viền cách chữ đủ xa.
            style: theme.textTheme.labelSmall
                ?.copyWith(color: color, height: 1.1, letterSpacing: 0.2),
          ),
        ],
      ),
    );
  }
}
