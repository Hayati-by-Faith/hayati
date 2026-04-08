import 'package:freezed_annotation/freezed_annotation.dart';

part 'service_event.freezed.dart';
part 'service_event.g.dart';

@freezed
sealed class ServiceEvent with _$ServiceEvent {
  const factory ServiceEvent({
    required String id,
    required String villageId,
    required String title,
    required String type,
    required String description,
    required DateTime startAt,
    required DateTime endAt,
    required String createdBy,
    DateTime? deletedAt,
    required int schemaVersion,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _ServiceEvent;

  factory ServiceEvent.fromJson(Map<String, dynamic> json) => _$ServiceEventFromJson(json);
}
