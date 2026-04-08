// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'household.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Household {

 String get id; String get villageId; String get ownerUid; String get name; int get householdSize; String get address; String get comment; double? get latitude; double? get longitude; String? get geohash; String? get qrTokenId; DateTime? get deletedAt; int get schemaVersion; DateTime get createdAt; DateTime get updatedAt;
/// Create a copy of Household
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HouseholdCopyWith<Household> get copyWith => _$HouseholdCopyWithImpl<Household>(this as Household, _$identity);

  /// Serializes this Household to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Household&&(identical(other.id, id) || other.id == id)&&(identical(other.villageId, villageId) || other.villageId == villageId)&&(identical(other.ownerUid, ownerUid) || other.ownerUid == ownerUid)&&(identical(other.name, name) || other.name == name)&&(identical(other.householdSize, householdSize) || other.householdSize == householdSize)&&(identical(other.address, address) || other.address == address)&&(identical(other.comment, comment) || other.comment == comment)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.geohash, geohash) || other.geohash == geohash)&&(identical(other.qrTokenId, qrTokenId) || other.qrTokenId == qrTokenId)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt)&&(identical(other.schemaVersion, schemaVersion) || other.schemaVersion == schemaVersion)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,villageId,ownerUid,name,householdSize,address,comment,latitude,longitude,geohash,qrTokenId,deletedAt,schemaVersion,createdAt,updatedAt);

