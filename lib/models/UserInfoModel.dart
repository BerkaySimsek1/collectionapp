class UserInfoModel {
  final int age;
  final String email;
  final String firstName;
  final String lastName;
  final String uid;
  final String username;
  final List<String> groups;
  final List<String> auctions;
  final List<String> followers;
  final List<String> following;

  UserInfoModel({
    required this.age,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.uid,
    required this.username,
    required this.groups,
    required this.auctions,
    required this.followers,
    required this.following,
  });

  // Firestore"dan veya JSON"dan veri almak için fromJson constructor
  factory UserInfoModel.fromJson(Map<String, dynamic> json) {
    return UserInfoModel(
      age: json["age"] ?? 0,
      email: json["email"] ?? "",
      firstName: json["firstName"] ?? "",
      lastName: json["lastName"] ?? "",
      uid: json["uid"] ?? "",
      username: json["username"] ?? "",
      groups: List<String>.from(json["groups"] ?? []),
      auctions: List<String>.from(json["auctions"] ?? []),
      followers: List<String>.from(json["followers"] ?? []),
      following: List<String>.from(json["following"] ?? []),
    );
  }

  // Firestore veya JSON"a veri göndermek için toJson metodu
  Map<String, dynamic> toJson() {
    return {
      "age": age,
      "email": email,
      "firstName": firstName,
      "lastName": lastName,
      "uid": uid,
      "username": username,
      "groups": groups,
      "auctions": auctions,
      "followers": followers,
      "following": following,
    };
  }
}
