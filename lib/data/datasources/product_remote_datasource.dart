import 'package:openfoodfacts/openfoodfacts.dart';

import '../../core/services/app_logger.dart';
import '../models/product_model.dart';

/// A data source to fetch product data from the Open Food Facts API.
class ProductRemoteDataSource {
  /// Fetches a product from the Open Food Facts API by its barcode.
  Future<ProductModel?> fetchProductFromApi(String barcode) async {
    try {
      AppLogger.debug('[ProductRemoteDataSource] Fetching product for barcode: $barcode');

      final productResult = await OpenFoodAPIClient.getProductV3(
        ProductQueryConfiguration(
          barcode,
          language: OpenFoodFactsLanguage.ENGLISH,
          fields: [ProductField.ALL],
          version: ProductQueryVersion.v3,
        ),
      );

      // Log the detailed response from the API for debugging
      AppLogger.debug(
        '[ProductRemoteDataSource] Response Status: ${productResult.status}',
      );
      AppLogger.debug(
        '[ProductRemoteDataSource] Response Product is null: ${productResult.product == null}',
      );

      if (productResult.product != null) {
        AppLogger.debug(
          '[ProductRemoteDataSource] Product found: ${productResult.product!.productName}',
        );
        return ProductModel.fromApi(productResult.product!);
      } else {
        AppLogger.warn('[ProductRemoteDataSource] Product not found or error in response.');
        return null;
      }
    } catch (e) {
      AppLogger.error(
        '[ProductRemoteDataSource] Exception while fetching product',
        error: e,
      );
      return null;
    }
  }
}