@override
String toString() {
  return 'Household(id: $id, villageId: $villageId, ownerUid: $ownerUid, name: $name, householdSize: $householdSize, address: $address, comment: $comment, latitude: $latitude, longitude: $longitude, geohash: $geohash, qrTokenId: $qrTokenId, deletedAt: $deletedAt, schemaVersion: $schemaVersion, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $HouseholdCopyWith<$Res>  {
  factory $HouseholdCopyWith(Household value, $Res Function(Household) _then) = _$HouseholdCopyWithImpl;
@useResult
$Res call({
 String id, String villageId, String ownerUid, String name, int householdSize, String address, String comment, double? latitude, double? longitude, String? geohash, String? qrTokenId, DateTime? deletedAt, int schemaVersion, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class _$HouseholdCopyWithImpl<$Res>
    implements $HouseholdCopyWith<$Res> {
  _$HouseholdCopyWithImpl(this._self, this._then);

  final Household _self;
  final $Res Function(Household) _then;

/// Create a copy of Household
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? villageId = null,Object? ownerUid = null,Object? name = null,Object? householdSize = null,Object? address = null,Object? comment = null,Object? latitude = freezed,Object? longitude = freezed,Object? geohash = freezed,Object? qrTokenId = freezed,Object? deletedAt = freezed,Object? schemaVersion = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,villageId: null == villageId ? _self.villageId : villageId // ignore: cast_nullable_to_non_nullable
as String,ownerUid: null == ownerUid ? _self.ownerUid : ownerUid // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,householdSize: null == householdSize ? _self.householdSize : householdSize // ignore: cast_nullable_to_non_nullable
as int,address: null == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String,comment: null == comment ? _self.comment : comment // ignore: cast_nullable_to_non_nullable
as String,latitude: freezed == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double?,longitude: freezed == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double?,geohash: freezed == geohash ? _self.geohash : geohash // ignore: cast_nullable_to_non_nullable
as String?,qrTokenId: freezed == qrTokenId ? _self.qrTokenId : qrTokenId // ignore: cast_nullable_to_non_nullable
as String?,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,schemaVersion: null == schemaVersion ? _self.schemaVersion : schemaVersion // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [Household].
extension HouseholdPatterns on Household {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Household value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Household() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Household value)  $default,){
final _that = this;
switch (_that) {
case _Household():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Household value)?  $default,){
final _that = this;
switch (_that) {
case _Household() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String villageId,  String ownerUid,  String name,  int householdSize,  String address,  String comment,  double? latitude,  double? longitude,  String? geohash,  String? qrTokenId,  DateTime? deletedAt,  int schemaVersion,  DateTime createdAt,  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Household() when $default != null:
return $default(_that.id,_that.villageId,_that.ownerUid,_that.name,_that.householdSize,_that.address,_that.comment,_that.latitude,_that.longitude,_that.geohash,_that.qrTokenId,_that.deletedAt,_that.schemaVersion,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String villageId,  String ownerUid,  String name,  int householdSize,  String address,  String comment,  double? latitude,  double? longitude,  String? geohash,  String? qrTokenId,  DateTime? deletedAt,  int schemaVersion,  DateTime createdAt,  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _Household():
return $default(_that.id,_that.villageId,_that.ownerUid,_that.name,_that.householdSize,_that.address,_that.comment,_that.latitude,_that.longitude,_that.geohash,_that.qrTokenId,_that.deletedAt,_that.schemaVersion,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String villageId,  String ownerUid,  String name,  int householdSize,  String address,  String comment,  double? latitude,  double? longitude,  String? geohash,  String? qrTokenId,  DateTime? deletedAt,  int schemaVersion,  DateTime createdAt,  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _Household() when $default != null:
return $default(_that.id,_that.villageId,_that.ownerUid,_that.name,_that.householdSize,_that.address,_that.comment,_that.latitude,_that.longitude,_that.geohash,_that.qrTokenId,_that.deletedAt,_that.schemaVersion,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Household implements Household {
  const _Household({required this.id, required this.villageId, required this.ownerUid, required this.name, required this.householdSize, required this.address, required this.comment, this.latitude, this.longitude, this.geohash, this.qrTokenId, this.deletedAt, required this.schemaVersion, required this.createdAt, required this.updatedAt});
  factory _Household.fromJson(Map<String, dynamic> json) => _$HouseholdFromJson(json);

@override final  String id;
@override final  String villageId;
@override final  String ownerUid;
@override final  String name;
@override final  int householdSize;
@override final  String address;
@override final  String comment;
@override final  double? latitude;
@override final  double? longitude;
@override final  String? geohash;
@override final  String? qrTokenId;
@override final  DateTime? deletedAt;
@override final  int schemaVersion;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;

/// Create a copy of Household
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HouseholdCopyWith<_Household> get copyWith => __$HouseholdCopyWithImpl<_Household>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$HouseholdToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Household&&(identical(other.id, id) || other.id == id)&&(identical(other.villageId, villageId) || other.villageId == villageId)&&(identical(other.ownerUid, ownerUid) || other.ownerUid == ownerUid)&&(identical(other.name, name) || other.name == name)&&(identical(other.householdSize, householdSize) || other.householdSize == householdSize)&&(identical(other.address, address) || other.address == address)&&(identical(other.comment, comment) || other.comment == comment)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.geohash, geohash) || other.geohash == geohash)&&(identical(other.qrTokenId, qrTokenId) || other.qrTokenId == qrTokenId)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt)&&(identical(other.schemaVersion, schemaVersion) || other.schemaVersion == schemaVersion)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,villageId,ownerUid,name,householdSize,address,comment,latitude,longitude,geohash,qrTokenId,deletedAt,schemaVersion,createdAt,updatedAt);

@override
String toString() {
  return 'Household(id: $id, villageId: $villageId, ownerUid: $ownerUid, name: $name, householdSize: $householdSize, address: $address, comment: $comment, latitude: $latitude, longitude: $longitude, geohash: $geohash, qrTokenId: $qrTokenId, deletedAt: $deletedAt, schemaVersion: $schemaVersion, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$HouseholdCopyWith<$Res> implements $HouseholdCopyWith<$Res> {
  factory _$HouseholdCopyWith(_Household value, $Res Function(_Household) _then) = __$HouseholdCopyWithImpl;
@override @useResult
$Res call({
 String id, String villageId, String ownerUid, String name, int householdSize, String address, String comment, double? latitude, double? longitude, String? geohash, String? qrTokenId, DateTime? deletedAt, int schemaVersion, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class __$HouseholdCopyWithImpl<$Res>
    implements _$HouseholdCopyWith<$Res> {
  __$HouseholdCopyWithImpl(this._self, this._then);

  final _Household _self;
  final $Res Function(_Household) _then;

/// Create a copy of Household
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? villageId = null,Object? ownerUid = null,Object? name = null,Object? householdSize = null,Object? address = null,Object? comment = null,Object? latitude = freezed,Object? longitude = freezed,Object? geohash = freezed,Object? qrTokenId = freezed,Object? deletedAt = freezed,Object? schemaVersion = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_Household(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,villageId: null == villageId ? _self.villageId : villageId // ignore: cast_nullable_to_non_nullable
as String,ownerUid: null == ownerUid ? _self.ownerUid : ownerUid // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,householdSize: null == householdSize ? _self.householdSize : householdSize // ignore: cast_nullable_to_non_nullable
as int,address: null == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String,comment: null == comment ? _self.comment : comment // ignore: cast_nullable_to_non_nullable
as String,latitude: freezed == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double?,longitude: freezed == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double?,geohash: freezed == geohash ? _self.geohash : geohash // ignore: cast_nullable_to_non_nullable
as String?,qrTokenId: freezed == qrTokenId ? _self.qrTokenId : qrTokenId // ignore: cast_nullable_to_non_nullable
as String?,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,schemaVersion: null == schemaVersion ? _self.schemaVersion : schemaVersion // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
