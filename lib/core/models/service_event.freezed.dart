// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'service_event.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ServiceEvent {

 String get id; String get villageId; String get title; String get type; String get description; DateTime get startAt; DateTime get endAt; String get createdBy; DateTime? get deletedAt; int get schemaVersion; DateTime get createdAt; DateTime get updatedAt;
/// Create a copy of ServiceEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ServiceEventCopyWith<ServiceEvent> get copyWith => _$ServiceEventCopyWithImpl<ServiceEvent>(this as ServiceEvent, _$identity);

  /// Serializes this ServiceEvent to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ServiceEvent&&(identical(other.id, id) || other.id == id)&&(identical(other.villageId, villageId) || other.villageId == villageId)&&(identical(other.title, title) || other.title == title)&&(identical(other.type, type) || other.type == type)&&(identical(other.description, description) || other.description == description)&&(identical(other.startAt, startAt) || other.startAt == startAt)&&(identical(other.endAt, endAt) || other.endAt == endAt)&&(identical(other.createdBy, createdBy) || other.createdBy == createdBy)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt)&&(identical(other.schemaVersion, schemaVersion) || other.schemaVersion == schemaVersion)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,villageId,title,type,description,startAt,endAt,createdBy,deletedAt,schemaVersion,createdAt,updatedAt);

