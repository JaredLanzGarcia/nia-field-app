// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $CapturedImagesTable extends CapturedImages
    with TableInfo<$CapturedImagesTable, CapturedImage> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CapturedImagesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _imagePathMeta = const VerificationMeta(
    'imagePath',
  );
  @override
  late final GeneratedColumn<String> imagePath = GeneratedColumn<String>(
    'image_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deviceTimestampMeta = const VerificationMeta(
    'deviceTimestamp',
  );
  @override
  late final GeneratedColumn<DateTime> deviceTimestamp =
      GeneratedColumn<DateTime>(
        'device_timestamp',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _geoTimestampMeta = const VerificationMeta(
    'geoTimestamp',
  );
  @override
  late final GeneratedColumn<DateTime> geoTimestamp = GeneratedColumn<DateTime>(
    'geo_timestamp',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<Duration, int> timeOffset =
      GeneratedColumn<int>(
        'time_offset',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<Duration>($CapturedImagesTable.$convertertimeOffset);
  static const VerificationMeta _latitudeMeta = const VerificationMeta(
    'latitude',
  );
  @override
  late final GeneratedColumn<double> latitude = GeneratedColumn<double>(
    'latitude',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _longitudeMeta = const VerificationMeta(
    'longitude',
  );
  @override
  late final GeneratedColumn<double> longitude = GeneratedColumn<double>(
    'longitude',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _placeMeta = const VerificationMeta('place');
  @override
  late final GeneratedColumn<String> place = GeneratedColumn<String>(
    'place',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isSyncedMeta = const VerificationMeta(
    'isSynced',
  );
  @override
  late final GeneratedColumn<bool> isSynced = GeneratedColumn<bool>(
    'is_synced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_synced" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    imagePath,
    deviceTimestamp,
    geoTimestamp,
    timeOffset,
    latitude,
    longitude,
    place,
    isSynced,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'captured_images';
  @override
  VerificationContext validateIntegrity(
    Insertable<CapturedImage> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('image_path')) {
      context.handle(
        _imagePathMeta,
        imagePath.isAcceptableOrUnknown(data['image_path']!, _imagePathMeta),
      );
    } else if (isInserting) {
      context.missing(_imagePathMeta);
    }
    if (data.containsKey('device_timestamp')) {
      context.handle(
        _deviceTimestampMeta,
        deviceTimestamp.isAcceptableOrUnknown(
          data['device_timestamp']!,
          _deviceTimestampMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_deviceTimestampMeta);
    }
    if (data.containsKey('geo_timestamp')) {
      context.handle(
        _geoTimestampMeta,
        geoTimestamp.isAcceptableOrUnknown(
          data['geo_timestamp']!,
          _geoTimestampMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_geoTimestampMeta);
    }
    if (data.containsKey('latitude')) {
      context.handle(
        _latitudeMeta,
        latitude.isAcceptableOrUnknown(data['latitude']!, _latitudeMeta),
      );
    } else if (isInserting) {
      context.missing(_latitudeMeta);
    }
    if (data.containsKey('longitude')) {
      context.handle(
        _longitudeMeta,
        longitude.isAcceptableOrUnknown(data['longitude']!, _longitudeMeta),
      );
    } else if (isInserting) {
      context.missing(_longitudeMeta);
    }
    if (data.containsKey('place')) {
      context.handle(
        _placeMeta,
        place.isAcceptableOrUnknown(data['place']!, _placeMeta),
      );
    } else if (isInserting) {
      context.missing(_placeMeta);
    }
    if (data.containsKey('is_synced')) {
      context.handle(
        _isSyncedMeta,
        isSynced.isAcceptableOrUnknown(data['is_synced']!, _isSyncedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CapturedImage map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CapturedImage(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}id'],
          )!,
      imagePath:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}image_path'],
          )!,
      deviceTimestamp:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}device_timestamp'],
          )!,
      geoTimestamp:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}geo_timestamp'],
          )!,
      timeOffset: $CapturedImagesTable.$convertertimeOffset.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}time_offset'],
        )!,
      ),
      latitude:
          attachedDatabase.typeMapping.read(
            DriftSqlType.double,
            data['${effectivePrefix}latitude'],
          )!,
      longitude:
          attachedDatabase.typeMapping.read(
            DriftSqlType.double,
            data['${effectivePrefix}longitude'],
          )!,
      place:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}place'],
          )!,
      isSynced:
          attachedDatabase.typeMapping.read(
            DriftSqlType.bool,
            data['${effectivePrefix}is_synced'],
          )!,
    );
  }

  @override
  $CapturedImagesTable createAlias(String alias) {
    return $CapturedImagesTable(attachedDatabase, alias);
  }

  static TypeConverter<Duration, int> $convertertimeOffset =
      const DurationConverter();
}

