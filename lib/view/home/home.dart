// Flutter imports:
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

// Project imports:
import '/model/model.dart';
import '/services/services.dart';
import '/ui/ui.dart';
import '/view/create/create.dart';
import '/view/scan/scan.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final List<ScanModel> _scanList = [];
  late Future _scanHanlder;

  @override
  void initState() {
    _scanHanlder = _init();

    super.initState();
  }

  _init() async {
    _scanList.clear();
    var data = await Db.getScannedData();
    if (data != null) {
      for (var i in data.entries) {
        _scanList.add(
          ScanModel(
            id: i.value["id"],
            data: i.value["data"],
            created: DateTime.fromMillisecondsSinceEpoch(i.value["created"]),
          ),
        );
      }

      _scanList.sort((a, b) {
        return b.created.compareTo(a.created);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const Padding(
          padding: EdgeInsets.all(7),
          child: CircleAvatar(
            backgroundColor: Colors.white,
            backgroundImage: AssetImage(
              'assets/images/logo.png',
            ),
          ),
        ),
        title: const Text("Scan Sphere"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(context, CupertinoPageRoute(builder: (context) {
                return const Create();
              }));
            },
          )
        ],
      ),
      body: FutureBuilder(
        future: _scanHanlder,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return futureWaitingLoading(context);
          } else if (snapshot.hasError) {
            return futureError(
                title: "Error", content: snapshot.error.toString());
          } else {
            return _buildBody(context);
          }
        },
      ),
      floatingActionButton: _floatingButton(),
    );
  }

  Widget _buildBody(context) {
    if (_scanList.isNotEmpty) {
      return ListView(
        padding: const EdgeInsets.all(10),
        children: [
          Row(
            children: [
              Icon(
                Icons.history_rounded,
                color: AppColors.greyColor,
              ),
              const SizedBox(width: 5),
              Text(
                "Your History",
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      color: AppColors.greyColor,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ListView.separated(
            primary: false,
            shrinkWrap: true,
            itemCount: _scanList.length,
            separatorBuilder: (context, index) {
              return Divider(
                color: Colors.grey.shade300,
              );
            },
            itemBuilder: (context, index) {
              return ListTile(
                tileColor: AppColors.pureWhiteColor,
                onTap: () async {
                  var v = await Sheet.showSheet(context,
                      size: 0.2, widget: const ScanOptions());
                  if (v != null) {
                    if (v == 1) {
                      if (_scanList[index].data.contains('http') ||
                          _scanList[index].data.contains('https')) {
                        await launchUrl(Uri.parse(_scanList[index].data));
                      } else {
                        await Clipboard.setData(ClipboardData(
                            text: _scanList[index].data.toString()));
                        Snackbar.showSnackBar(context,
                            content: "Text copied on clipboard",
                            isSuccess: true);
                      }
                    } else {
                      await Db.deleteScannedData(id: _scanList[index].id);
                      Snackbar.showSnackBar(context,
                          content: "History removed", isSuccess: true);
                      _scanHanlder = _init();
                      setState(() {});
                    }
                  }
                },
                title: _scanList[index].data.contains('http') ||
                        _scanList[index].data.contains('https')
                    ? Text(
                        _scanList[index].data,
                        style: const TextStyle(
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                          decorationColor: Colors.blue,
                        ),
                        overflow: TextOverflow.ellipsis,
                      )
                    : Text(
                        _scanList[index].data,
                        style: const TextStyle(color: Colors.black),
                        overflow: TextOverflow.ellipsis,
                      ),
                subtitle: Text(
                  DateFormat('dd-MM-yyyy hh:mm a')
                      .format(_scanList[index].created),
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium!
                      .copyWith(color: AppColors.greyColor),
                ),
                leading: Container(
                  height: 25,
                  width: 25,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      "${index + 1}",
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      );
    }
    return noDataQr(context);
  }

  Widget _floatingButton() {
    return FloatingActionButton(
      heroTag: null,
      foregroundColor: AppColors.whiteColor,
      backgroundColor: Theme.of(context).primaryColor,
      shape: const CircleBorder(),
      onPressed: () async {
        await _newScan();
      },
      child: const Icon(Icons.qr_code),
    );
  }

  Future<void> _newScan() async {
    var result = await Navigator.push(
      context,
      CupertinoPageRoute(builder: (context) => const Scan()),
    );

    if (result != null) {
      if (result["status"]) {
        if (result["value"] != null) {
          ScanModel model = ScanModel(
            id: '',
            data: result['value'].toString(),
            created: DateTime.now(),
          );

          await Db.setScanData(data: model);
          _scanHanlder = _init();
          setState(() {});
          if (result['value'].toString().contains('http') ||
              result['value'].toString().contains('https')) {
            await launchUrl(Uri.parse(result['value'].toString()));
          }
        }
        Snackbar.showSnackBar(context,
            content: "Scanned successfully", isSuccess: true);
      } else if (!result["status"]) {
        Snackbar.showSnackBar(context,
            content: result["error"], isSuccess: false);
      }
    }
  }
}
