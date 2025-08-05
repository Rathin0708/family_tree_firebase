import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:family_tree_firebase/features/family/domain/entities/family.dart';

class FamilyModel extends Family {
  const FamilyModel({
    required String id,
    required String name,
    required String createdBy,
    required DateTime createdAt,
    List<String> memberIds = const [],
    Map<String, DateTime> memberJoinDates = const {},
    String? currentInviteCode,
    DateTime? inviteCodeExpiresAt,
  }) : super(
          id: id,
          name: name,
          createdBy: createdBy,
          createdAt: createdAt,
          memberIds: memberIds,
          memberJoinDates: memberJoinDates,
          currentInviteCode: currentInviteCode,
          inviteCodeExpiresAt: inviteCodeExpiresAt,
        );

  /// Creates a FamilyModel from a JSON map
  factory FamilyModel.fromJson(Map<String, dynamic> json) {
    // Handle Timestamp to DateTime conversion
    final createdAt = json['createdAt'] is Timestamp
        ? (json['createdAt'] as Timestamp).toDate()
        : DateTime.parse(json['createdAt'].toString());

    // Handle member join dates
    final memberJoinDates = <String, DateTime>{};
    if (json['memberJoinDates'] != null) {
      (json['memberJoinDates'] as Map<String, dynamic>).forEach((key, value) {
        memberJoinDates[key] = value is Timestamp
            ? value.toDate()
            : DateTime.parse(value.toString());
      });
    }

    // Handle invite code expiry
    DateTime? inviteCodeExpiresAt;
    if (json['inviteCodeExpiresAt'] != null) {
      inviteCodeExpiresAt = json['inviteCodeExpiresAt'] is Timestamp
          ? (json['inviteCodeExpiresAt'] as Timestamp).toDate()
          : DateTime.parse(json['inviteCodeExpiresAt'].toString());
    }

    return FamilyModel(
      id: json['id'] as String,
      name: json['name'] as String,
      createdBy: json['createdBy'] as String,
      createdAt: createdAt,
      memberIds: List<String>.from(json['memberIds'] as List? ?? []),
      memberJoinDates: memberJoinDates,
      currentInviteCode: json['currentInviteCode'] as String?,
      inviteCodeExpiresAt: inviteCodeExpiresAt,
    );
  }

  /// Converts the FamilyModel to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
      'memberIds': memberIds,
      'memberJoinDates': {
        for (var entry in memberJoinDates.entries)
          entry.key: Timestamp.fromDate(entry.value),
      },
      'currentInviteCode': currentInviteCode,
      'inviteCodeExpiresAt': inviteCodeExpiresAt != null
          ? Timestamp.fromDate(inviteCodeExpiresAt!)
          : null,
    };
  }

  /// Creates a copy of this model with the given fields replaced with the new values
  @override
  FamilyModel copyWith({
    String? id,
    String? name,
    String? createdBy,
    DateTime? createdAt,
    List<String>? memberIds,
    Map<String, DateTime>? memberJoinDates,
    String? currentInviteCode,
    DateTime? inviteCodeExpiresAt,
  }) {
    return FamilyModel(
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
}
