import 'package:openfoodfacts/openfoodfacts.dart';

import '../models/product_model.dart';

/// A data source to fetch product data from the Open Food Facts API.
class ProductRemoteDataSource {
  /// Fetches a product from the Open Food Facts API by its barcode.
  Future<ProductModel?> fetchProductFromApi(String barcode) async {
    try {
      print('[API] Fetching product for barcode: $barcode');

      final productResult = await OpenFoodAPIClient.getProductV3(
        ProductQueryConfiguration(
          barcode,
          language: OpenFoodFactsLanguage.ENGLISH,
          fields: [ProductField.ALL],
          version: ProductQueryVersion.v3,
        ),
      );

      // Log the detailed response from the API for debugging
      print('[API] Response Status: ${productResult.status}');
      print('[API] Response Product is null: ${productResult.product == null}');

      if (productResult.product != null) {
        print('[API] Product found: ${productResult.product!.productName}');
        return ProductModel.fromApi(productResult.product!);
      } else {
        print('[API] Product not found or error in response.');
        return null;
      }
    } catch (e) {
      print('[API] !!! EXCEPTION while fetching product: $e');
      return null;
    }
  }
}
