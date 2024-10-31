class AuctionModel {
  String id;
  String name;
  double startingPrice;
  String creatorId;
  String bidderId;
  DateTime endTime; // Açık artırmanın biteceği zaman
  String description;
  String imageUrl;

  AuctionModel({
    required this.id,
    required this.name,
    required this.startingPrice,
    required this.creatorId,
    this.bidderId = '', // Başlangıçta boş olacak
    required this.endTime,
    required this.description,
    required this.imageUrl,
  });

  // Firestore'a eklemek için veriyi Map'e dönüştürme
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'starting_price': startingPrice,
      'creator_id': creatorId,
      'bidder_id': bidderId,
      'end_time': endTime.millisecondsSinceEpoch,
      'description': description,
      'image_url': imageUrl,
      'created_at': DateTime.now().millisecondsSinceEpoch,
    };
  }

  // Firestore'dan veriyi alırken AuctionModel'e dönüştürme
  factory AuctionModel.fromMap(Map<String, dynamic> map) {
    return AuctionModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      startingPrice: map['starting_price']?.toDouble() ?? 0.0,
      creatorId: map['creator_id'] ?? '',
      bidderId: map['bidder_id'] ?? '',
      endTime: DateTime.fromMillisecondsSinceEpoch(map['end_time'] ?? 0),
      description: map['description'] ?? '',
      imageUrl: map['image_url'] ?? '',
    );
  }
}
