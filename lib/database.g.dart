// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $UsersTable extends Users with TableInfo<$UsersTable, User> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UsersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _employeeIdMeta = const VerificationMeta(
    'employeeId',
  );
  @override
  late final GeneratedColumn<String> employeeId = GeneratedColumn<String>(
    'employee_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _passwordMeta = const VerificationMeta(
    'password',
  );
  @override
  late final GeneratedColumn<String> password = GeneratedColumn<String>(
    'password',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [employeeId, password];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'users';
  @override
  VerificationContext validateIntegrity(
    Insertable<User> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('employee_id')) {
      context.handle(
        _employeeIdMeta,
        employeeId.isAcceptableOrUnknown(data['employee_id']!, _employeeIdMeta),
      );
    } else if (isInserting) {
      context.missing(_employeeIdMeta);
    }
    if (data.containsKey('password')) {
      context.handle(
        _passwordMeta,
        password.isAcceptableOrUnknown(data['password']!, _passwordMeta),
      );
    } else if (isInserting) {
      context.missing(_passwordMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {employeeId};
  @override
  User map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return User(
      employeeId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}employee_id'],
          )!,
      password:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}password'],
          )!,
    );
  }

  @override
  $UsersTable createAlias(String alias) {
    return $UsersTable(attachedDatabase, alias);
  }
}

class User extends DataClass implements Insertable<User> {
  final String employeeId;
  final String password;
  const User({required this.employeeId, required this.password});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['employee_id'] = Variable<String>(employeeId);
    map['password'] = Variable<String>(password);
    return map;
  }

  UsersCompanion toCompanion(bool nullToAbsent) {
    return UsersCompanion(
      employeeId: Value(employeeId),
      password: Value(password),
    );
  }

  factory User.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return User(
      employeeId: serializer.fromJson<String>(json['employeeId']),
      password: serializer.fromJson<String>(json['password']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'employeeId': serializer.toJson<String>(employeeId),
      'password': serializer.toJson<String>(password),
    };
  }

  User copyWith({String? employeeId, String? password}) => User(
    employeeId: employeeId ?? this.employeeId,
    password: password ?? this.password,
  );
  User copyWithCompanion(UsersCompanion data) {
    return User(
      employeeId:
          data.employeeId.present ? data.employeeId.value : this.employeeId,
      password: data.password.present ? data.password.value : this.password,
    );
  }

  @override
  String toString() {
    return (StringBuffer('User(')
          ..write('employeeId: $employeeId, ')
          ..write('password: $password')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(employeeId, password);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is User &&
          other.employeeId == this.employeeId &&
          other.password == this.password);
}

