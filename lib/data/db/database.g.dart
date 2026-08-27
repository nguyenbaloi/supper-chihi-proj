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

  /// Đã hoàn tất luồng khởi tạo lần đầu chưa.
  final bool onboardingCompleted;
  const SettingsTableData({
    required this.id,
    required this.initialContributionAmount,
    required this.startDate,
    this.fxRateManualAmount,
    required this.driftThresholdBp,
    this.lastExportedAt,
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
          other.onboardingCompleted == this.onboardingCompleted);
}

class SettingsTableCompanion extends UpdateCompanion<SettingsTableData> {
  final Value<int> id;
  final Value<Money> initialContributionAmount;
  final Value<DateTime> startDate;
  final Value<Money?> fxRateManualAmount;
  final Value<int> driftThresholdBp;
  final Value<DateTime?> lastExportedAt;
  final Value<bool> onboardingCompleted;
  const SettingsTableCompanion({
    this.id = const Value.absent(),
    this.initialContributionAmount = const Value.absent(),
    this.startDate = const Value.absent(),
    this.fxRateManualAmount = const Value.absent(),
    this.driftThresholdBp = const Value.absent(),
    this.lastExportedAt = const Value.absent(),
    this.onboardingCompleted = const Value.absent(),
  });
  SettingsTableCompanion.insert({
    this.id = const Value.absent(),
    required Money initialContributionAmount,
    required DateTime startDate,
    this.fxRateManualAmount = const Value.absent(),
    this.driftThresholdBp = const Value.absent(),
    this.lastExportedAt = const Value.absent(),
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
          ..write('onboardingCompleted: $onboardingCompleted')
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

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $SettingsTableTable settingsTable = $SettingsTableTable(this);
  late final $AssetClassesTableTable assetClassesTable =
      $AssetClassesTableTable(this);
  late final $HoldingsTableTable holdingsTable = $HoldingsTableTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    settingsTable,
    assetClassesTable,
    holdingsTable,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'asset_classes',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('holdings', kind: UpdateKind.delete)],
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
                Value<bool> onboardingCompleted = const Value.absent(),
              }) => SettingsTableCompanion(
                id: id,
                initialContributionAmount: initialContributionAmount,
                startDate: startDate,
                fxRateManualAmount: fxRateManualAmount,
                driftThresholdBp: driftThresholdBp,
                lastExportedAt: lastExportedAt,
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
                Value<bool> onboardingCompleted = const Value.absent(),
              }) => SettingsTableCompanion.insert(
                id: id,
                initialContributionAmount: initialContributionAmount,
                startDate: startDate,
                fxRateManualAmount: fxRateManualAmount,
                driftThresholdBp: driftThresholdBp,
                lastExportedAt: lastExportedAt,
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
typedef $$AssetClassesTableTableCreateCompanionBuilder =
    AssetClassesTableCompanion Function({
      Value<int> id,
      required String name,
      required AssetKind kind,
      Value<int?> targetWeightBp,
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
          PrefetchHooks Function({bool holdingsTableRefs})
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
          prefetchHooksCallback: ({holdingsTableRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (holdingsTableRefs) db.holdingsTable,
              ],
              addJoins: null,
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
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where(
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
      PrefetchHooks Function({bool holdingsTableRefs})
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

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$SettingsTableTableTableManager get settingsTable =>
      $$SettingsTableTableTableManager(_db, _db.settingsTable);
  $$AssetClassesTableTableTableManager get assetClassesTable =>
      $$AssetClassesTableTableTableManager(_db, _db.assetClassesTable);
  $$HoldingsTableTableTableManager get holdingsTable =>
      $$HoldingsTableTableTableManager(_db, _db.holdingsTable);
}
