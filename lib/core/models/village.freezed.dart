// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'village.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Village {

 String get id; String get name; String get nameEn; String get governorate; double? get latitude; double? get longitude; Map<String, bool> get phaseConfig; bool get featureKillSwitch; Map<String, dynamic> get stats; String get createdBy; DateTime get createdAt; DateTime get updatedAt; int get schemaVersion; bool get isActive;
/// Create a copy of Village
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VillageCopyWith<Village> get copyWith => _$VillageCopyWithImpl<Village>(this as Village, _$identity);

  /// Serializes this Village to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Village&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.nameEn, nameEn) || other.nameEn == nameEn)&&(identical(other.governorate, governorate) || other.governorate == governorate)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&const DeepCollectionEquality().equals(other.phaseConfig, phaseConfig)&&(identical(other.featureKillSwitch, featureKillSwitch) || other.featureKillSwitch == featureKillSwitch)&&const DeepCollectionEquality().equals(other.stats, stats)&&(identical(other.createdBy, createdBy) || other.createdBy == createdBy)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.schemaVersion, schemaVersion) || other.schemaVersion == schemaVersion)&&(identical(other.isActive, isActive) || other.isActive == isActive));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,nameEn,governorate,latitude,longitude,const DeepCollectionEquality().hash(phaseConfig),featureKillSwitch,const DeepCollectionEquality().hash(stats),createdBy,createdAt,updatedAt,schemaVersion,isActive);

@override
String toString() {
  return 'Village(id: $id, name: $name, nameEn: $nameEn, governorate: $governorate, latitude: $latitude, longitude: $longitude, phaseConfig: $phaseConfig, featureKillSwitch: $featureKillSwitch, stats: $stats, createdBy: $createdBy, createdAt: $createdAt, updatedAt: $updatedAt, schemaVersion: $schemaVersion, isActive: $isActive)';
}


}

/// @nodoc
abstract mixin class $VillageCopyWith<$Res>  {
  factory $VillageCopyWith(Village value, $Res Function(Village) _then) = _$VillageCopyWithImpl;
@useResult
$Res call({
 String id, String name, String nameEn, String governorate, double? latitude, double? longitude, Map<String, bool> phaseConfig, bool featureKillSwitch, Map<String, dynamic> stats, String createdBy, DateTime createdAt, DateTime updatedAt, int schemaVersion, bool isActive
});




}
/// @nodoc
class _$VillageCopyWithImpl<$Res>
    implements $VillageCopyWith<$Res> {
  _$VillageCopyWithImpl(this._self, this._then);

  final Village _self;
  final $Res Function(Village) _then;

/// Create a copy of Village
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? nameEn = null,Object? governorate = null,Object? latitude = freezed,Object? longitude = freezed,Object? phaseConfig = null,Object? featureKillSwitch = null,Object? stats = null,Object? createdBy = null,Object? createdAt = null,Object? updatedAt = null,Object? schemaVersion = null,Object? isActive = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,nameEn: null == nameEn ? _self.nameEn : nameEn // ignore: cast_nullable_to_non_nullable
as String,governorate: null == governorate ? _self.governorate : governorate // ignore: cast_nullable_to_non_nullable
as String,latitude: freezed == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double?,longitude: freezed == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double?,phaseConfig: null == phaseConfig ? _self.phaseConfig : phaseConfig // ignore: cast_nullable_to_non_nullable
as Map<String, bool>,featureKillSwitch: null == featureKillSwitch ? _self.featureKillSwitch : featureKillSwitch // ignore: cast_nullable_to_non_nullable
as bool,stats: null == stats ? _self.stats : stats // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,createdBy: null == createdBy ? _self.createdBy : createdBy // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,schemaVersion: null == schemaVersion ? _self.schemaVersion : schemaVersion // ignore: cast_nullable_to_non_nullable
as int,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [Village].
extension VillagePatterns on Village {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Village value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Village() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Village value)  $default,){
final _that = this;
switch (_that) {
case _Village():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Village value)?  $default,){
final _that = this;
switch (_that) {
case _Village() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String nameEn,  String governorate,  double? latitude,  double? longitude,  Map<String, bool> phaseConfig,  bool featureKillSwitch,  Map<String, dynamic> stats,  String createdBy,  DateTime createdAt,  DateTime updatedAt,  int schemaVersion,  bool isActive)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Village() when $default != null:
return $default(_that.id,_that.name,_that.nameEn,_that.governorate,_that.latitude,_that.longitude,_that.phaseConfig,_that.featureKillSwitch,_that.stats,_that.createdBy,_that.createdAt,_that.updatedAt,_that.schemaVersion,_that.isActive);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String nameEn,  String governorate,  double? latitude,  double? longitude,  Map<String, bool> phaseConfig,  bool featureKillSwitch,  Map<String, dynamic> stats,  String createdBy,  DateTime createdAt,  DateTime updatedAt,  int schemaVersion,  bool isActive)  $default,) {final _that = this;
switch (_that) {
case _Village():
return $default(_that.id,_that.name,_that.nameEn,_that.governorate,_that.latitude,_that.longitude,_that.phaseConfig,_that.featureKillSwitch,_that.stats,_that.createdBy,_that.createdAt,_that.updatedAt,_that.schemaVersion,_that.isActive);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String nameEn,  String governorate,  double? latitude,  double? longitude,  Map<String, bool> phaseConfig,  bool featureKillSwitch,  Map<String, dynamic> stats,  String createdBy,  DateTime createdAt,  DateTime updatedAt,  int schemaVersion,  bool isActive)?  $default,) {final _that = this;
switch (_that) {
case _Village() when $default != null:
return $default(_that.id,_that.name,_that.nameEn,_that.governorate,_that.latitude,_that.longitude,_that.phaseConfig,_that.featureKillSwitch,_that.stats,_that.createdBy,_that.createdAt,_that.updatedAt,_that.schemaVersion,_that.isActive);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Village implements Village {
  const _Village({required this.id, required this.name, required this.nameEn, required this.governorate, this.latitude, this.longitude, required final  Map<String, bool> phaseConfig, required this.featureKillSwitch, required final  Map<String, dynamic> stats, required this.createdBy, required this.createdAt, required this.updatedAt, required this.schemaVersion, required this.isActive}): _phaseConfig = phaseConfig,_stats = stats;
  factory _Village.fromJson(Map<String, dynamic> json) => _$VillageFromJson(json);

@override final  String id;
@override final  String name;
@override final  String nameEn;
@override final  String governorate;
@override final  double? latitude;
@override final  double? longitude;
 final  Map<String, bool> _phaseConfig;
@override Map<String, bool> get phaseConfig {
  if (_phaseConfig is EqualUnmodifiableMapView) return _phaseConfig;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_phaseConfig);
}

@override final  bool featureKillSwitch;
 final  Map<String, dynamic> _stats;
@override Map<String, dynamic> get stats {
  if (_stats is EqualUnmodifiableMapView) return _stats;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_stats);
}

@override final  String createdBy;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
@override final  int schemaVersion;
@override final  bool isActive;

/// Create a copy of Village
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VillageCopyWith<_Village> get copyWith => __$VillageCopyWithImpl<_Village>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$VillageToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Village&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.nameEn, nameEn) || other.nameEn == nameEn)&&(identical(other.governorate, governorate) || other.governorate == governorate)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&const DeepCollectionEquality().equals(other._phaseConfig, _phaseConfig)&&(identical(other.featureKillSwitch, featureKillSwitch) || other.featureKillSwitch == featureKillSwitch)&&const DeepCollectionEquality().equals(other._stats, _stats)&&(identical(other.createdBy, createdBy) || other.createdBy == createdBy)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.schemaVersion, schemaVersion) || other.schemaVersion == schemaVersion)&&(identical(other.isActive, isActive) || other.isActive == isActive));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,nameEn,governorate,latitude,longitude,const DeepCollectionEquality().hash(_phaseConfig),featureKillSwitch,const DeepCollectionEquality().hash(_stats),createdBy,createdAt,updatedAt,schemaVersion,isActive);

