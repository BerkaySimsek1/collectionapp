import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AuctionViewModel with ChangeNotifier {
  String _filter = "all";
  String _sort = "newest";
  String _searchQuery = "";

  String get filter => _filter;
  String get sort => _sort;
  String get searchQuery => _searchQuery;

  void updateFilter(String newFilter) {
    _filter = newFilter;
    notifyListeners();
  }

  void updateSort(String newSort) {
    _sort = newSort;
    notifyListeners();
  }

  void updateSearchQuery(String newQuery) {
    _searchQuery = newQuery.toLowerCase();
    notifyListeners();
  }

  Stream<QuerySnapshot<Object?>> getAuctionStream() {
    Query query = FirebaseFirestore.instance.collection('auctions');

    // Filtreleme işlemleri
    if (_filter == "active") {
      // Açık artırmalar aktifse isAuctionEnd false olmalı
      query = query.where('isAuctionEnd', isEqualTo: false);
    } else if (_filter == "ended") {
      // Bitmiş açık artırmalar için isAuctionEnd true olmalı
      query = query.where('isAuctionEnd', isEqualTo: true);
    }

    return query.snapshots();
  }

  List<DocumentSnapshot> filterAuctions(List<DocumentSnapshot> auctionDocs) {
    if (_searchQuery.isEmpty) {
      return auctionDocs;
    }

    return auctionDocs.where((doc) {
      final name = doc['name'].toString().toLowerCase();
      return name.contains(_searchQuery);
    }).toList();
  }
}
