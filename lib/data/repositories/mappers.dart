import '../../domain/models/enums.dart';
import '../../domain/models/goal.dart';
import '../../domain/models/note.dart';
import '../../domain/models/project.dart';
import '../../domain/models/project_action.dart';
import '../../domain/models/topic.dart';
import '../db/database.dart';

/// Chuyển hàng Drift sang model của `domain`.
///
/// Đọc trạng thái luôn đi qua `fromWire`, nên một chuỗi lạ trong cơ sở dữ
/// liệu về giá trị mặc định thay vì làm chết màn hình — AD-9.
extension TopicMapper on TopicRow {
  Topic toModel() => Topic(
        id: id,
        name: name,
        colorValue: colorValue,
        iconKey: iconKey,
        sortOrder: sortOrder,
        isSystemFallback: isSystemFallback,
      );
}

extension ProjectMapper on ProjectRow {
  Project toModel() => Project(
        id: id,
        topicId: topicId,
        name: name,
        description: description,
        status: ProjectStatus.fromWire(status),
        priority: Priority.fromWire(priority),
        dueDate: dueDate,
        createdAt: createdAt,
        updatedAt: updatedAt,
        startedAt: startedAt,
        completedAt: completedAt,
      );
}

extension ActionMapper on ActionRow {
  ProjectAction toModel() => ProjectAction(
        id: id,
        projectId: projectId,
        title: title,
        note: note,
        status: ActionStatus.fromWire(status),
        dueDate: dueDate,
        sortOrder: sortOrder,
        createdAt: createdAt,
        updatedAt: updatedAt,
        startedAt: startedAt,
        completedAt: completedAt,
      );
}

extension GoalMapper on GoalRow {
  Goal toModel() => Goal(
        id: id,
        name: name,
        description: description,
        isNumeric: isNumeric,
        targetRaw: targetRaw,
        decimals: decimals,
        unit: unit,
        dueDate: dueDate,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
}

extension GoalUpdateMapper on GoalUpdateRow {
  GoalUpdate toModel() => GoalUpdate(
        id: id,
        goalId: goalId,
        date: date,
        valueRaw: valueRaw,
        decimals: decimals,
        note: note,
        createdAt: createdAt,
      );
}

extension NoteMapper on NoteRow {
  Note toModel() => Note(
        id: id,
        projectId: projectId,
        title: title,
        bodyMarkdown: bodyMarkdown,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
}

extension LinkMapper on LinkRow {
  Link toModel() => Link(
        id: id,
        projectId: projectId,
        label: label,
        url: url,
        sortOrder: sortOrder,
      );
}

extension StatusEventMapper on StatusEventRow {
  StatusEvent toModel() => StatusEvent(
        id: id,
        entityType: entityType,
        entityId: entityId,
        fromStatus: fromStatus,
        toStatus: toStatus,
        at: at,
      );
}
