import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/payment_method_model.dart';

class PaymentMethodViewModel extends ChangeNotifier {
  final formKey = GlobalKey<FormState>();
  final cardHolderController = TextEditingController();
  final cardNumberController = TextEditingController();
  final expiryController = TextEditingController();
  final cvvController = TextEditingController();
  final nicknameController = TextEditingController();
  bool isDefault = false;
  bool isLoading = false;

  void setIsDefault(bool value) {
    isDefault = value;
    notifyListeners();
  }

  Future<void> savePaymentMethod(BuildContext context) async {
    if (formKey.currentState!.validate()) {
      isLoading = true;
      notifyListeners();

      try {
        final userId = FirebaseAuth.instance.currentUser!.uid;
        final paymentMethod = PaymentMethod(
          id: const Uuid().v4(),
          userId: userId,
          cardHolderName: cardHolderController.text,
          cardNumber: cardNumberController.text,
          expiryDate: expiryController.text,
          cvv: cvvController.text,
          cardNickname: nicknameController.text,
          isDefault: isDefault,
          createdAt: DateTime.now(),
        );

        await FirebaseFirestore.instance
            .collection('paymentMethods')
            .doc(paymentMethod.id)
            .set(paymentMethod.toJson());

        if (context.mounted) {
          Navigator.pop(context);
        }
      } catch (e) {
        debugPrint(e.toString());
      }

      isLoading = false;
      notifyListeners();
    }
  }

  Stream<List<PaymentMethod>> getPaymentMethods() {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    return FirebaseFirestore.instance
        .collection('paymentMethods')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => PaymentMethod.fromSnapshot(doc))
            .toList());
  }

  @override
  void dispose() {
    cardHolderController.dispose();
    cardNumberController.dispose();
    expiryController.dispose();
    cvvController.dispose();
    nicknameController.dispose();
    super.dispose();
  }
}
