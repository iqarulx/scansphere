import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:iconsax/iconsax.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:syncfusion_flutter_barcodes/barcodes.dart';
import 'package:path/path.dart' as path;
import 'dart:ui' as ui;
import '/utils/utils.dart' as helper;
import '/utils/utils.dart';
import '/services/services.dart';
import '/ui/ui.dart';

Future<File> _captureAndSaveWidget(GlobalKey key, String fileName) async {
  RenderRepaintBoundary boundary =
      key.currentContext?.findRenderObject() as RenderRepaintBoundary;

  ui.Image image = await boundary.toImage(pixelRatio: 3.0);
  ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  final buffer = byteData!.buffer;

  final directory = await getApplicationDocumentsDirectory();
  final file = File('${directory.path}/$fileName');
  return await file.writeAsBytes(buffer.asUint8List());
}

class Create extends StatefulWidget {
  const Create({super.key});

  @override
  State<Create> createState() => _CreateState();
}

class _CreateState extends State<Create> {
  final TextEditingController _codeController = TextEditingController();
  String codeType = "qr";
  String codeValue = "";
  File? _qrLogoFile;
  final GlobalKey _qrKey = GlobalKey();
  final GlobalKey _barcodeKey = GlobalKey();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: "Back",
          icon:
              const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text("Create New"),
        actions: [
          IconButton(
            tooltip: "Image Upload",
            icon: const Icon(CupertinoIcons.cloud_upload, color: Colors.white),
            onPressed: () async {
              var v = await PickImage.pickImage();
              if (_qrLogoFile != null) {
                _qrLogoFile!.deleteSync();
              }
              _qrLogoFile = v;
              setState(() {});
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(10),
        children: [
          Container(
            height: 50,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () {
                      codeType = "qr";
                      setState(() {});
                    },
                    child: Container(
                      alignment: Alignment.center,
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(10),
                          topLeft: Radius.circular(10),
                        ),
                        color: codeType == "qr"
                            ? Theme.of(context).primaryColor
                            : Theme.of(context).secondaryHeaderColor,
                      ),
                      child: Text(
                        "Qr",
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium!
                            .copyWith(color: AppColors.pureWhiteColor),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: InkWell(
                    onTap: () {
                      codeType = "barCode";
                      setState(() {});
                    },
                    child: Container(
                      alignment: Alignment.center,
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(10),
                          bottomRight: Radius.circular(10),
                        ),
                        color: codeType == "barCode"
                            ? Theme.of(context).primaryColor
                            : Theme.of(context).secondaryHeaderColor,
                      ),
                      child: Text(
                        "Bar Code",
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium!
                            .copyWith(color: AppColors.pureWhiteColor),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          FormFields(
            controller: _codeController,
            onChanged: (value) {
              codeValue = value;
              setState(() {});
            },
            maxLines: 2,
            hintText: "Your content here...",
          ),
          const SizedBox(height: 10),
          _buildLogoFile(),
          if (codeValue.isNotEmpty)
            Column(
              children: [
                if (codeType == "qr")
                  RepaintBoundary(
                    key: _qrKey,
                    child: Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.only(
                          top: 20, bottom: 10, left: 10, right: 10),
                      decoration: BoxDecoration(
                        color: AppColors.pureWhiteColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: _qrLogoFile != null
                          ? QrImageView(
                              data: codeValue,
                              version: QrVersions.auto,
                              size: 320,
                              gapless: false,
                              embeddedImage: FileImage(_qrLogoFile!),
                              embeddedImageStyle: const QrEmbeddedImageStyle(
                                size: Size(80, 80),
                              ),
                            )
                          : QrImageView(
                              data: codeValue,
                              version: QrVersions.auto,
                              size: 320,
                              gapless: false,
                            ),
                    ),
                  )
                else
                  RepaintBoundary(
                    key: _barcodeKey,
                    child: Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.only(
                          top: 20, bottom: 10, left: 10, right: 10),
                      decoration: BoxDecoration(
                        color: AppColors.pureWhiteColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      height: 150,
                      child: SfBarcodeGenerator(
                        backgroundColor: Colors.white,
                        value: codeValue,
                        showValue: true,
                        textStyle: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                  ),
                const SizedBox(height: 10),
                Container(
                  height: 50,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            final fileName = codeType == "qr"
                                ? "qr_code.png"
                                : "barcode.png";
                            final key = codeType == "qr" ? _qrKey : _barcodeKey;
                            File file =
                                await _captureAndSaveWidget(key, fileName);
                            Share.shareXFiles([XFile(file.path)],
                                subject: "Shared via My App");
                          },
                          child: Container(
                            alignment: Alignment.center,
                            height: 50,
                            decoration: BoxDecoration(
                              borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(10),
                                topLeft: Radius.circular(10),
                              ),
                              color: AppColors.pureWhiteColor,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.share_rounded,
                                  color: AppColors.greyColor,
                                  size: 23,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  "Share",
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium!
                                      .copyWith(color: AppColors.greyColor),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            final fileName = codeType == "qr"
                                ? "qr_code.png"
                                : "barcode.png";
                            final key = codeType == "qr" ? _qrKey : _barcodeKey;
                            File file =
                                await _captureAndSaveWidget(key, fileName);

                            await helper.launchFile(
                                bt: file.readAsBytesSync(), fn: fileName);
                          },
                          child: Container(
                            alignment: Alignment.center,
                            height: 50,
                            decoration: BoxDecoration(
                              borderRadius: const BorderRadius.only(
                                topRight: Radius.circular(10),
                                bottomRight: Radius.circular(10),
                              ),
                              color: AppColors.pureWhiteColor,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.file_download_outlined,
                                    color: AppColors.greyColor),
                                const SizedBox(width: 5),
                                Text(
                                  "Download",
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium!
                                      .copyWith(color: AppColors.greyColor),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildLogoFile() {
    if (_qrLogoFile != null) {
      return Column(
        children: [
          Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.pureWhiteColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(path.basename(_qrLogoFile!.path)),
                ),
                IconButton(
                  icon: const Icon(Iconsax.trash),
                  onPressed: () {
                    _qrLogoFile!.deleteSync();
                    _qrLogoFile = null;
                    setState(() {});
                  },
                )
              ],
            ),
          ),
          const SizedBox(height: 10)
        ],
      );
    }
    return Container();
  }
}
