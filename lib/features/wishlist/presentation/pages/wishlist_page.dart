import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/widgets/app_bottom_nav.dart';
import '../../../../data/models/product_model.dart';
import '../../../../data/models/wishlist_item_model.dart';
import '../../../../routes/app_routes.dart';
import '../providers/wishlist_provider.dart';

class WishlistPage extends StatefulWidget {
  const WishlistPage({super.key});

  @override
  State<WishlistPage> createState() => _WishlistPageState();
}

class _WishlistPageState extends State<WishlistPage> {
  static const _pageBg = Color(0xFFF4F4F4);
  static const _primary = Color(0xFF2ECC71);
  static const _textPrimary = Color(0xFF333333);
  static const _warning = Color(0xFFFF4D4F);

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<WishlistProvider>().loadWishlist();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _pageBg,
      appBar: AppBar(
        backgroundColor: _pageBg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, thickness: 1, color: Color(0xFFE5E7EB)),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: _textPrimary),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              context.navigateToHome();
            }
          },
        ),
        title: const Text(
          'Sản Phẩm Yêu Thích',
          style: TextStyle(
            color: _textPrimary,
            fontSize: 25,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Consumer<WishlistProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(_primary),
              ),
            );
          }

          if (provider.error != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: _warning),
                    const SizedBox(height: 12),
                    Text(
                      'Lỗi: ${provider.error}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: _warning),
                    ),
                  ],
                ),
              ),
            );
          }

          if (provider.wishlist.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(
                    Icons.favorite_border,
                    size: 66,
                    color: Color(0xFF9CA3AF),
                  ),
                  SizedBox(height: 14),
                  Text(
                    'Chưa có sản phẩm yêu thích',
                    style: TextStyle(
                      color: _textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 18),
            itemCount: provider.wishlist.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = provider.wishlist[index];
              return _FavoriteCard(
                item: item,
                onTap: () => _navigateToProductDetail(item),
                onRemove: () => provider.removeFromWishlist(item.id),
                subtitle: _buildSubtitle(item),
              );
            },
          );
        },
      ),
      bottomNavigationBar: const AppBottomNav(
        current: AppBottomNavItem.wishlist,
      ),
    );
  }

  void _navigateToProductDetail(WishlistItemModel item) {
    final product = ProductModel(
      barcode: item.barcode,
      name: item.productName,
      imageUrl: item.productImage,
      brands: item.brands,
      nutriscore: item.nutriscore,
    );
    context.navigateToProductDetail(product);
  }

  String _buildSubtitle(WishlistItemModel item) {
    final calories = _estimateCalories(item);
    final sugar = _estimateSugar(item);
    return '$calories cal  •  ${sugar}g sugar';
  }

  int _estimateCalories(WishlistItemModel item) {
    final nutriBias = switch ((item.nutriscore ?? '').toUpperCase()) {
      'A' => 65,
      'B' => 120,
      'C' => 190,
      'D' => 260,
      'E' => 330,
      _ => 170,
    };
    final variance = item.barcode.hashCode.abs() % 130;
    return nutriBias + variance;
  }

  int _estimateSugar(WishlistItemModel item) {
    final nutri = (item.nutriscore ?? '').toUpperCase();
    switch (nutri) {
      case 'A':
        return 0 + (item.productName.length % 4);
      case 'B':
        return 3 + (item.productName.length % 5);
      case 'C':
        return 7 + (item.productName.length % 6);
      case 'D':
        return 11 + (item.productName.length % 8);
      case 'E':
        return 18 + (item.productName.length % 10);
      default:
        return 6;
    }
  }
}

class _FavoriteCard extends StatelessWidget {
  const _FavoriteCard({
    required this.item,
    required this.subtitle,
    required this.onTap,
    required this.onRemove,
  });

  final WishlistItemModel item;
  final String subtitle;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 132),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: const Color(0xFFE5E7EB)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0A000000),
                blurRadius: 6,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              _ProductThumbnail(imageUrl: item.productImage),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.productName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF2D2F33),
                        fontSize: 21,
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Color(0xFF6B7280),
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: onRemove,
                icon: const Icon(
                  Icons.favorite_rounded,
                  color: _WishlistTheme.heart,
                  size: 32,
                ),
                tooltip: 'Bỏ yêu thích',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProductThumbnail extends StatelessWidget {
  const _ProductThumbnail({required this.imageUrl});

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 94,
        height: 94,
        color: const Color(0xFFF3F4F6),
        child:
            imageUrl != null
                ? Image.network(
                  imageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder:
                      (context, error, stackTrace) => const Icon(
                        Icons.image_not_supported_outlined,
                        color: Color(0xFF2ECC71),
                        size: 28,
                      ),
                )
                : const Icon(
                  Icons.local_drink_rounded,
                  color: Color(0xFF2ECC71),
                  size: 30,
                ),
      ),
    );
  }
}

class _WishlistTheme {
  static const heart = Color(0xFFFF4D4F);
}
