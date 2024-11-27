import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:scansphere/services/services.dart';

class Scan extends StatefulWidget {
  const Scan({super.key});

  @override
  State<Scan> createState() => _ScanState();
}

class _ScanState extends State<Scan> {
  late MobileScannerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = MobileScannerController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Scan Any Code"),
        leading: IconButton(
          tooltip: "Back",
          icon:
              const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(10),
        children: [
          SizedBox(
            height: 300,
            child: MobileScanner(
              controller: _controller,
              onDetectError: (error, stackTrace) {
                _controller.dispose();

                Navigator.pop(
                  context,
                  {"status": false, "error": error.toString()},
                );
              },
              onDetect: (capture) {
                final List<Barcode> barcodes = capture.barcodes;
                _controller.dispose();

                if (barcodes.isNotEmpty) {
                  Navigator.pop(context, {
                    "status": true,
                    "value": barcodes.first.rawValue ?? "No Data found in QR",
                  });
                } else {
                  Navigator.pop(context, {
                    "status": false,
                    "error": "No QR code detected",
                  });
                }
              },
            ),
          ),
          const SizedBox(height: 10),
          _instructions(context),
        ],
      ),
    );
  }

  Container _instructions(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: AppColors.pureWhiteColor,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Instructions to scan",
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 5),
          const Divider(),
          const SizedBox(height: 5),
          Text(
            "1. Align the QR code within the scanner frame.",
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 5),
          Text(
            "2. Ensure the QR code is clearly visible and not blurry.",
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 5),
          Text(
            "3. Hold your device steady while scanning.",
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 5),
          Text(
            "4. Wait for the scanner to detect the QR code automatically.",
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 5),
          Text(
            "5. If scanning fails, ensure good lighting and try again.",
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }
}
