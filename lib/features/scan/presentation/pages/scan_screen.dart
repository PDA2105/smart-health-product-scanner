import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';

import '../../../../data/models/product_model.dart';
import '../../../../data/repositories/product_repository.dart';
import '../../../../routes/app_routes.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  // Controller for the scanner
  final MobileScannerController _scannerController = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
  );

  // A flag to prevent multiple scans at the same time
  bool _isProcessing = false;

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  /// Handles the detected barcode, fetches the product, and shows the result.
  Future<void> _onBarcodeDetected(BarcodeCapture capture) async {
    if (_isProcessing) return; // Don't process if a scan is already in progress

    final barcode = capture.barcodes.first.rawValue;
    if (barcode == null || barcode.isEmpty) {
      _showErrorSnackbar('Không thể đọc mã vạch. Vui lòng thử lại.');
      return;
    }

    // Haptic feedback when barcode is detected
    HapticFeedback.mediumImpact();

    setState(() {
      _isProcessing = true; // 1. Show loading indicator
    });

    try {
      // 2. Call the repository function to fetch product
      final product = await context.read<ProductRepository>().getProductByBarcode(barcode);

      if (!mounted) return;

      if (product != null) {
        // Success haptic feedback
        HapticFeedback.lightImpact();

        // 3. If a product is found, show a dialog
        _showProductDialog(product);
      } else {
        _showErrorSnackbar('Không tìm thấy sản phẩm với mã vạch: $barcode');
      }
    } catch (e) {
      // 4. If an error occurs, show a snackbar
      if (!mounted) return;

      // Extract meaningful error message
      String errorMessage = 'Đã xảy ra lỗi khi tìm kiếm sản phẩm.';
      if (e.toString().contains('not found')) {
        errorMessage = 'Sản phẩm với mã vạch $barcode không tồn tại trong cơ sở dữ liệu.';
      } else if (e.toString().contains('network')) {
        errorMessage = 'Lỗi kết nối mạng. Vui lòng kiểm tra kết nối internet.';
      }

      _showErrorSnackbar(errorMessage);
    } finally {
      // After 2 seconds, allow scanning again to prevent rapid-fire scans
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quét Sản Phẩm'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        actions: [
          // Camera switch button
          IconButton(
            onPressed: () => _scannerController.switchCamera(),
            icon: const Icon(Icons.cameraswitch),
            tooltip: 'Đổi camera trước/sau',
          ),
          // Flash toggle button
          IconButton(
            icon: ValueListenableBuilder(
              valueListenable: _scannerController.torchState,
              builder: (context, state, child) {
                return Icon(
                  state == TorchState.on ? Icons.flash_on : Icons.flash_off,
                );
              },
            ),
            onPressed: () => _scannerController.toggleTorch(),
            tooltip: 'Bật/Tắt đèn flash',
          ),
        ],
      ),
      body: Stack(
        children: [
          // Camera scanner
          MobileScanner(
            controller: _scannerController,
            onDetect: _onBarcodeDetected,
          ),

          // Scan overlay guide
          _buildScanOverlay(),

          // Loading indicator when processing
          if (_isProcessing)
            Container(
              color: Colors.black54,
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Đang tìm kiếm sản phẩm...',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Builds a scanning guide overlay
  Widget _buildScanOverlay() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
      ),
      child: Column(
        children: [
          const Spacer(flex: 2),

          // Scan frame
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.teal, width: 3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  color: Colors.transparent,
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Instruction text
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Đặt mã vạch vào trong khung để quét',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          const Spacer(flex: 3),
        ],
      ),
    );
  }

  /// Shows a dialog with the product information.
  void _showProductDialog(ProductModel product) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product image
                if (product.imageUrl != null)
                  Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        product.imageUrl!,
                        height: 150,
                        width: 150,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            Container(
                              height: 150,
                              width: 150,
                              color: Colors.grey[200],
                              child: const Icon(
                                Icons.image_not_supported,
                                size: 64,
                                color: Colors.grey,
                              ),
                            ),
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            height: 150,
                            width: 150,
                            color: Colors.grey[200],
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                const SizedBox(height: 16),

                // Product name
                Text(
                  product.name ?? 'Sản phẩm không có tên',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 16),

                // Product details
                _buildInfoRow(Icons.qr_code, 'Mã vạch', product.barcode),
                const SizedBox(height: 8),
                _buildInfoRow(Icons.business, 'Thương hiệu', product.brands ?? 'Không rõ'),
                const SizedBox(height: 8),
                _buildInfoRow(Icons.scale, 'Khối lượng', product.quantity ?? 'Không rõ'),

                // Nutriscore and Ecoscore
                if (product.nutriscore != null || product.ecoscore != null) ...[
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      if (product.nutriscore != null)
                        _buildScoreBadge('Nutriscore', product.nutriscore!, Colors.orange),
                      if (product.ecoscore != null)
                        _buildScoreBadge('Ecoscore', product.ecoscore!, Colors.green),
                    ],
                  ),
                ],

                const SizedBox(height: 20),

                // Action buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Đóng'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: () {
                        // Close dialog first
                        Navigator.of(context).pop();
                        // Then navigate using microtask to ensure dialog is closed
                        Future.microtask(() {
                          context.navigateToProductDetail(product);
                        });
                      },
                      icon: const Icon(Icons.info_outline),
                      label: const Text('Chi tiết'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Builds an info row with icon, label and value
  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(color: Colors.black87, fontSize: 14),
              children: [
                TextSpan(
                  text: '$label: ',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                TextSpan(text: value),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Builds a score badge
  Widget _buildScoreBadge(String label, String score, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color, width: 2),
          ),
          child: Text(
            score.toUpperCase(),
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  /// Shows an error message in a SnackBar.
  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }
}
