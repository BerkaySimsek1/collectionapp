import 'package:cloud_firestore/cloud_firestore.dart';

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
  final DateTime createdAt;
  final DateTime lastActive;
  final bool isActive; // bool? yerine bool, default true olarak ayarlanacak
  final double? balance;

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
    DateTime? createdAt,
    DateTime? lastActive,
    this.isActive = true, // Varsayılan değer true olarak ayarlandı
    this.balance,
  })  : createdAt = createdAt ??
            DateTime.now(), // Eğer null gelirse şimdiki zamanı kullan
        lastActive = lastActive ??
            DateTime.now(); // Eğer null gelirse şimdiki zamanı kullan

  factory UserInfoModel.fromJson(Map<String, dynamic> json) {
    // Firestore'dan Timestamp objesini DateTime'a dönüştürür.
    // Eğer null gelirse veya farklı bir tipteyse DateTime.now() döner.
    DateTime _parseTimestamp(dynamic v) {
      if (v is Timestamp) return v.toDate();
      if (v is int) return DateTime.fromMillisecondsSinceEpoch(v);
      return DateTime.now();
    }

    // Balance'ı doğru bir şekilde Double'a dönüştürür.
    double? _parseBalance(dynamic value) {
      if (value == null) return null;
      if (value is num) return value.toDouble(); // int veya double olabilir
      return null;
    }

    return UserInfoModel(
      age: json["age"] as int? ?? 0, // int? olarak oku, nullsa 0
      email: json["email"] as String? ?? "", // String? olarak oku, nullsa ""
      firstName: json["firstName"] as String? ?? "",
      lastName: json["lastName"] as String? ?? "",
      uid: json["uid"] as String? ?? "",
      username: json["username"] as String? ?? "",
      // Listeleri boş bir liste ile başlatmak için null-check eklendi
      groups: List<String>.from(json["groups"] ?? []),
      createdAuctions: List<String>.from(json["createdAuctions"] ?? []),
      joinedAuctions: List<String>.from(json["joinedAuctions"] ?? []),
      followers: List<String>.from(json["followers"] ?? []),
      following: List<String>.from(json["following"] ?? []),
      profileImageUrl: json["profileImageUrl"] as String? ?? "",
      // createdAt ve lastActive için özel ayrıştırıcı kullan
      createdAt: _parseTimestamp(json['createdAt']),
      lastActive: _parseTimestamp(json['lastActive']),
      isActive:
          json["isActive"] as bool? ?? true, // Null ise varsayılan olarak true
      balance: _parseBalance(json["balance"]),
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
      // DateTime'ı Timestamp olarak kaydetmek için
      "createdAt": Timestamp.fromDate(createdAt),
      "lastActive": Timestamp.fromDate(lastActive),
      "isActive": isActive,
      "balance": balance,
    };
  }

  // copyWith metodu, mevcut modelin bir kopyasını oluştururken belirli alanları değiştirmeyi sağlar.
  UserInfoModel copyWith({
    int? age,
    String? email,
    String? firstName,
    String? lastName,
    String? uid,
    String? username,
    List<String>? groups,
    List<String>? createdAuctions,
    List<String>? joinedAuctions,
    List<String>? followers,
    List<String>? following,
    String? profileImageUrl,
    DateTime? createdAt,
    DateTime? lastActive,
    bool? isActive,
    double? balance,
  }) {
    return UserInfoModel(
      age: age ?? this.age,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      uid: uid ?? this.uid,
      username: username ?? this.username,
      groups: groups ?? this.groups,
      createdAuctions: createdAuctions ?? this.createdAuctions,
      joinedAuctions: joinedAuctions ?? this.joinedAuctions,
      followers: followers ?? this.followers,
      following: following ?? this.following,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      createdAt: createdAt ?? this.createdAt,
      lastActive: lastActive ?? this.lastActive,
      isActive: isActive ?? this.isActive,
      balance: balance ?? this.balance,
    );
  }

  // Kullanıcının son aktif olma tarihini güncelleyen yardımcı metot
  UserInfoModel updateLastActive() {
    return copyWith(lastActive: DateTime.now());
  }
}
