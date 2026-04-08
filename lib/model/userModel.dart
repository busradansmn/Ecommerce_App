import 'package:hive/hive.dart';
part 'userModel.g.dart';

@HiveType(typeId: 5)
class UserModel {
  @HiveField(0)
  final int? id;
  @HiveField(1)
  final String? firstName;
  @HiveField(2)
  final String? lastName;
  @HiveField(3)
  final int? age;
  @HiveField(4)
  final String? gender;
  @HiveField(5)
  final String? username;
  @HiveField(6)
  final String? image;
  @HiveField(7)
  final String? role;

  final String? password;

  UserModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.age,
    required this.gender,
    required this.username,
    this.password,
    required this.image,
    required this.role,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: json["id"] as int?,
    firstName: json["firstName"] as String?,
    lastName: json["lastName"] as String?,
    age: json["age"] as int?,
    gender: json["gender"] as String?,
    username: json["username"] as String?,
    password: json["password"] as String?,
    image: json["image"] as String?,
    role: json["role"] as String?,
  );

  UserModel copyWith({
    int? id,
    String? firstName,
    String? lastName,
    int? age,
    String? gender,
    String? username,
    String? image,
    String? role,
    String? password,
  }) {
    return UserModel(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      username: username ?? this.username,
      image: image ?? this.image,
      role: role ?? this.role,
      password: password ?? this.password,
    );
  }
}
