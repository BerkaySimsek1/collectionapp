import 'package:collectionapp/common_ui_methods.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:csc_picker/csc_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddressPage extends StatefulWidget {
  const AddressPage({super.key});

  @override
  State<AddressPage> createState() => _AddressPageState();
}

class _AddressPageState extends State<AddressPage> {
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
            .collection('users')
            .doc(user!.uid)
            .collection('addresses')
            .add({
          'title': _addressTitleController.text,
          'country': countryValue,
          'state': stateValue,
          'city': cityValue,
          'detailedAddress': _addressController.text,
          'createdAt': Timestamp.now(),
        });

        if (mounted) {
          Navigator.pop(context);
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
    return Scaffold(
      resizeToAvoidBottomInset: false, // Add this line
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const ProjectBackButton(),
      ),
      body: Stack(
        children: [
          // Gradient Header
          Positioned(
            top: 0,
            bottom: 40,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.deepPurple.shade400,
                    Colors.deepPurple.shade900,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 5, 24, 80),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.location_on,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Add New Address",
                              style: GoogleFonts.poppins(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              "Fill in your address details",
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                color: Colors.white.withOpacity(0.8),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -60,
            top: 250,
            left: 0,
            right: 0,
            child: Transform.translate(
              offset: const Offset(0, -60),
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: ListView(
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
                                    border:
                                        Border.all(color: Colors.grey[300]!),
                                    color: Colors.white,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  disabledDropdownDecoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    border:
                                        Border.all(color: Colors.grey[300]!),
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
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: buildBottomButton(
        isLoading: _isLoading,
        onPressed: () => _saveAddress(),
        buttonText: "Save Address",
        icon: Icons.location_on_outlined,
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
            color: Colors.black.withOpacity(0.05),
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
              color: Colors.deepPurple.withOpacity(0.1),
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
