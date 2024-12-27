import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AuctionViewModel with ChangeNotifier {
  String _filter = "all";
  String _sort = "newest";

  String get filter => _filter;
  String get sort => _sort;

  void updateFilter(String newFilter) {
    _filter = newFilter;
    notifyListeners();
  }

  void updateSort(String newSort) {
    _sort = newSort;
    notifyListeners();
  }

  Stream<QuerySnapshot> getAuctionStream() {
    final collection = FirebaseFirestore.instance.collection("auctions");
    Query query = collection;

    if (_filter == "active") {
      query = query.where("isAuctionEnd", isEqualTo: false);
    } else if (_filter == "ended") {
      query = query.where("isAuctionEnd", isEqualTo: true);
    }

    if (_sort == "newest") {
      query = query.orderBy("created_at", descending: true);
    } else if (_sort == "oldest") {
      query = query.orderBy("created_at", descending: false);
    } else if (_sort == "name_az") {
      query = query.orderBy("name", descending: false);
    } else if (_sort == "name_za") {
      query = query.orderBy("name", descending: true);
    }

    return query.snapshots();
  }
}
