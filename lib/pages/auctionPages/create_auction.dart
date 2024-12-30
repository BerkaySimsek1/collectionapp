import "dart:io";
import "package:collectionapp/design_elements.dart";
import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "package:collectionapp/viewModels/auction_create_viewmodel.dart";

class AuctionUploadScreen extends StatelessWidget {
  const AuctionUploadScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuctionCreateViewModel(),
      child: Scaffold(
        backgroundColor: Colors.grey[200],
        appBar: const ProjectAppbar(
          titleText: "Create Auction",
        ),
        body: Consumer<AuctionCreateViewModel>(
          builder: (context, viewModel, child) {
            return Column(
              children: [
                // Header Section
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.deepPurple.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.gavel,
                          color: Colors.deepPurple,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Create New Auction",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.deepPurple,
                              ),
                            ),
                            Text(
                              "Fill in the details below to create your auction",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Form Section
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Form(
                        key: viewModel.formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Images Section
                            Card(
                              color: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Center(
                                  child: Column(
                                    children: [
                                      const Text(
                                        "Auction Images",
                                        style: ProjectTextStyles
                                            .cardHeaderTextStyle,
                                      ),
                                      const SizedBox(height: 16),
                                      if (viewModel.selectedImages.isEmpty)
                                        Container(
                                          height: 200,
                                          decoration: BoxDecoration(
                                            color: Colors.grey[100],
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            border: Border.all(
                                              color: Colors.black,
                                              width: 2,
                                              style: BorderStyle.none,
                                            ),
                                          ),
                                          child: InkWell(
                                            onTap: () =>
                                                _showImageSourceActionSheet(
                                                    context, viewModel),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons
                                                      .add_photo_alternate_outlined,
                                                  size: 48,
                                                  color: Colors.grey[400],
                                                ),
                                                const SizedBox(height: 8),
                                                Text(
                                                  "Add Images",
                                                  style: TextStyle(
                                                    color: Colors.grey[600],
                                                    fontSize: 16,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        )
                                      else
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            SizedBox(
                                              height: 120,
                                              child: ListView.builder(
                                                scrollDirection:
                                                    Axis.horizontal,
                                                itemCount: viewModel
                                                        .selectedImages.length +
                                                    1,
                                                itemBuilder: (context, index) {
                                                  if (index ==
                                                      viewModel.selectedImages
                                                          .length) {
                                                    return Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 8),
                                                      child: InkWell(
                                                        onTap: () =>
                                                            _showImageSourceActionSheet(
                                                                context,
                                                                viewModel),
                                                        child: Container(
                                                          width: 120,
                                                          decoration:
                                                              BoxDecoration(
                                                            color: Colors
                                                                .grey[100],
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        12),
                                                            border: Border.all(
                                                              color: Colors
                                                                  .grey[300]!,
                                                              style: BorderStyle
                                                                  .none,
                                                            ),
                                                          ),
                                                          child: const Icon(
                                                            Icons.add,
                                                            color: Colors.grey,
                                                          ),
                                                        ),
                                                      ),
                                                    );
                                                  }
                                                  return Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            right: 8),
                                                    child: ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              12),
                                                      child: Stack(
                                                        children: [
                                                          Image.file(
                                                            File(viewModel
                                                                .selectedImages[
                                                                    index]
                                                                .path),
                                                            width: 120,
                                                            height: 120,
                                                            fit: BoxFit.cover,
                                                          ),
                                                          Positioned(
                                                            top: 4,
                                                            right: 4,
                                                            child: Container(
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: Colors
                                                                    .black
                                                                    .withOpacity(
                                                                        0.5),
                                                                shape: BoxShape
                                                                    .circle,
                                                              ),
                                                              child: IconButton(
                                                                icon:
                                                                    const Icon(
                                                                  Icons.close,
                                                                  color: Colors
                                                                      .white,
                                                                  size: 20,
                                                                ),
                                                                onPressed: () {
                                                                  // Remove image logic
                                                                },
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Details Card
                            Card(
                              color: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "Auction Details",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    _buildTextField(
                                      controller: viewModel.nameController,
                                      label: "Auction Name",
                                      icon: Icons.title,
                                      validator: (value) => value!.isEmpty
                                          ? "This field is required"
                                          : null,
                                    ),
                                    const SizedBox(height: 16),
                                    _buildTextField(
                                      controller: viewModel.priceController,
                                      label: "Starting Price",
                                      icon: Icons.attach_money,
                                      keyboardType: TextInputType.number,
                                      validator: (value) => value!.isEmpty
                                          ? "This field is required"
                                          : null,
                                    ),
                                    const SizedBox(height: 16),
                                    _buildDurationDropdown(viewModel),
                                    const SizedBox(height: 16),
                                    _buildTextField(
                                      controller:
                                          viewModel.descriptionController,
                                      label: "Description",
                                      icon: Icons.description,
                                      maxLines: 3,
                                      validator: (value) => value!.isEmpty
                                          ? "This field is required"
                                          : null,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
        bottomNavigationBar: Consumer<AuctionCreateViewModel>(
          builder: (context, viewModel, child) {
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: viewModel.isUploading
                    ? null
                    : () => viewModel.uploadAuction(context),
                child: viewModel.isUploading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        "Create Auction",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    int? maxLines,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines ?? 1,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.deepPurple),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.deepPurple),
        ),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      validator: validator,
    );
  }

  Widget _buildDurationDropdown(AuctionCreateViewModel viewModel) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey[50],
      ),
      child: DropdownButtonFormField<int>(
        dropdownColor: Colors.white,
        borderRadius: BorderRadius.circular(8),
        value: viewModel.selectedDays,
        items: List.generate(10, (index) => index + 1)
            .map((day) => DropdownMenuItem(
                  value: day,
                  child: Text("$day days"),
                ))
            .toList(),
        decoration: const InputDecoration(
          labelText: "Duration",
          prefixIcon: Icon(Icons.timer, color: Colors.deepPurple),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
        onChanged: (value) => viewModel.updateDuration(value!),
      ),
    );
  }

  void _showImageSourceActionSheet(
      BuildContext context, AuctionCreateViewModel viewModel) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.of(context).pop();
                  viewModel.pickImages(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take a Photo'),
                onTap: () {
                  Navigator.of(context).pop();
                  viewModel.pickImageFromCamera(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Image source action sheet method remains the same
}
