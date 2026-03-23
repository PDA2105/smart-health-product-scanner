import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_health_product_scanner/data/models/product_model.dart';
import 'package:smart_health_product_scanner/data/repositories/product_repository.dart';
import 'package:smart_health_product_scanner/features/scan/presentation/providers/scan_history_provider.dart';
import 'package:smart_health_product_scanner/routes/app_routes.dart';

class ProductAlternativesPage extends StatefulWidget {
  const ProductAlternativesPage({
    super.key,
    required this.currentProduct,
  });

  final ProductModel currentProduct;

  @override
  State<ProductAlternativesPage> createState() => _ProductAlternativesPageState();
}

class _ProductAlternativesPageState extends State<ProductAlternativesPage> {
  late Future<List<_AlternativeItem>> _alternativesFuture;

  @override
  void initState() {
    super.initState();
    _alternativesFuture = _loadAlternatives();
  }

  Future<List<_AlternativeItem>> _loadAlternatives() async {
    final repo = context.read<ProductRepository>();
    final scanProvider = context.read<ScanHistoryProvider>();

    if (scanProvider.scanHistory.isEmpty) {
      await scanProvider.loadScanHistory();
    }

    final currentRank = _nutriscoreRank(widget.currentProduct.nutriscore);

    final fromHistory = <_AlternativeItem>[];
    for (final item in scanProvider.scanHistory) {
      final rank = _nutriscoreRank(item.nutriscore);
      if (item.barcode == widget.currentProduct.barcode) continue;
      if (rank >= currentRank) continue;

      fromHistory.add(
        _AlternativeItem(
          barcode: item.barcode,
          name: item.productName,
          imageUrl: item.productImage,
          brands: item.brands,
          nutriscore: item.nutriscore,
          source: _AlternativeSource.scanHistory,
        ),
      );
    }

    final fromCacheProducts =
        await repo.getHealthierAlternatives(widget.currentProduct, limit: 18);

    final fromCache = fromCacheProducts
        .map(
          (p) => _AlternativeItem(
            barcode: p.barcode,
            name: p.name ?? 'Sản phẩm chưa có tên',
            imageUrl: p.imageUrl,
            brands: p.brands,
            nutriscore: p.nutriscore,
            source: _AlternativeSource.cache,
          ),
        )
        .toList();

    final merged = <String, _AlternativeItem>{};
    for (final item in fromHistory) {
      merged[item.barcode] = item;
    }
    for (final item in fromCache) {
      merged.putIfAbsent(item.barcode, () => item);
    }

    final result = merged.values.toList()
      ..sort((a, b) {
        final rankCompare =
            _nutriscoreRank(a.nutriscore).compareTo(_nutriscoreRank(b.nutriscore));
        if (rankCompare != 0) return rankCompare;
        if (a.source != b.source) {
          if (a.source == _AlternativeSource.scanHistory) return -1;
          return 1;
        }
        return a.name.compareTo(b.name);
      });

    return result.take(20).toList();
  }

