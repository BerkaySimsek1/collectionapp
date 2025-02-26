class UserInfoModel {
  final int age;
  final String email;
  final String firstName;
  final String lastName;
  final String uid;
  final String username;
  final List<String> groups;
  final List<String> createdAuctions;
  final List<String> joinedAuctions;
  final List<String> followers;
  final List<String> following;
  final String profileImageUrl;
  final DateTime createdAt; // Oluşturma tarihi
  final DateTime lastActive; // Son aktivite tarihi

  UserInfoModel({
    required this.age,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.uid,
    required this.username,
    required this.groups,
    required this.createdAuctions,
    required this.joinedAuctions,
    required this.followers,
    required this.following,
    required this.profileImageUrl,
    DateTime? createdAt, // Opsiyonel parametre
    DateTime? lastActive, // Opsiyonel parametre
  })  : this.createdAt = createdAt ?? DateTime.now(),
        this.lastActive = lastActive ?? DateTime.now();

  factory UserInfoModel.fromJson(Map<String, dynamic> json) {
    // Timestamp veya milliseconds kontrolü
    DateTime getDateTime(dynamic value) {
      if (value == null) return DateTime.now();

      // Eğer bir sayı ise (millisecondsSinceEpoch)
      if (value is int) {
        return DateTime.fromMillisecondsSinceEpoch(value);
      }

      // Başka bir şekilde belirtilmişse (Firestore zaman damgası gibi)
      return DateTime.now();
    }

    return UserInfoModel(
      age: json["age"] ?? 0,
      email: json["email"] ?? "",
      firstName: json["firstName"] ?? "",
      lastName: json["lastName"] ?? "",
      uid: json["uid"] ?? "",
      username: json["username"] ?? "",
      groups: List<String>.from(json["groups"] ?? []),
      createdAuctions: List<String>.from(json["createdAuctions"] ?? []),
      joinedAuctions: List<String>.from(json["joinedAuctions"] ?? []),
      followers: List<String>.from(json["followers"] ?? []),
      following: List<String>.from(json["following"] ?? []),
      profileImageUrl: json["profileImageUrl"] ?? "",
      createdAt: getDateTime(json["createdAt"]),
      lastActive: getDateTime(json["lastActive"]),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "age": age,
      "email": email,
      "firstName": firstName,
      "lastName": lastName,
      "uid": uid,
      "username": username,
      "groups": groups,
      "createdAuctions": createdAuctions,
      "joinedAuctions": joinedAuctions,
      "followers": followers,
      "following": following,
      "profileImageUrl": profileImageUrl,
      "createdAt": createdAt.millisecondsSinceEpoch,
      "lastActive": lastActive.millisecondsSinceEpoch,
    };
  }

  // Kullanıcı etkinliğini güncelleyen yardımcı metot
  UserInfoModel updateLastActive() {
    return UserInfoModel(
      age: this.age,
      email: this.email,
      firstName: this.firstName,
      lastName: this.lastName,
      uid: this.uid,
      username: this.username,
      groups: this.groups,
      createdAuctions: this.createdAuctions,
      joinedAuctions: this.joinedAuctions,
      followers: this.followers,
      following: this.following,
      profileImageUrl: this.profileImageUrl,
      createdAt: this.createdAt,
      lastActive: DateTime.now(),
    );
  }
}
