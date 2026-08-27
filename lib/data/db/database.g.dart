// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $SettingsTableTable extends SettingsTable
    with TableInfo<$SettingsTableTable, SettingsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SettingsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  @override
  late final GeneratedColumnWithTypeConverter<Money, int>
  initialContributionAmount =
      GeneratedColumn<int>(
        'initial_contribution_amount',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<Money>(
        $SettingsTableTable.$converterinitialContributionAmount,
      );
  static const VerificationMeta _startDateMeta = const VerificationMeta(
    'startDate',
  );
  @override
  late final GeneratedColumn<DateTime> startDate = GeneratedColumn<DateTime>(
    'start_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<Money?, int> fxRateManualAmount =
      GeneratedColumn<int>(
        'fx_rate_manual_amount',
        aliasedName,
        true,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
      ).withConverter<Money?>(
        $SettingsTableTable.$converterfxRateManualAmountn,
      );
  static const VerificationMeta _driftThresholdBpMeta = const VerificationMeta(
    'driftThresholdBp',
  );
  @override
  late final GeneratedColumn<int> driftThresholdBp = GeneratedColumn<int>(
    'drift_threshold_bp',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(500),
  );
  static const VerificationMeta _lastExportedAtMeta = const VerificationMeta(
    'lastExportedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastExportedAt =
      GeneratedColumn<DateTime>(
        'last_exported_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  @override
  late final GeneratedColumnWithTypeConverter<ThemeModeSetting, String>
  themeMode = GeneratedColumn<String>(
    'theme_mode',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('system'),
  ).withConverter<ThemeModeSetting>($SettingsTableTable.$converterthemeMode);
  static const VerificationMeta _onboardingCompletedMeta =
      const VerificationMeta('onboardingCompleted');
  @override
  late final GeneratedColumn<bool> onboardingCompleted = GeneratedColumn<bool>(
    'onboarding_completed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("onboarding_completed" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    initialContributionAmount,
    startDate,
    fxRateManualAmount,
    driftThresholdBp,
    lastExportedAt,
    themeMode,
    onboardingCompleted,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<SettingsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('start_date')) {
      context.handle(
        _startDateMeta,
        startDate.isAcceptableOrUnknown(data['start_date']!, _startDateMeta),
      );
    } else if (isInserting) {
      context.missing(_startDateMeta);
    }
    if (data.containsKey('drift_threshold_bp')) {
      context.handle(
        _driftThresholdBpMeta,
        driftThresholdBp.isAcceptableOrUnknown(
          data['drift_threshold_bp']!,
          _driftThresholdBpMeta,
        ),
      );
    }
    if (data.containsKey('last_exported_at')) {
      context.handle(
        _lastExportedAtMeta,
        lastExportedAt.isAcceptableOrUnknown(
          data['last_exported_at']!,
          _lastExportedAtMeta,
        ),
      );
    }
    if (data.containsKey('onboarding_completed')) {
      context.handle(
        _onboardingCompletedMeta,
        onboardingCompleted.isAcceptableOrUnknown(
          data['onboarding_completed']!,
          _onboardingCompletedMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SettingsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SettingsTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      initialContributionAmount: $SettingsTableTable
          .$converterinitialContributionAmount
          .fromSql(
            attachedDatabase.typeMapping.read(
              DriftSqlType.int,
              data['${effectivePrefix}initial_contribution_amount'],
            )!,
          ),
      startDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}start_date'],
      )!,
      fxRateManualAmount: $SettingsTableTable.$converterfxRateManualAmountn
          .fromSql(
            attachedDatabase.typeMapping.read(
              DriftSqlType.int,
              data['${effectivePrefix}fx_rate_manual_amount'],
            ),
          ),
      driftThresholdBp: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}drift_threshold_bp'],
      )!,
      lastExportedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_exported_at'],
      ),
      themeMode: $SettingsTableTable.$converterthemeMode.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}theme_mode'],
        )!,
      ),
      onboardingCompleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}onboarding_completed'],
      )!,
    );
  }

  @override
  $SettingsTableTable createAlias(String alias) {
    return $SettingsTableTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<Money, int, int>
  $converterinitialContributionAmount = const MoneyConverter();
  static JsonTypeConverter2<Money, int, int> $converterfxRateManualAmount =
      const MoneyConverter();
  static JsonTypeConverter2<Money?, int?, int?> $converterfxRateManualAmountn =
      JsonTypeConverter2.asNullable($converterfxRateManualAmount);
  static JsonTypeConverter2<ThemeModeSetting, String, String>
  $converterthemeMode = const EnumNameConverter<ThemeModeSetting>(
    ThemeModeSetting.values,
  );
}

class SettingsTableData extends DataClass
    implements Insertable<SettingsTableData> {
  final int id;

  /// Tổng số tiền ròng đã bỏ vào Nhóm đầu tư tính đến [startDate].
  ///
  /// Bắt buộc phải có. Đây là điểm neo cho mọi phép tính Lãi lỗ về sau: người
  /// dùng bỏ toàn bộ lịch sử quá khứ và bắt đầu từ hiện tại, nên không có con
  /// số này thì ứng dụng sẽ hiểu là chưa bỏ đồng nào vào và báo lãi bằng đúng
  /// toàn bộ giá trị danh mục. Xem AD-4 và FR-3.
  final Money initialContributionAmount;

  /// Ngày bắt đầu dùng ứng dụng, mốc gắn với [initialContributionAmount].
  final DateTime startDate;

  /// Tỷ giá USD sang VND do người dùng nhập tay, `null` nếu dùng tỷ giá tự lấy.
  final Money? fxRateManualAmount;

  /// Ngưỡng cảnh báo lệch so với Tỷ trọng mục tiêu, đơn vị phần vạn.
  /// Mặc định 500 tương đương 5%.
  final int driftThresholdBp;

  /// Lần xuất dữ liệu gần nhất, dùng để nhắc sao lưu.
  final DateTime? lastExportedAt;

  /// Chế độ hiển thị sáng tối. Xem FR-39.
  final ThemeModeSetting themeMode;

  /// Đã hoàn tất luồng khởi tạo lần đầu chưa.
  final bool onboardingCompleted;
  const SettingsTableData({
    required this.id,
    required this.initialContributionAmount,
    required this.startDate,
    this.fxRateManualAmount,
    required this.driftThresholdBp,
    this.lastExportedAt,
    required this.themeMode,
    required this.onboardingCompleted,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    {
      map['initial_contribution_amount'] = Variable<int>(
        $SettingsTableTable.$converterinitialContributionAmount.toSql(
          initialContributionAmount,
        ),
      );
    }
    map['start_date'] = Variable<DateTime>(startDate);
    if (!nullToAbsent || fxRateManualAmount != null) {
      map['fx_rate_manual_amount'] = Variable<int>(
        $SettingsTableTable.$converterfxRateManualAmountn.toSql(
          fxRateManualAmount,
        ),
      );
    }
    map['drift_threshold_bp'] = Variable<int>(driftThresholdBp);
    if (!nullToAbsent || lastExportedAt != null) {
      map['last_exported_at'] = Variable<DateTime>(lastExportedAt);
    }
    {
      map['theme_mode'] = Variable<String>(
        $SettingsTableTable.$converterthemeMode.toSql(themeMode),
      );
    }
    map['onboarding_completed'] = Variable<bool>(onboardingCompleted);
    return map;
  }

  SettingsTableCompanion toCompanion(bool nullToAbsent) {
    return SettingsTableCompanion(
      id: Value(id),
      initialContributionAmount: Value(initialContributionAmount),
      startDate: Value(startDate),
      fxRateManualAmount: fxRateManualAmount == null && nullToAbsent
          ? const Value.absent()
          : Value(fxRateManualAmount),
      driftThresholdBp: Value(driftThresholdBp),
      lastExportedAt: lastExportedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastExportedAt),
      themeMode: Value(themeMode),
      onboardingCompleted: Value(onboardingCompleted),
    );
  }

  factory SettingsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SettingsTableData(
      id: serializer.fromJson<int>(json['id']),
      initialContributionAmount: $SettingsTableTable
          .$converterinitialContributionAmount
          .fromJson(
            serializer.fromJson<int>(json['initialContributionAmount']),
          ),
      startDate: serializer.fromJson<DateTime>(json['startDate']),
      fxRateManualAmount: $SettingsTableTable.$converterfxRateManualAmountn
          .fromJson(serializer.fromJson<int?>(json['fxRateManualAmount'])),
      driftThresholdBp: serializer.fromJson<int>(json['driftThresholdBp']),
      lastExportedAt: serializer.fromJson<DateTime?>(json['lastExportedAt']),
      themeMode: $SettingsTableTable.$converterthemeMode.fromJson(
        serializer.fromJson<String>(json['themeMode']),
      ),
      onboardingCompleted: serializer.fromJson<bool>(
        json['onboardingCompleted'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'initialContributionAmount': serializer.toJson<int>(
        $SettingsTableTable.$converterinitialContributionAmount.toJson(
          initialContributionAmount,
        ),
      ),
      'startDate': serializer.toJson<DateTime>(startDate),
      'fxRateManualAmount': serializer.toJson<int?>(
        $SettingsTableTable.$converterfxRateManualAmountn.toJson(
          fxRateManualAmount,
        ),
      ),
      'driftThresholdBp': serializer.toJson<int>(driftThresholdBp),
      'lastExportedAt': serializer.toJson<DateTime?>(lastExportedAt),
      'themeMode': serializer.toJson<String>(
        $SettingsTableTable.$converterthemeMode.toJson(themeMode),
      ),
      'onboardingCompleted': serializer.toJson<bool>(onboardingCompleted),
    };
  }

  SettingsTableData copyWith({
    int? id,
    Money? initialContributionAmount,
    DateTime? startDate,
    Value<Money?> fxRateManualAmount = const Value.absent(),
    int? driftThresholdBp,
    Value<DateTime?> lastExportedAt = const Value.absent(),
    ThemeModeSetting? themeMode,
    bool? onboardingCompleted,
  }) => SettingsTableData(
    id: id ?? this.id,
    initialContributionAmount:
        initialContributionAmount ?? this.initialContributionAmount,
    startDate: startDate ?? this.startDate,
    fxRateManualAmount: fxRateManualAmount.present
        ? fxRateManualAmount.value
        : this.fxRateManualAmount,
    driftThresholdBp: driftThresholdBp ?? this.driftThresholdBp,
    lastExportedAt: lastExportedAt.present
        ? lastExportedAt.value
        : this.lastExportedAt,
    themeMode: themeMode ?? this.themeMode,
    onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
  );
  SettingsTableData copyWithCompanion(SettingsTableCompanion data) {
    return SettingsTableData(
      id: data.id.present ? data.id.value : this.id,
      initialContributionAmount: data.initialContributionAmount.present
          ? data.initialContributionAmount.value
          : this.initialContributionAmount,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      fxRateManualAmount: data.fxRateManualAmount.present
          ? data.fxRateManualAmount.value
          : this.fxRateManualAmount,
      driftThresholdBp: data.driftThresholdBp.present
          ? data.driftThresholdBp.value
          : this.driftThresholdBp,
      lastExportedAt: data.lastExportedAt.present
          ? data.lastExportedAt.value
          : this.lastExportedAt,
      themeMode: data.themeMode.present ? data.themeMode.value : this.themeMode,
      onboardingCompleted: data.onboardingCompleted.present
          ? data.onboardingCompleted.value
          : this.onboardingCompleted,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SettingsTableData(')
          ..write('id: $id, ')
          ..write('initialContributionAmount: $initialContributionAmount, ')
          ..write('startDate: $startDate, ')
          ..write('fxRateManualAmount: $fxRateManualAmount, ')
          ..write('driftThresholdBp: $driftThresholdBp, ')
          ..write('lastExportedAt: $lastExportedAt, ')
          ..write('themeMode: $themeMode, ')
          ..write('onboardingCompleted: $onboardingCompleted')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    initialContributionAmount,
    startDate,
    fxRateManualAmount,
    driftThresholdBp,
    lastExportedAt,
    themeMode,
    onboardingCompleted,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SettingsTableData &&
          other.id == this.id &&
          other.initialContributionAmount == this.initialContributionAmount &&
          other.startDate == this.startDate &&
          other.fxRateManualAmount == this.fxRateManualAmount &&
          other.driftThresholdBp == this.driftThresholdBp &&
          other.lastExportedAt == this.lastExportedAt &&
          other.themeMode == this.themeMode &&
          other.onboardingCompleted == this.onboardingCompleted);
}

class SettingsTableCompanion extends UpdateCompanion<SettingsTableData> {
  final Value<int> id;
  final Value<Money> initialContributionAmount;
  final Value<DateTime> startDate;
  final Value<Money?> fxRateManualAmount;
  final Value<int> driftThresholdBp;
  final Value<DateTime?> lastExportedAt;
  final Value<ThemeModeSetting> themeMode;
  final Value<bool> onboardingCompleted;
  const SettingsTableCompanion({
    this.id = const Value.absent(),
    this.initialContributionAmount = const Value.absent(),
    this.startDate = const Value.absent(),
    this.fxRateManualAmount = const Value.absent(),
    this.driftThresholdBp = const Value.absent(),
    this.lastExportedAt = const Value.absent(),
    this.themeMode = const Value.absent(),
    this.onboardingCompleted = const Value.absent(),
  });
  SettingsTableCompanion.insert({
    this.id = const Value.absent(),
    required Money initialContributionAmount,
    required DateTime startDate,
    this.fxRateManualAmount = const Value.absent(),
    this.driftThresholdBp = const Value.absent(),
    this.lastExportedAt = const Value.absent(),
    this.themeMode = const Value.absent(),
    this.onboardingCompleted = const Value.absent(),
  }) : initialContributionAmount = Value(initialContributionAmount),
       startDate = Value(startDate);
  static Insertable<SettingsTableData> custom({
    Expression<int>? id,
    Expression<int>? initialContributionAmount,
    Expression<DateTime>? startDate,
    Expression<int>? fxRateManualAmount,
    Expression<int>? driftThresholdBp,
    Expression<DateTime>? lastExportedAt,
    Expression<String>? themeMode,
    Expression<bool>? onboardingCompleted,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (initialContributionAmount != null)
        'initial_contribution_amount': initialContributionAmount,
      if (startDate != null) 'start_date': startDate,
      if (fxRateManualAmount != null)
        'fx_rate_manual_amount': fxRateManualAmount,
      if (driftThresholdBp != null) 'drift_threshold_bp': driftThresholdBp,
      if (lastExportedAt != null) 'last_exported_at': lastExportedAt,
      if (themeMode != null) 'theme_mode': themeMode,
      if (onboardingCompleted != null)
        'onboarding_completed': onboardingCompleted,
    });
  }

  SettingsTableCompanion copyWith({
    Value<int>? id,
    Value<Money>? initialContributionAmount,
    Value<DateTime>? startDate,
    Value<Money?>? fxRateManualAmount,
    Value<int>? driftThresholdBp,
    Value<DateTime?>? lastExportedAt,
    Value<ThemeModeSetting>? themeMode,
    Value<bool>? onboardingCompleted,
  }) {
    return SettingsTableCompanion(
      id: id ?? this.id,
      initialContributionAmount:
          initialContributionAmount ?? this.initialContributionAmount,
      startDate: startDate ?? this.startDate,
      fxRateManualAmount: fxRateManualAmount ?? this.fxRateManualAmount,
      driftThresholdBp: driftThresholdBp ?? this.driftThresholdBp,
      lastExportedAt: lastExportedAt ?? this.lastExportedAt,
      themeMode: themeMode ?? this.themeMode,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (initialContributionAmount.present) {
      map['initial_contribution_amount'] = Variable<int>(
        $SettingsTableTable.$converterinitialContributionAmount.toSql(
          initialContributionAmount.value,
        ),
      );
    }
    if (startDate.present) {
      map['start_date'] = Variable<DateTime>(startDate.value);
    }
    if (fxRateManualAmount.present) {
      map['fx_rate_manual_amount'] = Variable<int>(
        $SettingsTableTable.$converterfxRateManualAmountn.toSql(
          fxRateManualAmount.value,
        ),
      );
    }
    if (driftThresholdBp.present) {
      map['drift_threshold_bp'] = Variable<int>(driftThresholdBp.value);
    }
    if (lastExportedAt.present) {
      map['last_exported_at'] = Variable<DateTime>(lastExportedAt.value);
    }
    if (themeMode.present) {
      map['theme_mode'] = Variable<String>(
        $SettingsTableTable.$converterthemeMode.toSql(themeMode.value),
      );
    }
    if (onboardingCompleted.present) {
      map['onboarding_completed'] = Variable<bool>(onboardingCompleted.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SettingsTableCompanion(')
          ..write('id: $id, ')
          ..write('initialContributionAmount: $initialContributionAmount, ')
          ..write('startDate: $startDate, ')
          ..write('fxRateManualAmount: $fxRateManualAmount, ')
          ..write('driftThresholdBp: $driftThresholdBp, ')
          ..write('lastExportedAt: $lastExportedAt, ')
          ..write('themeMode: $themeMode, ')
          ..write('onboardingCompleted: $onboardingCompleted')
          ..write(')'))
        .toString();
  }
}

class $TargetGroupsTableTable extends TargetGroupsTable
    with TableInfo<$TargetGroupsTableTable, TargetGroupsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TargetGroupsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 60,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _targetWeightBpMeta = const VerificationMeta(
    'targetWeightBp',
  );
  @override
  late final GeneratedColumn<int> targetWeightBp = GeneratedColumn<int>(
    'target_weight_bp',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, targetWeightBp, sortOrder];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'target_groups';
  @override
  VerificationContext validateIntegrity(
    Insertable<TargetGroupsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('target_weight_bp')) {
      context.handle(
        _targetWeightBpMeta,
        targetWeightBp.isAcceptableOrUnknown(
          data['target_weight_bp']!,
          _targetWeightBpMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_targetWeightBpMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TargetGroupsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TargetGroupsTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      targetWeightBp: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}target_weight_bp'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
    );
  }

  @override
  $TargetGroupsTableTable createAlias(String alias) {
    return $TargetGroupsTableTable(attachedDatabase, alias);
  }
}

class TargetGroupsTableData extends DataClass
    implements Insertable<TargetGroupsTableData> {
  final int id;
  final String name;

  /// Tỷ trọng mục tiêu của cả nhóm, đơn vị phần vạn.
  final int targetWeightBp;
  final int sortOrder;
  const TargetGroupsTableData({
    required this.id,
    required this.name,
    required this.targetWeightBp,
    required this.sortOrder,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['target_weight_bp'] = Variable<int>(targetWeightBp);
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  TargetGroupsTableCompanion toCompanion(bool nullToAbsent) {
    return TargetGroupsTableCompanion(
      id: Value(id),
      name: Value(name),
      targetWeightBp: Value(targetWeightBp),
      sortOrder: Value(sortOrder),
    );
  }

  factory TargetGroupsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TargetGroupsTableData(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      targetWeightBp: serializer.fromJson<int>(json['targetWeightBp']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'targetWeightBp': serializer.toJson<int>(targetWeightBp),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  TargetGroupsTableData copyWith({
    int? id,
    String? name,
    int? targetWeightBp,
    int? sortOrder,
  }) => TargetGroupsTableData(
    id: id ?? this.id,
    name: name ?? this.name,
    targetWeightBp: targetWeightBp ?? this.targetWeightBp,
    sortOrder: sortOrder ?? this.sortOrder,
  );
  TargetGroupsTableData copyWithCompanion(TargetGroupsTableCompanion data) {
    return TargetGroupsTableData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      targetWeightBp: data.targetWeightBp.present
          ? data.targetWeightBp.value
          : this.targetWeightBp,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TargetGroupsTableData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('targetWeightBp: $targetWeightBp, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, targetWeightBp, sortOrder);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TargetGroupsTableData &&
          other.id == this.id &&
          other.name == this.name &&
          other.targetWeightBp == this.targetWeightBp &&
          other.sortOrder == this.sortOrder);
}

class TargetGroupsTableCompanion
    extends UpdateCompanion<TargetGroupsTableData> {
  final Value<int> id;
  final Value<String> name;
  final Value<int> targetWeightBp;
  final Value<int> sortOrder;
  const TargetGroupsTableCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.targetWeightBp = const Value.absent(),
    this.sortOrder = const Value.absent(),
  });
  TargetGroupsTableCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required int targetWeightBp,
    this.sortOrder = const Value.absent(),
  }) : name = Value(name),
       targetWeightBp = Value(targetWeightBp);
  static Insertable<TargetGroupsTableData> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<int>? targetWeightBp,
    Expression<int>? sortOrder,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (targetWeightBp != null) 'target_weight_bp': targetWeightBp,
      if (sortOrder != null) 'sort_order': sortOrder,
    });
  }

  TargetGroupsTableCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<int>? targetWeightBp,
    Value<int>? sortOrder,
  }) {
    return TargetGroupsTableCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      targetWeightBp: targetWeightBp ?? this.targetWeightBp,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (targetWeightBp.present) {
      map['target_weight_bp'] = Variable<int>(targetWeightBp.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TargetGroupsTableCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('targetWeightBp: $targetWeightBp, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }
}

class $AssetClassesTableTable extends AssetClassesTable
    with TableInfo<$AssetClassesTableTable, AssetClassesTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AssetClassesTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 60,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<AssetKind, String> kind =
      GeneratedColumn<String>(
        'kind',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<AssetKind>($AssetClassesTableTable.$converterkind);
  static const VerificationMeta _targetWeightBpMeta = const VerificationMeta(
    'targetWeightBp',
  );
  @override
  late final GeneratedColumn<int> targetWeightBp = GeneratedColumn<int>(
    'target_weight_bp',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _targetGroupIdMeta = const VerificationMeta(
    'targetGroupId',
  );
  @override
  late final GeneratedColumn<int> targetGroupId = GeneratedColumn<int>(
    'target_group_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES target_groups (id) ON DELETE SET NULL',
    ),
  );
  static const VerificationMeta _inInvestmentGroupMeta = const VerificationMeta(
    'inInvestmentGroup',
  );
  @override
  late final GeneratedColumn<bool> inInvestmentGroup = GeneratedColumn<bool>(
    'in_investment_group',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("in_investment_group" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _hiddenMeta = const VerificationMeta('hidden');
  @override
  late final GeneratedColumn<bool> hidden = GeneratedColumn<bool>(
    'hidden',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("hidden" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _colorValueMeta = const VerificationMeta(
    'colorValue',
  );
  @override
  late final GeneratedColumn<int> colorValue = GeneratedColumn<int>(
    'color_value',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _iconCodePointMeta = const VerificationMeta(
    'iconCodePoint',
  );
  @override
  late final GeneratedColumn<int> iconCodePoint = GeneratedColumn<int>(
    'icon_code_point',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    kind,
    targetWeightBp,
    targetGroupId,
    inInvestmentGroup,
    hidden,
    sortOrder,
    colorValue,
    iconCodePoint,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'asset_classes';
  @override
  VerificationContext validateIntegrity(
    Insertable<AssetClassesTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('target_weight_bp')) {
      context.handle(
        _targetWeightBpMeta,
        targetWeightBp.isAcceptableOrUnknown(
          data['target_weight_bp']!,
          _targetWeightBpMeta,
        ),
      );
    }
    if (data.containsKey('target_group_id')) {
      context.handle(
        _targetGroupIdMeta,
        targetGroupId.isAcceptableOrUnknown(
          data['target_group_id']!,
          _targetGroupIdMeta,
        ),
      );
    }
    if (data.containsKey('in_investment_group')) {
      context.handle(
        _inInvestmentGroupMeta,
        inInvestmentGroup.isAcceptableOrUnknown(
          data['in_investment_group']!,
          _inInvestmentGroupMeta,
        ),
      );
    }
    if (data.containsKey('hidden')) {
      context.handle(
        _hiddenMeta,
        hidden.isAcceptableOrUnknown(data['hidden']!, _hiddenMeta),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    if (data.containsKey('color_value')) {
      context.handle(
        _colorValueMeta,
        colorValue.isAcceptableOrUnknown(data['color_value']!, _colorValueMeta),
      );
    } else if (isInserting) {
      context.missing(_colorValueMeta);
    }
    if (data.containsKey('icon_code_point')) {
      context.handle(
        _iconCodePointMeta,
        iconCodePoint.isAcceptableOrUnknown(
          data['icon_code_point']!,
          _iconCodePointMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_iconCodePointMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AssetClassesTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AssetClassesTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      kind: $AssetClassesTableTable.$converterkind.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}kind'],
        )!,
      ),
      targetWeightBp: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}target_weight_bp'],
      ),
      targetGroupId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}target_group_id'],
      ),
      inInvestmentGroup: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}in_investment_group'],
      )!,
      hidden: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}hidden'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      colorValue: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}color_value'],
      )!,
      iconCodePoint: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}icon_code_point'],
      )!,
    );
  }

  @override
  $AssetClassesTableTable createAlias(String alias) {
    return $AssetClassesTableTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<AssetKind, String, String> $converterkind =
      const EnumNameConverter<AssetKind>(AssetKind.values);
}