  Future<void> _openProduct(String barcode) async {
    try {
      final product = await context.read<ProductRepository>().getProductByBarcode(
        barcode,
        forceRefresh: false,
      );

      if (!mounted) return;
      if (product == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không thể tải thông tin sản phẩm.')),
        );
        return;
      }

      context.navigateToProductDetail(product);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không thể mở chi tiết sản phẩm lúc này.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FBF9),
      appBar: AppBar(
        title: const Text('Sản phẩm thay thế'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 1,
      ),
      body: FutureBuilder<List<_AlternativeItem>>(
        future: _alternativesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, size: 44, color: Colors.redAccent),
                    const SizedBox(height: 10),
                    const Text(
                      'Không thể tải gợi ý thay thế lúc này.',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          final alternatives = snapshot.data ?? const <_AlternativeItem>[];

          return RefreshIndicator(
            onRefresh: () async {
              setState(() {
                _alternativesFuture = _loadAlternatives();
              });
              await _alternativesFuture;
            },
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
              children: [
                _CurrentProductCard(product: widget.currentProduct),
                const SizedBox(height: 14),
                if (alternatives.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Column(
                      children: [
                        Icon(Icons.auto_awesome, size: 40, color: Color(0xFF2ECC71)),
                        SizedBox(height: 10),
                        Text(
                          'Chưa tìm thấy sản phẩm thay thế tốt hơn trong dữ liệu hiện có.',
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Hãy quét thêm sản phẩm để nhận gợi ý chính xác hơn.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.black54),
                        ),
                      ],
                    ),
                  )
                else ...[
                  Text(
                    'Gợi ý tốt hơn (${alternatives.length})',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 10),
                  ...alternatives.map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _AlternativeCard(
                        item: item,
                        onTap: () => _openProduct(item.barcode),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  int _nutriscoreRank(String? score) {
    switch ((score ?? '').toLowerCase()) {
      case 'a':
        return 1;
      case 'b':
        return 2;
      case 'c':
        return 3;
      case 'd':
        return 4;
      case 'e':
        return 5;
      default:
        return 99;
    }
  }
}

enum _AlternativeSource { scanHistory, cache }

class _AlternativeItem {
  const _AlternativeItem({
    required this.barcode,
    required this.name,
    required this.imageUrl,
    required this.brands,
    required this.nutriscore,
    required this.source,
  });

  final String barcode;
  final String name;
  final String? imageUrl;
  final String? brands;
  final String? nutriscore;
  final _AlternativeSource source;
}

class _CurrentProductCard extends StatelessWidget {
  const _CurrentProductCard({required this.product});

  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFDFE8E3)),
      ),
      child: Row(
        children: [
          _ProductImage(imageUrl: product.imageUrl),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Sản phẩm hiện tại',
                  style: TextStyle(fontSize: 12, color: Colors.black54),
                ),
                const SizedBox(height: 4),
                Text(
                  product.name ?? 'Sản phẩm không có tên',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                if ((product.brands ?? '').isNotEmpty)
                  Text(
                    product.brands!,
                    style: const TextStyle(color: Colors.black54, fontSize: 12),
                  ),
              ],
            ),
          ),
          _ScoreChip(score: product.nutriscore),
        ],
      ),
    );
  }
}

class _AlternativeCard extends StatelessWidget {
  const _AlternativeCard({required this.item, required this.onTap});

  final _AlternativeItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Color(0x12000000),
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            _ProductImage(imageUrl: item.imageUrl),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  if ((item.brands ?? '').isNotEmpty)
                    Text(
                      item.brands!,
                      style: const TextStyle(color: Colors.black54, fontSize: 12),
                    ),
                  const SizedBox(height: 6),
                  Text(
                    item.source == _AlternativeSource.scanHistory
                        ? 'Nguồn: Lịch sử quét của bạn'
                        : 'Nguồn: Kho dữ liệu đã quét',
                    style: const TextStyle(fontSize: 12, color: Color(0xFF2E7D32)),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            _ScoreChip(score: item.nutriscore),
          ],
        ),
      ),
    );
  }
}

class _ProductImage extends StatelessWidget {
  const _ProductImage({required this.imageUrl});

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 62,
      height: 62,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: const Color(0xFFEFF6F2),
      ),
      child: imageUrl == null
          ? const Icon(Icons.local_drink, color: Color(0xFF2ECC71))
          : ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.local_drink,
                  color: Color(0xFF2ECC71),
                ),
              ),
            ),
    );
  }
}

class _ScoreChip extends StatelessWidget {
  const _ScoreChip({required this.score});

  final String? score;

  @override
  Widget build(BuildContext context) {
    final value = (score ?? '?').toUpperCase();
    final color = _colorForScore(value);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.14),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 16,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          const Text(
            'Nutri',
            style: TextStyle(fontSize: 11, color: Colors.black54),
          ),
        ],
      ),
    );
  }

  Color _colorForScore(String value) {
    switch (value) {
      case 'A':
        return const Color(0xFF1E8E3E);
      case 'B':
        return const Color(0xFF34A853);
      case 'C':
        return const Color(0xFFF9AB00);
      case 'D':
        return const Color(0xFFFB8C00);
      case 'E':
        return const Color(0xFFEA4335);
      default:
        return Colors.grey;
    }
  }
}