@override
String toString() {
  return 'ServiceEvent(id: $id, villageId: $villageId, title: $title, type: $type, description: $description, startAt: $startAt, endAt: $endAt, createdBy: $createdBy, deletedAt: $deletedAt, schemaVersion: $schemaVersion, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $ServiceEventCopyWith<$Res>  {
  factory $ServiceEventCopyWith(ServiceEvent value, $Res Function(ServiceEvent) _then) = _$ServiceEventCopyWithImpl;
@useResult
$Res call({
 String id, String villageId, String title, String type, String description, DateTime startAt, DateTime endAt, String createdBy, DateTime? deletedAt, int schemaVersion, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class _$ServiceEventCopyWithImpl<$Res>
    implements $ServiceEventCopyWith<$Res> {
  _$ServiceEventCopyWithImpl(this._self, this._then);

  final ServiceEvent _self;
  final $Res Function(ServiceEvent) _then;

/// Create a copy of ServiceEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? villageId = null,Object? title = null,Object? type = null,Object? description = null,Object? startAt = null,Object? endAt = null,Object? createdBy = null,Object? deletedAt = freezed,Object? schemaVersion = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,villageId: null == villageId ? _self.villageId : villageId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,startAt: null == startAt ? _self.startAt : startAt // ignore: cast_nullable_to_non_nullable
as DateTime,endAt: null == endAt ? _self.endAt : endAt // ignore: cast_nullable_to_non_nullable
as DateTime,createdBy: null == createdBy ? _self.createdBy : createdBy // ignore: cast_nullable_to_non_nullable
as String,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,schemaVersion: null == schemaVersion ? _self.schemaVersion : schemaVersion // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [ServiceEvent].
extension ServiceEventPatterns on ServiceEvent {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ServiceEvent value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ServiceEvent() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ServiceEvent value)  $default,){
final _that = this;
switch (_that) {
case _ServiceEvent():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ServiceEvent value)?  $default,){
final _that = this;
switch (_that) {
case _ServiceEvent() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String villageId,  String title,  String type,  String description,  DateTime startAt,  DateTime endAt,  String createdBy,  DateTime? deletedAt,  int schemaVersion,  DateTime createdAt,  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ServiceEvent() when $default != null:
return $default(_that.id,_that.villageId,_that.title,_that.type,_that.description,_that.startAt,_that.endAt,_that.createdBy,_that.deletedAt,_that.schemaVersion,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String villageId,  String title,  String type,  String description,  DateTime startAt,  DateTime endAt,  String createdBy,  DateTime? deletedAt,  int schemaVersion,  DateTime createdAt,  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _ServiceEvent():
return $default(_that.id,_that.villageId,_that.title,_that.type,_that.description,_that.startAt,_that.endAt,_that.createdBy,_that.deletedAt,_that.schemaVersion,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String villageId,  String title,  String type,  String description,  DateTime startAt,  DateTime endAt,  String createdBy,  DateTime? deletedAt,  int schemaVersion,  DateTime createdAt,  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _ServiceEvent() when $default != null:
return $default(_that.id,_that.villageId,_that.title,_that.type,_that.description,_that.startAt,_that.endAt,_that.createdBy,_that.deletedAt,_that.schemaVersion,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ServiceEvent implements ServiceEvent {
  const _ServiceEvent({required this.id, required this.villageId, required this.title, required this.type, required this.description, required this.startAt, required this.endAt, required this.createdBy, this.deletedAt, required this.schemaVersion, required this.createdAt, required this.updatedAt});
  factory _ServiceEvent.fromJson(Map<String, dynamic> json) => _$ServiceEventFromJson(json);

@override final  String id;
@override final  String villageId;
@override final  String title;
@override final  String type;
@override final  String description;
@override final  DateTime startAt;
@override final  DateTime endAt;
@override final  String createdBy;
@override final  DateTime? deletedAt;
@override final  int schemaVersion;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;

/// Create a copy of ServiceEvent
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ServiceEventCopyWith<_ServiceEvent> get copyWith => __$ServiceEventCopyWithImpl<_ServiceEvent>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ServiceEventToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ServiceEvent&&(identical(other.id, id) || other.id == id)&&(identical(other.villageId, villageId) || other.villageId == villageId)&&(identical(other.title, title) || other.title == title)&&(identical(other.type, type) || other.type == type)&&(identical(other.description, description) || other.description == description)&&(identical(other.startAt, startAt) || other.startAt == startAt)&&(identical(other.endAt, endAt) || other.endAt == endAt)&&(identical(other.createdBy, createdBy) || other.createdBy == createdBy)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt)&&(identical(other.schemaVersion, schemaVersion) || other.schemaVersion == schemaVersion)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,villageId,title,type,description,startAt,endAt,createdBy,deletedAt,schemaVersion,createdAt,updatedAt);

@override
String toString() {
  return 'ServiceEvent(id: $id, villageId: $villageId, title: $title, type: $type, description: $description, startAt: $startAt, endAt: $endAt, createdBy: $createdBy, deletedAt: $deletedAt, schemaVersion: $schemaVersion, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$ServiceEventCopyWith<$Res> implements $ServiceEventCopyWith<$Res> {
  factory _$ServiceEventCopyWith(_ServiceEvent value, $Res Function(_ServiceEvent) _then) = __$ServiceEventCopyWithImpl;
@override @useResult
$Res call({
 String id, String villageId, String title, String type, String description, DateTime startAt, DateTime endAt, String createdBy, DateTime? deletedAt, int schemaVersion, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class __$ServiceEventCopyWithImpl<$Res>
    implements _$ServiceEventCopyWith<$Res> {
  __$ServiceEventCopyWithImpl(this._self, this._then);

  final _ServiceEvent _self;
  final $Res Function(_ServiceEvent) _then;

/// Create a copy of ServiceEvent
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? villageId = null,Object? title = null,Object? type = null,Object? description = null,Object? startAt = null,Object? endAt = null,Object? createdBy = null,Object? deletedAt = freezed,Object? schemaVersion = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_ServiceEvent(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,villageId: null == villageId ? _self.villageId : villageId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,startAt: null == startAt ? _self.startAt : startAt // ignore: cast_nullable_to_non_nullable
as DateTime,endAt: null == endAt ? _self.endAt : endAt // ignore: cast_nullable_to_non_nullable
as DateTime,createdBy: null == createdBy ? _self.createdBy : createdBy // ignore: cast_nullable_to_non_nullable
as String,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,schemaVersion: null == schemaVersion ? _self.schemaVersion : schemaVersion // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
