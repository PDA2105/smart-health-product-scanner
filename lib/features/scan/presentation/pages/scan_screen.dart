import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';

import '../../../../data/models/product_model.dart';
import '../../../../data/repositories/product_repository.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  // Controller for the scanner
  final MobileScannerController _scannerController = MobileScannerController();
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
    if (barcode == null) {
      _showErrorSnackbar('Could not read barcode.');
      return;
    }

    setState(() {
      _isProcessing = true; // 1. Show loading indicator
    });

    try {
      // 2. Call the repository function
      final product = await context.read<ProductRepository>().getProductByBarcode(barcode);
      
      if (!mounted) return;
      
      // 3. If a product is found, show a dialog
      _showProductDialog(product!); 
    } catch (e) {
      // 4. If an error occurs, show a snackbar
      if (!mounted) return;
      _showErrorSnackbar(e.toString());
    } finally {
      // After 3 seconds, allow scanning again to prevent rapid-fire scans
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            _isProcessing = false;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Product'),
        actions: [
          IconButton(
            icon: ValueListenableBuilder(
              valueListenable: _scannerController.torchState,
              builder: (context, state, child) {
                return Icon(state == TorchState.on ? Icons.flash_on : Icons.flash_off);
              },
            ),
            onPressed: () => _scannerController.toggleTorch(),
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _scannerController,
            onDetect: _onBarcodeDetected,
          ),
          // Show a loading indicator in the center while processing
          if (_isProcessing)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }

  /// Shows a dialog with the product information.
  void _showProductDialog(ProductModel product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(product.name ?? 'Product Found'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (product.imageUrl != null)
                Center(
                  child: Image.network(
                    product.imageUrl!,
                    height: 100,
                    errorBuilder: (context, error, stackTrace) => const Icon(Icons.image),
                  ),
                ),
              const SizedBox(height: 16),
              Text('Barcode: ${product.barcode}'),
              const SizedBox(height: 8),
              Text('Brand: ${product.brands ?? 'N/A'}'),
              const SizedBox(height: 8),
              Text('Quantity: ${product.quantity ?? 'N/A'}'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  /// Shows an error message in a SnackBar.
  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
      ),
    );
  }
}
