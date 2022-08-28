class Ayat {
  final int id, nomor, surah;
  final String arab, arab_latin, indonesia;

  Ayat(
      {required this.id,
      required this.nomor,
      required this.surah,
      required this.arab,
      required this.arab_latin,
      required this.indonesia});

  factory Ayat.fromJson(Map<String, dynamic> json) {
    return Ayat(
      id: json['id'],
      nomor: json['nomor'],
      surah: json['surah'],
      arab: json['ar'],
      arab_latin: json['tr'],
      indonesia: json['idn'],
    );
  }

  static toJson(Ayat data) {
    Map<String, dynamic> tmp = {
      'id': data.id,
      'nomor': data.nomor,
      'surah': data.surah,
      'ar': data.arab,
      'tr': data.arab_latin,
      'idn': data.indonesia,
    };
    return tmp;
  }
}
