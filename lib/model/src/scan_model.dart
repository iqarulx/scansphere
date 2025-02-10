// ignore_for_file: public_member_api_docs, sort_constructors_first

// Dart imports:
import 'dart:convert';

class ScanModel {
  String id;
  String data;
  DateTime created;
  ScanModel({
    required this.id,
    required this.data,
    required this.created,
  });

  ScanModel copyWith({
    String? id,
    String? data,
    DateTime? created,
  }) {
    return ScanModel(
      id: id ?? this.id,
      data: data ?? this.data,
      created: created ?? this.created,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'data': data,
      'created': created.millisecondsSinceEpoch,
    };
  }

  factory ScanModel.fromMap(Map<String, dynamic> map) {
    return ScanModel(
      id: map['id'] as String,
      data: map['data'] as String,
      created: DateTime.fromMillisecondsSinceEpoch(map['created'] as int),
    );
  }

  String toJson() => json.encode(toMap());

  factory ScanModel.fromJson(String source) =>
      ScanModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'ScanModel(id: $id, data: $data, created: $created)';

  @override
  bool operator ==(covariant ScanModel other) {
    if (identical(this, other)) return true;

    return other.id == id && other.data == data && other.created == created;
  }

  @override
  int get hashCode => id.hashCode ^ data.hashCode ^ created.hashCode;
}
