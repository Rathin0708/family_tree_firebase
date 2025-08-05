import 'package:equatable/equatable.dart';

class Family extends Equatable {
  final String id;
  final String name;
  final String createdBy;
  final DateTime createdAt;
  final List<String> memberIds;
  final Map<String, DateTime> memberJoinDates;
  final String? currentInviteCode;
  final DateTime? inviteCodeExpiresAt;

  const Family({
    required this.id,
    required this.name,
    required this.createdBy,
    required this.createdAt,
    this.memberIds = const [],
    this.memberJoinDates = const {},
    this.currentInviteCode,
    this.inviteCodeExpiresAt,
  });

  /// Creates a copy of this family with the given fields replaced with the new values
  Family copyWith({
    String? id,
    String? name,
    String? createdBy,
    DateTime? createdAt,
    List<String>? memberIds,
    Map<String, DateTime>? memberJoinDates,
    String? currentInviteCode,
    DateTime? inviteCodeExpiresAt,
  }) {
    return Family(
      id: id ?? this.id,
      name: name ?? this.name,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      memberIds: memberIds ?? this.memberIds,
      memberJoinDates: memberJoinDates ?? this.memberJoinDates,
      currentInviteCode: currentInviteCode ?? this.currentInviteCode,
      inviteCodeExpiresAt: inviteCodeExpiresAt ?? this.inviteCodeExpiresAt,
    );
  }

  /// Converts the family to a map for serialization
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'createdBy': createdBy,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'memberIds': memberIds,
      'memberJoinDates': {
        for (var entry in memberJoinDates.entries)
          entry.key: entry.value.millisecondsSinceEpoch,
      },
      'currentInviteCode': currentInviteCode,
      'inviteCodeExpiresAt': inviteCodeExpiresAt?.millisecondsSinceEpoch,
    };
  }

  /// Creates a family from a map (deserialization)
  factory Family.fromJson(Map<String, dynamic> json) {
    return Family(
      id: json['id'] as String,
      name: json['name'] as String,
      createdBy: json['createdBy'] as String,
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt'] as int),
      memberIds: List<String>.from(json['memberIds'] as List),
      memberJoinDates: (json['memberJoinDates'] as Map<String, dynamic>).map(
        (key, value) => MapEntry(key, DateTime.fromMillisecondsSinceEpoch(value as int)),
      ),
      currentInviteCode: json['currentInviteCode'] as String?,
      inviteCodeExpiresAt: json['inviteCodeExpiresAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['inviteCodeExpiresAt'] as int)
          : null,
    );
  }

  /// Checks if the invite code is expired
  bool get isInviteCodeExpired {
    if (inviteCodeExpiresAt == null) return true;
    return DateTime.now().isAfter(inviteCodeExpiresAt!);
  }

  /// Gets the number of members in the family
  int get memberCount => memberIds.length;

  /// Checks if a user is a member of this family
  bool isMember(String userId) => memberIds.contains(userId);

  /// Gets the join date of a member
  DateTime? getMemberJoinDate(String userId) => memberJoinDates[userId];

  @override
  List<Object?> get props => [
        id,
        name,
        createdBy,
        createdAt,
        memberIds,
        memberJoinDates,
        currentInviteCode,
        inviteCodeExpiresAt,
      ];
}
