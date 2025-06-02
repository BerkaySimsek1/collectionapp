import 'package:collectionapp/designElements/layouts/project_single_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../viewModels/payment_method_viewmodel.dart';

class AddPaymentMethodScreen extends StatelessWidget {
  const AddPaymentMethodScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PaymentMethodViewModel(),
      child: Consumer<PaymentMethodViewModel>(
        builder: (context, viewModel, child) {
          return ProjectSingleLayout(
            title: "Add Payment Method",
            subtitle: "Enter your card details",
            headerIcon: Icons.add_card,
            headerHeight: 250,
            isLoading: viewModel.isLoading,
            onPressed: () => viewModel.savePaymentMethod(context),
            buttonText: "Save Card",
            buttonIcon: Icons.payment_outlined,
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: viewModel.formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTextField(
                        controller: viewModel.nicknameController,
                        label: "Card Nickname",
                        icon: Icons.label_outline,
                        validator: (value) =>
                            value!.isEmpty ? "Required" : null,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: viewModel.cardHolderController,
                        label: "Card Holder Name",
                        icon: Icons.person_outline,
                        validator: (value) =>
                            value!.isEmpty ? "Required" : null,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: viewModel.cardNumberController,
                        label: "Card Number",
                        icon: Icons.credit_card,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(16),
                          _CardNumberFormatter(),
                        ],
                        validator: (value) => value!.length < 19
                            ? "Enter valid card number"
                            : null,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controller: viewModel.expiryController,
                              label: "MM/YY",
                              icon: Icons.date_range,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(4),
                                _CardDateFormatter(),
                              ],
                              validator: (value) =>
                                  value!.length < 5 ? "Enter valid date" : null,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildTextField(
                              controller: viewModel.cvvController,
                              label: "CVV",
                              icon: Icons.lock_outline,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(3),
                              ],
                              validator: (value) =>
                                  value!.length < 3 ? "Enter valid CVV" : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      SwitchListTile(
                        value: viewModel.isDefault,
                        onChanged: (value) {
                          viewModel.setIsDefault(value);
                        },
                        title: Text(
                          "Set as default payment method",
                          style: GoogleFonts.poppins(),
                        ),
                        activeColor: Colors.deepPurple,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.poppins(
            color: Colors.grey[600],
          ),
          prefixIcon: Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: Colors.deepPurple.withValues(alpha: 0.15),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                bottomLeft: Radius.circular(12),
              ),
            ),
            child: Icon(icon, color: Colors.deepPurple),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
        ),
        style: GoogleFonts.poppins(),
      ),
    );
  }
}

class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    String numbers = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
    String formatted = '';

    for (var i = 0; i < numbers.length; i++) {
      if (i > 0 && i % 4 == 0) {
        formatted += ' ';
      }
      formatted += numbers[i];
    }

    return newValue.copyWith(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class _CardDateFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String text = newValue.text;
    if (text.isEmpty) return newValue;

    String numbers = text.replaceAll(RegExp(r'[^\d]'), '');
    String formatted = '';

    if (numbers.length >= 2) {
      formatted = '${numbers.substring(0, 2)}/${numbers.substring(2)}';
    } else {
      formatted = numbers;
    }

    return newValue.copyWith(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