@override
String toString() {
  return 'Village(id: $id, name: $name, nameEn: $nameEn, governorate: $governorate, latitude: $latitude, longitude: $longitude, phaseConfig: $phaseConfig, featureKillSwitch: $featureKillSwitch, stats: $stats, createdBy: $createdBy, createdAt: $createdAt, updatedAt: $updatedAt, schemaVersion: $schemaVersion, isActive: $isActive)';
}


}

/// @nodoc
abstract mixin class _$VillageCopyWith<$Res> implements $VillageCopyWith<$Res> {
  factory _$VillageCopyWith(_Village value, $Res Function(_Village) _then) = __$VillageCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String nameEn, String governorate, double? latitude, double? longitude, Map<String, bool> phaseConfig, bool featureKillSwitch, Map<String, dynamic> stats, String createdBy, DateTime createdAt, DateTime updatedAt, int schemaVersion, bool isActive
});




}
/// @nodoc
class __$VillageCopyWithImpl<$Res>
    implements _$VillageCopyWith<$Res> {
  __$VillageCopyWithImpl(this._self, this._then);

  final _Village _self;
  final $Res Function(_Village) _then;

/// Create a copy of Village
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? nameEn = null,Object? governorate = null,Object? latitude = freezed,Object? longitude = freezed,Object? phaseConfig = null,Object? featureKillSwitch = null,Object? stats = null,Object? createdBy = null,Object? createdAt = null,Object? updatedAt = null,Object? schemaVersion = null,Object? isActive = null,}) {
  return _then(_Village(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,nameEn: null == nameEn ? _self.nameEn : nameEn // ignore: cast_nullable_to_non_nullable
as String,governorate: null == governorate ? _self.governorate : governorate // ignore: cast_nullable_to_non_nullable
as String,latitude: freezed == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double?,longitude: freezed == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double?,phaseConfig: null == phaseConfig ? _self._phaseConfig : phaseConfig // ignore: cast_nullable_to_non_nullable
as Map<String, bool>,featureKillSwitch: null == featureKillSwitch ? _self.featureKillSwitch : featureKillSwitch // ignore: cast_nullable_to_non_nullable
as bool,stats: null == stats ? _self._stats : stats // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,createdBy: null == createdBy ? _self.createdBy : createdBy // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,schemaVersion: null == schemaVersion ? _self.schemaVersion : schemaVersion // ignore: cast_nullable_to_non_nullable
as int,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
