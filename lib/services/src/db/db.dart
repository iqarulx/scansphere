// Package imports:
import 'package:localstore/localstore.dart';

// Project imports:
import '/model/model.dart';

class Db {
  static final db = Localstore.instance;

  static Future<Map<String, dynamic>?> getScannedData() async {
    final items = await db.collection('scanned_data').get();
    return items;
  }

  static Future deleteScannedData({required String id}) async {
    await db.collection('scanned_data').doc(id).delete();
  }

  static Future clearScannedData() async {
    await db.collection('scanned_data').delete();
  }

  static Future setScanData({required ScanModel data}) async {
    var value = await checkAlreadyScanned(data.data);
    if (value["status"]) {
      data.id = value["id"];
      db
          .collection('scanned_data')
          .doc(value["id"])
          .set(data.toMap(), SetOptions(merge: true));
    } else {
      final id = db.collection('scanned_data').doc().id;
      data.id = id;
      db.collection('scanned_data').doc(id).set(data.toMap());
    }
  }

  static Future<Map<String, dynamic>> checkAlreadyScanned(String name) async {
    final items = await db.collection('scanned_data').get();
    if (items != null) {
      for (var i in items.entries) {
        if (i.value['data'] == name) {
          return {"status": true, "id": i.key.split('/').last};
        }
      }
      return {"status": false, "id": null};
    } else {
      return {"status": false, "id": null};
    }
  }
}
