import 'package:cloud_firestore/cloud_firestore.dart';

class PaymentMethod {
  final String id;
  final String userId;
  final String cardHolderName;
  final String cardNumber;
  final String expiryDate;
  final String cvv;
  final String cardNickname;
  final bool isDefault;
  final DateTime createdAt;

  PaymentMethod({
    required this.id,
    required this.userId,
    required this.cardHolderName,
    required this.cardNumber,
    required this.expiryDate,
    required this.cvv,
    required this.cardNickname,
    this.isDefault = false,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'cardHolderName': cardHolderName,
      'cardNumber': cardNumber,
      'expiryDate': expiryDate,
      'cvv': cvv,
      'cardNickname': cardNickname,
      'isDefault': isDefault,
      'createdAt': createdAt,
    };
  }

  factory PaymentMethod.fromSnapshot(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;
    return PaymentMethod(
      id: snapshot['id'],
      userId: snapshot['userId'],
      cardHolderName: snapshot['cardHolderName'],
      cardNumber: snapshot['cardNumber'],
      expiryDate: snapshot['expiryDate'],
      cvv: snapshot['cvv'],
      cardNickname: snapshot['cardNickname'],
      isDefault: snapshot['isDefault'],
      createdAt: (snapshot['createdAt'] as Timestamp).toDate(),
    );
  }
}
