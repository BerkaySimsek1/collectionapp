import 'package:collectionapp/designElements/common_ui_methods.dart';
import 'package:collectionapp/designElements/layouts/project_single_layout.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:csc_picker/csc_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddAddressPage extends StatefulWidget {
  const AddAddressPage({super.key});

  @override
  State<AddAddressPage> createState() => _AddAddressPageState();
}

class _AddAddressPageState extends State<AddAddressPage> {
  final _formKey = GlobalKey<FormState>();
  String? countryValue;
  String? stateValue;
  String? cityValue;
  final _addressController = TextEditingController();
  final _addressTitleController = TextEditingController();
  bool _isLoading = false;

  Future<void> _saveAddress() async {
    if (_formKey.currentState!.validate() &&
        countryValue != null &&
        stateValue != null &&
        cityValue != null) {
      setState(() => _isLoading = true);
      try {
        final user = FirebaseAuth.instance.currentUser;
        await FirebaseFirestore.instance
            .collection('adresses')
            .doc(user!.uid)
            .set({
          'title': _addressTitleController.text,
          'country': countryValue,
          'state': stateValue,
          'city': cityValue,
          'detailedAddress': _addressController.text,
          'createdAt': Timestamp.now(),
        });

        if (mounted) {
          Navigator.pop(context, true); // Return true to indicate success
          projectSnackBar(context, "Address saved successfully", "green");
        }
      } catch (e) {
        if (mounted) {
          projectSnackBar(context, "Error saving address", "red");
        }
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ProjectSingleLayout(
      title: "Add New Address",
      subtitle: "Fill in your address details",
      headerIcon: Icons.location_on,
      isLoading: _isLoading,
      onPressed: _saveAddress,
      buttonText: "Save Address",
      buttonIcon: Icons.location_on_outlined,
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(1),
                  child: Column(
                    children: [
                      _buildTextField(
                        controller: _addressTitleController,
                        label: "Address Title",
                        icon: Icons.label_outline,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter an address title';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      CSCPicker(
                        showStates: true,
                        showCities: true,
                        flagState: CountryFlag.DISABLE,
                        dropdownDecoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey[300]!),
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        disabledDropdownDecoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey[300]!),
                          color: Colors.grey[200],
                        ),
                        selectedItemStyle: GoogleFonts.poppins(
                          color: Colors.deepPurple,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        dropdownHeadingStyle: GoogleFonts.poppins(
                          color: Colors.deepPurple,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        dropdownItemStyle: GoogleFonts.poppins(
                          color: Colors.grey[800],
                          fontSize: 14,
                        ),
                        dropdownDialogRadius: 16,
                        searchBarRadius: 16,
                        onCountryChanged: (country) {
                          setState(() => countryValue = country);
                        },
                        onStateChanged: (state) {
                          setState(() => stateValue = state);
                        },
                        onCityChanged: (city) {
                          setState(() => cityValue = city);
                        },
                        layout: Layout.vertical,
                        countrySearchPlaceholder: "Search country",
                        stateSearchPlaceholder: "Search state",
                        citySearchPlaceholder: "Search city",
                      ),
                      const SizedBox(height: 20),
                      _buildTextField(
                        controller: _addressController,
                        label: "Detailed Address",
                        icon: Icons.location_on_outlined,
                        maxLines: 3,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter detailed address';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int? maxLines,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
        maxLines: maxLines ?? 1,
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
                topLeft: Radius.circular(16),
                bottomLeft: Radius.circular(16),
              ),
            ),
            child: Icon(icon, color: Colors.deepPurple),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.all(16),
        ),
        validator: validator,
        style: GoogleFonts.poppins(),
      ),
    );
  }

  @override
  void dispose() {
    _addressController.dispose();
    _addressTitleController.dispose();
    super.dispose();
  }
}
