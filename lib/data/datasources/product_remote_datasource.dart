import 'package:openfoodfacts/openfoodfacts.dart';

import '../models/product_model.dart';

/// A data source to fetch product data from the Open Food Facts API.
class ProductRemoteDataSource {
  /// Fetches a product from the Open Food Facts API by its barcode.
  Future<ProductModel?> fetchProductFromApi(String barcode) async {
    try {
      final productResult = await OpenFoodAPIClient.getProductV3(
        ProductQueryConfiguration(
          barcode,
          language: OpenFoodFactsLanguage.VIETNAMESE,
          fields: [ProductField.ALL],
          version: ProductQueryVersion.v3, // Thêm dòng này để sửa lỗi
        ),
      );

      if (productResult.product != null) {
        return ProductModel.fromApi(productResult.product!);
      }
      return null;
    } catch (e) {
      // Log the error and return null or rethrow a more specific exception.
      print('Error fetching product from Open Food Facts API: $e');
      return null;
    }
  }
}
