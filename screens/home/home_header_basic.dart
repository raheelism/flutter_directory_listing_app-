import 'package:flutter/material.dart';
import 'package:listar_flutter_pro/models/model.dart';
import 'package:listar_flutter_pro/widgets/widget.dart';

class HomeHeaderBasic extends SliverPersistentHeaderDelegate {
  final double expandedHeight;
  final double minHeight;
  final List<String>? banners;
  final VoidCallback onSearch;
  final VoidCallback onScan;

  HomeHeaderBasic({
    required this.expandedHeight,
    required this.minHeight,
    required this.onSearch,
    required this.onScan,
    this.banners,
  });

  @override
  Widget build(context, shrinkOffset, overlapsContent) {
    return Container(
      color: Theme.of(context).cardColor,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Container(
            color: Theme.of(context).scaffoldBackgroundColor,
            child: Column(
              children: [
                Expanded(
                  child: Opacity(
                    opacity: (1 - shrinkOffset / minExtent).clamp(0.0, 1.0),
                    child: AppImageSwiper(
                      images: banners?.map((e) {
                        return ImageModel(id: 0, full: e, thumb: e);
                      }).toList(),
                      alignment: const Alignment(0.0, 0.7),
                    ),
                  ),
                ),
                SizedBox(height: 28),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
            child: AppSearchBar(
              onSearch: onSearch,
              onScan: onScan,
            ),
          ),
        ],
      ),
    );
  }

  @override
  double get maxExtent => expandedHeight;

  @override
  double get minExtent => minHeight;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) => true;
}
