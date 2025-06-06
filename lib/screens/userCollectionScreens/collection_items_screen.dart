import 'dart:io';
import 'dart:async';
import 'package:collectionapp/designElements/common_ui_methods.dart';
import 'package:collectionapp/designElements/layouts/project_single_layout.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path_provider/path_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'item_details_screen.dart';
import 'add_item_screen.dart';

class CollectionItemsScreen extends StatefulWidget {
  final String userId;
  final String collectionName;

  const CollectionItemsScreen({
    super.key,
    required this.userId,
    required this.collectionName,
  });

  @override
  State<CollectionItemsScreen> createState() => _CollectionItemsScreenState();
}

class _CollectionItemsScreenState extends State<CollectionItemsScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;
  String _searchQuery = '';
  List<QueryDocumentSnapshot> _allItems = [];
  List<QueryDocumentSnapshot> _filteredItems = [];
  bool _isDataLoaded = false; // Track if data has been loaded initially

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          _searchQuery = _searchController.text.toLowerCase().trim();
          _filterItems();
        });
      }
    });
  }

  void _filterItems() {
    if (_searchQuery.isEmpty) {
      _filteredItems = List.from(_allItems);
    } else {
      _filteredItems = _allItems.where((item) {
        final data = item.data() as Map<String, dynamic>;
        final itemName = (data['İsim'] ?? '').toString().toLowerCase();
        final description = (data['Açıklama'] ?? '').toString().toLowerCase();
        final category = (data['Kategori'] ?? '').toString().toLowerCase();
        final brand = (data['Marka'] ?? '').toString().toLowerCase();

        return itemName.contains(_searchQuery) ||
            description.contains(_searchQuery) ||
            category.contains(_searchQuery) ||
            brand.contains(_searchQuery);
      }).toList();
    }
  }

  void _clearSearch() {
    _searchController.clear();
    if (mounted) {
      setState(() {
        _searchQuery = '';
        _filteredItems = List.from(_allItems);
      });
    }
  }

  Future<String> _ensureLocalCopy(String filePath) async {
    final appDir = await getApplicationDocumentsDirectory();
    final fileName = filePath.split("/").last;
    final newFilePath = "${appDir.path}/$fileName";

    final file = File(filePath);
    if (await file.exists()) {
      if (!await File(newFilePath).exists()) {
        await file.copy(newFilePath);
      }
      return newFilePath;
    } else {
      return "";
    }
  }

  @override
  Widget build(BuildContext context) {
    return ProjectSingleLayout(
      title: widget.collectionName,
      subtitle: "Collection Items",
      headerIcon: Icons.grid_view_rounded,
      isLoading: false,
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AddItemScreen(
              userId: widget.userId,
              collectionName: widget.collectionName,
            ),
          ),
        );
      },
      buttonText: "Add Item",
      buttonIcon: Icons.add,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SizedBox(
            height: constraints.maxHeight,
            child: Column(
              children: [
                // Enhanced Search Bar
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: _searchQuery.isNotEmpty
                            ? Colors.deepPurple.withValues(alpha: 0.5)
                            : Colors.grey[400]!,
                        width: _searchQuery.isNotEmpty ? 2 : 1,
                      ),
                      boxShadow: _searchQuery.isNotEmpty
                          ? [
                              BoxShadow(
                                color: Colors.deepPurple.withValues(alpha: 0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText:
                            "Search items by name, description, category...",
                        hintStyle: GoogleFonts.poppins(
                          color: Colors.grey[400],
                          fontSize: 14,
                        ),
                        prefixIcon: Icon(
                          Icons.search,
                          color: _searchQuery.isNotEmpty
                              ? Colors.deepPurple
                              : Colors.grey[400],
                        ),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: Icon(
                                  Icons.clear,
                                  color: Colors.grey[600],
                                ),
                                onPressed: _clearSearch,
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey[800],
                      ),
                    ),
                  ),
                ),

                // Search Results Info
                if (_searchQuery.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Found ${_filteredItems.length} item${_filteredItems.length != 1 ? 's' : ''} for "$_searchQuery"',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        const Spacer(),
                        if (_filteredItems.length != _allItems.length)
                          TextButton(
                            onPressed: _clearSearch,
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text(
                              'Show all',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.deepPurple,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                Expanded(
                  child: StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection("userCollections")
                        .doc(widget.userId)
                        .collection("collectionsList")
                        .doc(widget.collectionName)
                        .collection("items")
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting &&
                          !_isDataLoaded) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const CircularProgressIndicator(
                                color: Colors.deepPurple,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                "Loading items...",
                                style: GoogleFonts.poppins(
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        if (!_isDataLoaded) {
                          _isDataLoaded = true;
                        }
                        return buildEmptyState(
                          icon: Icons.grid_off,
                          title: "No items yet",
                          subtitle: "Add your first item to this collection",
                        );
                      }

                      // Only update items list if data has actually changed
                      final newItems = snapshot.data!.docs;
                      if (!_isDataLoaded ||
                          _allItems.length != newItems.length) {
                        _allItems = newItems;
                        _isDataLoaded = true;

                        // Only re-filter if we have a search query or if filteredItems is empty
                        if (_searchQuery.isNotEmpty || _filteredItems.isEmpty) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            _filterItems();
                          });
                        } else {
                          _filteredItems = List.from(_allItems);
                        }
                      }

                      // Show search results
                      final itemsToShow = _filteredItems;

                      if (_searchQuery.isNotEmpty && itemsToShow.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.search_off,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No items found',
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Try adjusting your search terms',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: Colors.grey[500],
                                ),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                onPressed: _clearSearch,
                                icon: const Icon(Icons.clear_all),
                                label: const Text('Clear search'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.deepPurple,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          physics: const BouncingScrollPhysics(),
                          itemCount: itemsToShow.length,
                          itemBuilder: (context, index) {
                            final item = itemsToShow[index];
                            final itemData =
                                item.data() as Map<String, dynamic>;
                            final photos = itemData["Photos"] as List<dynamic>?;
                            final itemName = itemData["İsim"] ?? "İsimsiz Ürün";

                            return FutureBuilder<String>(
                              future: photos != null && photos.isNotEmpty
                                  ? _ensureLocalCopy(photos[0])
                                  : Future.value(""),
                              builder: (context, fileSnapshot) {
                                if (fileSnapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return Container(
                                    height: 104,
                                    margin: const EdgeInsets.only(bottom: 16),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[100],
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: const Center(
                                      child: CircularProgressIndicator(
                                        color: Colors.deepPurple,
                                        strokeWidth: 2,
                                      ),
                                    ),
                                  );
                                }

                                final localPath = fileSnapshot.data ?? "";

                                return Container(
                                  margin: const EdgeInsets.only(bottom: 16),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    border: _searchQuery.isNotEmpty &&
                                            itemName
                                                .toLowerCase()
                                                .contains(_searchQuery)
                                        ? Border.all(
                                            color: Colors.deepPurple
                                                .withValues(alpha: 0.3),
                                            width: 2,
                                          )
                                        : null,
                                    boxShadow: [
                                      BoxShadow(
                                        color:
                                            Colors.black.withValues(alpha: 0.1),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Material(
                                    color: Colors.transparent,
                                    borderRadius: BorderRadius.circular(16),
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(16),
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                ItemDetailsScreen(
                                              userId: widget.userId,
                                              collectionName:
                                                  widget.collectionName,
                                              itemId: item.id,
                                            ),
                                          ),
                                        );
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.all(12),
                                        child: Row(
                                          children: [
                                            // Item Image
                                            Container(
                                              width: 80,
                                              height: 80,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black
                                                        .withValues(alpha: 0.1),
                                                    blurRadius: 8,
                                                    offset: const Offset(0, 2),
                                                  ),
                                                ],
                                              ),
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                child: photos != null &&
                                                        photos.isNotEmpty
                                                    ? Image.network(
                                                        photos[0].toString(),
                                                        fit: BoxFit.cover,
                                                        loadingBuilder: (context,
                                                            child,
                                                            loadingProgress) {
                                                          if (loadingProgress ==
                                                              null) {
                                                            return child;
                                                          }
                                                          return Container(
                                                            color: Colors
                                                                .grey[200],
                                                            child: Center(
                                                              child:
                                                                  CircularProgressIndicator(
                                                                color: Colors
                                                                    .deepPurple,
                                                                strokeWidth: 2,
                                                                value: loadingProgress
                                                                            .expectedTotalBytes !=
                                                                        null
                                                                    ? loadingProgress
                                                                            .cumulativeBytesLoaded /
                                                                        loadingProgress
                                                                            .expectedTotalBytes!
                                                                    : null,
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                        errorBuilder: (context,
                                                                error,
                                                                stackTrace) =>
                                                            Container(
                                                          color:
                                                              Colors.grey[200],
                                                          child: const Icon(
                                                            Icons.error_outline,
                                                            color: Colors.red,
                                                            size: 32,
                                                          ),
                                                        ),
                                                      )
                                                    : localPath.isNotEmpty
                                                        ? Image.file(
                                                            File(localPath),
                                                            fit: BoxFit.cover,
                                                          )
                                                        : Container(
                                                            color: Colors
                                                                .grey[200],
                                                            child: Icon(
                                                              Icons
                                                                  .image_outlined,
                                                              color: Colors
                                                                  .grey[400],
                                                              size: 32,
                                                            ),
                                                          ),
                                              ),
                                            ),
                                            const SizedBox(width: 16),

                                            // Item Details with highlighted search terms
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  RichText(
                                                    text: _buildHighlightedText(
                                                      itemName,
                                                      _searchQuery,
                                                      GoogleFonts.poppins(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: Colors.grey[800],
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    _searchQuery.isNotEmpty
                                                        ? "Matched search • Tap to view"
                                                        : "Tap to view details",
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 12,
                                                      color: _searchQuery
                                                              .isNotEmpty
                                                          ? Colors.deepPurple
                                                          : Colors.grey[600],
                                                      fontWeight: _searchQuery
                                                              .isNotEmpty
                                                          ? FontWeight.w500
                                                          : FontWeight.normal,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),

                                            // Arrow Icon
                                            Container(
                                              padding: const EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                color: Colors.deepPurple
                                                    .withValues(alpha: 0.1),
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Icon(
                                                Icons.arrow_forward_ios,
                                                color: Colors.deepPurple,
                                                size: 16,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Helper method to highlight search terms in text
  TextSpan _buildHighlightedText(String text, String query, TextStyle style) {
    if (query.isEmpty) {
      return TextSpan(text: text, style: style);
    }

    final lowerText = text.toLowerCase();
    final lowerQuery = query.toLowerCase();
    final List<TextSpan> spans = [];

    int start = 0;
    int index = lowerText.indexOf(lowerQuery, start);

    while (index >= 0) {
      // Add text before the match
      if (index > start) {
        spans.add(TextSpan(
          text: text.substring(start, index),
          style: style,
        ));
      }

      // Add highlighted match
      spans.add(TextSpan(
        text: text.substring(index, index + query.length),
        style: style.copyWith(
          backgroundColor: Colors.yellow.withValues(alpha: 0.3),
          fontWeight: FontWeight.bold,
        ),
      ));

      start = index + query.length;
      index = lowerText.indexOf(lowerQuery, start);
    }

    // Add remaining text
    if (start < text.length) {
      spans.add(TextSpan(
        text: text.substring(start),
        style: style,
      ));
    }

    return TextSpan(children: spans);
  }
}