class CapturedImage extends DataClass implements Insertable<CapturedImage> {
  final int id;
  final String imagePath;
  final DateTime deviceTimestamp;
  final DateTime geoTimestamp;
  final Duration timeOffset;
  final double latitude;
  final double longitude;
  final String place;
  final bool isSynced;
  const CapturedImage({
    required this.id,
    required this.imagePath,
    required this.deviceTimestamp,
    required this.geoTimestamp,
    required this.timeOffset,
    required this.latitude,
    required this.longitude,
    required this.place,
    required this.isSynced,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['image_path'] = Variable<String>(imagePath);
    map['device_timestamp'] = Variable<DateTime>(deviceTimestamp);
    map['geo_timestamp'] = Variable<DateTime>(geoTimestamp);
    {
      map['time_offset'] = Variable<int>(
        $CapturedImagesTable.$convertertimeOffset.toSql(timeOffset),
      );
    }
    map['latitude'] = Variable<double>(latitude);
    map['longitude'] = Variable<double>(longitude);
    map['place'] = Variable<String>(place);
    map['is_synced'] = Variable<bool>(isSynced);
    return map;
  }

  CapturedImagesCompanion toCompanion(bool nullToAbsent) {
    return CapturedImagesCompanion(
      id: Value(id),
      imagePath: Value(imagePath),
      deviceTimestamp: Value(deviceTimestamp),
      geoTimestamp: Value(geoTimestamp),
      timeOffset: Value(timeOffset),
      latitude: Value(latitude),
      longitude: Value(longitude),
      place: Value(place),
      isSynced: Value(isSynced),
    );
  }

  factory CapturedImage.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CapturedImage(
      id: serializer.fromJson<int>(json['id']),
      imagePath: serializer.fromJson<String>(json['imagePath']),
      deviceTimestamp: serializer.fromJson<DateTime>(json['deviceTimestamp']),
      geoTimestamp: serializer.fromJson<DateTime>(json['geoTimestamp']),
      timeOffset: serializer.fromJson<Duration>(json['timeOffset']),
      latitude: serializer.fromJson<double>(json['latitude']),
      longitude: serializer.fromJson<double>(json['longitude']),
      place: serializer.fromJson<String>(json['place']),
      isSynced: serializer.fromJson<bool>(json['isSynced']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'imagePath': serializer.toJson<String>(imagePath),
      'deviceTimestamp': serializer.toJson<DateTime>(deviceTimestamp),
      'geoTimestamp': serializer.toJson<DateTime>(geoTimestamp),
      'timeOffset': serializer.toJson<Duration>(timeOffset),
      'latitude': serializer.toJson<double>(latitude),
      'longitude': serializer.toJson<double>(longitude),
      'place': serializer.toJson<String>(place),
      'isSynced': serializer.toJson<bool>(isSynced),
    };
  }

  CapturedImage copyWith({
    int? id,
    String? imagePath,
    DateTime? deviceTimestamp,
    DateTime? geoTimestamp,
    Duration? timeOffset,
    double? latitude,
    double? longitude,
    String? place,
    bool? isSynced,
  }) => CapturedImage(
    id: id ?? this.id,
    imagePath: imagePath ?? this.imagePath,
    deviceTimestamp: deviceTimestamp ?? this.deviceTimestamp,
    geoTimestamp: geoTimestamp ?? this.geoTimestamp,
    timeOffset: timeOffset ?? this.timeOffset,
    latitude: latitude ?? this.latitude,
    longitude: longitude ?? this.longitude,
    place: place ?? this.place,
    isSynced: isSynced ?? this.isSynced,
  );
  CapturedImage copyWithCompanion(CapturedImagesCompanion data) {
    return CapturedImage(
      id: data.id.present ? data.id.value : this.id,
      imagePath: data.imagePath.present ? data.imagePath.value : this.imagePath,
      deviceTimestamp:
          data.deviceTimestamp.present
              ? data.deviceTimestamp.value
              : this.deviceTimestamp,
      geoTimestamp:
          data.geoTimestamp.present
              ? data.geoTimestamp.value
              : this.geoTimestamp,
      timeOffset:
          data.timeOffset.present ? data.timeOffset.value : this.timeOffset,
      latitude: data.latitude.present ? data.latitude.value : this.latitude,
      longitude: data.longitude.present ? data.longitude.value : this.longitude,
      place: data.place.present ? data.place.value : this.place,
      isSynced: data.isSynced.present ? data.isSynced.value : this.isSynced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CapturedImage(')
          ..write('id: $id, ')
          ..write('imagePath: $imagePath, ')
          ..write('deviceTimestamp: $deviceTimestamp, ')
          ..write('geoTimestamp: $geoTimestamp, ')
          ..write('timeOffset: $timeOffset, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('place: $place, ')
          ..write('isSynced: $isSynced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    imagePath,
    deviceTimestamp,
    geoTimestamp,
    timeOffset,
    latitude,
    longitude,
    place,
    isSynced,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CapturedImage &&
          other.id == this.id &&
          other.imagePath == this.imagePath &&
          other.deviceTimestamp == this.deviceTimestamp &&
          other.geoTimestamp == this.geoTimestamp &&
          other.timeOffset == this.timeOffset &&
          other.latitude == this.latitude &&
          other.longitude == this.longitude &&
          other.place == this.place &&
          other.isSynced == this.isSynced);
}

class CapturedImagesCompanion extends UpdateCompanion<CapturedImage> {
  final Value<int> id;
  final Value<String> imagePath;
  final Value<DateTime> deviceTimestamp;
  final Value<DateTime> geoTimestamp;
  final Value<Duration> timeOffset;
  final Value<double> latitude;
  final Value<double> longitude;
  final Value<String> place;
  final Value<bool> isSynced;
  const CapturedImagesCompanion({
    this.id = const Value.absent(),
    this.imagePath = const Value.absent(),
    this.deviceTimestamp = const Value.absent(),
    this.geoTimestamp = const Value.absent(),
    this.timeOffset = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.place = const Value.absent(),
    this.isSynced = const Value.absent(),
  });
  CapturedImagesCompanion.insert({
    this.id = const Value.absent(),
    required String imagePath,
    required DateTime deviceTimestamp,
    required DateTime geoTimestamp,
    required Duration timeOffset,
    required double latitude,
    required double longitude,
    required String place,
    this.isSynced = const Value.absent(),
  }) : imagePath = Value(imagePath),
       deviceTimestamp = Value(deviceTimestamp),
       geoTimestamp = Value(geoTimestamp),
       timeOffset = Value(timeOffset),
       latitude = Value(latitude),
       longitude = Value(longitude),
       place = Value(place);
  static Insertable<CapturedImage> custom({
    Expression<int>? id,
    Expression<String>? imagePath,
    Expression<DateTime>? deviceTimestamp,
    Expression<DateTime>? geoTimestamp,
    Expression<int>? timeOffset,
    Expression<double>? latitude,
    Expression<double>? longitude,
    Expression<String>? place,
    Expression<bool>? isSynced,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (imagePath != null) 'image_path': imagePath,
      if (deviceTimestamp != null) 'device_timestamp': deviceTimestamp,
      if (geoTimestamp != null) 'geo_timestamp': geoTimestamp,
      if (timeOffset != null) 'time_offset': timeOffset,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (place != null) 'place': place,
      if (isSynced != null) 'is_synced': isSynced,
    });
  }

  CapturedImagesCompanion copyWith({
    Value<int>? id,
    Value<String>? imagePath,
    Value<DateTime>? deviceTimestamp,
    Value<DateTime>? geoTimestamp,
    Value<Duration>? timeOffset,
    Value<double>? latitude,
    Value<double>? longitude,
    Value<String>? place,
    Value<bool>? isSynced,
  }) {
    return CapturedImagesCompanion(
      id: id ?? this.id,
      imagePath: imagePath ?? this.imagePath,
      deviceTimestamp: deviceTimestamp ?? this.deviceTimestamp,
      geoTimestamp: geoTimestamp ?? this.geoTimestamp,
      timeOffset: timeOffset ?? this.timeOffset,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      place: place ?? this.place,
      isSynced: isSynced ?? this.isSynced,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (imagePath.present) {
      map['image_path'] = Variable<String>(imagePath.value);
    }
    if (deviceTimestamp.present) {
      map['device_timestamp'] = Variable<DateTime>(deviceTimestamp.value);
    }
    if (geoTimestamp.present) {
      map['geo_timestamp'] = Variable<DateTime>(geoTimestamp.value);
    }
    if (timeOffset.present) {
      map['time_offset'] = Variable<int>(
        $CapturedImagesTable.$convertertimeOffset.toSql(timeOffset.value),
      );
    }
    if (latitude.present) {
      map['latitude'] = Variable<double>(latitude.value);
    }
    if (longitude.present) {
      map['longitude'] = Variable<double>(longitude.value);
    }
    if (place.present) {
      map['place'] = Variable<String>(place.value);
    }
    if (isSynced.present) {
      map['is_synced'] = Variable<bool>(isSynced.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CapturedImagesCompanion(')
          ..write('id: $id, ')
          ..write('imagePath: $imagePath, ')
          ..write('deviceTimestamp: $deviceTimestamp, ')
          ..write('geoTimestamp: $geoTimestamp, ')
          ..write('timeOffset: $timeOffset, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('place: $place, ')
          ..write('isSynced: $isSynced')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $CapturedImagesTable capturedImages = $CapturedImagesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [capturedImages];
}

typedef $$CapturedImagesTableCreateCompanionBuilder =
    CapturedImagesCompanion Function({
      Value<int> id,
      required String imagePath,
      required DateTime deviceTimestamp,
      required DateTime geoTimestamp,
      required Duration timeOffset,
      required double latitude,
      required double longitude,
      required String place,
      Value<bool> isSynced,
    });
typedef $$CapturedImagesTableUpdateCompanionBuilder =
    CapturedImagesCompanion Function({
      Value<int> id,
      Value<String> imagePath,
      Value<DateTime> deviceTimestamp,
      Value<DateTime> geoTimestamp,
      Value<Duration> timeOffset,
      Value<double> latitude,
      Value<double> longitude,
      Value<String> place,
      Value<bool> isSynced,
    });

class $$CapturedImagesTableFilterComposer
    extends Composer<_$AppDatabase, $CapturedImagesTable> {
  $$CapturedImagesTableFilterComposer({
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

  ColumnFilters<String> get imagePath => $composableBuilder(
    column: $table.imagePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deviceTimestamp => $composableBuilder(
    column: $table.deviceTimestamp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get geoTimestamp => $composableBuilder(
    column: $table.geoTimestamp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<Duration, Duration, int> get timeOffset =>
      $composableBuilder(
        column: $table.timeOffset,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get place => $composableBuilder(
    column: $table.place,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CapturedImagesTableOrderingComposer
    extends Composer<_$AppDatabase, $CapturedImagesTable> {
  $$CapturedImagesTableOrderingComposer({
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

  ColumnOrderings<String> get imagePath => $composableBuilder(
    column: $table.imagePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deviceTimestamp => $composableBuilder(
    column: $table.deviceTimestamp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get geoTimestamp => $composableBuilder(
    column: $table.geoTimestamp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get timeOffset => $composableBuilder(
    column: $table.timeOffset,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get place => $composableBuilder(
    column: $table.place,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CapturedImagesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CapturedImagesTable> {
  $$CapturedImagesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get imagePath =>
      $composableBuilder(column: $table.imagePath, builder: (column) => column);

  GeneratedColumn<DateTime> get deviceTimestamp => $composableBuilder(
    column: $table.deviceTimestamp,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get geoTimestamp => $composableBuilder(
    column: $table.geoTimestamp,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<Duration, int> get timeOffset =>
      $composableBuilder(
        column: $table.timeOffset,
        builder: (column) => column,
      );

  GeneratedColumn<double> get latitude =>
      $composableBuilder(column: $table.latitude, builder: (column) => column);

  GeneratedColumn<double> get longitude =>
      $composableBuilder(column: $table.longitude, builder: (column) => column);

  GeneratedColumn<String> get place =>
      $composableBuilder(column: $table.place, builder: (column) => column);

  GeneratedColumn<bool> get isSynced =>
      $composableBuilder(column: $table.isSynced, builder: (column) => column);
}

class $$CapturedImagesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CapturedImagesTable,
          CapturedImage,
          $$CapturedImagesTableFilterComposer,
          $$CapturedImagesTableOrderingComposer,
          $$CapturedImagesTableAnnotationComposer,
          $$CapturedImagesTableCreateCompanionBuilder,
          $$CapturedImagesTableUpdateCompanionBuilder,
          (
            CapturedImage,
            BaseReferences<_$AppDatabase, $CapturedImagesTable, CapturedImage>,
          ),
          CapturedImage,
          PrefetchHooks Function()
        > {
  $$CapturedImagesTableTableManager(
    _$AppDatabase db,
    $CapturedImagesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$CapturedImagesTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () =>
                  $$CapturedImagesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$CapturedImagesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> imagePath = const Value.absent(),
                Value<DateTime> deviceTimestamp = const Value.absent(),
                Value<DateTime> geoTimestamp = const Value.absent(),
                Value<Duration> timeOffset = const Value.absent(),
                Value<double> latitude = const Value.absent(),
                Value<double> longitude = const Value.absent(),
                Value<String> place = const Value.absent(),
                Value<bool> isSynced = const Value.absent(),
              }) => CapturedImagesCompanion(
                id: id,
                imagePath: imagePath,
                deviceTimestamp: deviceTimestamp,
                geoTimestamp: geoTimestamp,
                timeOffset: timeOffset,
                latitude: latitude,
                longitude: longitude,
                place: place,
                isSynced: isSynced,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String imagePath,
                required DateTime deviceTimestamp,
                required DateTime geoTimestamp,
                required Duration timeOffset,
                required double latitude,
                required double longitude,
                required String place,
                Value<bool> isSynced = const Value.absent(),
              }) => CapturedImagesCompanion.insert(
                id: id,
                imagePath: imagePath,
                deviceTimestamp: deviceTimestamp,
                geoTimestamp: geoTimestamp,
                timeOffset: timeOffset,
                latitude: latitude,
                longitude: longitude,
                place: place,
                isSynced: isSynced,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CapturedImagesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CapturedImagesTable,
      CapturedImage,
      $$CapturedImagesTableFilterComposer,
      $$CapturedImagesTableOrderingComposer,
      $$CapturedImagesTableAnnotationComposer,
      $$CapturedImagesTableCreateCompanionBuilder,
      $$CapturedImagesTableUpdateCompanionBuilder,
      (
        CapturedImage,
        BaseReferences<_$AppDatabase, $CapturedImagesTable, CapturedImage>,
      ),
      CapturedImage,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$CapturedImagesTableTableManager get capturedImages =>
      $$CapturedImagesTableTableManager(_db, _db.capturedImages);
}
