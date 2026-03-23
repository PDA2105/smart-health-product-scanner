import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_health_product_scanner/data/models/health_profile.dart';
import 'package:smart_health_product_scanner/data/models/product_model.dart';
import 'package:smart_health_product_scanner/data/repositories/product_repository.dart';
import 'package:smart_health_product_scanner/features/auth/presentation/providers/auth_provider.dart';
import 'package:smart_health_product_scanner/features/profile/presentation/providers/profile_provider.dart';
import 'package:smart_health_product_scanner/features/scan/presentation/providers/scan_history_provider.dart';
import 'package:smart_health_product_scanner/features/wishlist/presentation/providers/wishlist_provider.dart';
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
  _HealthGoal? _selectedGoal;
  final Set<String> _savingWishlist = <String>{};
  final Set<String> _savedWishlist = <String>{};

  @override
  void initState() {
    super.initState();
    _alternativesFuture = _loadAlternatives();
  }

  Future<List<_AlternativeItem>> _loadAlternatives() async {
    final repo = context.read<ProductRepository>();
    final scanProvider = context.read<ScanHistoryProvider>();
    final profileProvider = context.read<ProfileProvider>();
    final authProvider = context.read<AuthProvider>();
    final wishlistProvider = context.read<WishlistProvider>();

    if (scanProvider.scanHistory.isEmpty) {
      await scanProvider.loadScanHistory();
    }

    final userId = authProvider.user?.uid;
    if (userId != null && userId.isNotEmpty && profileProvider.profile == null) {
      await profileProvider.loadProfile(userId);
    }

    if (wishlistProvider.wishlist.isEmpty) {
      await wishlistProvider.loadWishlist();
    }
    for (final item in wishlistProvider.wishlist) {
      _savedWishlist.add(item.barcode);
    }

    _selectedGoal ??= _inferHealthGoal(profileProvider.profile);

    final currentRank = _nutriscoreRank(widget.currentProduct.nutriscore);
    final fromHistory = <_AlternativeItem>[];

    for (final item in scanProvider.scanHistory) {
      if (item.barcode == widget.currentProduct.barcode) continue;

      final cachedProduct = await repo.getCachedProductByBarcode(item.barcode);
      final alternativeNutri = cachedProduct?.nutriscore ?? item.nutriscore;
      final rank = _nutriscoreRank(alternativeNutri);
      if (rank >= currentRank) continue;

      fromHistory.add(
        _AlternativeItem(
          barcode: item.barcode,
          name: (cachedProduct?.name ?? item.productName).trim().isEmpty
              ? 'Sản phẩm chưa có tên'
              : (cachedProduct?.name ?? item.productName),
          imageUrl: cachedProduct?.imageUrl ?? item.productImage,
          brands: cachedProduct?.brands ?? item.brands,
          nutriscore: alternativeNutri,
          nutriments: cachedProduct?.nutriments,
          source: _AlternativeSource.scanHistory,
          improvementSteps: currentRank - rank,
        ),
      );
    }

    final fromCacheProducts =
        await repo.getHealthierAlternatives(widget.currentProduct, limit: 20);

    final fromCache = fromCacheProducts
        .map(
          (p) => _AlternativeItem(
            barcode: p.barcode,
            name: (p.name ?? 'Sản phẩm chưa có tên').trim().isEmpty
                ? 'Sản phẩm chưa có tên'
                : (p.name ?? 'Sản phẩm chưa có tên'),
            imageUrl: p.imageUrl,
            brands: p.brands,
            nutriscore: p.nutriscore,
            nutriments: p.nutriments,
            source: _AlternativeSource.cache,
            improvementSteps: currentRank - _nutriscoreRank(p.nutriscore),
          ),
        )
        .toList();

    final merged = <String, _AlternativeItem>{};
    for (final item in fromHistory) {
      merged[item.barcode] = item;
    }
    for (final item in fromCache) {
      final existing = merged[item.barcode];
      if (existing == null) {
        merged[item.barcode] = item;
        continue;
      }
      if (existing.nutriments == null && item.nutriments != null) {
        merged[item.barcode] = existing.copyWith(
          nutriments: item.nutriments,
          nutriscore: existing.nutriscore ?? item.nutriscore,
          improvementSteps: existing.improvementSteps > 0
              ? existing.improvementSteps
              : item.improvementSteps,
        );
      }
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

    return result.take(24).toList();
  }

  Future<void> _openProduct(String barcode) async {
    try {
      final product = await context.read<ProductRepository>().getProductByBarcode(
        barcode,
        forceRefresh: false,
      );

      if (!mounted) return;
      if (product == null) {
        _showMessage('Không thể tải thông tin sản phẩm.');
        return;
      }

      context.navigateToProductDetail(product);
    } catch (_) {
      if (!mounted) return;
      _showMessage('Không thể mở chi tiết sản phẩm lúc này.');
    }
  }

  Future<void> _saveToWishlist(_AlternativeItem item) async {
    if (_savedWishlist.contains(item.barcode) || _savingWishlist.contains(item.barcode)) {
      return;
    }

    setState(() {
      _savingWishlist.add(item.barcode);
    });

    try {
      final productRepo = context.read<ProductRepository>();
      final wishlistProvider = context.read<WishlistProvider>();

      final product = await productRepo.getCachedProductByBarcode(item.barcode) ??
          await productRepo.getProductByBarcode(item.barcode, forceRefresh: false);

      if (!mounted) return;

      if (product == null) {
        _showMessage('Không thể lưu sản phẩm vào yêu thích lúc này.');
        return;
      }

      await wishlistProvider.addToWishlist(product);
      if (!mounted) return;

      final providerError = wishlistProvider.error;
      if (providerError != null && providerError.trim().isNotEmpty) {
        _showMessage(providerError.replaceFirst('Exception: ', ''));
        return;
      }

      setState(() {
        _savedWishlist.add(item.barcode);
      });
      _showMessage('Đã lưu vào danh sách yêu thích.');
    } catch (_) {
      if (!mounted) return;
      _showMessage('Không thể lưu sản phẩm vào yêu thích lúc này.');
    } finally {
      if (!mounted) return;
      setState(() {
        _savingWishlist.remove(item.barcode);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileProvider>().profile;
    final activeGoal = _selectedGoal ?? _inferHealthGoal(profile);

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
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.error_outline, size: 44, color: Colors.redAccent),
                    SizedBox(height: 10),
                    Text(
                      'Không thể tải gợi ý thay thế lúc này.',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          final allAlternatives = snapshot.data ?? const <_AlternativeItem>[];
          final filtered = _filterByGoal(allAlternatives, activeGoal);

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
                _buildGoalFilter(activeGoal),
                const SizedBox(height: 12),
                if (filtered.isEmpty)
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
                          'Chưa có gợi ý phù hợp với mục tiêu sức khỏe này.',
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Bạn có thể đổi bộ lọc hoặc quét thêm sản phẩm để có dữ liệu tốt hơn.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.black54),
                        ),
                      ],
                    ),
                  )
                else ...[
                  Text(
                    'Gợi ý phù hợp (${filtered.length})',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 10),
                  ...filtered.map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _AlternativeCard(
                        item: item,
                        reasons: _buildReasons(item, activeGoal),
                        isSaved: _savedWishlist.contains(item.barcode),
                        isSaving: _savingWishlist.contains(item.barcode),
                        onTap: () => _openProduct(item.barcode),
                        onSave: () => _saveToWishlist(item),
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

  Widget _buildGoalFilter(_HealthGoal activeGoal) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Lọc theo mục tiêu sức khỏe',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _HealthGoal.values.map((goal) {
              return ChoiceChip(
                label: Text(_goalLabel(goal)),
                selected: activeGoal == goal,
                onSelected: (_) {
                  setState(() {
                    _selectedGoal = goal;
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 6),
          Text(
            'Đang dùng bộ lọc: ${_goalLabel(activeGoal)}',
            style: const TextStyle(fontSize: 12, color: Colors.black54),
          ),
        ],
      ),
    );
  }

  List<_AlternativeItem> _filterByGoal(
    List<_AlternativeItem> items,
    _HealthGoal goal,
  ) {
    final filtered = items.where((item) {
      switch (goal) {
        case _HealthGoal.loseWeight:
          return _isLowerEnergy(item) ||
              _isLowerSugar(item) ||
              item.improvementSteps >= 2;
        case _HealthGoal.gainWeight:
          return _isHigherProtein(item) ||
              _isHigherEnergy(item) ||
              item.improvementSteps >= 2;
        case _HealthGoal.maintainWeight:
          return _isLowerSugar(item) ||
              _isLowerSalt(item) ||
              item.improvementSteps >= 1;
      }
    }).toList();

    return filtered;
  }

  List<String> _buildReasons(_AlternativeItem item, _HealthGoal goal) {
    final reasons = <String>[];

    if (item.improvementSteps > 0) {
      reasons.add('Nutri tốt hơn ${item.improvementSteps} bậc');
    }

    final sugarDiff = _currentSugar() - _itemSugar(item);
    if (sugarDiff > 0.5) {
      reasons.add('Ít đường hơn ${sugarDiff.toStringAsFixed(1)}g');
    }

    final saltDiff = _currentSalt() - _itemSalt(item);
    if (saltDiff > 0.05) {
      reasons.add('Ít muối hơn ${saltDiff.toStringAsFixed(2)}g');
    }

    if (goal == _HealthGoal.loseWeight) {
      final energyDiff = _currentEnergy() - _itemEnergy(item);
      if (energyDiff > 10) {
        reasons.add('Ít năng lượng hơn ${energyDiff.toStringAsFixed(0)} kcal');
      }
    }

    if (goal == _HealthGoal.gainWeight) {
      final proteinDiff = _itemProtein(item) - _currentProtein();
      if (proteinDiff > 0.5) {
        reasons.add('Nhiều protein hơn ${proteinDiff.toStringAsFixed(1)}g');
      }
    }

    if (reasons.isEmpty) {
      reasons.add('Phù hợp hơn với mục tiêu sức khỏe của bạn');
    }

    return reasons.take(3).toList();
  }

  _HealthGoal _inferHealthGoal(HealthProfile? profile) {
    final bmiCategory = (profile?.computedBmiCategory ?? '').toLowerCase();
    final dietType = (profile?.dietType ?? '').toLowerCase();

    if (bmiCategory.contains('thiếu cân') ||
        dietType.contains('bulking') ||
        dietType.contains('tăng cân')) {
      return _HealthGoal.gainWeight;
    }

    if (bmiCategory.contains('thừa cân') ||
        bmiCategory.contains('béo phì') ||
        dietType.contains('weight loss') ||
        dietType.contains('giảm cân')) {
      return _HealthGoal.loseWeight;
    }

    return _HealthGoal.maintainWeight;
  }

  String _goalLabel(_HealthGoal goal) {
    switch (goal) {
      case _HealthGoal.loseWeight:
        return 'Giảm cân';
      case _HealthGoal.gainWeight:
        return 'Tăng cân';
      case _HealthGoal.maintainWeight:
        return 'Giữ cân';
    }
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

  bool _isLowerSugar(_AlternativeItem item) => _itemSugar(item) < _currentSugar();
  bool _isLowerSalt(_AlternativeItem item) => _itemSalt(item) < _currentSalt();
  bool _isLowerEnergy(_AlternativeItem item) => _itemEnergy(item) < _currentEnergy();
  bool _isHigherEnergy(_AlternativeItem item) => _itemEnergy(item) > _currentEnergy();
  bool _isHigherProtein(_AlternativeItem item) => _itemProtein(item) > _currentProtein();

  double _currentSugar() => _readNutrient(widget.currentProduct.nutriments, const [
        'sugars_100g',
        'sugars',
      ]);

  double _currentSalt() => _readNutrient(widget.currentProduct.nutriments, const [
        'salt_100g',
        'sodium_100g',
        'salt',
        'sodium',
      ]);

  double _currentEnergy() => _readNutrient(widget.currentProduct.nutriments, const [
        'energy-kcal_100g',
        'energy-kcal',
        'energy',
      ]);

  double _currentProtein() => _readNutrient(widget.currentProduct.nutriments, const [
        'proteins_100g',
        'proteins',
        'protein',
      ]);

  double _itemSugar(_AlternativeItem item) =>
      _readNutrient(item.nutriments, const ['sugars_100g', 'sugars']);

  double _itemSalt(_AlternativeItem item) => _readNutrient(
        item.nutriments,
        const ['salt_100g', 'sodium_100g', 'salt', 'sodium'],
      );

  double _itemEnergy(_AlternativeItem item) =>
      _readNutrient(item.nutriments, const ['energy-kcal_100g', 'energy-kcal', 'energy']);

  double _itemProtein(_AlternativeItem item) =>
      _readNutrient(item.nutriments, const ['proteins_100g', 'proteins', 'protein']);

  double _readNutrient(Map<String, dynamic>? nutriments, List<String> keys) {
    if (nutriments == null) return 0;
    for (final key in keys) {
      final value = nutriments[key];
      if (value is num) return value.toDouble();
      if (value is String) {
        final parsed = double.tryParse(value);
        if (parsed != null) return parsed;
      }
    }
    return 0;
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}

enum _AlternativeSource { scanHistory, cache }

enum _HealthGoal { loseWeight, gainWeight, maintainWeight }

class _AlternativeItem {
  const _AlternativeItem({
    required this.barcode,
    required this.name,
    required this.imageUrl,
    required this.brands,
    required this.nutriscore,
    required this.nutriments,
    required this.source,
    required this.improvementSteps,
  });

  final String barcode;
  final String name;
  final String? imageUrl;
  final String? brands;
  final String? nutriscore;
  final Map<String, dynamic>? nutriments;
  final _AlternativeSource source;
  final int improvementSteps;

  _AlternativeItem copyWith({
    String? nutriscore,
    Map<String, dynamic>? nutriments,
    int? improvementSteps,
  }) {
    return _AlternativeItem(
      barcode: barcode,
      name: name,
      imageUrl: imageUrl,
      brands: brands,
      nutriscore: nutriscore ?? this.nutriscore,
      nutriments: nutriments ?? this.nutriments,
      source: source,
      improvementSteps: improvementSteps ?? this.improvementSteps,
    );
  }
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
  const _AlternativeCard({
    required this.item,
    required this.reasons,
    required this.isSaved,
    required this.isSaving,
    required this.onTap,
    required this.onSave,
  });

  final _AlternativeItem item;
  final List<String> reasons;
  final bool isSaved;
  final bool isSaving;
  final VoidCallback onTap;
  final VoidCallback onSave;

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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF2E7D32),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                _ScoreChip(score: item.nutriscore),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: reasons
                  .map(
                    (reason) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE9F7EF),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: const Color(0xFFB8E4C8)),
                      ),
                      child: Text(
                        reason,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1E7D42),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.icon(
                onPressed: (isSaved || isSaving) ? null : onSave,
                style: FilledButton.styleFrom(
                  backgroundColor:
                      isSaved ? Colors.grey.shade400 : const Color(0xFF2ECC71),
                ),
                icon: isSaving
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(isSaved ? Icons.check : Icons.favorite_border),
                label: Text(isSaved ? 'Đã lưu' : 'Lưu vào yêu thích'),
              ),
            ),
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
