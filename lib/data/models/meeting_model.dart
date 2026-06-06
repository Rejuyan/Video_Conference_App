import 'dart:convert';

class MeetingModel {
  final String id;
  final String roomCode;
  final String subject;
  final DateTime timestamp;
  final bool isScheduled;
  final int durationMinutes;

  MeetingModel({
    required this.id,
    required this.roomCode,
    required this.subject,
    required this.timestamp,
    this.isScheduled = false,
    this.durationMinutes = 0,
  });

  MeetingModel copyWith({
    String? id,
    String? roomCode,
    String? subject,
    DateTime? timestamp,
    bool? isScheduled,
    int? durationMinutes,
  }) {
    return MeetingModel(
      id: id ?? this.id,
      roomCode: roomCode ?? this.roomCode,
      subject: subject ?? this.subject,
      timestamp: timestamp ?? this.timestamp,
      isScheduled: isScheduled ?? this.isScheduled,
      durationMinutes: durationMinutes ?? this.durationMinutes,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'roomCode': roomCode,
      'subject': subject,
      'timestamp': timestamp.toIso8601String(),
      'isScheduled': isScheduled,
      'durationMinutes': durationMinutes,
    };
  }

  factory MeetingModel.fromMap(Map<String, dynamic> map) {
    return MeetingModel(
      id: map['id'] ?? '',
      roomCode: map['roomCode'] ?? '',
      subject: map['subject'] ?? '',
      timestamp: DateTime.parse(map['timestamp'] ?? DateTime.now().toIso8601String()),
      isScheduled: map['isScheduled'] ?? false,
      durationMinutes: map['durationMinutes'] ?? 0,
    );
  }

  String toJson() => json.encode(toMap());

  factory MeetingModel.fromJson(String source) => MeetingModel.fromMap(json.decode(source));
}
