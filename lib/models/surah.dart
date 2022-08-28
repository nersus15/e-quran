
class Surah {
  final int nomor, jumlah_ayat;
  final String nama, nama_latin, tempat_turun, arti, deskripsi, audio_url;
  // final List<Ayat> ayat;
  Surah({
    required this.nomor,
    required this.jumlah_ayat,
    required this.nama,
    required this.nama_latin,
    required this.tempat_turun,
    required this.arti,
    required this.deskripsi,
    required this.audio_url,
    // required this.ayat,
  });

  factory Surah.fromJson(Map<String, dynamic> json) {
    // List<Ayat> ayat = [];
    // json['ayat'].map((a) {
    //   ayat.add(Ayat.fromJson(a));
    // });
    return Surah(
      nomor: json['nomor'],
      jumlah_ayat: json['jumlah_ayat'],
      nama: json['nama'],
      nama_latin: json['nama_latin'],
      tempat_turun: json['tempat_turun'],
      arti: json['arti'],
      deskripsi: json['deskripsi'],
      audio_url: json['audio'],
      // ayat: ayat,
    );
  }
}