class UsersCompanion extends UpdateCompanion<User> {
  final Value<String> employeeId;
  final Value<String> password;
  final Value<int> rowid;
  const UsersCompanion({
    this.employeeId = const Value.absent(),
    this.password = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UsersCompanion.insert({
    required String employeeId,
    required String password,
    this.rowid = const Value.absent(),
  }) : employeeId = Value(employeeId),
       password = Value(password);
  static Insertable<User> custom({
    Expression<String>? employeeId,
    Expression<String>? password,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (employeeId != null) 'employee_id': employeeId,
      if (password != null) 'password': password,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UsersCompanion copyWith({
    Value<String>? employeeId,
    Value<String>? password,
    Value<int>? rowid,
  }) {
    return UsersCompanion(
      employeeId: employeeId ?? this.employeeId,
      password: password ?? this.password,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (employeeId.present) {
      map['employee_id'] = Variable<String>(employeeId.value);
    }
    if (password.present) {
      map['password'] = Variable<String>(password.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UsersCompanion(')
          ..write('employeeId: $employeeId, ')
          ..write('password: $password, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

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
  static const VerificationMeta _lastActivityMeta = const VerificationMeta(
    'lastActivity',
  );
  @override
  late final GeneratedColumn<DateTime> lastActivity = GeneratedColumn<DateTime>(
    'last_activity',
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
  static const VerificationMeta _employeeIdMeta = const VerificationMeta(
    'employeeId',
  );
  @override
  late final GeneratedColumn<String> employeeId = GeneratedColumn<String>(
    'employee_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES users (employee_id)',
    ),
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
    lastActivity,
    timeOffset,
    latitude,
    longitude,
    place,
    employeeId,
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
    if (data.containsKey('last_activity')) {
      context.handle(
        _lastActivityMeta,
        lastActivity.isAcceptableOrUnknown(
          data['last_activity']!,
          _lastActivityMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lastActivityMeta);
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
    if (data.containsKey('employee_id')) {
      context.handle(
        _employeeIdMeta,
        employeeId.isAcceptableOrUnknown(data['employee_id']!, _employeeIdMeta),
      );
    } else if (isInserting) {
      context.missing(_employeeIdMeta);
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
      lastActivity:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}last_activity'],
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
      employeeId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}employee_id'],
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
  final DateTime lastActivity;
  final Duration timeOffset;
  final double latitude;
  final double longitude;
  final String place;
  final String employeeId;
  final bool isSynced;
  const CapturedImage({
    required this.id,
    required this.imagePath,
    required this.deviceTimestamp,
    required this.lastActivity,
    required this.timeOffset,
    required this.latitude,
    required this.longitude,
    required this.place,
    required this.employeeId,
    required this.isSynced,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['image_path'] = Variable<String>(imagePath);
    map['device_timestamp'] = Variable<DateTime>(deviceTimestamp);
    map['last_activity'] = Variable<DateTime>(lastActivity);
    {
      map['time_offset'] = Variable<int>(
        $CapturedImagesTable.$convertertimeOffset.toSql(timeOffset),
      );
    }
    map['latitude'] = Variable<double>(latitude);
    map['longitude'] = Variable<double>(longitude);
    map['place'] = Variable<String>(place);
    map['employee_id'] = Variable<String>(employeeId);
    map['is_synced'] = Variable<bool>(isSynced);
    return map;
  }

  CapturedImagesCompanion toCompanion(bool nullToAbsent) {
    return CapturedImagesCompanion(
      id: Value(id),
      imagePath: Value(imagePath),
      deviceTimestamp: Value(deviceTimestamp),
      lastActivity: Value(lastActivity),
      timeOffset: Value(timeOffset),
      latitude: Value(latitude),
      longitude: Value(longitude),
      place: Value(place),
      employeeId: Value(employeeId),
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
      lastActivity: serializer.fromJson<DateTime>(json['lastActivity']),
      timeOffset: serializer.fromJson<Duration>(json['timeOffset']),
      latitude: serializer.fromJson<double>(json['latitude']),
      longitude: serializer.fromJson<double>(json['longitude']),
      place: serializer.fromJson<String>(json['place']),
      employeeId: serializer.fromJson<String>(json['employeeId']),
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
      'lastActivity': serializer.toJson<DateTime>(lastActivity),
      'timeOffset': serializer.toJson<Duration>(timeOffset),
      'latitude': serializer.toJson<double>(latitude),
      'longitude': serializer.toJson<double>(longitude),
      'place': serializer.toJson<String>(place),
      'employeeId': serializer.toJson<String>(employeeId),
      'isSynced': serializer.toJson<bool>(isSynced),
    };
  }

  CapturedImage copyWith({
    int? id,
    String? imagePath,
    DateTime? deviceTimestamp,
    DateTime? lastActivity,
    Duration? timeOffset,
    double? latitude,
    double? longitude,
    String? place,
    String? employeeId,
    bool? isSynced,
  }) => CapturedImage(
    id: id ?? this.id,
    imagePath: imagePath ?? this.imagePath,
    deviceTimestamp: deviceTimestamp ?? this.deviceTimestamp,
    lastActivity: lastActivity ?? this.lastActivity,
    timeOffset: timeOffset ?? this.timeOffset,
    latitude: latitude ?? this.latitude,
    longitude: longitude ?? this.longitude,
    place: place ?? this.place,
    employeeId: employeeId ?? this.employeeId,
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
      lastActivity:
          data.lastActivity.present
              ? data.lastActivity.value
              : this.lastActivity,
      timeOffset:
          data.timeOffset.present ? data.timeOffset.value : this.timeOffset,
      latitude: data.latitude.present ? data.latitude.value : this.latitude,
      longitude: data.longitude.present ? data.longitude.value : this.longitude,
      place: data.place.present ? data.place.value : this.place,
      employeeId:
          data.employeeId.present ? data.employeeId.value : this.employeeId,
      isSynced: data.isSynced.present ? data.isSynced.value : this.isSynced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CapturedImage(')
          ..write('id: $id, ')
          ..write('imagePath: $imagePath, ')
          ..write('deviceTimestamp: $deviceTimestamp, ')
          ..write('lastActivity: $lastActivity, ')
          ..write('timeOffset: $timeOffset, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('place: $place, ')
          ..write('employeeId: $employeeId, ')
          ..write('isSynced: $isSynced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    imagePath,
    deviceTimestamp,
    lastActivity,
    timeOffset,
    latitude,
    longitude,
    place,
    employeeId,
    isSynced,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CapturedImage &&
          other.id == this.id &&
          other.imagePath == this.imagePath &&
          other.deviceTimestamp == this.deviceTimestamp &&
          other.lastActivity == this.lastActivity &&
          other.timeOffset == this.timeOffset &&
          other.latitude == this.latitude &&
          other.longitude == this.longitude &&
          other.place == this.place &&
          other.employeeId == this.employeeId &&
          other.isSynced == this.isSynced);
}

class CapturedImagesCompanion extends UpdateCompanion<CapturedImage> {
  final Value<int> id;
  final Value<String> imagePath;
  final Value<DateTime> deviceTimestamp;
  final Value<DateTime> lastActivity;
  final Value<Duration> timeOffset;
  final Value<double> latitude;
  final Value<double> longitude;
  final Value<String> place;
  final Value<String> employeeId;
  final Value<bool> isSynced;
  const CapturedImagesCompanion({
    this.id = const Value.absent(),
    this.imagePath = const Value.absent(),
    this.deviceTimestamp = const Value.absent(),
    this.lastActivity = const Value.absent(),
    this.timeOffset = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.place = const Value.absent(),
    this.employeeId = const Value.absent(),
    this.isSynced = const Value.absent(),
  });
  CapturedImagesCompanion.insert({
    this.id = const Value.absent(),
    required String imagePath,
    required DateTime deviceTimestamp,
    required DateTime lastActivity,
    required Duration timeOffset,
    required double latitude,
    required double longitude,
    required String place,
    required String employeeId,
    this.isSynced = const Value.absent(),
  }) : imagePath = Value(imagePath),
       deviceTimestamp = Value(deviceTimestamp),
       lastActivity = Value(lastActivity),
       timeOffset = Value(timeOffset),
       latitude = Value(latitude),
       longitude = Value(longitude),
       place = Value(place),
       employeeId = Value(employeeId);
  static Insertable<CapturedImage> custom({
    Expression<int>? id,
    Expression<String>? imagePath,
    Expression<DateTime>? deviceTimestamp,
    Expression<DateTime>? lastActivity,
    Expression<int>? timeOffset,
    Expression<double>? latitude,
    Expression<double>? longitude,
    Expression<String>? place,
    Expression<String>? employeeId,
    Expression<bool>? isSynced,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (imagePath != null) 'image_path': imagePath,
      if (deviceTimestamp != null) 'device_timestamp': deviceTimestamp,
      if (lastActivity != null) 'last_activity': lastActivity,
      if (timeOffset != null) 'time_offset': timeOffset,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (place != null) 'place': place,
      if (employeeId != null) 'employee_id': employeeId,
      if (isSynced != null) 'is_synced': isSynced,
    });
  }

  CapturedImagesCompanion copyWith({
    Value<int>? id,
    Value<String>? imagePath,
    Value<DateTime>? deviceTimestamp,
    Value<DateTime>? lastActivity,
    Value<Duration>? timeOffset,
    Value<double>? latitude,
    Value<double>? longitude,
    Value<String>? place,
    Value<String>? employeeId,
    Value<bool>? isSynced,
  }) {
    return CapturedImagesCompanion(
      id: id ?? this.id,
      imagePath: imagePath ?? this.imagePath,
      deviceTimestamp: deviceTimestamp ?? this.deviceTimestamp,
      lastActivity: lastActivity ?? this.lastActivity,
      timeOffset: timeOffset ?? this.timeOffset,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      place: place ?? this.place,
      employeeId: employeeId ?? this.employeeId,
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
    if (lastActivity.present) {
      map['last_activity'] = Variable<DateTime>(lastActivity.value);
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
    if (employeeId.present) {
      map['employee_id'] = Variable<String>(employeeId.value);
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
          ..write('lastActivity: $lastActivity, ')
          ..write('timeOffset: $timeOffset, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('place: $place, ')
          ..write('employeeId: $employeeId, ')
          ..write('isSynced: $isSynced')
          ..write(')'))
        .toString();
  }
}

class $TimeAnchorsTable extends TimeAnchors
    with TableInfo<$TimeAnchorsTable, TimeAnchor> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TimeAnchorsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _lastTickMeta = const VerificationMeta(
    'lastTick',
  );
  @override
  late final GeneratedColumn<DateTime> lastTick = GeneratedColumn<DateTime>(
    'last_tick',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _uptimeSecondsMeta = const VerificationMeta(
    'uptimeSeconds',
  );
  @override
  late final GeneratedColumn<int> uptimeSeconds = GeneratedColumn<int>(
    'uptime_seconds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, lastTick, uptimeSeconds];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'time_anchors';
  @override
  VerificationContext validateIntegrity(
    Insertable<TimeAnchor> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('last_tick')) {
      context.handle(
        _lastTickMeta,
        lastTick.isAcceptableOrUnknown(data['last_tick']!, _lastTickMeta),
      );
    } else if (isInserting) {
      context.missing(_lastTickMeta);
    }
    if (data.containsKey('uptime_seconds')) {
      context.handle(
        _uptimeSecondsMeta,
        uptimeSeconds.isAcceptableOrUnknown(
          data['uptime_seconds']!,
          _uptimeSecondsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_uptimeSecondsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TimeAnchor map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TimeAnchor(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}id'],
          )!,
      lastTick:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}last_tick'],
          )!,
      uptimeSeconds:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}uptime_seconds'],
          )!,
    );
  }

  @override
  $TimeAnchorsTable createAlias(String alias) {
    return $TimeAnchorsTable(attachedDatabase, alias);
  }
}

class TimeAnchor extends DataClass implements Insertable<TimeAnchor> {
  final int id;
  final DateTime lastTick;
  final int uptimeSeconds;
  const TimeAnchor({
    required this.id,
    required this.lastTick,
    required this.uptimeSeconds,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['last_tick'] = Variable<DateTime>(lastTick);
    map['uptime_seconds'] = Variable<int>(uptimeSeconds);
    return map;
  }

  TimeAnchorsCompanion toCompanion(bool nullToAbsent) {
    return TimeAnchorsCompanion(
      id: Value(id),
      lastTick: Value(lastTick),
      uptimeSeconds: Value(uptimeSeconds),
    );
  }

  factory TimeAnchor.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TimeAnchor(
      id: serializer.fromJson<int>(json['id']),
      lastTick: serializer.fromJson<DateTime>(json['lastTick']),
      uptimeSeconds: serializer.fromJson<int>(json['uptimeSeconds']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'lastTick': serializer.toJson<DateTime>(lastTick),
      'uptimeSeconds': serializer.toJson<int>(uptimeSeconds),
    };
  }

  TimeAnchor copyWith({int? id, DateTime? lastTick, int? uptimeSeconds}) =>
      TimeAnchor(
        id: id ?? this.id,
        lastTick: lastTick ?? this.lastTick,
        uptimeSeconds: uptimeSeconds ?? this.uptimeSeconds,
      );
  TimeAnchor copyWithCompanion(TimeAnchorsCompanion data) {
    return TimeAnchor(
      id: data.id.present ? data.id.value : this.id,
      lastTick: data.lastTick.present ? data.lastTick.value : this.lastTick,
      uptimeSeconds:
          data.uptimeSeconds.present
              ? data.uptimeSeconds.value
              : this.uptimeSeconds,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TimeAnchor(')
          ..write('id: $id, ')
          ..write('lastTick: $lastTick, ')
          ..write('uptimeSeconds: $uptimeSeconds')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, lastTick, uptimeSeconds);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TimeAnchor &&
          other.id == this.id &&
          other.lastTick == this.lastTick &&
          other.uptimeSeconds == this.uptimeSeconds);
}

class TimeAnchorsCompanion extends UpdateCompanion<TimeAnchor> {
  final Value<int> id;
  final Value<DateTime> lastTick;
  final Value<int> uptimeSeconds;
  const TimeAnchorsCompanion({
    this.id = const Value.absent(),
    this.lastTick = const Value.absent(),
    this.uptimeSeconds = const Value.absent(),
  });
  TimeAnchorsCompanion.insert({
    this.id = const Value.absent(),
    required DateTime lastTick,
    required int uptimeSeconds,
  }) : lastTick = Value(lastTick),
       uptimeSeconds = Value(uptimeSeconds);
  static Insertable<TimeAnchor> custom({
    Expression<int>? id,
    Expression<DateTime>? lastTick,
    Expression<int>? uptimeSeconds,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (lastTick != null) 'last_tick': lastTick,
      if (uptimeSeconds != null) 'uptime_seconds': uptimeSeconds,
    });
  }

  TimeAnchorsCompanion copyWith({
    Value<int>? id,
    Value<DateTime>? lastTick,
    Value<int>? uptimeSeconds,
  }) {
    return TimeAnchorsCompanion(
      id: id ?? this.id,
      lastTick: lastTick ?? this.lastTick,
      uptimeSeconds: uptimeSeconds ?? this.uptimeSeconds,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (lastTick.present) {
      map['last_tick'] = Variable<DateTime>(lastTick.value);
    }
    if (uptimeSeconds.present) {
      map['uptime_seconds'] = Variable<int>(uptimeSeconds.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TimeAnchorsCompanion(')
          ..write('id: $id, ')
          ..write('lastTick: $lastTick, ')
          ..write('uptimeSeconds: $uptimeSeconds')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $UsersTable users = $UsersTable(this);
  late final $CapturedImagesTable capturedImages = $CapturedImagesTable(this);
  late final $TimeAnchorsTable timeAnchors = $TimeAnchorsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    users,
    capturedImages,
    timeAnchors,
  ];
}

typedef $$UsersTableCreateCompanionBuilder =
    UsersCompanion Function({
      required String employeeId,
      required String password,
      Value<int> rowid,
    });
typedef $$UsersTableUpdateCompanionBuilder =
    UsersCompanion Function({
      Value<String> employeeId,
      Value<String> password,
      Value<int> rowid,
    });

final class $$UsersTableReferences
    extends BaseReferences<_$AppDatabase, $UsersTable, User> {
  $$UsersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$CapturedImagesTable, List<CapturedImage>>
  _capturedImagesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.capturedImages,
    aliasName: $_aliasNameGenerator(
      db.users.employeeId,
      db.capturedImages.employeeId,
    ),
  );

  $$CapturedImagesTableProcessedTableManager get capturedImagesRefs {
    final manager = $$CapturedImagesTableTableManager(
      $_db,
      $_db.capturedImages,
    ).filter(
      (f) => f.employeeId.employeeId.sqlEquals(
        $_itemColumn<String>('employee_id')!,
      ),
    );

    final cache = $_typedResult.readTableOrNull(_capturedImagesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$UsersTableFilterComposer extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get employeeId => $composableBuilder(
    column: $table.employeeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get password => $composableBuilder(
    column: $table.password,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> capturedImagesRefs(
    Expression<bool> Function($$CapturedImagesTableFilterComposer f) f,
  ) {
    final $$CapturedImagesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.employeeId,
      referencedTable: $db.capturedImages,
      getReferencedColumn: (t) => t.employeeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CapturedImagesTableFilterComposer(
            $db: $db,
            $table: $db.capturedImages,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$UsersTableOrderingComposer
    extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get employeeId => $composableBuilder(
    column: $table.employeeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get password => $composableBuilder(
    column: $table.password,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UsersTableAnnotationComposer
    extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get employeeId => $composableBuilder(
    column: $table.employeeId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get password =>
      $composableBuilder(column: $table.password, builder: (column) => column);

  Expression<T> capturedImagesRefs<T extends Object>(
    Expression<T> Function($$CapturedImagesTableAnnotationComposer a) f,
  ) {
    final $$CapturedImagesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.employeeId,
      referencedTable: $db.capturedImages,
      getReferencedColumn: (t) => t.employeeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CapturedImagesTableAnnotationComposer(
            $db: $db,
            $table: $db.capturedImages,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$UsersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UsersTable,
          User,
          $$UsersTableFilterComposer,
          $$UsersTableOrderingComposer,
          $$UsersTableAnnotationComposer,
          $$UsersTableCreateCompanionBuilder,
          $$UsersTableUpdateCompanionBuilder,
          (User, $$UsersTableReferences),
          User,
          PrefetchHooks Function({bool capturedImagesRefs})
        > {
  $$UsersTableTableManager(_$AppDatabase db, $UsersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$UsersTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$UsersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$UsersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> employeeId = const Value.absent(),
                Value<String> password = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UsersCompanion(
                employeeId: employeeId,
                password: password,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String employeeId,
                required String password,
                Value<int> rowid = const Value.absent(),
              }) => UsersCompanion.insert(
                employeeId: employeeId,
                password: password,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          $$UsersTableReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: ({capturedImagesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (capturedImagesRefs) db.capturedImages,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (capturedImagesRefs)
                    await $_getPrefetchedData<User, $UsersTable, CapturedImage>(
                      currentTable: table,
                      referencedTable: $$UsersTableReferences
                          ._capturedImagesRefsTable(db),
                      managerFromTypedResult:
                          (p0) =>
                              $$UsersTableReferences(
                                db,
                                table,
                                p0,
                              ).capturedImagesRefs,
                      referencedItemsForCurrentItem:
                          (item, referencedItems) => referencedItems.where(
                            (e) => e.employeeId == item.employeeId,
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

typedef $$UsersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UsersTable,
      User,
      $$UsersTableFilterComposer,
      $$UsersTableOrderingComposer,
      $$UsersTableAnnotationComposer,
      $$UsersTableCreateCompanionBuilder,
      $$UsersTableUpdateCompanionBuilder,
      (User, $$UsersTableReferences),
      User,
      PrefetchHooks Function({bool capturedImagesRefs})
    >;
typedef $$CapturedImagesTableCreateCompanionBuilder =
    CapturedImagesCompanion Function({
      Value<int> id,
      required String imagePath,
      required DateTime deviceTimestamp,
      required DateTime lastActivity,
      required Duration timeOffset,
      required double latitude,
      required double longitude,
      required String place,
      required String employeeId,
      Value<bool> isSynced,
    });
typedef $$CapturedImagesTableUpdateCompanionBuilder =
    CapturedImagesCompanion Function({
      Value<int> id,
      Value<String> imagePath,
      Value<DateTime> deviceTimestamp,
      Value<DateTime> lastActivity,
      Value<Duration> timeOffset,
      Value<double> latitude,
      Value<double> longitude,
      Value<String> place,
      Value<String> employeeId,
      Value<bool> isSynced,
    });

final class $$CapturedImagesTableReferences
    extends BaseReferences<_$AppDatabase, $CapturedImagesTable, CapturedImage> {
  $$CapturedImagesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $UsersTable _employeeIdTable(_$AppDatabase db) => db.users.createAlias(
    $_aliasNameGenerator(db.capturedImages.employeeId, db.users.employeeId),
  );

  $$UsersTableProcessedTableManager get employeeId {
    final $_column = $_itemColumn<String>('employee_id')!;

    final manager = $$UsersTableTableManager(
      $_db,
      $_db.users,
    ).filter((f) => f.employeeId.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_employeeIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

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

  ColumnFilters<DateTime> get lastActivity => $composableBuilder(
    column: $table.lastActivity,
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

  $$UsersTableFilterComposer get employeeId {
    final $$UsersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.employeeId,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.employeeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersTableFilterComposer(
            $db: $db,
            $table: $db.users,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
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

  ColumnOrderings<DateTime> get lastActivity => $composableBuilder(
    column: $table.lastActivity,
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

  $$UsersTableOrderingComposer get employeeId {
    final $$UsersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.employeeId,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.employeeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersTableOrderingComposer(
            $db: $db,
            $table: $db.users,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
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

  GeneratedColumn<DateTime> get lastActivity => $composableBuilder(
    column: $table.lastActivity,
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

  $$UsersTableAnnotationComposer get employeeId {
    final $$UsersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.employeeId,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.employeeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersTableAnnotationComposer(
            $db: $db,
            $table: $db.users,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
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
          (CapturedImage, $$CapturedImagesTableReferences),
          CapturedImage,
          PrefetchHooks Function({bool employeeId})
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
                Value<DateTime> lastActivity = const Value.absent(),
                Value<Duration> timeOffset = const Value.absent(),
                Value<double> latitude = const Value.absent(),
                Value<double> longitude = const Value.absent(),
                Value<String> place = const Value.absent(),
                Value<String> employeeId = const Value.absent(),
                Value<bool> isSynced = const Value.absent(),
              }) => CapturedImagesCompanion(
                id: id,
                imagePath: imagePath,
                deviceTimestamp: deviceTimestamp,
                lastActivity: lastActivity,
                timeOffset: timeOffset,
                latitude: latitude,
                longitude: longitude,
                place: place,
                employeeId: employeeId,
                isSynced: isSynced,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String imagePath,
                required DateTime deviceTimestamp,
                required DateTime lastActivity,
                required Duration timeOffset,
                required double latitude,
                required double longitude,
                required String place,
                required String employeeId,
                Value<bool> isSynced = const Value.absent(),
              }) => CapturedImagesCompanion.insert(
                id: id,
                imagePath: imagePath,
                deviceTimestamp: deviceTimestamp,
                lastActivity: lastActivity,
                timeOffset: timeOffset,
                latitude: latitude,
                longitude: longitude,
                place: place,
                employeeId: employeeId,
                isSynced: isSynced,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          $$CapturedImagesTableReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: ({employeeId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
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
                if (employeeId) {
                  state =
                      state.withJoin(
                            currentTable: table,
                            currentColumn: table.employeeId,
                            referencedTable: $$CapturedImagesTableReferences
                                ._employeeIdTable(db),
                            referencedColumn:
                                $$CapturedImagesTableReferences
                                    ._employeeIdTable(db)
                                    .employeeId,
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
      (CapturedImage, $$CapturedImagesTableReferences),
      CapturedImage,
      PrefetchHooks Function({bool employeeId})
    >;
typedef $$TimeAnchorsTableCreateCompanionBuilder =
    TimeAnchorsCompanion Function({
      Value<int> id,
      required DateTime lastTick,
      required int uptimeSeconds,
    });
typedef $$TimeAnchorsTableUpdateCompanionBuilder =
    TimeAnchorsCompanion Function({
      Value<int> id,
      Value<DateTime> lastTick,
      Value<int> uptimeSeconds,
    });

class $$TimeAnchorsTableFilterComposer
    extends Composer<_$AppDatabase, $TimeAnchorsTable> {
  $$TimeAnchorsTableFilterComposer({
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

  ColumnFilters<DateTime> get lastTick => $composableBuilder(
    column: $table.lastTick,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get uptimeSeconds => $composableBuilder(
    column: $table.uptimeSeconds,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TimeAnchorsTableOrderingComposer
    extends Composer<_$AppDatabase, $TimeAnchorsTable> {
  $$TimeAnchorsTableOrderingComposer({
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

  ColumnOrderings<DateTime> get lastTick => $composableBuilder(
    column: $table.lastTick,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get uptimeSeconds => $composableBuilder(
    column: $table.uptimeSeconds,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TimeAnchorsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TimeAnchorsTable> {
  $$TimeAnchorsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get lastTick =>
      $composableBuilder(column: $table.lastTick, builder: (column) => column);

  GeneratedColumn<int> get uptimeSeconds => $composableBuilder(
    column: $table.uptimeSeconds,
    builder: (column) => column,
  );
}

class $$TimeAnchorsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TimeAnchorsTable,
          TimeAnchor,
          $$TimeAnchorsTableFilterComposer,
          $$TimeAnchorsTableOrderingComposer,
          $$TimeAnchorsTableAnnotationComposer,
          $$TimeAnchorsTableCreateCompanionBuilder,
          $$TimeAnchorsTableUpdateCompanionBuilder,
          (
            TimeAnchor,
            BaseReferences<_$AppDatabase, $TimeAnchorsTable, TimeAnchor>,
          ),
          TimeAnchor,
          PrefetchHooks Function()
        > {
  $$TimeAnchorsTableTableManager(_$AppDatabase db, $TimeAnchorsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$TimeAnchorsTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$TimeAnchorsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () =>
                  $$TimeAnchorsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> lastTick = const Value.absent(),
                Value<int> uptimeSeconds = const Value.absent(),
              }) => TimeAnchorsCompanion(
                id: id,
                lastTick: lastTick,
                uptimeSeconds: uptimeSeconds,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required DateTime lastTick,
                required int uptimeSeconds,
              }) => TimeAnchorsCompanion.insert(
                id: id,
                lastTick: lastTick,
                uptimeSeconds: uptimeSeconds,
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

typedef $$TimeAnchorsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TimeAnchorsTable,
      TimeAnchor,
      $$TimeAnchorsTableFilterComposer,
      $$TimeAnchorsTableOrderingComposer,
      $$TimeAnchorsTableAnnotationComposer,
      $$TimeAnchorsTableCreateCompanionBuilder,
      $$TimeAnchorsTableUpdateCompanionBuilder,
      (
        TimeAnchor,
        BaseReferences<_$AppDatabase, $TimeAnchorsTable, TimeAnchor>,
      ),
      TimeAnchor,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$UsersTableTableManager get users =>
      $$UsersTableTableManager(_db, _db.users);
  $$CapturedImagesTableTableManager get capturedImages =>
      $$CapturedImagesTableTableManager(_db, _db.capturedImages);
  $$TimeAnchorsTableTableManager get timeAnchors =>
      $$TimeAnchorsTableTableManager(_db, _db.timeAnchors);
}