class AssetClassesTableData extends DataClass
    implements Insertable<AssetClassesTableData> {
  final int id;
  final String name;
  final AssetKind kind;

  /// Tỷ trọng mục tiêu, đơn vị phần vạn — 5000 tương đương 50%.
  ///
  /// Dùng phần vạn thay vì số thực để giữ nguyên tắc cấm dấu phẩy động,
  /// và đủ mịn cho mọi mục tiêu người dùng đặt ra.
  final int? targetWeightBp;

  /// Nhóm mục tiêu chứa lớp này, `null` nếu lớp tự đứng một mình.
  ///
  /// Khi có nhóm, [targetWeightBp] của riêng lớp bị bỏ qua — mục tiêu đặt ở
  /// cấp nhóm. Xem FR-19.
  final int? targetGroupId;

  /// Lớp này có tham gia tính Lãi lỗ không.
  ///
  /// Mặc định chỉ Chứng khoán và Crypto — đây là hai lớp người dùng coi là
  /// tài sản đầu tư thật sự. Xem FR-25 và FR-27.
  final bool inInvestmentGroup;
  final bool hidden;
  final int sortOrder;

  /// Màu hiển thị trên biểu đồ tròn, dạng ARGB.
  final int colorValue;

  /// Điểm mã của biểu tượng trong bộ Material Icons.
  final int iconCodePoint;
  const AssetClassesTableData({
    required this.id,
    required this.name,
    required this.kind,
    this.targetWeightBp,
    this.targetGroupId,
    required this.inInvestmentGroup,
    required this.hidden,
    required this.sortOrder,
    required this.colorValue,
    required this.iconCodePoint,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    {
      map['kind'] = Variable<String>(
        $AssetClassesTableTable.$converterkind.toSql(kind),
      );
    }
    if (!nullToAbsent || targetWeightBp != null) {
      map['target_weight_bp'] = Variable<int>(targetWeightBp);
    }
    if (!nullToAbsent || targetGroupId != null) {
      map['target_group_id'] = Variable<int>(targetGroupId);
    }
    map['in_investment_group'] = Variable<bool>(inInvestmentGroup);
    map['hidden'] = Variable<bool>(hidden);
    map['sort_order'] = Variable<int>(sortOrder);
    map['color_value'] = Variable<int>(colorValue);
    map['icon_code_point'] = Variable<int>(iconCodePoint);
    return map;
  }

  AssetClassesTableCompanion toCompanion(bool nullToAbsent) {
    return AssetClassesTableCompanion(
      id: Value(id),
      name: Value(name),
      kind: Value(kind),
      targetWeightBp: targetWeightBp == null && nullToAbsent
          ? const Value.absent()
          : Value(targetWeightBp),
      targetGroupId: targetGroupId == null && nullToAbsent
          ? const Value.absent()
          : Value(targetGroupId),
      inInvestmentGroup: Value(inInvestmentGroup),
      hidden: Value(hidden),
      sortOrder: Value(sortOrder),
      colorValue: Value(colorValue),
      iconCodePoint: Value(iconCodePoint),
    );
  }

  factory AssetClassesTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AssetClassesTableData(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      kind: $AssetClassesTableTable.$converterkind.fromJson(
        serializer.fromJson<String>(json['kind']),
      ),
      targetWeightBp: serializer.fromJson<int?>(json['targetWeightBp']),
      targetGroupId: serializer.fromJson<int?>(json['targetGroupId']),
      inInvestmentGroup: serializer.fromJson<bool>(json['inInvestmentGroup']),
      hidden: serializer.fromJson<bool>(json['hidden']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      colorValue: serializer.fromJson<int>(json['colorValue']),
      iconCodePoint: serializer.fromJson<int>(json['iconCodePoint']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'kind': serializer.toJson<String>(
        $AssetClassesTableTable.$converterkind.toJson(kind),
      ),
      'targetWeightBp': serializer.toJson<int?>(targetWeightBp),
      'targetGroupId': serializer.toJson<int?>(targetGroupId),
      'inInvestmentGroup': serializer.toJson<bool>(inInvestmentGroup),
      'hidden': serializer.toJson<bool>(hidden),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'colorValue': serializer.toJson<int>(colorValue),
      'iconCodePoint': serializer.toJson<int>(iconCodePoint),
    };
  }

  AssetClassesTableData copyWith({
    int? id,
    String? name,
    AssetKind? kind,
    Value<int?> targetWeightBp = const Value.absent(),
    Value<int?> targetGroupId = const Value.absent(),
    bool? inInvestmentGroup,
    bool? hidden,
    int? sortOrder,
    int? colorValue,
    int? iconCodePoint,
  }) => AssetClassesTableData(
    id: id ?? this.id,
    name: name ?? this.name,
    kind: kind ?? this.kind,
    targetWeightBp: targetWeightBp.present
        ? targetWeightBp.value
        : this.targetWeightBp,
    targetGroupId: targetGroupId.present
        ? targetGroupId.value
        : this.targetGroupId,
    inInvestmentGroup: inInvestmentGroup ?? this.inInvestmentGroup,
    hidden: hidden ?? this.hidden,
    sortOrder: sortOrder ?? this.sortOrder,
    colorValue: colorValue ?? this.colorValue,
    iconCodePoint: iconCodePoint ?? this.iconCodePoint,
  );
  AssetClassesTableData copyWithCompanion(AssetClassesTableCompanion data) {
    return AssetClassesTableData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      kind: data.kind.present ? data.kind.value : this.kind,
      targetWeightBp: data.targetWeightBp.present
          ? data.targetWeightBp.value
          : this.targetWeightBp,
      targetGroupId: data.targetGroupId.present
          ? data.targetGroupId.value
          : this.targetGroupId,
      inInvestmentGroup: data.inInvestmentGroup.present
          ? data.inInvestmentGroup.value
          : this.inInvestmentGroup,
      hidden: data.hidden.present ? data.hidden.value : this.hidden,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      colorValue: data.colorValue.present
          ? data.colorValue.value
          : this.colorValue,
      iconCodePoint: data.iconCodePoint.present
          ? data.iconCodePoint.value
          : this.iconCodePoint,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AssetClassesTableData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('kind: $kind, ')
          ..write('targetWeightBp: $targetWeightBp, ')
          ..write('targetGroupId: $targetGroupId, ')
          ..write('inInvestmentGroup: $inInvestmentGroup, ')
          ..write('hidden: $hidden, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('colorValue: $colorValue, ')
          ..write('iconCodePoint: $iconCodePoint')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    kind,
    targetWeightBp,
    targetGroupId,
    inInvestmentGroup,
    hidden,
    sortOrder,
    colorValue,
    iconCodePoint,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AssetClassesTableData &&
          other.id == this.id &&
          other.name == this.name &&
          other.kind == this.kind &&
          other.targetWeightBp == this.targetWeightBp &&
          other.targetGroupId == this.targetGroupId &&
          other.inInvestmentGroup == this.inInvestmentGroup &&
          other.hidden == this.hidden &&
          other.sortOrder == this.sortOrder &&
          other.colorValue == this.colorValue &&
          other.iconCodePoint == this.iconCodePoint);
}

class AssetClassesTableCompanion
    extends UpdateCompanion<AssetClassesTableData> {
  final Value<int> id;
  final Value<String> name;
  final Value<AssetKind> kind;
  final Value<int?> targetWeightBp;
  final Value<int?> targetGroupId;
  final Value<bool> inInvestmentGroup;
  final Value<bool> hidden;
  final Value<int> sortOrder;
  final Value<int> colorValue;
  final Value<int> iconCodePoint;
  const AssetClassesTableCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.kind = const Value.absent(),
    this.targetWeightBp = const Value.absent(),
    this.targetGroupId = const Value.absent(),
    this.inInvestmentGroup = const Value.absent(),
    this.hidden = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.colorValue = const Value.absent(),
    this.iconCodePoint = const Value.absent(),
  });
  AssetClassesTableCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required AssetKind kind,
    this.targetWeightBp = const Value.absent(),
    this.targetGroupId = const Value.absent(),
    this.inInvestmentGroup = const Value.absent(),
    this.hidden = const Value.absent(),
    this.sortOrder = const Value.absent(),
    required int colorValue,
    required int iconCodePoint,
  }) : name = Value(name),
       kind = Value(kind),
       colorValue = Value(colorValue),
       iconCodePoint = Value(iconCodePoint);
  static Insertable<AssetClassesTableData> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? kind,
    Expression<int>? targetWeightBp,
    Expression<int>? targetGroupId,
    Expression<bool>? inInvestmentGroup,
    Expression<bool>? hidden,
    Expression<int>? sortOrder,
    Expression<int>? colorValue,
    Expression<int>? iconCodePoint,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (kind != null) 'kind': kind,
      if (targetWeightBp != null) 'target_weight_bp': targetWeightBp,
      if (targetGroupId != null) 'target_group_id': targetGroupId,
      if (inInvestmentGroup != null) 'in_investment_group': inInvestmentGroup,
      if (hidden != null) 'hidden': hidden,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (colorValue != null) 'color_value': colorValue,
      if (iconCodePoint != null) 'icon_code_point': iconCodePoint,
    });
  }

  AssetClassesTableCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<AssetKind>? kind,
    Value<int?>? targetWeightBp,
    Value<int?>? targetGroupId,
    Value<bool>? inInvestmentGroup,
    Value<bool>? hidden,
    Value<int>? sortOrder,
    Value<int>? colorValue,
    Value<int>? iconCodePoint,
  }) {
    return AssetClassesTableCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      kind: kind ?? this.kind,
      targetWeightBp: targetWeightBp ?? this.targetWeightBp,
      targetGroupId: targetGroupId ?? this.targetGroupId,
      inInvestmentGroup: inInvestmentGroup ?? this.inInvestmentGroup,
      hidden: hidden ?? this.hidden,
      sortOrder: sortOrder ?? this.sortOrder,
      colorValue: colorValue ?? this.colorValue,
      iconCodePoint: iconCodePoint ?? this.iconCodePoint,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(
        $AssetClassesTableTable.$converterkind.toSql(kind.value),
      );
    }
    if (targetWeightBp.present) {
      map['target_weight_bp'] = Variable<int>(targetWeightBp.value);
    }
    if (targetGroupId.present) {
      map['target_group_id'] = Variable<int>(targetGroupId.value);
    }
    if (inInvestmentGroup.present) {
      map['in_investment_group'] = Variable<bool>(inInvestmentGroup.value);
    }
    if (hidden.present) {
      map['hidden'] = Variable<bool>(hidden.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (colorValue.present) {
      map['color_value'] = Variable<int>(colorValue.value);
    }
    if (iconCodePoint.present) {
      map['icon_code_point'] = Variable<int>(iconCodePoint.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AssetClassesTableCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('kind: $kind, ')
          ..write('targetWeightBp: $targetWeightBp, ')
          ..write('targetGroupId: $targetGroupId, ')
          ..write('inInvestmentGroup: $inInvestmentGroup, ')
          ..write('hidden: $hidden, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('colorValue: $colorValue, ')
          ..write('iconCodePoint: $iconCodePoint')
          ..write(')'))
        .toString();
  }
}

class $HoldingsTableTable extends HoldingsTable
    with TableInfo<$HoldingsTableTable, HoldingsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HoldingsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _assetClassIdMeta = const VerificationMeta(
    'assetClassId',
  );
  @override
  late final GeneratedColumn<int> assetClassId = GeneratedColumn<int>(
    'asset_class_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES asset_classes (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _symbolMeta = const VerificationMeta('symbol');
  @override
  late final GeneratedColumn<String> symbol = GeneratedColumn<String>(
    'symbol',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 20,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _displayNameMeta = const VerificationMeta(
    'displayName',
  );
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
    'display_name',
    aliasedName,
    true,
    additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 100),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<InputMode, String> inputMode =
      GeneratedColumn<String>(
        'input_mode',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<InputMode>($HoldingsTableTable.$converterinputMode);
  static const VerificationMeta _quantityRawMeta = const VerificationMeta(
    'quantityRaw',
  );
  @override
  late final GeneratedColumn<int> quantityRaw = GeneratedColumn<int>(
    'quantity_raw',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _decimalsMeta = const VerificationMeta(
    'decimals',
  );
  @override
  late final GeneratedColumn<int> decimals = GeneratedColumn<int>(
    'decimals',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  late final GeneratedColumnWithTypeConverter<Money?, int> manualValueAmount =
      GeneratedColumn<int>(
        'manual_value_amount',
        aliasedName,
        true,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
      ).withConverter<Money?>($HoldingsTableTable.$convertermanualValueAmountn);
  @override
  late final GeneratedColumnWithTypeConverter<Currency, String> currency =
      GeneratedColumn<String>(
        'currency',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<Currency>($HoldingsTableTable.$convertercurrency);
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 500),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    assetClassId,
    symbol,
    displayName,
    inputMode,
    quantityRaw,
    decimals,
    manualValueAmount,
    currency,
    note,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'holdings';
  @override
  VerificationContext validateIntegrity(
    Insertable<HoldingsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('asset_class_id')) {
      context.handle(
        _assetClassIdMeta,
        assetClassId.isAcceptableOrUnknown(
          data['asset_class_id']!,
          _assetClassIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_assetClassIdMeta);
    }
    if (data.containsKey('symbol')) {
      context.handle(
        _symbolMeta,
        symbol.isAcceptableOrUnknown(data['symbol']!, _symbolMeta),
      );
    } else if (isInserting) {
      context.missing(_symbolMeta);
    }
    if (data.containsKey('display_name')) {
      context.handle(
        _displayNameMeta,
        displayName.isAcceptableOrUnknown(
          data['display_name']!,
          _displayNameMeta,
        ),
      );
    }
    if (data.containsKey('quantity_raw')) {
      context.handle(
        _quantityRawMeta,
        quantityRaw.isAcceptableOrUnknown(
          data['quantity_raw']!,
          _quantityRawMeta,
        ),
      );
    }
    if (data.containsKey('decimals')) {
      context.handle(
        _decimalsMeta,
        decimals.isAcceptableOrUnknown(data['decimals']!, _decimalsMeta),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {assetClassId, symbol},
  ];
  @override
  HoldingsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HoldingsTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      assetClassId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}asset_class_id'],
      )!,
      symbol: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}symbol'],
      )!,
      displayName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}display_name'],
      ),
      inputMode: $HoldingsTableTable.$converterinputMode.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}input_mode'],
        )!,
      ),
      quantityRaw: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}quantity_raw'],
      ),
      decimals: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}decimals'],
      )!,
      manualValueAmount: $HoldingsTableTable.$convertermanualValueAmountn
          .fromSql(
            attachedDatabase.typeMapping.read(
              DriftSqlType.int,
              data['${effectivePrefix}manual_value_amount'],
            ),
          ),
      currency: $HoldingsTableTable.$convertercurrency.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}currency'],
        )!,
      ),
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $HoldingsTableTable createAlias(String alias) {
    return $HoldingsTableTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<InputMode, String, String> $converterinputMode =
      const EnumNameConverter<InputMode>(InputMode.values);
  static JsonTypeConverter2<Money, int, int> $convertermanualValueAmount =
      const MoneyConverter();
  static JsonTypeConverter2<Money?, int?, int?> $convertermanualValueAmountn =
      JsonTypeConverter2.asNullable($convertermanualValueAmount);
  static JsonTypeConverter2<Currency, String, String> $convertercurrency =
      const EnumNameConverter<Currency>(Currency.values);
}

