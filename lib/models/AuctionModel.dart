class AuctionModel {
  String id;
  String name;
  double startingPrice;
  String creatorId;
  String bidderId;
  DateTime endTime;
  String description;
  List<String> imageUrls; // Tek resim yerine liste yapısına dönüştürdük
  bool isAuctionEnd;

  AuctionModel({
    required this.id,
    required this.name,
    required this.startingPrice,
    required this.creatorId,
    this.bidderId = "",
    required this.endTime,
    required this.description,
    required this.imageUrls,
    required this.isAuctionEnd,
  });

  // Firestore"a eklemek için veriyi Map"e dönüştürme
  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "name": name,
      "starting_price": startingPrice,
      "creator_id": creatorId,
      "bidder_id": bidderId,
      "end_time": endTime.millisecondsSinceEpoch,
      "description": description,
      "image_urls": imageUrls, // Liste olarak kaydediliyor
      "created_at": DateTime.now().millisecondsSinceEpoch,
      "isAuctionEnd": isAuctionEnd,
    };
  }

  // Firestore"dan veriyi alırken AuctionModel"e dönüştürme
  factory AuctionModel.fromMap(Map<String, dynamic> map) {
    return AuctionModel(
      id: map["id"] ?? "",
      name: map["name"] ?? "",
      startingPrice: map["starting_price"]?.toDouble() ?? 0.0,
      creatorId: map["creator_id"] ?? "",
      bidderId: map["bidder_id"] ?? "",
      endTime: DateTime.fromMillisecondsSinceEpoch(map["end_time"] ?? 0),
      description: map["description"] ?? "",
      imageUrls:
          List<String>.from(map["image_urls"] ?? []), // Listeye dönüştürme
      isAuctionEnd: map["isAuctionEnd"] ?? false,
    );
  }
}
