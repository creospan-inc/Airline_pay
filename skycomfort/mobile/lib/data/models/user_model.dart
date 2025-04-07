/// UserModel represents a user in the system
class UserModel {
  final int? id;
  final String username;
  final String name;
  final String email;
  final String flightId;
  final String seatNumber;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  
  const UserModel({
    this.id,
    required this.username,
    required this.name,
    required this.email,
    required this.flightId,
    required this.seatNumber,
    this.createdAt,
    this.updatedAt,
  });
  
  /// Create a copy of this user with updated fields
  UserModel copyWith({
    int? id,
    String? username,
    String? name,
    String? email,
    String? flightId,
    String? seatNumber,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      username: username ?? this.username,
      name: name ?? this.name,
      email: email ?? this.email,
      flightId: flightId ?? this.flightId,
      seatNumber: seatNumber ?? this.seatNumber,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
  
  /// Create a UserModel from a JSON map
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int?,
      username: json['username'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      flightId: json['flightId'] as String,
      seatNumber: json['seatNumber'] as String,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }
  
  /// Convert this UserModel to a JSON map
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'username': username,
      'name': name,
      'email': email,
      'flightId': flightId,
      'seatNumber': seatNumber,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
  }
  
  @override
  String toString() {
    return 'User: $name ($username)';
  }
} 