class HoldingsTableData extends DataClass
    implements Insertable<HoldingsTableData> {
  final int id;
  final int assetClassId;

  /// Ký hiệu: BTC, ETH, FPT, HCM. Duy nhất trong phạm vi một Lớp tài sản.
  final String symbol;
  final String? displayName;
  final InputMode inputMode;

  /// Số lượng đã nhân `10^decimals`. Chỉ dùng khi [inputMode] là `quantity`.
  final int? quantityRaw;

  /// Số chữ số thập phân của [quantityRaw].
  final int decimals;

  /// Giá trị nhập thẳng. Chỉ dùng khi [inputMode] là `value`.
  final Money? manualValueAmount;
  final Currency currency;
  final String? note;
  final DateTime updatedAt;
  const HoldingsTableData({
    required this.id,
    required this.assetClassId,
    required this.symbol,
    this.displayName,
    required this.inputMode,
    this.quantityRaw,
    required this.decimals,
    this.manualValueAmount,
    required this.currency,
    this.note,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['asset_class_id'] = Variable<int>(assetClassId);
    map['symbol'] = Variable<String>(symbol);
    if (!nullToAbsent || displayName != null) {
      map['display_name'] = Variable<String>(displayName);
    }
    {
      map['input_mode'] = Variable<String>(
        $HoldingsTableTable.$converterinputMode.toSql(inputMode),
      );
    }
    if (!nullToAbsent || quantityRaw != null) {
      map['quantity_raw'] = Variable<int>(quantityRaw);
    }
    map['decimals'] = Variable<int>(decimals);
    if (!nullToAbsent || manualValueAmount != null) {
      map['manual_value_amount'] = Variable<int>(
        $HoldingsTableTable.$convertermanualValueAmountn.toSql(
          manualValueAmount,
        ),
      );
    }
    {
      map['currency'] = Variable<String>(
        $HoldingsTableTable.$convertercurrency.toSql(currency),
      );
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  HoldingsTableCompanion toCompanion(bool nullToAbsent) {
    return HoldingsTableCompanion(
      id: Value(id),
      assetClassId: Value(assetClassId),
      symbol: Value(symbol),
      displayName: displayName == null && nullToAbsent
          ? const Value.absent()
          : Value(displayName),
      inputMode: Value(inputMode),
      quantityRaw: quantityRaw == null && nullToAbsent
          ? const Value.absent()
          : Value(quantityRaw),
      decimals: Value(decimals),
      manualValueAmount: manualValueAmount == null && nullToAbsent
          ? const Value.absent()
          : Value(manualValueAmount),
      currency: Value(currency),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      updatedAt: Value(updatedAt),
    );
  }

  factory HoldingsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HoldingsTableData(
      id: serializer.fromJson<int>(json['id']),
      assetClassId: serializer.fromJson<int>(json['assetClassId']),
      symbol: serializer.fromJson<String>(json['symbol']),
      displayName: serializer.fromJson<String?>(json['displayName']),
      inputMode: $HoldingsTableTable.$converterinputMode.fromJson(
        serializer.fromJson<String>(json['inputMode']),
      ),
      quantityRaw: serializer.fromJson<int?>(json['quantityRaw']),
      decimals: serializer.fromJson<int>(json['decimals']),
      manualValueAmount: $HoldingsTableTable.$convertermanualValueAmountn
          .fromJson(serializer.fromJson<int?>(json['manualValueAmount'])),
      currency: $HoldingsTableTable.$convertercurrency.fromJson(
        serializer.fromJson<String>(json['currency']),
      ),
      note: serializer.fromJson<String?>(json['note']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'assetClassId': serializer.toJson<int>(assetClassId),
      'symbol': serializer.toJson<String>(symbol),
      'displayName': serializer.toJson<String?>(displayName),
      'inputMode': serializer.toJson<String>(
        $HoldingsTableTable.$converterinputMode.toJson(inputMode),
      ),
      'quantityRaw': serializer.toJson<int?>(quantityRaw),
      'decimals': serializer.toJson<int>(decimals),
      'manualValueAmount': serializer.toJson<int?>(
        $HoldingsTableTable.$convertermanualValueAmountn.toJson(
          manualValueAmount,
        ),
      ),
      'currency': serializer.toJson<String>(
        $HoldingsTableTable.$convertercurrency.toJson(currency),
      ),
      'note': serializer.toJson<String?>(note),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  HoldingsTableData copyWith({
    int? id,
    int? assetClassId,
    String? symbol,
    Value<String?> displayName = const Value.absent(),
    InputMode? inputMode,
    Value<int?> quantityRaw = const Value.absent(),
    int? decimals,
    Value<Money?> manualValueAmount = const Value.absent(),
    Currency? currency,
    Value<String?> note = const Value.absent(),
    DateTime? updatedAt,
  }) => HoldingsTableData(
    id: id ?? this.id,
    assetClassId: assetClassId ?? this.assetClassId,
    symbol: symbol ?? this.symbol,
    displayName: displayName.present ? displayName.value : this.displayName,
    inputMode: inputMode ?? this.inputMode,
    quantityRaw: quantityRaw.present ? quantityRaw.value : this.quantityRaw,
    decimals: decimals ?? this.decimals,
    manualValueAmount: manualValueAmount.present
        ? manualValueAmount.value
        : this.manualValueAmount,
    currency: currency ?? this.currency,
    note: note.present ? note.value : this.note,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  HoldingsTableData copyWithCompanion(HoldingsTableCompanion data) {
    return HoldingsTableData(
      id: data.id.present ? data.id.value : this.id,
      assetClassId: data.assetClassId.present
          ? data.assetClassId.value
          : this.assetClassId,
      symbol: data.symbol.present ? data.symbol.value : this.symbol,
      displayName: data.displayName.present
          ? data.displayName.value
          : this.displayName,
      inputMode: data.inputMode.present ? data.inputMode.value : this.inputMode,
      quantityRaw: data.quantityRaw.present
          ? data.quantityRaw.value
          : this.quantityRaw,
      decimals: data.decimals.present ? data.decimals.value : this.decimals,
      manualValueAmount: data.manualValueAmount.present
          ? data.manualValueAmount.value
          : this.manualValueAmount,
      currency: data.currency.present ? data.currency.value : this.currency,
      note: data.note.present ? data.note.value : this.note,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HoldingsTableData(')
          ..write('id: $id, ')
          ..write('assetClassId: $assetClassId, ')
          ..write('symbol: $symbol, ')
          ..write('displayName: $displayName, ')
          ..write('inputMode: $inputMode, ')
          ..write('quantityRaw: $quantityRaw, ')
          ..write('decimals: $decimals, ')
          ..write('manualValueAmount: $manualValueAmount, ')
          ..write('currency: $currency, ')
          ..write('note: $note, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    assetClassId,
    symbol,
    displayName,
    inputMode,
    quantityRaw,
    decimals,
    manualValueAmount,
    currency,
    note,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HoldingsTableData &&
          other.id == this.id &&
          other.assetClassId == this.assetClassId &&
          other.symbol == this.symbol &&
          other.displayName == this.displayName &&
          other.inputMode == this.inputMode &&
          other.quantityRaw == this.quantityRaw &&
          other.decimals == this.decimals &&
          other.manualValueAmount == this.manualValueAmount &&
          other.currency == this.currency &&
          other.note == this.note &&
          other.updatedAt == this.updatedAt);
}

class HoldingsTableCompanion extends UpdateCompanion<HoldingsTableData> {
  final Value<int> id;
  final Value<int> assetClassId;
  final Value<String> symbol;
  final Value<String?> displayName;
  final Value<InputMode> inputMode;
  final Value<int?> quantityRaw;
  final Value<int> decimals;
  final Value<Money?> manualValueAmount;
  final Value<Currency> currency;
  final Value<String?> note;
  final Value<DateTime> updatedAt;
  const HoldingsTableCompanion({
    this.id = const Value.absent(),
    this.assetClassId = const Value.absent(),
    this.symbol = const Value.absent(),
    this.displayName = const Value.absent(),
    this.inputMode = const Value.absent(),
    this.quantityRaw = const Value.absent(),
    this.decimals = const Value.absent(),
    this.manualValueAmount = const Value.absent(),
    this.currency = const Value.absent(),
    this.note = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  HoldingsTableCompanion.insert({
    this.id = const Value.absent(),
    required int assetClassId,
    required String symbol,
    this.displayName = const Value.absent(),
    required InputMode inputMode,
    this.quantityRaw = const Value.absent(),
    this.decimals = const Value.absent(),
    this.manualValueAmount = const Value.absent(),
    required Currency currency,
    this.note = const Value.absent(),
    required DateTime updatedAt,
  }) : assetClassId = Value(assetClassId),
       symbol = Value(symbol),
       inputMode = Value(inputMode),
       currency = Value(currency),
       updatedAt = Value(updatedAt);
  static Insertable<HoldingsTableData> custom({
    Expression<int>? id,
    Expression<int>? assetClassId,
    Expression<String>? symbol,
    Expression<String>? displayName,
    Expression<String>? inputMode,
    Expression<int>? quantityRaw,
    Expression<int>? decimals,
    Expression<int>? manualValueAmount,
    Expression<String>? currency,
    Expression<String>? note,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (assetClassId != null) 'asset_class_id': assetClassId,
      if (symbol != null) 'symbol': symbol,
      if (displayName != null) 'display_name': displayName,
      if (inputMode != null) 'input_mode': inputMode,
      if (quantityRaw != null) 'quantity_raw': quantityRaw,
      if (decimals != null) 'decimals': decimals,
      if (manualValueAmount != null) 'manual_value_amount': manualValueAmount,
      if (currency != null) 'currency': currency,
      if (note != null) 'note': note,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  HoldingsTableCompanion copyWith({
    Value<int>? id,
    Value<int>? assetClassId,
    Value<String>? symbol,
    Value<String?>? displayName,
    Value<InputMode>? inputMode,
    Value<int?>? quantityRaw,
    Value<int>? decimals,
    Value<Money?>? manualValueAmount,
    Value<Currency>? currency,
    Value<String?>? note,
    Value<DateTime>? updatedAt,
  }) {
    return HoldingsTableCompanion(
      id: id ?? this.id,
      assetClassId: assetClassId ?? this.assetClassId,
      symbol: symbol ?? this.symbol,
      displayName: displayName ?? this.displayName,
      inputMode: inputMode ?? this.inputMode,
      quantityRaw: quantityRaw ?? this.quantityRaw,
      decimals: decimals ?? this.decimals,
      manualValueAmount: manualValueAmount ?? this.manualValueAmount,
      currency: currency ?? this.currency,
      note: note ?? this.note,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (assetClassId.present) {
      map['asset_class_id'] = Variable<int>(assetClassId.value);
    }
    if (symbol.present) {
      map['symbol'] = Variable<String>(symbol.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (inputMode.present) {
      map['input_mode'] = Variable<String>(
        $HoldingsTableTable.$converterinputMode.toSql(inputMode.value),
      );
    }
    if (quantityRaw.present) {
      map['quantity_raw'] = Variable<int>(quantityRaw.value);
    }
    if (decimals.present) {
      map['decimals'] = Variable<int>(decimals.value);
    }
    if (manualValueAmount.present) {
      map['manual_value_amount'] = Variable<int>(
        $HoldingsTableTable.$convertermanualValueAmountn.toSql(
          manualValueAmount.value,
        ),
      );
    }
    if (currency.present) {
      map['currency'] = Variable<String>(
        $HoldingsTableTable.$convertercurrency.toSql(currency.value),
      );
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HoldingsTableCompanion(')
          ..write('id: $id, ')
          ..write('assetClassId: $assetClassId, ')
          ..write('symbol: $symbol, ')
          ..write('displayName: $displayName, ')
          ..write('inputMode: $inputMode, ')
          ..write('quantityRaw: $quantityRaw, ')
          ..write('decimals: $decimals, ')
          ..write('manualValueAmount: $manualValueAmount, ')
          ..write('currency: $currency, ')
          ..write('note: $note, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $PriceQuotesTableTable extends PriceQuotesTable
    with TableInfo<$PriceQuotesTableTable, PriceQuotesTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PriceQuotesTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _symbolMeta = const VerificationMeta('symbol');
  @override
  late final GeneratedColumn<String> symbol = GeneratedColumn<String>(
    'symbol',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 20,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<PriceSource, String> source =
      GeneratedColumn<String>(
        'source',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<PriceSource>($PriceQuotesTableTable.$convertersource);
  @override
  late final GeneratedColumnWithTypeConverter<Money, int> priceAmount =
      GeneratedColumn<int>(
        'price_amount',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<Money>($PriceQuotesTableTable.$converterpriceAmount);
  @override
  late final GeneratedColumnWithTypeConverter<Currency, String> currency =
      GeneratedColumn<String>(
        'currency',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<Currency>($PriceQuotesTableTable.$convertercurrency);
  static const VerificationMeta _fetchedAtMeta = const VerificationMeta(
    'fetchedAt',
  );
  @override
  late final GeneratedColumn<DateTime> fetchedAt = GeneratedColumn<DateTime>(
    'fetched_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    symbol,
    source,
    priceAmount,
    currency,
    fetchedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'price_quotes';
  @override
  VerificationContext validateIntegrity(
    Insertable<PriceQuotesTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('symbol')) {
      context.handle(
        _symbolMeta,
        symbol.isAcceptableOrUnknown(data['symbol']!, _symbolMeta),
      );
    } else if (isInserting) {
      context.missing(_symbolMeta);
    }
    if (data.containsKey('fetched_at')) {
      context.handle(
        _fetchedAtMeta,
        fetchedAt.isAcceptableOrUnknown(data['fetched_at']!, _fetchedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_fetchedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {symbol, source};
  @override
  PriceQuotesTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PriceQuotesTableData(
      symbol: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}symbol'],
      )!,
      source: $PriceQuotesTableTable.$convertersource.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}source'],
        )!,
      ),
      priceAmount: $PriceQuotesTableTable.$converterpriceAmount.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}price_amount'],
        )!,
      ),
      currency: $PriceQuotesTableTable.$convertercurrency.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}currency'],
        )!,
      ),
      fetchedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}fetched_at'],
      )!,
    );
  }

  @override
  $PriceQuotesTableTable createAlias(String alias) {
    return $PriceQuotesTableTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<PriceSource, String, String> $convertersource =
      const EnumNameConverter<PriceSource>(PriceSource.values);
  static JsonTypeConverter2<Money, int, int> $converterpriceAmount =
      const MoneyConverter();
  static JsonTypeConverter2<Currency, String, String> $convertercurrency =
      const EnumNameConverter<Currency>(Currency.values);
}

class PriceQuotesTableData extends DataClass
    implements Insertable<PriceQuotesTableData> {
  final String symbol;
  final PriceSource source;

  /// Giá một đơn vị, tính theo đơn vị nhỏ nhất của [currency]: đồng với VND,
  /// xu với USD. Xem `CurrencyX.decimals`.
  final Money priceAmount;
  final Currency currency;

  /// Thời điểm lấy được giá này. Bắt buộc — không có trạng thái nào mà ứng
  /// dụng hiện số liệu tài chính mà không cho biết nó tính từ giá lúc nào.
  /// Xem FR-13.
  final DateTime fetchedAt;
  const PriceQuotesTableData({
    required this.symbol,
    required this.source,
    required this.priceAmount,
    required this.currency,
    required this.fetchedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['symbol'] = Variable<String>(symbol);
    {
      map['source'] = Variable<String>(
        $PriceQuotesTableTable.$convertersource.toSql(source),
      );
    }
    {
      map['price_amount'] = Variable<int>(
        $PriceQuotesTableTable.$converterpriceAmount.toSql(priceAmount),
      );
    }
    {
      map['currency'] = Variable<String>(
        $PriceQuotesTableTable.$convertercurrency.toSql(currency),
      );
    }
    map['fetched_at'] = Variable<DateTime>(fetchedAt);
    return map;
  }

  PriceQuotesTableCompanion toCompanion(bool nullToAbsent) {
    return PriceQuotesTableCompanion(
      symbol: Value(symbol),
      source: Value(source),
      priceAmount: Value(priceAmount),
      currency: Value(currency),
      fetchedAt: Value(fetchedAt),
    );
  }

  factory PriceQuotesTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PriceQuotesTableData(
      symbol: serializer.fromJson<String>(json['symbol']),
      source: $PriceQuotesTableTable.$convertersource.fromJson(
        serializer.fromJson<String>(json['source']),
      ),
      priceAmount: $PriceQuotesTableTable.$converterpriceAmount.fromJson(
        serializer.fromJson<int>(json['priceAmount']),
      ),
      currency: $PriceQuotesTableTable.$convertercurrency.fromJson(
        serializer.fromJson<String>(json['currency']),
      ),
      fetchedAt: serializer.fromJson<DateTime>(json['fetchedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'symbol': serializer.toJson<String>(symbol),
      'source': serializer.toJson<String>(
        $PriceQuotesTableTable.$convertersource.toJson(source),
      ),
      'priceAmount': serializer.toJson<int>(
        $PriceQuotesTableTable.$converterpriceAmount.toJson(priceAmount),
      ),
      'currency': serializer.toJson<String>(
        $PriceQuotesTableTable.$convertercurrency.toJson(currency),
      ),
      'fetchedAt': serializer.toJson<DateTime>(fetchedAt),
    };
  }

  PriceQuotesTableData copyWith({
    String? symbol,
    PriceSource? source,
    Money? priceAmount,
    Currency? currency,
    DateTime? fetchedAt,
  }) => PriceQuotesTableData(
    symbol: symbol ?? this.symbol,
    source: source ?? this.source,
    priceAmount: priceAmount ?? this.priceAmount,
    currency: currency ?? this.currency,
    fetchedAt: fetchedAt ?? this.fetchedAt,
  );
  PriceQuotesTableData copyWithCompanion(PriceQuotesTableCompanion data) {
    return PriceQuotesTableData(
      symbol: data.symbol.present ? data.symbol.value : this.symbol,
      source: data.source.present ? data.source.value : this.source,
      priceAmount: data.priceAmount.present
          ? data.priceAmount.value
          : this.priceAmount,
      currency: data.currency.present ? data.currency.value : this.currency,
      fetchedAt: data.fetchedAt.present ? data.fetchedAt.value : this.fetchedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PriceQuotesTableData(')
          ..write('symbol: $symbol, ')
          ..write('source: $source, ')
          ..write('priceAmount: $priceAmount, ')
          ..write('currency: $currency, ')
          ..write('fetchedAt: $fetchedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(symbol, source, priceAmount, currency, fetchedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PriceQuotesTableData &&
          other.symbol == this.symbol &&
          other.source == this.source &&
          other.priceAmount == this.priceAmount &&
          other.currency == this.currency &&
          other.fetchedAt == this.fetchedAt);
}

class PriceQuotesTableCompanion extends UpdateCompanion<PriceQuotesTableData> {
  final Value<String> symbol;
  final Value<PriceSource> source;
  final Value<Money> priceAmount;
  final Value<Currency> currency;
  final Value<DateTime> fetchedAt;
  final Value<int> rowid;
  const PriceQuotesTableCompanion({
    this.symbol = const Value.absent(),
    this.source = const Value.absent(),
    this.priceAmount = const Value.absent(),
    this.currency = const Value.absent(),
    this.fetchedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PriceQuotesTableCompanion.insert({
    required String symbol,
    required PriceSource source,
    required Money priceAmount,
    required Currency currency,
    required DateTime fetchedAt,
    this.rowid = const Value.absent(),
  }) : symbol = Value(symbol),
       source = Value(source),
       priceAmount = Value(priceAmount),
       currency = Value(currency),
       fetchedAt = Value(fetchedAt);
  static Insertable<PriceQuotesTableData> custom({
    Expression<String>? symbol,
    Expression<String>? source,
    Expression<int>? priceAmount,
    Expression<String>? currency,
    Expression<DateTime>? fetchedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (symbol != null) 'symbol': symbol,
      if (source != null) 'source': source,
      if (priceAmount != null) 'price_amount': priceAmount,
      if (currency != null) 'currency': currency,
      if (fetchedAt != null) 'fetched_at': fetchedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PriceQuotesTableCompanion copyWith({
    Value<String>? symbol,
    Value<PriceSource>? source,
    Value<Money>? priceAmount,
    Value<Currency>? currency,
    Value<DateTime>? fetchedAt,
    Value<int>? rowid,
  }) {
    return PriceQuotesTableCompanion(
      symbol: symbol ?? this.symbol,
      source: source ?? this.source,
      priceAmount: priceAmount ?? this.priceAmount,
      currency: currency ?? this.currency,
      fetchedAt: fetchedAt ?? this.fetchedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (symbol.present) {
      map['symbol'] = Variable<String>(symbol.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(
        $PriceQuotesTableTable.$convertersource.toSql(source.value),
      );
    }
    if (priceAmount.present) {
      map['price_amount'] = Variable<int>(
        $PriceQuotesTableTable.$converterpriceAmount.toSql(priceAmount.value),
      );
    }
    if (currency.present) {
      map['currency'] = Variable<String>(
        $PriceQuotesTableTable.$convertercurrency.toSql(currency.value),
      );
    }
    if (fetchedAt.present) {
      map['fetched_at'] = Variable<DateTime>(fetchedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PriceQuotesTableCompanion(')
          ..write('symbol: $symbol, ')
          ..write('source: $source, ')
          ..write('priceAmount: $priceAmount, ')
          ..write('currency: $currency, ')
          ..write('fetchedAt: $fetchedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FxRatesTableTable extends FxRatesTable
    with TableInfo<$FxRatesTableTable, FxRatesTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FxRatesTableTable(this.attachedDatabase, [this._alias]);
  @override
  late final GeneratedColumnWithTypeConverter<PriceSource, String> source =
      GeneratedColumn<String>(
        'source',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<PriceSource>($FxRatesTableTable.$convertersource);
  @override
  late final GeneratedColumnWithTypeConverter<Money, int> rateAmount =
      GeneratedColumn<int>(
        'rate_amount',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<Money>($FxRatesTableTable.$converterrateAmount);
  static const VerificationMeta _fetchedAtMeta = const VerificationMeta(
    'fetchedAt',
  );
  @override
  late final GeneratedColumn<DateTime> fetchedAt = GeneratedColumn<DateTime>(
    'fetched_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [source, rateAmount, fetchedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'fx_rates';
  @override
  VerificationContext validateIntegrity(
    Insertable<FxRatesTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('fetched_at')) {
      context.handle(
        _fetchedAtMeta,
        fetchedAt.isAcceptableOrUnknown(data['fetched_at']!, _fetchedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_fetchedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {source};
  @override
  FxRatesTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FxRatesTableData(
      source: $FxRatesTableTable.$convertersource.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}source'],
        )!,
      ),
      rateAmount: $FxRatesTableTable.$converterrateAmount.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}rate_amount'],
        )!,
      ),
      fetchedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}fetched_at'],
      )!,
    );
  }

  @override
  $FxRatesTableTable createAlias(String alias) {
    return $FxRatesTableTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<PriceSource, String, String> $convertersource =
      const EnumNameConverter<PriceSource>(PriceSource.values);
  static JsonTypeConverter2<Money, int, int> $converterrateAmount =
      const MoneyConverter();
}

class FxRatesTableData extends DataClass
    implements Insertable<FxRatesTableData> {
  final PriceSource source;

  /// Số đồng cho một đô la.
  final Money rateAmount;
  final DateTime fetchedAt;
  const FxRatesTableData({
    required this.source,
    required this.rateAmount,
    required this.fetchedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    {
      map['source'] = Variable<String>(
        $FxRatesTableTable.$convertersource.toSql(source),
      );
    }
    {
      map['rate_amount'] = Variable<int>(
        $FxRatesTableTable.$converterrateAmount.toSql(rateAmount),
      );
    }
    map['fetched_at'] = Variable<DateTime>(fetchedAt);
    return map;
  }

  FxRatesTableCompanion toCompanion(bool nullToAbsent) {
    return FxRatesTableCompanion(
      source: Value(source),
      rateAmount: Value(rateAmount),
      fetchedAt: Value(fetchedAt),
    );
  }

  factory FxRatesTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FxRatesTableData(
      source: $FxRatesTableTable.$convertersource.fromJson(
        serializer.fromJson<String>(json['source']),
      ),
      rateAmount: $FxRatesTableTable.$converterrateAmount.fromJson(
        serializer.fromJson<int>(json['rateAmount']),
      ),
      fetchedAt: serializer.fromJson<DateTime>(json['fetchedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'source': serializer.toJson<String>(
        $FxRatesTableTable.$convertersource.toJson(source),
      ),
      'rateAmount': serializer.toJson<int>(
        $FxRatesTableTable.$converterrateAmount.toJson(rateAmount),
      ),
      'fetchedAt': serializer.toJson<DateTime>(fetchedAt),
    };
  }

  FxRatesTableData copyWith({
    PriceSource? source,
    Money? rateAmount,
    DateTime? fetchedAt,
  }) => FxRatesTableData(
    source: source ?? this.source,
    rateAmount: rateAmount ?? this.rateAmount,
    fetchedAt: fetchedAt ?? this.fetchedAt,
  );
  FxRatesTableData copyWithCompanion(FxRatesTableCompanion data) {
    return FxRatesTableData(
      source: data.source.present ? data.source.value : this.source,
      rateAmount: data.rateAmount.present
          ? data.rateAmount.value
          : this.rateAmount,
      fetchedAt: data.fetchedAt.present ? data.fetchedAt.value : this.fetchedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FxRatesTableData(')
          ..write('source: $source, ')
          ..write('rateAmount: $rateAmount, ')
          ..write('fetchedAt: $fetchedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(source, rateAmount, fetchedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FxRatesTableData &&
          other.source == this.source &&
          other.rateAmount == this.rateAmount &&
          other.fetchedAt == this.fetchedAt);
}

class FxRatesTableCompanion extends UpdateCompanion<FxRatesTableData> {
  final Value<PriceSource> source;
  final Value<Money> rateAmount;
  final Value<DateTime> fetchedAt;
  final Value<int> rowid;
  const FxRatesTableCompanion({
    this.source = const Value.absent(),
    this.rateAmount = const Value.absent(),
    this.fetchedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FxRatesTableCompanion.insert({
    required PriceSource source,
    required Money rateAmount,
    required DateTime fetchedAt,
    this.rowid = const Value.absent(),
  }) : source = Value(source),
       rateAmount = Value(rateAmount),
       fetchedAt = Value(fetchedAt);
  static Insertable<FxRatesTableData> custom({
    Expression<String>? source,
    Expression<int>? rateAmount,
    Expression<DateTime>? fetchedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (source != null) 'source': source,
      if (rateAmount != null) 'rate_amount': rateAmount,
      if (fetchedAt != null) 'fetched_at': fetchedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FxRatesTableCompanion copyWith({
    Value<PriceSource>? source,
    Value<Money>? rateAmount,
    Value<DateTime>? fetchedAt,
    Value<int>? rowid,
  }) {
    return FxRatesTableCompanion(
      source: source ?? this.source,
      rateAmount: rateAmount ?? this.rateAmount,
      fetchedAt: fetchedAt ?? this.fetchedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (source.present) {
      map['source'] = Variable<String>(
        $FxRatesTableTable.$convertersource.toSql(source.value),
      );
    }
    if (rateAmount.present) {
      map['rate_amount'] = Variable<int>(
        $FxRatesTableTable.$converterrateAmount.toSql(rateAmount.value),
      );
    }
    if (fetchedAt.present) {
      map['fetched_at'] = Variable<DateTime>(fetchedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FxRatesTableCompanion(')
          ..write('source: $source, ')
          ..write('rateAmount: $rateAmount, ')
          ..write('fetchedAt: $fetchedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CashFlowsTableTable extends CashFlowsTable
    with TableInfo<$CashFlowsTableTable, CashFlowsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CashFlowsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<Money, int> amount =
      GeneratedColumn<int>(
        'amount',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<Money>($CashFlowsTableTable.$converteramount);
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 500),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [id, date, amount, note];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cash_flows';
  @override
  VerificationContext validateIntegrity(
    Insertable<CashFlowsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CashFlowsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CashFlowsTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      amount: $CashFlowsTableTable.$converteramount.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}amount'],
        )!,
      ),
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
    );
  }

  @override
  $CashFlowsTableTable createAlias(String alias) {
    return $CashFlowsTableTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<Money, int, int> $converteramount =
      const MoneyConverter();
}

class CashFlowsTableData extends DataClass
    implements Insertable<CashFlowsTableData> {
  final int id;

  /// Ngày đã cắt về đầu ngày UTC, để so sánh không bị lệch bởi giờ phút.
  final DateTime date;

  /// Số tiền: dương là nạp vào, âm là rút ra.
  final Money amount;
  final String? note;
  const CashFlowsTableData({
    required this.id,
    required this.date,
    required this.amount,
    this.note,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['date'] = Variable<DateTime>(date);
    {
      map['amount'] = Variable<int>(
        $CashFlowsTableTable.$converteramount.toSql(amount),
      );
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    return map;
  }

  CashFlowsTableCompanion toCompanion(bool nullToAbsent) {
    return CashFlowsTableCompanion(
      id: Value(id),
      date: Value(date),
      amount: Value(amount),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
    );
  }

  factory CashFlowsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CashFlowsTableData(
      id: serializer.fromJson<int>(json['id']),
      date: serializer.fromJson<DateTime>(json['date']),
      amount: $CashFlowsTableTable.$converteramount.fromJson(
        serializer.fromJson<int>(json['amount']),
      ),
      note: serializer.fromJson<String?>(json['note']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'date': serializer.toJson<DateTime>(date),
      'amount': serializer.toJson<int>(
        $CashFlowsTableTable.$converteramount.toJson(amount),
      ),
      'note': serializer.toJson<String?>(note),
    };
  }

  CashFlowsTableData copyWith({
    int? id,
    DateTime? date,
    Money? amount,
    Value<String?> note = const Value.absent(),
  }) => CashFlowsTableData(
    id: id ?? this.id,
    date: date ?? this.date,
    amount: amount ?? this.amount,
    note: note.present ? note.value : this.note,
  );
  CashFlowsTableData copyWithCompanion(CashFlowsTableCompanion data) {
    return CashFlowsTableData(
      id: data.id.present ? data.id.value : this.id,
      date: data.date.present ? data.date.value : this.date,
      amount: data.amount.present ? data.amount.value : this.amount,
      note: data.note.present ? data.note.value : this.note,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CashFlowsTableData(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('amount: $amount, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, date, amount, note);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CashFlowsTableData &&
          other.id == this.id &&
          other.date == this.date &&
          other.amount == this.amount &&
          other.note == this.note);
}

class CashFlowsTableCompanion extends UpdateCompanion<CashFlowsTableData> {
  final Value<int> id;
  final Value<DateTime> date;
  final Value<Money> amount;
  final Value<String?> note;
  const CashFlowsTableCompanion({
    this.id = const Value.absent(),
    this.date = const Value.absent(),
    this.amount = const Value.absent(),
    this.note = const Value.absent(),
  });
  CashFlowsTableCompanion.insert({
    this.id = const Value.absent(),
    required DateTime date,
    required Money amount,
    this.note = const Value.absent(),
  }) : date = Value(date),
       amount = Value(amount);
  static Insertable<CashFlowsTableData> custom({
    Expression<int>? id,
    Expression<DateTime>? date,
    Expression<int>? amount,
    Expression<String>? note,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (date != null) 'date': date,
      if (amount != null) 'amount': amount,
      if (note != null) 'note': note,
    });
  }

  CashFlowsTableCompanion copyWith({
    Value<int>? id,
    Value<DateTime>? date,
    Value<Money>? amount,
    Value<String?>? note,
  }) {
    return CashFlowsTableCompanion(
      id: id ?? this.id,
      date: date ?? this.date,
      amount: amount ?? this.amount,
      note: note ?? this.note,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (amount.present) {
      map['amount'] = Variable<int>(
        $CashFlowsTableTable.$converteramount.toSql(amount.value),
      );
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CashFlowsTableCompanion(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('amount: $amount, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }
}

class $DebtsTableTable extends DebtsTable
    with TableInfo<$DebtsTableTable, DebtsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DebtsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _personNameMeta = const VerificationMeta(
    'personName',
  );
  @override
  late final GeneratedColumn<String> personName = GeneratedColumn<String>(
    'person_name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 100,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<Money, int> amount =
      GeneratedColumn<int>(
        'amount',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<Money>($DebtsTableTable.$converteramount);
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 500),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _settledAtMeta = const VerificationMeta(
    'settledAt',
  );
  @override
  late final GeneratedColumn<DateTime> settledAt = GeneratedColumn<DateTime>(
    'settled_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    personName,
    amount,
    date,
    note,
    settledAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'debts';
  @override
  VerificationContext validateIntegrity(
    Insertable<DebtsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('person_name')) {
      context.handle(
        _personNameMeta,
        personName.isAcceptableOrUnknown(data['person_name']!, _personNameMeta),
      );
    } else if (isInserting) {
      context.missing(_personNameMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('settled_at')) {
      context.handle(
        _settledAtMeta,
        settledAt.isAcceptableOrUnknown(data['settled_at']!, _settledAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DebtsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DebtsTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      personName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}person_name'],
      )!,
      amount: $DebtsTableTable.$converteramount.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}amount'],
        )!,
      ),
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      settledAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}settled_at'],
      ),
    );
  }

  @override
  $DebtsTableTable createAlias(String alias) {
    return $DebtsTableTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<Money, int, int> $converteramount =
      const MoneyConverter();
}

class DebtsTableData extends DataClass implements Insertable<DebtsTableData> {
  final int id;
  final String personName;

  /// Số tiền: dương là mình cho vay, âm là mình đi vay.
  final Money amount;
  final DateTime date;
  final String? note;

  /// Ngày tất toán. `null` nghĩa là đang hiệu lực.
  ///
  /// Tất toán không xoá dòng: người dùng vẫn tra cứu lại được, nhưng khoản đó
  /// rời khỏi Tổng tài sản. Xem FR-33.
  final DateTime? settledAt;
  const DebtsTableData({
    required this.id,
    required this.personName,
    required this.amount,
    required this.date,
    this.note,
    this.settledAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['person_name'] = Variable<String>(personName);
    {
      map['amount'] = Variable<int>(
        $DebtsTableTable.$converteramount.toSql(amount),
      );
    }
    map['date'] = Variable<DateTime>(date);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    if (!nullToAbsent || settledAt != null) {
      map['settled_at'] = Variable<DateTime>(settledAt);
    }
    return map;
  }

  DebtsTableCompanion toCompanion(bool nullToAbsent) {
    return DebtsTableCompanion(
      id: Value(id),
      personName: Value(personName),
      amount: Value(amount),
      date: Value(date),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      settledAt: settledAt == null && nullToAbsent
          ? const Value.absent()
          : Value(settledAt),
    );
  }

  factory DebtsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DebtsTableData(
      id: serializer.fromJson<int>(json['id']),
      personName: serializer.fromJson<String>(json['personName']),
      amount: $DebtsTableTable.$converteramount.fromJson(
        serializer.fromJson<int>(json['amount']),
      ),
      date: serializer.fromJson<DateTime>(json['date']),
      note: serializer.fromJson<String?>(json['note']),
      settledAt: serializer.fromJson<DateTime?>(json['settledAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'personName': serializer.toJson<String>(personName),
      'amount': serializer.toJson<int>(
        $DebtsTableTable.$converteramount.toJson(amount),
      ),
      'date': serializer.toJson<DateTime>(date),
      'note': serializer.toJson<String?>(note),
      'settledAt': serializer.toJson<DateTime?>(settledAt),
    };
  }

  DebtsTableData copyWith({
    int? id,
    String? personName,
    Money? amount,
    DateTime? date,
    Value<String?> note = const Value.absent(),
    Value<DateTime?> settledAt = const Value.absent(),
  }) => DebtsTableData(
    id: id ?? this.id,
    personName: personName ?? this.personName,
    amount: amount ?? this.amount,
    date: date ?? this.date,
    note: note.present ? note.value : this.note,
    settledAt: settledAt.present ? settledAt.value : this.settledAt,
  );
  DebtsTableData copyWithCompanion(DebtsTableCompanion data) {
    return DebtsTableData(
      id: data.id.present ? data.id.value : this.id,
      personName: data.personName.present
          ? data.personName.value
          : this.personName,
      amount: data.amount.present ? data.amount.value : this.amount,
      date: data.date.present ? data.date.value : this.date,
      note: data.note.present ? data.note.value : this.note,
      settledAt: data.settledAt.present ? data.settledAt.value : this.settledAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DebtsTableData(')
          ..write('id: $id, ')
          ..write('personName: $personName, ')
          ..write('amount: $amount, ')
          ..write('date: $date, ')
          ..write('note: $note, ')
          ..write('settledAt: $settledAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, personName, amount, date, note, settledAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DebtsTableData &&
          other.id == this.id &&
          other.personName == this.personName &&
          other.amount == this.amount &&
          other.date == this.date &&
          other.note == this.note &&
          other.settledAt == this.settledAt);
}

class DebtsTableCompanion extends UpdateCompanion<DebtsTableData> {
  final Value<int> id;
  final Value<String> personName;
  final Value<Money> amount;
  final Value<DateTime> date;
  final Value<String?> note;
  final Value<DateTime?> settledAt;
  const DebtsTableCompanion({
    this.id = const Value.absent(),
    this.personName = const Value.absent(),
    this.amount = const Value.absent(),
    this.date = const Value.absent(),
    this.note = const Value.absent(),
    this.settledAt = const Value.absent(),
  });
  DebtsTableCompanion.insert({
    this.id = const Value.absent(),
    required String personName,
    required Money amount,
    required DateTime date,
    this.note = const Value.absent(),
    this.settledAt = const Value.absent(),
  }) : personName = Value(personName),
       amount = Value(amount),
       date = Value(date);
  static Insertable<DebtsTableData> custom({
    Expression<int>? id,
    Expression<String>? personName,
    Expression<int>? amount,
    Expression<DateTime>? date,
    Expression<String>? note,
    Expression<DateTime>? settledAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (personName != null) 'person_name': personName,
      if (amount != null) 'amount': amount,
      if (date != null) 'date': date,
      if (note != null) 'note': note,
      if (settledAt != null) 'settled_at': settledAt,
    });
  }

  DebtsTableCompanion copyWith({
    Value<int>? id,
    Value<String>? personName,
    Value<Money>? amount,
    Value<DateTime>? date,
    Value<String?>? note,
    Value<DateTime?>? settledAt,
  }) {
    return DebtsTableCompanion(
      id: id ?? this.id,
      personName: personName ?? this.personName,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      note: note ?? this.note,
      settledAt: settledAt ?? this.settledAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (personName.present) {
      map['person_name'] = Variable<String>(personName.value);
    }
    if (amount.present) {
      map['amount'] = Variable<int>(
        $DebtsTableTable.$converteramount.toSql(amount.value),
      );
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (settledAt.present) {
      map['settled_at'] = Variable<DateTime>(settledAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DebtsTableCompanion(')
          ..write('id: $id, ')
          ..write('personName: $personName, ')
          ..write('amount: $amount, ')
          ..write('date: $date, ')
          ..write('note: $note, ')
          ..write('settledAt: $settledAt')
          ..write(')'))
        .toString();
  }
}

class $SnapshotsTableTable extends SnapshotsTable
    with TableInfo<$SnapshotsTableTable, SnapshotsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SnapshotsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<Money, int> totalAssetsAmount =
      GeneratedColumn<int>(
        'total_assets_amount',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<Money>($SnapshotsTableTable.$convertertotalAssetsAmount);
  @override
  late final GeneratedColumnWithTypeConverter<Money, int>
  investmentGroupAmount = GeneratedColumn<int>(
    'investment_group_amount',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  ).withConverter<Money>($SnapshotsTableTable.$converterinvestmentGroupAmount);
  @override
  late final GeneratedColumnWithTypeConverter<SnapshotKind, String> kind =
      GeneratedColumn<String>(
        'kind',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<SnapshotKind>($SnapshotsTableTable.$converterkind);
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 500),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    date,
    totalAssetsAmount,
    investmentGroupAmount,
    kind,
    note,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'snapshots';
  @override
  VerificationContext validateIntegrity(
    Insertable<SnapshotsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {date, kind},
  ];
  @override
  SnapshotsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SnapshotsTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      totalAssetsAmount: $SnapshotsTableTable.$convertertotalAssetsAmount
          .fromSql(
            attachedDatabase.typeMapping.read(
              DriftSqlType.int,
              data['${effectivePrefix}total_assets_amount'],
            )!,
          ),
      investmentGroupAmount: $SnapshotsTableTable
          .$converterinvestmentGroupAmount
          .fromSql(
            attachedDatabase.typeMapping.read(
              DriftSqlType.int,
              data['${effectivePrefix}investment_group_amount'],
            )!,
          ),
      kind: $SnapshotsTableTable.$converterkind.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}kind'],
        )!,
      ),
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
    );
  }

  @override
  $SnapshotsTableTable createAlias(String alias) {
    return $SnapshotsTableTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<Money, int, int> $convertertotalAssetsAmount =
      const MoneyConverter();
  static JsonTypeConverter2<Money, int, int> $converterinvestmentGroupAmount =
      const MoneyConverter();
  static JsonTypeConverter2<SnapshotKind, String, String> $converterkind =
      const EnumNameConverter<SnapshotKind>(SnapshotKind.values);
}

class SnapshotsTableData extends DataClass
    implements Insertable<SnapshotsTableData> {
  final int id;

  /// Ngày đã cắt về đầu ngày UTC. Mỗi ngày nhiều nhất một bản chốt tự động.
  final DateTime date;
  final Money totalAssetsAmount;

  /// Giá trị Nhóm đầu tư tại thời điểm chốt, để tính Lãi lỗ về sau mà không
  /// phải dựng lại từ chi tiết.
  final Money investmentGroupAmount;
  final SnapshotKind kind;
  final String? note;
  const SnapshotsTableData({
    required this.id,
    required this.date,
    required this.totalAssetsAmount,
    required this.investmentGroupAmount,
    required this.kind,
    this.note,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['date'] = Variable<DateTime>(date);
    {
      map['total_assets_amount'] = Variable<int>(
        $SnapshotsTableTable.$convertertotalAssetsAmount.toSql(
          totalAssetsAmount,
        ),
      );
    }
    {
      map['investment_group_amount'] = Variable<int>(
        $SnapshotsTableTable.$converterinvestmentGroupAmount.toSql(
          investmentGroupAmount,
        ),
      );
    }
    {
      map['kind'] = Variable<String>(
        $SnapshotsTableTable.$converterkind.toSql(kind),
      );
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    return map;
  }

  SnapshotsTableCompanion toCompanion(bool nullToAbsent) {
    return SnapshotsTableCompanion(
      id: Value(id),
      date: Value(date),
      totalAssetsAmount: Value(totalAssetsAmount),
      investmentGroupAmount: Value(investmentGroupAmount),
      kind: Value(kind),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
    );
  }

  factory SnapshotsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SnapshotsTableData(
      id: serializer.fromJson<int>(json['id']),
      date: serializer.fromJson<DateTime>(json['date']),
      totalAssetsAmount: $SnapshotsTableTable.$convertertotalAssetsAmount
          .fromJson(serializer.fromJson<int>(json['totalAssetsAmount'])),
      investmentGroupAmount: $SnapshotsTableTable
          .$converterinvestmentGroupAmount
          .fromJson(serializer.fromJson<int>(json['investmentGroupAmount'])),
      kind: $SnapshotsTableTable.$converterkind.fromJson(
        serializer.fromJson<String>(json['kind']),
      ),
      note: serializer.fromJson<String?>(json['note']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'date': serializer.toJson<DateTime>(date),
      'totalAssetsAmount': serializer.toJson<int>(
        $SnapshotsTableTable.$convertertotalAssetsAmount.toJson(
          totalAssetsAmount,
        ),
      ),
      'investmentGroupAmount': serializer.toJson<int>(
        $SnapshotsTableTable.$converterinvestmentGroupAmount.toJson(
          investmentGroupAmount,
        ),
      ),
      'kind': serializer.toJson<String>(
        $SnapshotsTableTable.$converterkind.toJson(kind),
      ),
      'note': serializer.toJson<String?>(note),
    };
  }

  SnapshotsTableData copyWith({
    int? id,
    DateTime? date,
    Money? totalAssetsAmount,
    Money? investmentGroupAmount,
    SnapshotKind? kind,
    Value<String?> note = const Value.absent(),
  }) => SnapshotsTableData(
    id: id ?? this.id,
    date: date ?? this.date,
    totalAssetsAmount: totalAssetsAmount ?? this.totalAssetsAmount,
    investmentGroupAmount: investmentGroupAmount ?? this.investmentGroupAmount,
    kind: kind ?? this.kind,
    note: note.present ? note.value : this.note,
  );
  SnapshotsTableData copyWithCompanion(SnapshotsTableCompanion data) {
    return SnapshotsTableData(
      id: data.id.present ? data.id.value : this.id,
      date: data.date.present ? data.date.value : this.date,
      totalAssetsAmount: data.totalAssetsAmount.present
          ? data.totalAssetsAmount.value
          : this.totalAssetsAmount,
      investmentGroupAmount: data.investmentGroupAmount.present
          ? data.investmentGroupAmount.value
          : this.investmentGroupAmount,
      kind: data.kind.present ? data.kind.value : this.kind,
      note: data.note.present ? data.note.value : this.note,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SnapshotsTableData(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('totalAssetsAmount: $totalAssetsAmount, ')
          ..write('investmentGroupAmount: $investmentGroupAmount, ')
          ..write('kind: $kind, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    date,
    totalAssetsAmount,
    investmentGroupAmount,
    kind,
    note,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SnapshotsTableData &&
          other.id == this.id &&
          other.date == this.date &&
          other.totalAssetsAmount == this.totalAssetsAmount &&
          other.investmentGroupAmount == this.investmentGroupAmount &&
          other.kind == this.kind &&
          other.note == this.note);
}

class SnapshotsTableCompanion extends UpdateCompanion<SnapshotsTableData> {
  final Value<int> id;
  final Value<DateTime> date;
  final Value<Money> totalAssetsAmount;
  final Value<Money> investmentGroupAmount;
  final Value<SnapshotKind> kind;
  final Value<String?> note;
  const SnapshotsTableCompanion({
    this.id = const Value.absent(),
    this.date = const Value.absent(),
    this.totalAssetsAmount = const Value.absent(),
    this.investmentGroupAmount = const Value.absent(),
    this.kind = const Value.absent(),
    this.note = const Value.absent(),
  });
  SnapshotsTableCompanion.insert({
    this.id = const Value.absent(),
    required DateTime date,
    required Money totalAssetsAmount,
    required Money investmentGroupAmount,
    required SnapshotKind kind,
    this.note = const Value.absent(),
  }) : date = Value(date),
       totalAssetsAmount = Value(totalAssetsAmount),
       investmentGroupAmount = Value(investmentGroupAmount),
       kind = Value(kind);
  static Insertable<SnapshotsTableData> custom({
    Expression<int>? id,
    Expression<DateTime>? date,
    Expression<int>? totalAssetsAmount,
    Expression<int>? investmentGroupAmount,
    Expression<String>? kind,
    Expression<String>? note,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (date != null) 'date': date,
      if (totalAssetsAmount != null) 'total_assets_amount': totalAssetsAmount,
      if (investmentGroupAmount != null)
        'investment_group_amount': investmentGroupAmount,
      if (kind != null) 'kind': kind,
      if (note != null) 'note': note,
    });
  }

  SnapshotsTableCompanion copyWith({
    Value<int>? id,
    Value<DateTime>? date,
    Value<Money>? totalAssetsAmount,
    Value<Money>? investmentGroupAmount,
    Value<SnapshotKind>? kind,
    Value<String?>? note,
  }) {
    return SnapshotsTableCompanion(
      id: id ?? this.id,
      date: date ?? this.date,
      totalAssetsAmount: totalAssetsAmount ?? this.totalAssetsAmount,
      investmentGroupAmount:
          investmentGroupAmount ?? this.investmentGroupAmount,
      kind: kind ?? this.kind,
      note: note ?? this.note,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (totalAssetsAmount.present) {
      map['total_assets_amount'] = Variable<int>(
        $SnapshotsTableTable.$convertertotalAssetsAmount.toSql(
          totalAssetsAmount.value,
        ),
      );
    }
    if (investmentGroupAmount.present) {
      map['investment_group_amount'] = Variable<int>(
        $SnapshotsTableTable.$converterinvestmentGroupAmount.toSql(
          investmentGroupAmount.value,
        ),
      );
    }
    if (kind.present) {
      map['kind'] = Variable<String>(
        $SnapshotsTableTable.$converterkind.toSql(kind.value),
      );
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SnapshotsTableCompanion(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('totalAssetsAmount: $totalAssetsAmount, ')
          ..write('investmentGroupAmount: $investmentGroupAmount, ')
          ..write('kind: $kind, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }
}

class $SnapshotDetailsTableTable extends SnapshotDetailsTable
    with TableInfo<$SnapshotDetailsTableTable, SnapshotDetailsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SnapshotDetailsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _snapshotIdMeta = const VerificationMeta(
    'snapshotId',
  );
  @override
  late final GeneratedColumn<int> snapshotId = GeneratedColumn<int>(
    'snapshot_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES snapshots (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _assetClassIdMeta = const VerificationMeta(
    'assetClassId',
  );
  @override
  late final GeneratedColumn<int> assetClassId = GeneratedColumn<int>(
    'asset_class_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES asset_classes (id) ON DELETE SET NULL',
    ),
  );
  static const VerificationMeta _assetClassNameMeta = const VerificationMeta(
    'assetClassName',
  );
  @override
  late final GeneratedColumn<String> assetClassName = GeneratedColumn<String>(
    'asset_class_name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 60,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<Money, int> valueAmount =
      GeneratedColumn<int>(
        'value_amount',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<Money>($SnapshotDetailsTableTable.$convertervalueAmount);
  @override
  List<GeneratedColumn> get $columns => [
    id,
    snapshotId,
    assetClassId,
    assetClassName,
    valueAmount,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'snapshot_details';
  @override
  VerificationContext validateIntegrity(
    Insertable<SnapshotDetailsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('snapshot_id')) {
      context.handle(
        _snapshotIdMeta,
        snapshotId.isAcceptableOrUnknown(data['snapshot_id']!, _snapshotIdMeta),
      );
    } else if (isInserting) {
      context.missing(_snapshotIdMeta);
    }
    if (data.containsKey('asset_class_id')) {
      context.handle(
        _assetClassIdMeta,
        assetClassId.isAcceptableOrUnknown(
          data['asset_class_id']!,
          _assetClassIdMeta,
        ),
      );
    }
    if (data.containsKey('asset_class_name')) {
      context.handle(
        _assetClassNameMeta,
        assetClassName.isAcceptableOrUnknown(
          data['asset_class_name']!,
          _assetClassNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_assetClassNameMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SnapshotDetailsTableData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SnapshotDetailsTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      snapshotId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}snapshot_id'],
      )!,
      assetClassId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}asset_class_id'],
      ),
      assetClassName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}asset_class_name'],
      )!,
      valueAmount: $SnapshotDetailsTableTable.$convertervalueAmount.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}value_amount'],
        )!,
      ),
    );
  }

  @override
  $SnapshotDetailsTableTable createAlias(String alias) {
    return $SnapshotDetailsTableTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<Money, int, int> $convertervalueAmount =
      const MoneyConverter();
}

class SnapshotDetailsTableData extends DataClass
    implements Insertable<SnapshotDetailsTableData> {
  final int id;
  final int snapshotId;
  final int? assetClassId;

  /// Tên Lớp tài sản tại thời điểm chốt.
  final String assetClassName;
  final Money valueAmount;
  const SnapshotDetailsTableData({
    required this.id,
    required this.snapshotId,
    this.assetClassId,
    required this.assetClassName,
    required this.valueAmount,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['snapshot_id'] = Variable<int>(snapshotId);
    if (!nullToAbsent || assetClassId != null) {
      map['asset_class_id'] = Variable<int>(assetClassId);
    }
    map['asset_class_name'] = Variable<String>(assetClassName);
    {
      map['value_amount'] = Variable<int>(
        $SnapshotDetailsTableTable.$convertervalueAmount.toSql(valueAmount),
      );
    }
    return map;
  }

  SnapshotDetailsTableCompanion toCompanion(bool nullToAbsent) {
    return SnapshotDetailsTableCompanion(
      id: Value(id),
      snapshotId: Value(snapshotId),
      assetClassId: assetClassId == null && nullToAbsent
          ? const Value.absent()
          : Value(assetClassId),
      assetClassName: Value(assetClassName),
      valueAmount: Value(valueAmount),
    );
  }

  factory SnapshotDetailsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SnapshotDetailsTableData(
      id: serializer.fromJson<int>(json['id']),
      snapshotId: serializer.fromJson<int>(json['snapshotId']),
      assetClassId: serializer.fromJson<int?>(json['assetClassId']),
      assetClassName: serializer.fromJson<String>(json['assetClassName']),
      valueAmount: $SnapshotDetailsTableTable.$convertervalueAmount.fromJson(
        serializer.fromJson<int>(json['valueAmount']),
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'snapshotId': serializer.toJson<int>(snapshotId),
      'assetClassId': serializer.toJson<int?>(assetClassId),
      'assetClassName': serializer.toJson<String>(assetClassName),
      'valueAmount': serializer.toJson<int>(
        $SnapshotDetailsTableTable.$convertervalueAmount.toJson(valueAmount),
      ),
    };
  }

  SnapshotDetailsTableData copyWith({
    int? id,
    int? snapshotId,
    Value<int?> assetClassId = const Value.absent(),
    String? assetClassName,
    Money? valueAmount,
  }) => SnapshotDetailsTableData(
    id: id ?? this.id,
    snapshotId: snapshotId ?? this.snapshotId,
    assetClassId: assetClassId.present ? assetClassId.value : this.assetClassId,
    assetClassName: assetClassName ?? this.assetClassName,
    valueAmount: valueAmount ?? this.valueAmount,
  );
  SnapshotDetailsTableData copyWithCompanion(
    SnapshotDetailsTableCompanion data,
  ) {
    return SnapshotDetailsTableData(
      id: data.id.present ? data.id.value : this.id,
      snapshotId: data.snapshotId.present
          ? data.snapshotId.value
          : this.snapshotId,
      assetClassId: data.assetClassId.present
          ? data.assetClassId.value
          : this.assetClassId,
      assetClassName: data.assetClassName.present
          ? data.assetClassName.value
          : this.assetClassName,
      valueAmount: data.valueAmount.present
          ? data.valueAmount.value
          : this.valueAmount,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SnapshotDetailsTableData(')
          ..write('id: $id, ')
          ..write('snapshotId: $snapshotId, ')
          ..write('assetClassId: $assetClassId, ')
          ..write('assetClassName: $assetClassName, ')
          ..write('valueAmount: $valueAmount')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, snapshotId, assetClassId, assetClassName, valueAmount);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SnapshotDetailsTableData &&
          other.id == this.id &&
          other.snapshotId == this.snapshotId &&
          other.assetClassId == this.assetClassId &&
          other.assetClassName == this.assetClassName &&
          other.valueAmount == this.valueAmount);
}

class SnapshotDetailsTableCompanion
    extends UpdateCompanion<SnapshotDetailsTableData> {
  final Value<int> id;
  final Value<int> snapshotId;
  final Value<int?> assetClassId;
  final Value<String> assetClassName;
  final Value<Money> valueAmount;
  const SnapshotDetailsTableCompanion({
    this.id = const Value.absent(),
    this.snapshotId = const Value.absent(),
    this.assetClassId = const Value.absent(),
    this.assetClassName = const Value.absent(),
    this.valueAmount = const Value.absent(),
  });
  SnapshotDetailsTableCompanion.insert({
    this.id = const Value.absent(),
    required int snapshotId,
    this.assetClassId = const Value.absent(),
    required String assetClassName,
    required Money valueAmount,
  }) : snapshotId = Value(snapshotId),
       assetClassName = Value(assetClassName),
       valueAmount = Value(valueAmount);
  static Insertable<SnapshotDetailsTableData> custom({
    Expression<int>? id,
    Expression<int>? snapshotId,
    Expression<int>? assetClassId,
    Expression<String>? assetClassName,
    Expression<int>? valueAmount,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (snapshotId != null) 'snapshot_id': snapshotId,
      if (assetClassId != null) 'asset_class_id': assetClassId,
      if (assetClassName != null) 'asset_class_name': assetClassName,
      if (valueAmount != null) 'value_amount': valueAmount,
    });
  }

  SnapshotDetailsTableCompanion copyWith({
    Value<int>? id,
    Value<int>? snapshotId,
    Value<int?>? assetClassId,
    Value<String>? assetClassName,
    Value<Money>? valueAmount,
  }) {
    return SnapshotDetailsTableCompanion(
      id: id ?? this.id,
      snapshotId: snapshotId ?? this.snapshotId,
      assetClassId: assetClassId ?? this.assetClassId,
      assetClassName: assetClassName ?? this.assetClassName,
      valueAmount: valueAmount ?? this.valueAmount,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (snapshotId.present) {
      map['snapshot_id'] = Variable<int>(snapshotId.value);
    }
    if (assetClassId.present) {
      map['asset_class_id'] = Variable<int>(assetClassId.value);
    }
    if (assetClassName.present) {
      map['asset_class_name'] = Variable<String>(assetClassName.value);
    }
    if (valueAmount.present) {
      map['value_amount'] = Variable<int>(
        $SnapshotDetailsTableTable.$convertervalueAmount.toSql(
          valueAmount.value,
        ),
      );
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SnapshotDetailsTableCompanion(')
          ..write('id: $id, ')
          ..write('snapshotId: $snapshotId, ')
          ..write('assetClassId: $assetClassId, ')
          ..write('assetClassName: $assetClassName, ')
          ..write('valueAmount: $valueAmount')
          ..write(')'))
        .toString();
  }
}

class $ActionNotesTableTable extends ActionNotesTable
    with TableInfo<$ActionNotesTableTable, ActionNotesTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ActionNotesTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _bodyMeta = const VerificationMeta('body');
  @override
  late final GeneratedColumn<String> body = GeneratedColumn<String>(
    'body',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 1000,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
    'completed_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [id, body, createdAt, completedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'action_notes';
  @override
  VerificationContext validateIntegrity(
    Insertable<ActionNotesTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('body')) {
      context.handle(
        _bodyMeta,
        body.isAcceptableOrUnknown(data['body']!, _bodyMeta),
      );
    } else if (isInserting) {
      context.missing(_bodyMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ActionNotesTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ActionNotesTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      body: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}body'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}completed_at'],
      ),
    );
  }

  @override
  $ActionNotesTableTable createAlias(String alias) {
    return $ActionNotesTableTable(attachedDatabase, alias);
  }
}

class ActionNotesTableData extends DataClass
    implements Insertable<ActionNotesTableData> {
  final int id;
  final String body;
  final DateTime createdAt;

  /// `null` nghĩa là chưa hoàn thành.
  final DateTime? completedAt;
  const ActionNotesTableData({
    required this.id,
    required this.body,
    required this.createdAt,
    this.completedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['body'] = Variable<String>(body);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<DateTime>(completedAt);
    }
    return map;
  }

  ActionNotesTableCompanion toCompanion(bool nullToAbsent) {
    return ActionNotesTableCompanion(
      id: Value(id),
      body: Value(body),
      createdAt: Value(createdAt),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
    );
  }

  factory ActionNotesTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ActionNotesTableData(
      id: serializer.fromJson<int>(json['id']),
      body: serializer.fromJson<String>(json['body']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      completedAt: serializer.fromJson<DateTime?>(json['completedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'body': serializer.toJson<String>(body),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'completedAt': serializer.toJson<DateTime?>(completedAt),
    };
  }

  ActionNotesTableData copyWith({
    int? id,
    String? body,
    DateTime? createdAt,
    Value<DateTime?> completedAt = const Value.absent(),
  }) => ActionNotesTableData(
    id: id ?? this.id,
    body: body ?? this.body,
    createdAt: createdAt ?? this.createdAt,
    completedAt: completedAt.present ? completedAt.value : this.completedAt,
  );
  ActionNotesTableData copyWithCompanion(ActionNotesTableCompanion data) {
    return ActionNotesTableData(
      id: data.id.present ? data.id.value : this.id,
      body: data.body.present ? data.body.value : this.body,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ActionNotesTableData(')
          ..write('id: $id, ')
          ..write('body: $body, ')
          ..write('createdAt: $createdAt, ')
          ..write('completedAt: $completedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, body, createdAt, completedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ActionNotesTableData &&
          other.id == this.id &&
          other.body == this.body &&
          other.createdAt == this.createdAt &&
          other.completedAt == this.completedAt);
}

class ActionNotesTableCompanion extends UpdateCompanion<ActionNotesTableData> {
  final Value<int> id;
  final Value<String> body;
  final Value<DateTime> createdAt;
  final Value<DateTime?> completedAt;
  const ActionNotesTableCompanion({
    this.id = const Value.absent(),
    this.body = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.completedAt = const Value.absent(),
  });
  ActionNotesTableCompanion.insert({
    this.id = const Value.absent(),
    required String body,
    required DateTime createdAt,
    this.completedAt = const Value.absent(),
  }) : body = Value(body),
       createdAt = Value(createdAt);
  static Insertable<ActionNotesTableData> custom({
    Expression<int>? id,
    Expression<String>? body,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? completedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (body != null) 'body': body,
      if (createdAt != null) 'created_at': createdAt,
      if (completedAt != null) 'completed_at': completedAt,
    });
  }

  ActionNotesTableCompanion copyWith({
    Value<int>? id,
    Value<String>? body,
    Value<DateTime>? createdAt,
    Value<DateTime?>? completedAt,
  }) {
    return ActionNotesTableCompanion(
      id: id ?? this.id,
      body: body ?? this.body,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (body.present) {
      map['body'] = Variable<String>(body.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ActionNotesTableCompanion(')
          ..write('id: $id, ')
          ..write('body: $body, ')
          ..write('createdAt: $createdAt, ')
          ..write('completedAt: $completedAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $SettingsTableTable settingsTable = $SettingsTableTable(this);
  late final $TargetGroupsTableTable targetGroupsTable =
      $TargetGroupsTableTable(this);
  late final $AssetClassesTableTable assetClassesTable =
      $AssetClassesTableTable(this);
  late final $HoldingsTableTable holdingsTable = $HoldingsTableTable(this);
  late final $PriceQuotesTableTable priceQuotesTable = $PriceQuotesTableTable(
    this,
  );
  late final $FxRatesTableTable fxRatesTable = $FxRatesTableTable(this);
  late final $CashFlowsTableTable cashFlowsTable = $CashFlowsTableTable(this);
  late final $DebtsTableTable debtsTable = $DebtsTableTable(this);
  late final $SnapshotsTableTable snapshotsTable = $SnapshotsTableTable(this);
  late final $SnapshotDetailsTableTable snapshotDetailsTable =
      $SnapshotDetailsTableTable(this);
  late final $ActionNotesTableTable actionNotesTable = $ActionNotesTableTable(
    this,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    settingsTable,
    targetGroupsTable,
    assetClassesTable,
    holdingsTable,
    priceQuotesTable,
    fxRatesTable,
    cashFlowsTable,
    debtsTable,
    snapshotsTable,
    snapshotDetailsTable,
    actionNotesTable,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'target_groups',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('asset_classes', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'asset_classes',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('holdings', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'snapshots',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('snapshot_details', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'asset_classes',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('snapshot_details', kind: UpdateKind.update)],
    ),
  ]);
  @override
  DriftDatabaseOptions get options =>
      const DriftDatabaseOptions(storeDateTimeAsText: true);
}

typedef $$SettingsTableTableCreateCompanionBuilder =
    SettingsTableCompanion Function({
      Value<int> id,
      required Money initialContributionAmount,
      required DateTime startDate,
      Value<Money?> fxRateManualAmount,
      Value<int> driftThresholdBp,
      Value<DateTime?> lastExportedAt,
      Value<ThemeModeSetting> themeMode,
      Value<bool> onboardingCompleted,
    });
typedef $$SettingsTableTableUpdateCompanionBuilder =
    SettingsTableCompanion Function({
      Value<int> id,
      Value<Money> initialContributionAmount,
      Value<DateTime> startDate,
      Value<Money?> fxRateManualAmount,
      Value<int> driftThresholdBp,
      Value<DateTime?> lastExportedAt,
      Value<ThemeModeSetting> themeMode,
      Value<bool> onboardingCompleted,
    });

class $$SettingsTableTableFilterComposer
    extends Composer<_$AppDatabase, $SettingsTableTable> {
  $$SettingsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<Money, Money, int>
  get initialContributionAmount => $composableBuilder(
    column: $table.initialContributionAmount,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<DateTime> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<Money?, Money, int> get fxRateManualAmount =>
      $composableBuilder(
        column: $table.fxRateManualAmount,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<int> get driftThresholdBp => $composableBuilder(
    column: $table.driftThresholdBp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastExportedAt => $composableBuilder(
    column: $table.lastExportedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<ThemeModeSetting, ThemeModeSetting, String>
  get themeMode => $composableBuilder(
    column: $table.themeMode,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<bool> get onboardingCompleted => $composableBuilder(
    column: $table.onboardingCompleted,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SettingsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $SettingsTableTable> {
  $$SettingsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get initialContributionAmount => $composableBuilder(
    column: $table.initialContributionAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get fxRateManualAmount => $composableBuilder(
    column: $table.fxRateManualAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get driftThresholdBp => $composableBuilder(
    column: $table.driftThresholdBp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastExportedAt => $composableBuilder(
    column: $table.lastExportedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get themeMode => $composableBuilder(
    column: $table.themeMode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get onboardingCompleted => $composableBuilder(
    column: $table.onboardingCompleted,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SettingsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $SettingsTableTable> {
  $$SettingsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Money, int> get initialContributionAmount =>
      $composableBuilder(
        column: $table.initialContributionAmount,
        builder: (column) => column,
      );

  GeneratedColumn<DateTime> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Money?, int> get fxRateManualAmount =>
      $composableBuilder(
        column: $table.fxRateManualAmount,
        builder: (column) => column,
      );

  GeneratedColumn<int> get driftThresholdBp => $composableBuilder(
    column: $table.driftThresholdBp,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastExportedAt => $composableBuilder(
    column: $table.lastExportedAt,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<ThemeModeSetting, String> get themeMode =>
      $composableBuilder(column: $table.themeMode, builder: (column) => column);

  GeneratedColumn<bool> get onboardingCompleted => $composableBuilder(
    column: $table.onboardingCompleted,
    builder: (column) => column,
  );
}

class $$SettingsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SettingsTableTable,
          SettingsTableData,
          $$SettingsTableTableFilterComposer,
          $$SettingsTableTableOrderingComposer,
          $$SettingsTableTableAnnotationComposer,
          $$SettingsTableTableCreateCompanionBuilder,
          $$SettingsTableTableUpdateCompanionBuilder,
          (
            SettingsTableData,
            BaseReferences<
              _$AppDatabase,
              $SettingsTableTable,
              SettingsTableData
            >,
          ),
          SettingsTableData,
          PrefetchHooks Function()
        > {
  $$SettingsTableTableTableManager(_$AppDatabase db, $SettingsTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SettingsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SettingsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SettingsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<Money> initialContributionAmount = const Value.absent(),
                Value<DateTime> startDate = const Value.absent(),
                Value<Money?> fxRateManualAmount = const Value.absent(),
                Value<int> driftThresholdBp = const Value.absent(),
                Value<DateTime?> lastExportedAt = const Value.absent(),
                Value<ThemeModeSetting> themeMode = const Value.absent(),
                Value<bool> onboardingCompleted = const Value.absent(),
              }) => SettingsTableCompanion(
                id: id,
                initialContributionAmount: initialContributionAmount,
                startDate: startDate,
                fxRateManualAmount: fxRateManualAmount,
                driftThresholdBp: driftThresholdBp,
                lastExportedAt: lastExportedAt,
                themeMode: themeMode,
                onboardingCompleted: onboardingCompleted,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required Money initialContributionAmount,
                required DateTime startDate,
                Value<Money?> fxRateManualAmount = const Value.absent(),
                Value<int> driftThresholdBp = const Value.absent(),
                Value<DateTime?> lastExportedAt = const Value.absent(),
                Value<ThemeModeSetting> themeMode = const Value.absent(),
                Value<bool> onboardingCompleted = const Value.absent(),
              }) => SettingsTableCompanion.insert(
                id: id,
                initialContributionAmount: initialContributionAmount,
                startDate: startDate,
                fxRateManualAmount: fxRateManualAmount,
                driftThresholdBp: driftThresholdBp,
                lastExportedAt: lastExportedAt,
                themeMode: themeMode,
                onboardingCompleted: onboardingCompleted,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SettingsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SettingsTableTable,
      SettingsTableData,
      $$SettingsTableTableFilterComposer,
      $$SettingsTableTableOrderingComposer,
      $$SettingsTableTableAnnotationComposer,
      $$SettingsTableTableCreateCompanionBuilder,
      $$SettingsTableTableUpdateCompanionBuilder,
      (
        SettingsTableData,
        BaseReferences<_$AppDatabase, $SettingsTableTable, SettingsTableData>,
      ),
      SettingsTableData,
      PrefetchHooks Function()
    >;
typedef $$TargetGroupsTableTableCreateCompanionBuilder =
    TargetGroupsTableCompanion Function({
      Value<int> id,
      required String name,
      required int targetWeightBp,
      Value<int> sortOrder,
    });
typedef $$TargetGroupsTableTableUpdateCompanionBuilder =
    TargetGroupsTableCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<int> targetWeightBp,
      Value<int> sortOrder,
    });

final class $$TargetGroupsTableTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $TargetGroupsTableTable,
          TargetGroupsTableData
        > {
  $$TargetGroupsTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<
    $AssetClassesTableTable,
    List<AssetClassesTableData>
  >
  _assetClassesTableRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.assetClassesTable,
        aliasName: $_aliasNameGenerator(
          db.targetGroupsTable.id,
          db.assetClassesTable.targetGroupId,
        ),
      );

  $$AssetClassesTableTableProcessedTableManager get assetClassesTableRefs {
    final manager = $$AssetClassesTableTableTableManager(
      $_db,
      $_db.assetClassesTable,
    ).filter((f) => f.targetGroupId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _assetClassesTableRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$TargetGroupsTableTableFilterComposer
    extends Composer<_$AppDatabase, $TargetGroupsTableTable> {
  $$TargetGroupsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get targetWeightBp => $composableBuilder(
    column: $table.targetWeightBp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> assetClassesTableRefs(
    Expression<bool> Function($$AssetClassesTableTableFilterComposer f) f,
  ) {
    final $$AssetClassesTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.assetClassesTable,
      getReferencedColumn: (t) => t.targetGroupId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AssetClassesTableTableFilterComposer(
            $db: $db,
            $table: $db.assetClassesTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TargetGroupsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $TargetGroupsTableTable> {
  $$TargetGroupsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get targetWeightBp => $composableBuilder(
    column: $table.targetWeightBp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TargetGroupsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $TargetGroupsTableTable> {
  $$TargetGroupsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get targetWeightBp => $composableBuilder(
    column: $table.targetWeightBp,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  Expression<T> assetClassesTableRefs<T extends Object>(
    Expression<T> Function($$AssetClassesTableTableAnnotationComposer a) f,
  ) {
    final $$AssetClassesTableTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.assetClassesTable,
          getReferencedColumn: (t) => t.targetGroupId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$AssetClassesTableTableAnnotationComposer(
                $db: $db,
                $table: $db.assetClassesTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$TargetGroupsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TargetGroupsTableTable,
          TargetGroupsTableData,
          $$TargetGroupsTableTableFilterComposer,
          $$TargetGroupsTableTableOrderingComposer,
          $$TargetGroupsTableTableAnnotationComposer,
          $$TargetGroupsTableTableCreateCompanionBuilder,
          $$TargetGroupsTableTableUpdateCompanionBuilder,
          (TargetGroupsTableData, $$TargetGroupsTableTableReferences),
          TargetGroupsTableData,
          PrefetchHooks Function({bool assetClassesTableRefs})
        > {
  $$TargetGroupsTableTableTableManager(
    _$AppDatabase db,
    $TargetGroupsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TargetGroupsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TargetGroupsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TargetGroupsTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> targetWeightBp = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
              }) => TargetGroupsTableCompanion(
                id: id,
                name: name,
                targetWeightBp: targetWeightBp,
                sortOrder: sortOrder,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required int targetWeightBp,
                Value<int> sortOrder = const Value.absent(),
              }) => TargetGroupsTableCompanion.insert(
                id: id,
                name: name,
                targetWeightBp: targetWeightBp,
                sortOrder: sortOrder,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$TargetGroupsTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({assetClassesTableRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (assetClassesTableRefs) db.assetClassesTable,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (assetClassesTableRefs)
                    await $_getPrefetchedData<
                      TargetGroupsTableData,
                      $TargetGroupsTableTable,
                      AssetClassesTableData
                    >(
                      currentTable: table,
                      referencedTable: $$TargetGroupsTableTableReferences
                          ._assetClassesTableRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$TargetGroupsTableTableReferences(
                            db,
                            table,
                            p0,
                          ).assetClassesTableRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where(
                            (e) => e.targetGroupId == item.id,
                          ),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$TargetGroupsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TargetGroupsTableTable,
      TargetGroupsTableData,
      $$TargetGroupsTableTableFilterComposer,
      $$TargetGroupsTableTableOrderingComposer,
      $$TargetGroupsTableTableAnnotationComposer,
      $$TargetGroupsTableTableCreateCompanionBuilder,
      $$TargetGroupsTableTableUpdateCompanionBuilder,
      (TargetGroupsTableData, $$TargetGroupsTableTableReferences),
      TargetGroupsTableData,
      PrefetchHooks Function({bool assetClassesTableRefs})
    >;
typedef $$AssetClassesTableTableCreateCompanionBuilder =
    AssetClassesTableCompanion Function({
      Value<int> id,
      required String name,
      required AssetKind kind,
      Value<int?> targetWeightBp,
      Value<int?> targetGroupId,
      Value<bool> inInvestmentGroup,
      Value<bool> hidden,
      Value<int> sortOrder,
      required int colorValue,
      required int iconCodePoint,
    });
typedef $$AssetClassesTableTableUpdateCompanionBuilder =
    AssetClassesTableCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<AssetKind> kind,
      Value<int?> targetWeightBp,
      Value<int?> targetGroupId,
      Value<bool> inInvestmentGroup,
      Value<bool> hidden,
      Value<int> sortOrder,
      Value<int> colorValue,
      Value<int> iconCodePoint,
    });

final class $$AssetClassesTableTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $AssetClassesTableTable,
          AssetClassesTableData
        > {
  $$AssetClassesTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $TargetGroupsTableTable _targetGroupIdTable(_$AppDatabase db) =>
      db.targetGroupsTable.createAlias(
        $_aliasNameGenerator(
          db.assetClassesTable.targetGroupId,
          db.targetGroupsTable.id,
        ),
      );

  $$TargetGroupsTableTableProcessedTableManager? get targetGroupId {
    final $_column = $_itemColumn<int>('target_group_id');
    if ($_column == null) return null;
    final manager = $$TargetGroupsTableTableTableManager(
      $_db,
      $_db.targetGroupsTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_targetGroupIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$HoldingsTableTable, List<HoldingsTableData>>
  _holdingsTableRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.holdingsTable,
    aliasName: $_aliasNameGenerator(
      db.assetClassesTable.id,
      db.holdingsTable.assetClassId,
    ),
  );

  $$HoldingsTableTableProcessedTableManager get holdingsTableRefs {
    final manager = $$HoldingsTableTableTableManager(
      $_db,
      $_db.holdingsTable,
    ).filter((f) => f.assetClassId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_holdingsTableRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $SnapshotDetailsTableTable,
    List<SnapshotDetailsTableData>
  >
  _snapshotDetailsTableRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.snapshotDetailsTable,
        aliasName: $_aliasNameGenerator(
          db.assetClassesTable.id,
          db.snapshotDetailsTable.assetClassId,
        ),
      );

  $$SnapshotDetailsTableTableProcessedTableManager
  get snapshotDetailsTableRefs {
    final manager = $$SnapshotDetailsTableTableTableManager(
      $_db,
      $_db.snapshotDetailsTable,
    ).filter((f) => f.assetClassId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _snapshotDetailsTableRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$AssetClassesTableTableFilterComposer
    extends Composer<_$AppDatabase, $AssetClassesTableTable> {
  $$AssetClassesTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<AssetKind, AssetKind, String> get kind =>
      $composableBuilder(
        column: $table.kind,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<int> get targetWeightBp => $composableBuilder(
    column: $table.targetWeightBp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get inInvestmentGroup => $composableBuilder(
    column: $table.inInvestmentGroup,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get hidden => $composableBuilder(
    column: $table.hidden,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get colorValue => $composableBuilder(
    column: $table.colorValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get iconCodePoint => $composableBuilder(
    column: $table.iconCodePoint,
    builder: (column) => ColumnFilters(column),
  );

  $$TargetGroupsTableTableFilterComposer get targetGroupId {
    final $$TargetGroupsTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.targetGroupId,
      referencedTable: $db.targetGroupsTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TargetGroupsTableTableFilterComposer(
            $db: $db,
            $table: $db.targetGroupsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> holdingsTableRefs(
    Expression<bool> Function($$HoldingsTableTableFilterComposer f) f,
  ) {
    final $$HoldingsTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.holdingsTable,
      getReferencedColumn: (t) => t.assetClassId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HoldingsTableTableFilterComposer(
            $db: $db,
            $table: $db.holdingsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> snapshotDetailsTableRefs(
    Expression<bool> Function($$SnapshotDetailsTableTableFilterComposer f) f,
  ) {
    final $$SnapshotDetailsTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.snapshotDetailsTable,
      getReferencedColumn: (t) => t.assetClassId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SnapshotDetailsTableTableFilterComposer(
            $db: $db,
            $table: $db.snapshotDetailsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$AssetClassesTableTableOrderingComposer
    extends Composer<_$AppDatabase, $AssetClassesTableTable> {
  $$AssetClassesTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get targetWeightBp => $composableBuilder(
    column: $table.targetWeightBp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get inInvestmentGroup => $composableBuilder(
    column: $table.inInvestmentGroup,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get hidden => $composableBuilder(
    column: $table.hidden,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get colorValue => $composableBuilder(
    column: $table.colorValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get iconCodePoint => $composableBuilder(
    column: $table.iconCodePoint,
    builder: (column) => ColumnOrderings(column),
  );

  $$TargetGroupsTableTableOrderingComposer get targetGroupId {
    final $$TargetGroupsTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.targetGroupId,
      referencedTable: $db.targetGroupsTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TargetGroupsTableTableOrderingComposer(
            $db: $db,
            $table: $db.targetGroupsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AssetClassesTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $AssetClassesTableTable> {
  $$AssetClassesTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumnWithTypeConverter<AssetKind, String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<int> get targetWeightBp => $composableBuilder(
    column: $table.targetWeightBp,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get inInvestmentGroup => $composableBuilder(
    column: $table.inInvestmentGroup,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get hidden =>
      $composableBuilder(column: $table.hidden, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<int> get colorValue => $composableBuilder(
    column: $table.colorValue,
    builder: (column) => column,
  );

  GeneratedColumn<int> get iconCodePoint => $composableBuilder(
    column: $table.iconCodePoint,
    builder: (column) => column,
  );

  $$TargetGroupsTableTableAnnotationComposer get targetGroupId {
    final $$TargetGroupsTableTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.targetGroupId,
          referencedTable: $db.targetGroupsTable,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$TargetGroupsTableTableAnnotationComposer(
                $db: $db,
                $table: $db.targetGroupsTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  Expression<T> holdingsTableRefs<T extends Object>(
    Expression<T> Function($$HoldingsTableTableAnnotationComposer a) f,
  ) {
    final $$HoldingsTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.holdingsTable,
      getReferencedColumn: (t) => t.assetClassId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HoldingsTableTableAnnotationComposer(
            $db: $db,
            $table: $db.holdingsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> snapshotDetailsTableRefs<T extends Object>(
    Expression<T> Function($$SnapshotDetailsTableTableAnnotationComposer a) f,
  ) {
    final $$SnapshotDetailsTableTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.snapshotDetailsTable,
          getReferencedColumn: (t) => t.assetClassId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$SnapshotDetailsTableTableAnnotationComposer(
                $db: $db,
                $table: $db.snapshotDetailsTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$AssetClassesTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AssetClassesTableTable,
          AssetClassesTableData,
          $$AssetClassesTableTableFilterComposer,
          $$AssetClassesTableTableOrderingComposer,
          $$AssetClassesTableTableAnnotationComposer,
          $$AssetClassesTableTableCreateCompanionBuilder,
          $$AssetClassesTableTableUpdateCompanionBuilder,
          (AssetClassesTableData, $$AssetClassesTableTableReferences),
          AssetClassesTableData,
          PrefetchHooks Function({
            bool targetGroupId,
            bool holdingsTableRefs,
            bool snapshotDetailsTableRefs,
          })
        > {
  $$AssetClassesTableTableTableManager(
    _$AppDatabase db,
    $AssetClassesTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AssetClassesTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AssetClassesTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AssetClassesTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<AssetKind> kind = const Value.absent(),
                Value<int?> targetWeightBp = const Value.absent(),
                Value<int?> targetGroupId = const Value.absent(),
                Value<bool> inInvestmentGroup = const Value.absent(),
                Value<bool> hidden = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<int> colorValue = const Value.absent(),
                Value<int> iconCodePoint = const Value.absent(),
              }) => AssetClassesTableCompanion(
                id: id,
                name: name,
                kind: kind,
                targetWeightBp: targetWeightBp,
                targetGroupId: targetGroupId,
                inInvestmentGroup: inInvestmentGroup,
                hidden: hidden,
                sortOrder: sortOrder,
                colorValue: colorValue,
                iconCodePoint: iconCodePoint,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required AssetKind kind,
                Value<int?> targetWeightBp = const Value.absent(),
                Value<int?> targetGroupId = const Value.absent(),
                Value<bool> inInvestmentGroup = const Value.absent(),
                Value<bool> hidden = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                required int colorValue,
                required int iconCodePoint,
              }) => AssetClassesTableCompanion.insert(
                id: id,
                name: name,
                kind: kind,
                targetWeightBp: targetWeightBp,
                targetGroupId: targetGroupId,
                inInvestmentGroup: inInvestmentGroup,
                hidden: hidden,
                sortOrder: sortOrder,
                colorValue: colorValue,
                iconCodePoint: iconCodePoint,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$AssetClassesTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                targetGroupId = false,
                holdingsTableRefs = false,
                snapshotDetailsTableRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (holdingsTableRefs) db.holdingsTable,
                    if (snapshotDetailsTableRefs) db.snapshotDetailsTable,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (targetGroupId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.targetGroupId,
                                    referencedTable:
                                        $$AssetClassesTableTableReferences
                                            ._targetGroupIdTable(db),
                                    referencedColumn:
                                        $$AssetClassesTableTableReferences
                                            ._targetGroupIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (holdingsTableRefs)
                        await $_getPrefetchedData<
                          AssetClassesTableData,
                          $AssetClassesTableTable,
                          HoldingsTableData
                        >(
                          currentTable: table,
                          referencedTable: $$AssetClassesTableTableReferences
                              ._holdingsTableRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$AssetClassesTableTableReferences(
                                db,
                                table,
                                p0,
                              ).holdingsTableRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.assetClassId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (snapshotDetailsTableRefs)
                        await $_getPrefetchedData<
                          AssetClassesTableData,
                          $AssetClassesTableTable,
                          SnapshotDetailsTableData
                        >(
                          currentTable: table,
                          referencedTable: $$AssetClassesTableTableReferences
                              ._snapshotDetailsTableRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$AssetClassesTableTableReferences(
                                db,
                                table,
                                p0,
                              ).snapshotDetailsTableRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.assetClassId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$AssetClassesTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AssetClassesTableTable,
      AssetClassesTableData,
      $$AssetClassesTableTableFilterComposer,
      $$AssetClassesTableTableOrderingComposer,
      $$AssetClassesTableTableAnnotationComposer,
      $$AssetClassesTableTableCreateCompanionBuilder,
      $$AssetClassesTableTableUpdateCompanionBuilder,
      (AssetClassesTableData, $$AssetClassesTableTableReferences),
      AssetClassesTableData,
      PrefetchHooks Function({
        bool targetGroupId,
        bool holdingsTableRefs,
        bool snapshotDetailsTableRefs,
      })
    >;
typedef $$HoldingsTableTableCreateCompanionBuilder =
    HoldingsTableCompanion Function({
      Value<int> id,
      required int assetClassId,
      required String symbol,
      Value<String?> displayName,
      required InputMode inputMode,
      Value<int?> quantityRaw,
      Value<int> decimals,
      Value<Money?> manualValueAmount,
      required Currency currency,
      Value<String?> note,
      required DateTime updatedAt,
    });
typedef $$HoldingsTableTableUpdateCompanionBuilder =
    HoldingsTableCompanion Function({
      Value<int> id,
      Value<int> assetClassId,
      Value<String> symbol,
      Value<String?> displayName,
      Value<InputMode> inputMode,
      Value<int?> quantityRaw,
      Value<int> decimals,
      Value<Money?> manualValueAmount,
      Value<Currency> currency,
      Value<String?> note,
      Value<DateTime> updatedAt,
    });

final class $$HoldingsTableTableReferences
    extends
        BaseReferences<_$AppDatabase, $HoldingsTableTable, HoldingsTableData> {
  $$HoldingsTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $AssetClassesTableTable _assetClassIdTable(_$AppDatabase db) =>
      db.assetClassesTable.createAlias(
        $_aliasNameGenerator(
          db.holdingsTable.assetClassId,
          db.assetClassesTable.id,
        ),
      );

  $$AssetClassesTableTableProcessedTableManager get assetClassId {
    final $_column = $_itemColumn<int>('asset_class_id')!;

    final manager = $$AssetClassesTableTableTableManager(
      $_db,
      $_db.assetClassesTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_assetClassIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$HoldingsTableTableFilterComposer
    extends Composer<_$AppDatabase, $HoldingsTableTable> {
  $$HoldingsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get symbol => $composableBuilder(
    column: $table.symbol,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<InputMode, InputMode, String> get inputMode =>
      $composableBuilder(
        column: $table.inputMode,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<int> get quantityRaw => $composableBuilder(
    column: $table.quantityRaw,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get decimals => $composableBuilder(
    column: $table.decimals,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<Money?, Money, int> get manualValueAmount =>
      $composableBuilder(
        column: $table.manualValueAmount,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<Currency, Currency, String> get currency =>
      $composableBuilder(
        column: $table.currency,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$AssetClassesTableTableFilterComposer get assetClassId {
    final $$AssetClassesTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.assetClassId,
      referencedTable: $db.assetClassesTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AssetClassesTableTableFilterComposer(
            $db: $db,
            $table: $db.assetClassesTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$HoldingsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $HoldingsTableTable> {
  $$HoldingsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get symbol => $composableBuilder(
    column: $table.symbol,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get inputMode => $composableBuilder(
    column: $table.inputMode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get quantityRaw => $composableBuilder(
    column: $table.quantityRaw,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get decimals => $composableBuilder(
    column: $table.decimals,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get manualValueAmount => $composableBuilder(
    column: $table.manualValueAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$AssetClassesTableTableOrderingComposer get assetClassId {
    final $$AssetClassesTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.assetClassId,
      referencedTable: $db.assetClassesTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AssetClassesTableTableOrderingComposer(
            $db: $db,
            $table: $db.assetClassesTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$HoldingsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $HoldingsTableTable> {
  $$HoldingsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get symbol =>
      $composableBuilder(column: $table.symbol, builder: (column) => column);

  GeneratedColumn<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<InputMode, String> get inputMode =>
      $composableBuilder(column: $table.inputMode, builder: (column) => column);

  GeneratedColumn<int> get quantityRaw => $composableBuilder(
    column: $table.quantityRaw,
    builder: (column) => column,
  );

  GeneratedColumn<int> get decimals =>
      $composableBuilder(column: $table.decimals, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Money?, int> get manualValueAmount =>
      $composableBuilder(
        column: $table.manualValueAmount,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<Currency, String> get currency =>
      $composableBuilder(column: $table.currency, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$AssetClassesTableTableAnnotationComposer get assetClassId {
    final $$AssetClassesTableTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.assetClassId,
          referencedTable: $db.assetClassesTable,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$AssetClassesTableTableAnnotationComposer(
                $db: $db,
                $table: $db.assetClassesTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$HoldingsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $HoldingsTableTable,
          HoldingsTableData,
          $$HoldingsTableTableFilterComposer,
          $$HoldingsTableTableOrderingComposer,
          $$HoldingsTableTableAnnotationComposer,
          $$HoldingsTableTableCreateCompanionBuilder,
          $$HoldingsTableTableUpdateCompanionBuilder,
          (HoldingsTableData, $$HoldingsTableTableReferences),
          HoldingsTableData,
          PrefetchHooks Function({bool assetClassId})
        > {
  $$HoldingsTableTableTableManager(_$AppDatabase db, $HoldingsTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HoldingsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HoldingsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HoldingsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> assetClassId = const Value.absent(),
                Value<String> symbol = const Value.absent(),
                Value<String?> displayName = const Value.absent(),
                Value<InputMode> inputMode = const Value.absent(),
                Value<int?> quantityRaw = const Value.absent(),
                Value<int> decimals = const Value.absent(),
                Value<Money?> manualValueAmount = const Value.absent(),
                Value<Currency> currency = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => HoldingsTableCompanion(
                id: id,
                assetClassId: assetClassId,
                symbol: symbol,
                displayName: displayName,
                inputMode: inputMode,
                quantityRaw: quantityRaw,
                decimals: decimals,
                manualValueAmount: manualValueAmount,
                currency: currency,
                note: note,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int assetClassId,
                required String symbol,
                Value<String?> displayName = const Value.absent(),
                required InputMode inputMode,
                Value<int?> quantityRaw = const Value.absent(),
                Value<int> decimals = const Value.absent(),
                Value<Money?> manualValueAmount = const Value.absent(),
                required Currency currency,
                Value<String?> note = const Value.absent(),
                required DateTime updatedAt,
              }) => HoldingsTableCompanion.insert(
                id: id,
                assetClassId: assetClassId,
                symbol: symbol,
                displayName: displayName,
                inputMode: inputMode,
                quantityRaw: quantityRaw,
                decimals: decimals,
                manualValueAmount: manualValueAmount,
                currency: currency,
                note: note,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$HoldingsTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({assetClassId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (assetClassId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.assetClassId,
                                referencedTable: $$HoldingsTableTableReferences
                                    ._assetClassIdTable(db),
                                referencedColumn: $$HoldingsTableTableReferences
                                    ._assetClassIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$HoldingsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $HoldingsTableTable,
      HoldingsTableData,
      $$HoldingsTableTableFilterComposer,
      $$HoldingsTableTableOrderingComposer,
      $$HoldingsTableTableAnnotationComposer,
      $$HoldingsTableTableCreateCompanionBuilder,
      $$HoldingsTableTableUpdateCompanionBuilder,
      (HoldingsTableData, $$HoldingsTableTableReferences),
      HoldingsTableData,
      PrefetchHooks Function({bool assetClassId})
    >;
typedef $$PriceQuotesTableTableCreateCompanionBuilder =
    PriceQuotesTableCompanion Function({
      required String symbol,
      required PriceSource source,
      required Money priceAmount,
      required Currency currency,
      required DateTime fetchedAt,
      Value<int> rowid,
    });
typedef $$PriceQuotesTableTableUpdateCompanionBuilder =
    PriceQuotesTableCompanion Function({
      Value<String> symbol,
      Value<PriceSource> source,
      Value<Money> priceAmount,
      Value<Currency> currency,
      Value<DateTime> fetchedAt,
      Value<int> rowid,
    });

class $$PriceQuotesTableTableFilterComposer
    extends Composer<_$AppDatabase, $PriceQuotesTableTable> {
  $$PriceQuotesTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get symbol => $composableBuilder(
    column: $table.symbol,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<PriceSource, PriceSource, String> get source =>
      $composableBuilder(
        column: $table.source,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<Money, Money, int> get priceAmount =>
      $composableBuilder(
        column: $table.priceAmount,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<Currency, Currency, String> get currency =>
      $composableBuilder(
        column: $table.currency,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<DateTime> get fetchedAt => $composableBuilder(
    column: $table.fetchedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PriceQuotesTableTableOrderingComposer
    extends Composer<_$AppDatabase, $PriceQuotesTableTable> {
  $$PriceQuotesTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get symbol => $composableBuilder(
    column: $table.symbol,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get priceAmount => $composableBuilder(
    column: $table.priceAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get fetchedAt => $composableBuilder(
    column: $table.fetchedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PriceQuotesTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $PriceQuotesTableTable> {
  $$PriceQuotesTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get symbol =>
      $composableBuilder(column: $table.symbol, builder: (column) => column);

  GeneratedColumnWithTypeConverter<PriceSource, String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Money, int> get priceAmount =>
      $composableBuilder(
        column: $table.priceAmount,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<Currency, String> get currency =>
      $composableBuilder(column: $table.currency, builder: (column) => column);

  GeneratedColumn<DateTime> get fetchedAt =>
      $composableBuilder(column: $table.fetchedAt, builder: (column) => column);
}

class $$PriceQuotesTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PriceQuotesTableTable,
          PriceQuotesTableData,
          $$PriceQuotesTableTableFilterComposer,
          $$PriceQuotesTableTableOrderingComposer,
          $$PriceQuotesTableTableAnnotationComposer,
          $$PriceQuotesTableTableCreateCompanionBuilder,
          $$PriceQuotesTableTableUpdateCompanionBuilder,
          (
            PriceQuotesTableData,
            BaseReferences<
              _$AppDatabase,
              $PriceQuotesTableTable,
              PriceQuotesTableData
            >,
          ),
          PriceQuotesTableData,
          PrefetchHooks Function()
        > {
  $$PriceQuotesTableTableTableManager(
    _$AppDatabase db,
    $PriceQuotesTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PriceQuotesTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PriceQuotesTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PriceQuotesTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> symbol = const Value.absent(),
                Value<PriceSource> source = const Value.absent(),
                Value<Money> priceAmount = const Value.absent(),
                Value<Currency> currency = const Value.absent(),
                Value<DateTime> fetchedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PriceQuotesTableCompanion(
                symbol: symbol,
                source: source,
                priceAmount: priceAmount,
                currency: currency,
                fetchedAt: fetchedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String symbol,
                required PriceSource source,
                required Money priceAmount,
                required Currency currency,
                required DateTime fetchedAt,
                Value<int> rowid = const Value.absent(),
              }) => PriceQuotesTableCompanion.insert(
                symbol: symbol,
                source: source,
                priceAmount: priceAmount,
                currency: currency,
                fetchedAt: fetchedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PriceQuotesTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PriceQuotesTableTable,
      PriceQuotesTableData,
      $$PriceQuotesTableTableFilterComposer,
      $$PriceQuotesTableTableOrderingComposer,
      $$PriceQuotesTableTableAnnotationComposer,
      $$PriceQuotesTableTableCreateCompanionBuilder,
      $$PriceQuotesTableTableUpdateCompanionBuilder,
      (
        PriceQuotesTableData,
        BaseReferences<
          _$AppDatabase,
          $PriceQuotesTableTable,
          PriceQuotesTableData
        >,
      ),
      PriceQuotesTableData,
      PrefetchHooks Function()
    >;
typedef $$FxRatesTableTableCreateCompanionBuilder =
    FxRatesTableCompanion Function({
      required PriceSource source,
      required Money rateAmount,
      required DateTime fetchedAt,
      Value<int> rowid,
    });
typedef $$FxRatesTableTableUpdateCompanionBuilder =
    FxRatesTableCompanion Function({
      Value<PriceSource> source,
      Value<Money> rateAmount,
      Value<DateTime> fetchedAt,
      Value<int> rowid,
    });

class $$FxRatesTableTableFilterComposer
    extends Composer<_$AppDatabase, $FxRatesTableTable> {
  $$FxRatesTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnWithTypeConverterFilters<PriceSource, PriceSource, String> get source =>
      $composableBuilder(
        column: $table.source,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<Money, Money, int> get rateAmount =>
      $composableBuilder(
        column: $table.rateAmount,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<DateTime> get fetchedAt => $composableBuilder(
    column: $table.fetchedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$FxRatesTableTableOrderingComposer
    extends Composer<_$AppDatabase, $FxRatesTableTable> {
  $$FxRatesTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rateAmount => $composableBuilder(
    column: $table.rateAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get fetchedAt => $composableBuilder(
    column: $table.fetchedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FxRatesTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $FxRatesTableTable> {
  $$FxRatesTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumnWithTypeConverter<PriceSource, String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Money, int> get rateAmount =>
      $composableBuilder(
        column: $table.rateAmount,
        builder: (column) => column,
      );

  GeneratedColumn<DateTime> get fetchedAt =>
      $composableBuilder(column: $table.fetchedAt, builder: (column) => column);
}

class $$FxRatesTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FxRatesTableTable,
          FxRatesTableData,
          $$FxRatesTableTableFilterComposer,
          $$FxRatesTableTableOrderingComposer,
          $$FxRatesTableTableAnnotationComposer,
          $$FxRatesTableTableCreateCompanionBuilder,
          $$FxRatesTableTableUpdateCompanionBuilder,
          (
            FxRatesTableData,
            BaseReferences<_$AppDatabase, $FxRatesTableTable, FxRatesTableData>,
          ),
          FxRatesTableData,
          PrefetchHooks Function()
        > {
  $$FxRatesTableTableTableManager(_$AppDatabase db, $FxRatesTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FxRatesTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FxRatesTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FxRatesTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<PriceSource> source = const Value.absent(),
                Value<Money> rateAmount = const Value.absent(),
                Value<DateTime> fetchedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FxRatesTableCompanion(
                source: source,
                rateAmount: rateAmount,
                fetchedAt: fetchedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required PriceSource source,
                required Money rateAmount,
                required DateTime fetchedAt,
                Value<int> rowid = const Value.absent(),
              }) => FxRatesTableCompanion.insert(
                source: source,
                rateAmount: rateAmount,
                fetchedAt: fetchedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FxRatesTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FxRatesTableTable,
      FxRatesTableData,
      $$FxRatesTableTableFilterComposer,
      $$FxRatesTableTableOrderingComposer,
      $$FxRatesTableTableAnnotationComposer,
      $$FxRatesTableTableCreateCompanionBuilder,
      $$FxRatesTableTableUpdateCompanionBuilder,
      (
        FxRatesTableData,
        BaseReferences<_$AppDatabase, $FxRatesTableTable, FxRatesTableData>,
      ),
      FxRatesTableData,
      PrefetchHooks Function()
    >;
typedef $$CashFlowsTableTableCreateCompanionBuilder =
    CashFlowsTableCompanion Function({
      Value<int> id,
      required DateTime date,
      required Money amount,
      Value<String?> note,
    });
typedef $$CashFlowsTableTableUpdateCompanionBuilder =
    CashFlowsTableCompanion Function({
      Value<int> id,
      Value<DateTime> date,
      Value<Money> amount,
      Value<String?> note,
    });

class $$CashFlowsTableTableFilterComposer
    extends Composer<_$AppDatabase, $CashFlowsTableTable> {
  $$CashFlowsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<Money, Money, int> get amount =>
      $composableBuilder(
        column: $table.amount,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CashFlowsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $CashFlowsTableTable> {
  $$CashFlowsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CashFlowsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $CashFlowsTableTable> {
  $$CashFlowsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Money, int> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);
}

class $$CashFlowsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CashFlowsTableTable,
          CashFlowsTableData,
          $$CashFlowsTableTableFilterComposer,
          $$CashFlowsTableTableOrderingComposer,
          $$CashFlowsTableTableAnnotationComposer,
          $$CashFlowsTableTableCreateCompanionBuilder,
          $$CashFlowsTableTableUpdateCompanionBuilder,
          (
            CashFlowsTableData,
            BaseReferences<
              _$AppDatabase,
              $CashFlowsTableTable,
              CashFlowsTableData
            >,
          ),
          CashFlowsTableData,
          PrefetchHooks Function()
        > {
  $$CashFlowsTableTableTableManager(
    _$AppDatabase db,
    $CashFlowsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CashFlowsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CashFlowsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CashFlowsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<Money> amount = const Value.absent(),
                Value<String?> note = const Value.absent(),
              }) => CashFlowsTableCompanion(
                id: id,
                date: date,
                amount: amount,
                note: note,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required DateTime date,
                required Money amount,
                Value<String?> note = const Value.absent(),
              }) => CashFlowsTableCompanion.insert(
                id: id,
                date: date,
                amount: amount,
                note: note,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CashFlowsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CashFlowsTableTable,
      CashFlowsTableData,
      $$CashFlowsTableTableFilterComposer,
      $$CashFlowsTableTableOrderingComposer,
      $$CashFlowsTableTableAnnotationComposer,
      $$CashFlowsTableTableCreateCompanionBuilder,
      $$CashFlowsTableTableUpdateCompanionBuilder,
      (
        CashFlowsTableData,
        BaseReferences<_$AppDatabase, $CashFlowsTableTable, CashFlowsTableData>,
      ),
      CashFlowsTableData,
      PrefetchHooks Function()
    >;
typedef $$DebtsTableTableCreateCompanionBuilder =
    DebtsTableCompanion Function({
      Value<int> id,
      required String personName,
      required Money amount,
      required DateTime date,
      Value<String?> note,
      Value<DateTime?> settledAt,
    });
typedef $$DebtsTableTableUpdateCompanionBuilder =
    DebtsTableCompanion Function({
      Value<int> id,
      Value<String> personName,
      Value<Money> amount,
      Value<DateTime> date,
      Value<String?> note,
      Value<DateTime?> settledAt,
    });

class $$DebtsTableTableFilterComposer
    extends Composer<_$AppDatabase, $DebtsTableTable> {
  $$DebtsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get personName => $composableBuilder(
    column: $table.personName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<Money, Money, int> get amount =>
      $composableBuilder(
        column: $table.amount,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get settledAt => $composableBuilder(
    column: $table.settledAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DebtsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $DebtsTableTable> {
  $$DebtsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get personName => $composableBuilder(
    column: $table.personName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get settledAt => $composableBuilder(
    column: $table.settledAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DebtsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $DebtsTableTable> {
  $$DebtsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get personName => $composableBuilder(
    column: $table.personName,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<Money, int> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<DateTime> get settledAt =>
      $composableBuilder(column: $table.settledAt, builder: (column) => column);
}

class $$DebtsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DebtsTableTable,
          DebtsTableData,
          $$DebtsTableTableFilterComposer,
          $$DebtsTableTableOrderingComposer,
          $$DebtsTableTableAnnotationComposer,
          $$DebtsTableTableCreateCompanionBuilder,
          $$DebtsTableTableUpdateCompanionBuilder,
          (
            DebtsTableData,
            BaseReferences<_$AppDatabase, $DebtsTableTable, DebtsTableData>,
          ),
          DebtsTableData,
          PrefetchHooks Function()
        > {
  $$DebtsTableTableTableManager(_$AppDatabase db, $DebtsTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DebtsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DebtsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DebtsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> personName = const Value.absent(),
                Value<Money> amount = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<DateTime?> settledAt = const Value.absent(),
              }) => DebtsTableCompanion(
                id: id,
                personName: personName,
                amount: amount,
                date: date,
                note: note,
                settledAt: settledAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String personName,
                required Money amount,
                required DateTime date,
                Value<String?> note = const Value.absent(),
                Value<DateTime?> settledAt = const Value.absent(),
              }) => DebtsTableCompanion.insert(
                id: id,
                personName: personName,
                amount: amount,
                date: date,
                note: note,
                settledAt: settledAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DebtsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DebtsTableTable,
      DebtsTableData,
      $$DebtsTableTableFilterComposer,
      $$DebtsTableTableOrderingComposer,
      $$DebtsTableTableAnnotationComposer,
      $$DebtsTableTableCreateCompanionBuilder,
      $$DebtsTableTableUpdateCompanionBuilder,
      (
        DebtsTableData,
        BaseReferences<_$AppDatabase, $DebtsTableTable, DebtsTableData>,
      ),
      DebtsTableData,
      PrefetchHooks Function()
    >;
typedef $$SnapshotsTableTableCreateCompanionBuilder =
    SnapshotsTableCompanion Function({
      Value<int> id,
      required DateTime date,
      required Money totalAssetsAmount,
      required Money investmentGroupAmount,
      required SnapshotKind kind,
      Value<String?> note,
    });
typedef $$SnapshotsTableTableUpdateCompanionBuilder =
    SnapshotsTableCompanion Function({
      Value<int> id,
      Value<DateTime> date,
      Value<Money> totalAssetsAmount,
      Value<Money> investmentGroupAmount,
      Value<SnapshotKind> kind,
      Value<String?> note,
    });

final class $$SnapshotsTableTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $SnapshotsTableTable,
          SnapshotsTableData
        > {
  $$SnapshotsTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<
    $SnapshotDetailsTableTable,
    List<SnapshotDetailsTableData>
  >
  _snapshotDetailsTableRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.snapshotDetailsTable,
        aliasName: $_aliasNameGenerator(
          db.snapshotsTable.id,
          db.snapshotDetailsTable.snapshotId,
        ),
      );

  $$SnapshotDetailsTableTableProcessedTableManager
  get snapshotDetailsTableRefs {
    final manager = $$SnapshotDetailsTableTableTableManager(
      $_db,
      $_db.snapshotDetailsTable,
    ).filter((f) => f.snapshotId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _snapshotDetailsTableRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$SnapshotsTableTableFilterComposer
    extends Composer<_$AppDatabase, $SnapshotsTableTable> {
  $$SnapshotsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<Money, Money, int> get totalAssetsAmount =>
      $composableBuilder(
        column: $table.totalAssetsAmount,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<Money, Money, int> get investmentGroupAmount =>
      $composableBuilder(
        column: $table.investmentGroupAmount,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<SnapshotKind, SnapshotKind, String> get kind =>
      $composableBuilder(
        column: $table.kind,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> snapshotDetailsTableRefs(
    Expression<bool> Function($$SnapshotDetailsTableTableFilterComposer f) f,
  ) {
    final $$SnapshotDetailsTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.snapshotDetailsTable,
      getReferencedColumn: (t) => t.snapshotId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SnapshotDetailsTableTableFilterComposer(
            $db: $db,
            $table: $db.snapshotDetailsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SnapshotsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $SnapshotsTableTable> {
  $$SnapshotsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalAssetsAmount => $composableBuilder(
    column: $table.totalAssetsAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get investmentGroupAmount => $composableBuilder(
    column: $table.investmentGroupAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SnapshotsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $SnapshotsTableTable> {
  $$SnapshotsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Money, int> get totalAssetsAmount =>
      $composableBuilder(
        column: $table.totalAssetsAmount,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<Money, int> get investmentGroupAmount =>
      $composableBuilder(
        column: $table.investmentGroupAmount,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<SnapshotKind, String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  Expression<T> snapshotDetailsTableRefs<T extends Object>(
    Expression<T> Function($$SnapshotDetailsTableTableAnnotationComposer a) f,
  ) {
    final $$SnapshotDetailsTableTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.snapshotDetailsTable,
          getReferencedColumn: (t) => t.snapshotId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$SnapshotDetailsTableTableAnnotationComposer(
                $db: $db,
                $table: $db.snapshotDetailsTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$SnapshotsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SnapshotsTableTable,
          SnapshotsTableData,
          $$SnapshotsTableTableFilterComposer,
          $$SnapshotsTableTableOrderingComposer,
          $$SnapshotsTableTableAnnotationComposer,
          $$SnapshotsTableTableCreateCompanionBuilder,
          $$SnapshotsTableTableUpdateCompanionBuilder,
          (SnapshotsTableData, $$SnapshotsTableTableReferences),
          SnapshotsTableData,
          PrefetchHooks Function({bool snapshotDetailsTableRefs})
        > {
  $$SnapshotsTableTableTableManager(
    _$AppDatabase db,
    $SnapshotsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SnapshotsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SnapshotsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SnapshotsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<Money> totalAssetsAmount = const Value.absent(),
                Value<Money> investmentGroupAmount = const Value.absent(),
                Value<SnapshotKind> kind = const Value.absent(),
                Value<String?> note = const Value.absent(),
              }) => SnapshotsTableCompanion(
                id: id,
                date: date,
                totalAssetsAmount: totalAssetsAmount,
                investmentGroupAmount: investmentGroupAmount,
                kind: kind,
                note: note,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required DateTime date,
                required Money totalAssetsAmount,
                required Money investmentGroupAmount,
                required SnapshotKind kind,
                Value<String?> note = const Value.absent(),
              }) => SnapshotsTableCompanion.insert(
                id: id,
                date: date,
                totalAssetsAmount: totalAssetsAmount,
                investmentGroupAmount: investmentGroupAmount,
                kind: kind,
                note: note,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$SnapshotsTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({snapshotDetailsTableRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (snapshotDetailsTableRefs) db.snapshotDetailsTable,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (snapshotDetailsTableRefs)
                    await $_getPrefetchedData<
                      SnapshotsTableData,
                      $SnapshotsTableTable,
                      SnapshotDetailsTableData
                    >(
                      currentTable: table,
                      referencedTable: $$SnapshotsTableTableReferences
                          ._snapshotDetailsTableRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$SnapshotsTableTableReferences(
                            db,
                            table,
                            p0,
                          ).snapshotDetailsTableRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.snapshotId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$SnapshotsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SnapshotsTableTable,
      SnapshotsTableData,
      $$SnapshotsTableTableFilterComposer,
      $$SnapshotsTableTableOrderingComposer,
      $$SnapshotsTableTableAnnotationComposer,
      $$SnapshotsTableTableCreateCompanionBuilder,
      $$SnapshotsTableTableUpdateCompanionBuilder,
      (SnapshotsTableData, $$SnapshotsTableTableReferences),
      SnapshotsTableData,
      PrefetchHooks Function({bool snapshotDetailsTableRefs})
    >;
typedef $$SnapshotDetailsTableTableCreateCompanionBuilder =
    SnapshotDetailsTableCompanion Function({
      Value<int> id,
      required int snapshotId,
      Value<int?> assetClassId,
      required String assetClassName,
      required Money valueAmount,
    });
typedef $$SnapshotDetailsTableTableUpdateCompanionBuilder =
    SnapshotDetailsTableCompanion Function({
      Value<int> id,
      Value<int> snapshotId,
      Value<int?> assetClassId,
      Value<String> assetClassName,
      Value<Money> valueAmount,
    });

final class $$SnapshotDetailsTableTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $SnapshotDetailsTableTable,
          SnapshotDetailsTableData
        > {
  $$SnapshotDetailsTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $SnapshotsTableTable _snapshotIdTable(_$AppDatabase db) =>
      db.snapshotsTable.createAlias(
        $_aliasNameGenerator(
          db.snapshotDetailsTable.snapshotId,
          db.snapshotsTable.id,
        ),
      );

  $$SnapshotsTableTableProcessedTableManager get snapshotId {
    final $_column = $_itemColumn<int>('snapshot_id')!;

    final manager = $$SnapshotsTableTableTableManager(
      $_db,
      $_db.snapshotsTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_snapshotIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $AssetClassesTableTable _assetClassIdTable(_$AppDatabase db) =>
      db.assetClassesTable.createAlias(
        $_aliasNameGenerator(
          db.snapshotDetailsTable.assetClassId,
          db.assetClassesTable.id,
        ),
      );

  $$AssetClassesTableTableProcessedTableManager? get assetClassId {
    final $_column = $_itemColumn<int>('asset_class_id');
    if ($_column == null) return null;
    final manager = $$AssetClassesTableTableTableManager(
      $_db,
      $_db.assetClassesTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_assetClassIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$SnapshotDetailsTableTableFilterComposer
    extends Composer<_$AppDatabase, $SnapshotDetailsTableTable> {
  $$SnapshotDetailsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get assetClassName => $composableBuilder(
    column: $table.assetClassName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<Money, Money, int> get valueAmount =>
      $composableBuilder(
        column: $table.valueAmount,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  $$SnapshotsTableTableFilterComposer get snapshotId {
    final $$SnapshotsTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.snapshotId,
      referencedTable: $db.snapshotsTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SnapshotsTableTableFilterComposer(
            $db: $db,
            $table: $db.snapshotsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$AssetClassesTableTableFilterComposer get assetClassId {
    final $$AssetClassesTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.assetClassId,
      referencedTable: $db.assetClassesTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AssetClassesTableTableFilterComposer(
            $db: $db,
            $table: $db.assetClassesTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SnapshotDetailsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $SnapshotDetailsTableTable> {
  $$SnapshotDetailsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get assetClassName => $composableBuilder(
    column: $table.assetClassName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get valueAmount => $composableBuilder(
    column: $table.valueAmount,
    builder: (column) => ColumnOrderings(column),
  );

  $$SnapshotsTableTableOrderingComposer get snapshotId {
    final $$SnapshotsTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.snapshotId,
      referencedTable: $db.snapshotsTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SnapshotsTableTableOrderingComposer(
            $db: $db,
            $table: $db.snapshotsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$AssetClassesTableTableOrderingComposer get assetClassId {
    final $$AssetClassesTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.assetClassId,
      referencedTable: $db.assetClassesTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AssetClassesTableTableOrderingComposer(
            $db: $db,
            $table: $db.assetClassesTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SnapshotDetailsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $SnapshotDetailsTableTable> {
  $$SnapshotDetailsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get assetClassName => $composableBuilder(
    column: $table.assetClassName,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<Money, int> get valueAmount =>
      $composableBuilder(
        column: $table.valueAmount,
        builder: (column) => column,
      );

  $$SnapshotsTableTableAnnotationComposer get snapshotId {
    final $$SnapshotsTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.snapshotId,
      referencedTable: $db.snapshotsTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SnapshotsTableTableAnnotationComposer(
            $db: $db,
            $table: $db.snapshotsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$AssetClassesTableTableAnnotationComposer get assetClassId {
    final $$AssetClassesTableTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.assetClassId,
          referencedTable: $db.assetClassesTable,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$AssetClassesTableTableAnnotationComposer(
                $db: $db,
                $table: $db.assetClassesTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$SnapshotDetailsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SnapshotDetailsTableTable,
          SnapshotDetailsTableData,
          $$SnapshotDetailsTableTableFilterComposer,
          $$SnapshotDetailsTableTableOrderingComposer,
          $$SnapshotDetailsTableTableAnnotationComposer,
          $$SnapshotDetailsTableTableCreateCompanionBuilder,
          $$SnapshotDetailsTableTableUpdateCompanionBuilder,
          (SnapshotDetailsTableData, $$SnapshotDetailsTableTableReferences),
          SnapshotDetailsTableData,
          PrefetchHooks Function({bool snapshotId, bool assetClassId})
        > {
  $$SnapshotDetailsTableTableTableManager(
    _$AppDatabase db,
    $SnapshotDetailsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SnapshotDetailsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SnapshotDetailsTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$SnapshotDetailsTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> snapshotId = const Value.absent(),
                Value<int?> assetClassId = const Value.absent(),
                Value<String> assetClassName = const Value.absent(),
                Value<Money> valueAmount = const Value.absent(),
              }) => SnapshotDetailsTableCompanion(
                id: id,
                snapshotId: snapshotId,
                assetClassId: assetClassId,
                assetClassName: assetClassName,
                valueAmount: valueAmount,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int snapshotId,
                Value<int?> assetClassId = const Value.absent(),
                required String assetClassName,
                required Money valueAmount,
              }) => SnapshotDetailsTableCompanion.insert(
                id: id,
                snapshotId: snapshotId,
                assetClassId: assetClassId,
                assetClassName: assetClassName,
                valueAmount: valueAmount,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$SnapshotDetailsTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({snapshotId = false, assetClassId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (snapshotId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.snapshotId,
                                referencedTable:
                                    $$SnapshotDetailsTableTableReferences
                                        ._snapshotIdTable(db),
                                referencedColumn:
                                    $$SnapshotDetailsTableTableReferences
                                        ._snapshotIdTable(db)
                                        .id,
                              )
                              as T;
                    }
                    if (assetClassId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.assetClassId,
                                referencedTable:
                                    $$SnapshotDetailsTableTableReferences
                                        ._assetClassIdTable(db),
                                referencedColumn:
                                    $$SnapshotDetailsTableTableReferences
                                        ._assetClassIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$SnapshotDetailsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SnapshotDetailsTableTable,
      SnapshotDetailsTableData,
      $$SnapshotDetailsTableTableFilterComposer,
      $$SnapshotDetailsTableTableOrderingComposer,
      $$SnapshotDetailsTableTableAnnotationComposer,
      $$SnapshotDetailsTableTableCreateCompanionBuilder,
      $$SnapshotDetailsTableTableUpdateCompanionBuilder,
      (SnapshotDetailsTableData, $$SnapshotDetailsTableTableReferences),
      SnapshotDetailsTableData,
      PrefetchHooks Function({bool snapshotId, bool assetClassId})
    >;
typedef $$ActionNotesTableTableCreateCompanionBuilder =
    ActionNotesTableCompanion Function({
      Value<int> id,
      required String body,
      required DateTime createdAt,
      Value<DateTime?> completedAt,
    });
typedef $$ActionNotesTableTableUpdateCompanionBuilder =
    ActionNotesTableCompanion Function({
      Value<int> id,
      Value<String> body,
      Value<DateTime> createdAt,
      Value<DateTime?> completedAt,
    });

class $$ActionNotesTableTableFilterComposer
    extends Composer<_$AppDatabase, $ActionNotesTableTable> {
  $$ActionNotesTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ActionNotesTableTableOrderingComposer
    extends Composer<_$AppDatabase, $ActionNotesTableTable> {
  $$ActionNotesTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ActionNotesTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $ActionNotesTableTable> {
  $$ActionNotesTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get body =>
      $composableBuilder(column: $table.body, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );
}

class $$ActionNotesTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ActionNotesTableTable,
          ActionNotesTableData,
          $$ActionNotesTableTableFilterComposer,
          $$ActionNotesTableTableOrderingComposer,
          $$ActionNotesTableTableAnnotationComposer,
          $$ActionNotesTableTableCreateCompanionBuilder,
          $$ActionNotesTableTableUpdateCompanionBuilder,
          (
            ActionNotesTableData,
            BaseReferences<
              _$AppDatabase,
              $ActionNotesTableTable,
              ActionNotesTableData
            >,
          ),
          ActionNotesTableData,
          PrefetchHooks Function()
        > {
  $$ActionNotesTableTableTableManager(
    _$AppDatabase db,
    $ActionNotesTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ActionNotesTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ActionNotesTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ActionNotesTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> body = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
              }) => ActionNotesTableCompanion(
                id: id,
                body: body,
                createdAt: createdAt,
                completedAt: completedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String body,
                required DateTime createdAt,
                Value<DateTime?> completedAt = const Value.absent(),
              }) => ActionNotesTableCompanion.insert(
                id: id,
                body: body,
                createdAt: createdAt,
                completedAt: completedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ActionNotesTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ActionNotesTableTable,
      ActionNotesTableData,
      $$ActionNotesTableTableFilterComposer,
      $$ActionNotesTableTableOrderingComposer,
      $$ActionNotesTableTableAnnotationComposer,
      $$ActionNotesTableTableCreateCompanionBuilder,
      $$ActionNotesTableTableUpdateCompanionBuilder,
      (
        ActionNotesTableData,
        BaseReferences<
          _$AppDatabase,
          $ActionNotesTableTable,
          ActionNotesTableData
        >,
      ),
      ActionNotesTableData,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$SettingsTableTableTableManager get settingsTable =>
      $$SettingsTableTableTableManager(_db, _db.settingsTable);
  $$TargetGroupsTableTableTableManager get targetGroupsTable =>
      $$TargetGroupsTableTableTableManager(_db, _db.targetGroupsTable);
  $$AssetClassesTableTableTableManager get assetClassesTable =>
      $$AssetClassesTableTableTableManager(_db, _db.assetClassesTable);
  $$HoldingsTableTableTableManager get holdingsTable =>
      $$HoldingsTableTableTableManager(_db, _db.holdingsTable);
  $$PriceQuotesTableTableTableManager get priceQuotesTable =>
      $$PriceQuotesTableTableTableManager(_db, _db.priceQuotesTable);
  $$FxRatesTableTableTableManager get fxRatesTable =>
      $$FxRatesTableTableTableManager(_db, _db.fxRatesTable);
  $$CashFlowsTableTableTableManager get cashFlowsTable =>
      $$CashFlowsTableTableTableManager(_db, _db.cashFlowsTable);
  $$DebtsTableTableTableManager get debtsTable =>
      $$DebtsTableTableTableManager(_db, _db.debtsTable);
  $$SnapshotsTableTableTableManager get snapshotsTable =>
      $$SnapshotsTableTableTableManager(_db, _db.snapshotsTable);
  $$SnapshotDetailsTableTableTableManager get snapshotDetailsTable =>
      $$SnapshotDetailsTableTableTableManager(_db, _db.snapshotDetailsTable);
  $$ActionNotesTableTableTableManager get actionNotesTable =>
      $$ActionNotesTableTableTableManager(_db, _db.actionNotesTable);
}
