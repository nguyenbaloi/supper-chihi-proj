import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/format/vn_date.dart';
import '../../domain/models/enums.dart';
import '../../core/l10n/generated/app_localizations.dart';
import '../../presentation/providers/repository_providers.dart';

/// Xuất toàn bộ dữ liệu ra tệp CSV rồi mở hộp chia sẻ của hệ điều hành.
///
/// Đây là đối trọng bắt buộc của kiến trúc chỉ lưu trên máy: không có epic
/// này thì mất máy là mất trắng toàn bộ lịch sử. Xem FR-38.
Future<void> exportAndShare(BuildContext context, WidgetRef ref) async {
  final l10n = AppL10n.of(context);
  final csv = await buildExportCsv(ref);

  final dir = await getTemporaryDirectory();
  final stamp = VnDate.full(DateTime.now()).replaceAll('/', '-');
  final file = File('${dir.path}/danh-muc-dau-tu-$stamp.csv');

  // BOM UTF-8 để Excel trên Windows đọc đúng dấu tiếng Việt. Thiếu ba byte
  // này thì "Chứng khoán" mở ra thành "Chá»©ng khoÃ¡n".
  await file.writeAsString('﻿$csv', encoding: utf8);

  await ref.read(settingsRepositoryProvider).markExported(
        DateTime.now().toUtc(),
      );

  if (!context.mounted) return;
  await SharePlus.instance.share(
    ShareParams(files: [XFile(file.path)], text: l10n.settingsExport),
  );
}

/// Dựng nội dung CSV gồm đủ Khoản nắm giữ, Dòng vốn, Khoản nợ, Bản chốt và
/// Ghi chú kế hoạch.
Future<String> buildExportCsv(WidgetRef ref) async {
  final classes = await ref.read(assetClassRepositoryProvider).all();
  final holdings = await ref.read(holdingRepositoryProvider).all();
  final cashFlows = await ref.read(cashFlowRepositoryProvider).all();
  final debts = await ref.read(debtRepositoryProvider).all();
  final snapshots = await ref.read(snapshotRepositoryProvider).all();
  final notes = await ref.read(actionNoteRepositoryProvider).all();

  final nameById = {for (final c in classes) c.id: c.name};
  final buffer = StringBuffer();

  void section(String title, List<String> header) {
    buffer
      ..writeln()
      ..writeln(_escape(title))
      ..writeln(header.map(_escape).join(','));
  }

  void row(List<Object?> cells) =>
      buffer.writeln(cells.map((c) => _escape('${c ?? ''}')).join(','));

  section('KHOAN NAM GIU', [
    'Lớp tài sản',
    'Ký hiệu',
    'Tên',
    'Chế độ nhập',
    'Số lượng',
    'Giá trị nhập tay',
    'Tiền tệ',
    'Ghi chú',
  ]);
  for (final h in holdings) {
    row([
      nameById[h.assetClassId],
      h.symbol,
      h.displayName,
      h.inputMode.name,
      h.quantity?.toPlainString(),
      h.manualValueAmount?.amount,
      h.currency.code,
      h.note,
    ]);
  }

  section('DONG VON', ['Ngày', 'Số tiền', 'Ghi chú']);
  for (final f in cashFlows) {
    row([VnDate.full(f.date), f.amount.amount, f.note]);
  }

  section('SO NO', ['Tên người', 'Số tiền', 'Ngày', 'Tất toán', 'Ghi chú']);
  for (final d in debts) {
    row([
      d.personName,
      d.amount.amount,
      VnDate.full(d.date),
      d.settledAt == null ? '' : VnDate.full(d.settledAt!),
      d.note,
    ]);
  }

  section('BAN CHOT', [
    'Ngày',
    'Loại',
    'Tổng tài sản',
    'Nhóm đầu tư',
    'Lớp tài sản',
    'Giá trị',
    'Ghi chú',
  ]);
  for (final s in snapshots) {
    if (s.details.isEmpty) {
      row([
        VnDate.full(s.date),
        s.kind.name,
        s.totalAssetsAmount.amount,
        s.investmentGroupAmount.amount,
        '',
        '',
        s.note,
      ]);
      continue;
    }
    for (final detail in s.details) {
      row([
        VnDate.full(s.date),
        s.kind.name,
        s.totalAssetsAmount.amount,
        s.investmentGroupAmount.amount,
        detail.assetClassName,
        detail.valueAmount.amount,
        s.note,
      ]);
    }
  }

  section('GHI CHU KE HOACH', ['Nội dung', 'Tạo lúc', 'Hoàn thành lúc']);
  for (final n in notes) {
    row([
      n.body,
      VnDate.full(n.createdAt),
      n.completedAt == null ? '' : VnDate.full(n.completedAt!),
    ]);
  }

  return buffer.toString();
}

/// Bọc ô CSV theo RFC 4180 — tên người và ghi chú có thể chứa dấu phẩy.
String _escape(String value) {
  final needsQuotes = value.contains(RegExp(r'[",\n\r]'));
  final escaped = value.replaceAll('"', '""');
  return needsQuotes ? '"$escaped"' : escaped;
}
