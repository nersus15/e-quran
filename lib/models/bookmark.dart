import 'dart:math';

class BookmarkModel {
  String id, nama, jenis;
  List<dynamic> item;

  BookmarkModel(
      {required this.id,
      required this.nama,
      required this.jenis,
      required this.item});

  static String randomid({int length = 8}) {
    const _chars =
        'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
    Random _rnd = Random();

    return String.fromCharCodes(Iterable.generate(
        length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));
  }

  static toJson(BookmarkModel data) {
    Map<String, dynamic> tmp = {
      'id': data.id,
      'nama': data.nama,
      'jenis': data.jenis,
      'item': data.item,
    };
    return tmp;
  }

  factory BookmarkModel.fromJson(Map<String, dynamic> json) {
    return BookmarkModel(
      id: json['id'],
      nama: json['nama'],
      jenis: json['jenis'],
      item: json['item'],
    );
  }
}
