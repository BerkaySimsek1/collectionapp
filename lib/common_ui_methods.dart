import 'package:flutter/material.dart';

class SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  SliverAppBarDelegate({
    required this.minHeight,
    required this.maxHeight,
    required this.child,
  });

  final double minHeight;
  final double maxHeight;
  final Widget child;

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => maxHeight;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(SliverAppBarDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }
}

IconData getIconForCollectionType(String type) {
  switch (type) {
    case 'Record':
      return Icons.album_outlined;
    case 'Stamp':
      return Icons.local_post_office_outlined;
    case 'Coin':
      return Icons.monetization_on_outlined;
    case 'Book':
      return Icons.menu_book_outlined;
    case 'Painting':
      return Icons.palette_outlined;
    case 'Comic Book':
      return Icons.auto_stories_outlined;
    case 'Vintage Posters':
      return Icons.image_outlined;
    case 'Diğer':
      return Icons.category_outlined;
    default:
      return Icons.category_outlined;
  }
}

Color getColorForCollectionType(String type) {
  switch (type) {
    case 'Record':
      return Colors.purple;
    case 'Stamp':
      return Colors.blue;
    case 'Coin':
      return Colors.amber;
    case 'Book':
      return Colors.green;
    case 'Painting':
      return Colors.orange;
    case 'Comic Book':
      return Colors.red;
    case 'Vintage Posters':
      return Colors.teal;
    default:
      return Colors.deepPurple;
  }
}
