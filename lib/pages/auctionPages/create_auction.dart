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
        backgroundColor: Colors.grey[100],
        appBar: const ProjectAppbar(
          titleText: "Create Auction",
        ),
        body: Consumer<AuctionCreateViewModel>(
          builder: (context, viewModel, child) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: viewModel.formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Auction Name Field
                            TextFormField(
                              controller: viewModel.nameController,
                              decoration: const InputDecoration(
                                labelText: "Auction Name",
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) => value!.isEmpty
                                  ? "This field is required"
                                  : null,
                            ),
                            const SizedBox(height: 10),
                            // Starting Price Field
                            TextFormField(
                              controller: viewModel.priceController,
                              decoration: const InputDecoration(
                                labelText: "Starting Price",
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) => value!.isEmpty
                                  ? "This field is required"
                                  : null,
                            ),
                            const SizedBox(height: 10),
                            // Duration Dropdown
                            DropdownButtonFormField<int>(
                              value: viewModel.selectedDays,
                              items: List.generate(10, (index) => index + 1)
                                  .map((day) => DropdownMenuItem(
                                        value: day,
                                        child: Text("$day days"),
                                      ))
                                  .toList(),
                              decoration: const InputDecoration(
                                labelText: "Duration",
                                border: OutlineInputBorder(),
                              ),
                              onChanged: (value) =>
                                  viewModel.updateDuration(value!),
                            ),
                            const SizedBox(height: 10),
                            // Description Field
                            TextFormField(
                              controller: viewModel.descriptionController,
                              decoration: const InputDecoration(
                                labelText: "Description",
                                border: OutlineInputBorder(),
                              ),
                              maxLines: 3,
                              validator: (value) => value!.isEmpty
                                  ? "This field is required"
                                  : null,
                            ),
                            const SizedBox(height: 20),
                            // Select Images Button
                            ElevatedButton.icon(
                              onPressed: () => viewModel.pickImages(context),
                              icon:
                                  const Icon(Icons.image, color: Colors.white),
                              label: const Text(
                                "Select Images",
                                style: ProjectTextStyles.buttonTextStyle,
                              ),
                              style: ProjectDecorations.elevatedButtonStyle,
                            ),
                            const SizedBox(height: 10),
                            // Selected Images Preview
                            Wrap(
                              spacing: 10,
                              children: viewModel.selectedImages
                                  .map((image) => Image.file(
                                        File(image.path),
                                        width: 100,
                                        height: 100,
                                        fit: BoxFit.cover,
                                      ))
                                  .toList(),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Upload Auction Button
                    ElevatedButton(
                      style: ProjectDecorations.elevatedButtonStyle,
                      onPressed: viewModel.isUploading
                          ? null
                          : () => viewModel.uploadAuction(context),
                      child: viewModel.isUploading
                          ? const CircularProgressIndicator()
                          : const Text(
                              "Upload Auction",
                              style: TextStyle(color: Colors.white),
                            ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
