import 'package:e_quran/models/surah.dart';
import 'package:e_quran/providers/provider_surah.dart';
import 'package:e_quran/screens/surah_screen.dart';
import 'package:e_quran/values/custom_colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ListSurah extends StatelessWidget {
  const ListSurah({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final surahProvider = Provider.of<SurahProvider>(context);
    List<Surah> surah = surahProvider.surah;
    surah.sort((a, b) => a.nomor.compareTo(b.nomor));
    return Expanded(
      child: ListView.builder(
        itemCount: surah.length,
        shrinkWrap: true,
        itemBuilder: ((context, index) {
          Surah s = surah[index];
          return GestureDetector(
            key: Key(s.nomor.toString()),
            onTap: () async {
              print("Surah Ke " + s.nomor.toString());

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SurahScreen(nomor_surat: s.nomor),
                ),
              );
            },
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 0),
              decoration: BoxDecoration(
                border: Border(
                    bottom:
                        BorderSide(color: devider.withOpacity(0.35), width: 1)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text(
                    s.nomor.toString(),
                    style: TextStyle(
                        color: primary,
                        fontFamily: 'Poppins-Medium',
                        fontSize: 18),
                  ),
                  Column(
                    // crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        s.nama_latin,
                        style: TextStyle(
                          color: primary,
                          fontFamily: 'Poppins-Medium',
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        "${s.tempat_turun}  ${s.jumlah_ayat.toString()} ayat",
                        style: TextStyle(
                          color: secondary,
                          fontFamily: 'Poppins-Medium',
                          fontSize: 18,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                  Text(
                    s.nama,
                    style: TextStyle(
                      color: primary,
                      fontFamily: 'Amiri-Regular',
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
