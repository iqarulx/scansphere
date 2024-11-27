import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:scansphere/ui/src/form_fields.dart';
import 'package:share_plus/share_plus.dart';
import 'package:syncfusion_flutter_barcodes/barcodes.dart';
import '../../services/services.dart';
import '../../ui/ui.dart';
import '../../ui/src/open_file.dart' as helper;

class Create extends StatefulWidget {
  const Create({super.key});

  @override
  State<Create> createState() => _CreateState();
}

class _CreateState extends State<Create> {
  final TextEditingController _codeController = TextEditingController();
  String codeType = "qr";
  String codeValue = "";

  final GlobalKey _qrObjectKey = GlobalKey();
  final GlobalKey _barCodeObjectKey = GlobalKey();

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
            maxLines: 5,
            hintText: "Your content here...",
          ),
          const SizedBox(height: 10),
          _buildCodeView(context),
        ],
      ),
    );
  }

  Widget _buildCodeView(context) {
    if (codeValue.isNotEmpty) {
      return Column(
        children: [
          if (codeType == "qr")
            RepaintBoundary(
              key: _qrObjectKey,
              child: Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.only(
                    top: 20, bottom: 10, left: 10, right: 10),
                decoration: BoxDecoration(
                  color: AppColors.pureWhiteColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: SfBarcodeGenerator(
                  backgroundColor: Colors.white,
                  value: codeValue,
                  symbology: QRCode(),
                  showValue: true,
                  textStyle: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
            )
          else
            RepaintBoundary(
              key: _barCodeObjectKey,
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
                      Uint8List? imgData;
                      String? path;
                      if (codeType == "qr") {
                        imgData = await _getQrImage();
                      } else {
                        imgData = await _getBarcodeImage();
                      }
                      if (imgData != null) {
                        path = await helper.saveFile(
                            bt: imgData, fn: "$codeType.png");
                      }
                      if (path != null) {
                        await Share.shareXFiles(
                          [XFile(path)],
                          subject: "Shared via ScanSphere 🚀",
                        );
                      }
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
                      Uint8List? imgData;
                      if (codeType == "qr") {
                        imgData = await _getQrImage();
                      } else {
                        imgData = await _getBarcodeImage();
                      }
                      if (imgData != null) {
                        await helper.launchFile(
                            bt: imgData, fn: "$codeType.png");
                      }
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
      );
    }
    return Container();
  }

  Future<Uint8List?> _getQrImage() async {
    try {
      futureLoading(context);
      await Future.delayed(const Duration(milliseconds: 100));

      RenderRepaintBoundary boundary = _qrObjectKey.currentContext
          ?.findRenderObject() as RenderRepaintBoundary;

      if (boundary.debugNeedsPaint) {
        await Future.delayed(const Duration(milliseconds: 100));
      }

      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      Navigator.pop(context);
      return byteData?.buffer.asUint8List();
    } catch (e) {
      Navigator.pop(context);
      return null;
    }
  }

  Future<Uint8List?> _getBarcodeImage() async {
    try {
      futureLoading(context);
      await Future.delayed(const Duration(milliseconds: 100));

      RenderRepaintBoundary boundary = _barCodeObjectKey.currentContext
          ?.findRenderObject() as RenderRepaintBoundary;

      if (boundary.debugNeedsPaint) {
        await Future.delayed(const Duration(milliseconds: 100));
      }

      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      Navigator.pop(context);
      return byteData?.buffer.asUint8List();
    } catch (e) {
      Navigator.pop(context);
      return null;
    }
  }
}
