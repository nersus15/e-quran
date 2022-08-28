import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:e_quran/components/list_ayat_component.dart';
import 'package:e_quran/models/ayat.dart';
import 'package:e_quran/models/bookmark.dart';
import 'package:e_quran/models/surah.dart';
import 'package:e_quran/providers/provider_surah.dart';
import 'package:e_quran/screens/tafsir_screen.dart';
import 'package:e_quran/values/custom_colors.dart';
import 'package:e_quran/widgets/appbar.dart';
import 'package:e_quran/widgets/cardgradient.dart';
import 'package:e_quran/widgets/media_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:localstore/localstore.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class SurahScreen extends StatefulWidget {
  const SurahScreen({
    Key? key,
    required this.nomor_surat,
    this.nomor_ayat = '0',
  }) : super(key: key);
  final int nomor_surat;
  final String nomor_ayat;
  @override
  State<SurahScreen> createState() => _SurahScreenState();
}

class _SurahScreenState extends State<SurahScreen> {
  final String namespace = '/surahscreen';
  // late Surah surah;
  late List<Ayat> ayat = [];
  bool isWaiting = false;
  final db = Localstore.instance;
  bool play = false;
  double time = 0;
  late Duration _duration;
  late Duration _position;
  final _scrollController = ScrollController();
  final player = AudioPlayer();

  noInternet({String title = "No Internet Access"}) async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(
              "You Must Connected to Internet for first thi time to download the Qur'an content"),
          actions: [
            TextButton(
              onPressed: () {
                isWaiting = true;
                Navigator.pop(context);
              },
              child: Text(
                'Wait',
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                'Close',
                style: TextStyle(color: Color.fromARGB(255, 142, 38, 30)),
              ),
            ),
          ],
        );
      },
    );
  }

  Future fetchSurah() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        final response = await http.get(Uri.parse(
            'https://equran.id/api/surat/' + widget.nomor_surat.toString()));
        if (response.statusCode == 200) {
          isWaiting = false;
          Map<String, dynamic> body = await jsonDecode(response.body);
          List<dynamic> ayat = body['ayat'];
          db
              .collection('ayat')
              .doc(widget.nomor_surat.toString())
              .set({'ayat': ayat});
          List<Ayat> a = [];
          for (var key in ayat) {
            a.add(Ayat.fromJson(key));
          }

          print("Set Ayat  ======================");
          print(a);
          return a;
        } else {
          // No Internet
          await noInternet();
        }
      } else {
        print(result);
      }
    } on SocketException catch (_) {
      await noInternet();
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    SchedulerBinding.instance.addPostFrameCallback((_) async {
      // _scrollController.animateTo(offset, duration: duration, curve: curve)
      // Scrollable.ensureVisible(context, GlobalKey().currentContext!)
      player.setSource(
          UrlSource("https://audio.equran.id/content/audio/001.mp3"));
      _duration = (await player.getDuration())!;
      _position = (await player.getCurrentPosition())!;

      var data = await db
          .collection('ayat')
          .doc((widget.nomor_surat).toString())
          .get();

      if (data == null) {
        print("Fetching Ayat");
        List<Ayat> a = await fetchSurah();
        while (isWaiting) {
          List<Ayat> a = await fetchSurah();
        }
        setState(() {
          ayat = a;
        });
      } else {
        print("Use Local data");
        data = await db
            .collection('ayat')
            .doc((widget.nomor_surat).toString())
            .get();
        if (data != null) {
          List<Ayat> a = [];

          for (var key in data['ayat']) {
            a.add(Ayat.fromJson(key));
          }
          setState(() {
            ayat = a;
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    List<GlobalKey> ayatKey = ayat.map((e) => GlobalKey()).toList();

    if (ayatKey.length > 0) {
      Future.delayed(Duration(milliseconds: 100), () {
        if (widget.nomor_ayat != '0') {
          Scrollable.ensureVisible(
            ayatKey[(int.parse(widget.nomor_ayat) - 1)].currentContext!,
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut,
          );
        }
      });
    }

    final surahProvider = Provider.of<SurahProvider>(context);
    Surah surah =
        surahProvider.surah.firstWhere((s) => s.nomor == widget.nomor_surat);

    void playAudio() {
      setState(() {
        play = true;
      });
    }

    void pauseAudio() {
      setState(() {
        play = false;
      });
    }

    List<Widget> generateWidget() {
      List<Widget> widgets = [];
      ayat.sort(
        (a, b) => a.nomor.compareTo(b.nomor),
      );
      for (var a in ayat) {
        widgets.add(ListAyat(
          key: ayatKey.length > 0
              ? ayatKey[a.nomor - 1]
              : Key(BookmarkModel.randomid(length: 5)),
          ayat: a,
          nama_surah: surah.nama_latin,
          nomor_surat: surah.nomor.toString(),
        ));
      }
      return widgets;
    }

    return ayat.length < 1
        ? Scaffold(
            body: Container(
              child: Center(child: Text("Loading")),
            ),
          )
        : Scaffold(
            body: Dismissible(
              key: Key(widget.nomor_surat.toString()),
              onDismissed: (direction) {
                if (direction == DismissDirection.startToEnd) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          SurahScreen(nomor_surat: widget.nomor_surat - 1),
                    ),
                  );
                } else if (direction == DismissDirection.endToStart) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          SurahScreen(nomor_surat: widget.nomor_surat + 1),
                    ),
                  );
                }
              },
              confirmDismiss: (direction) async {
                if (direction == DismissDirection.startToEnd) {
                  return widget.nomor_surat > 1;
                } else if (direction == DismissDirection.endToStart) {
                  return widget.nomor_surat < 144;
                }
                return null;
              },
              child: SingleChildScrollView(
                controller: _scrollController,
                child: Container(
                  margin: EdgeInsets.only(left: 25, right: 25),
                  color: Colors.white,
                  child: Column(
                    children: [
                      CustomAppBar(
                        bisaKembali: true,
                        title: surah.nama_latin,
                      ),
                      CardGradient(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onTap: () {
                                if (surah.nomor == null) return;
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => TafsirScreen(
                                          nomor_surah: surah.nomor),
                                    ));
                              },
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        surah.nama_latin,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 25,
                                          fontFamily: 'Poppins-Medium',
                                        ),
                                      ),
                                      Icon(
                                        Icons.description,
                                        color: Colors.white,
                                      )
                                    ],
                                  ),
                                  Text(
                                    surah.arti,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Divider(
                              height: 10,
                              color: devider,
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text(
                              "${surah.tempat_turun} . ${surah.jumlah_ayat.toString()} Ayat",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontFamily: 'Poppins-Light'),
                            ),
                            SizedBox(
                              height: 30,
                            ),
                            Image.asset('assets/images/bismillah.png',
                                color: Colors.white),
                            SizedBox(
                              height: 20,
                            ),
                            MediaPlayer(
                              source: surah.audio_url,
                              nomorsurah: surah.nomor.toString(),
                            ),
                          ],
                        ),
                      ),
                      ...generateWidget(),
                    ],
                  ),
                ),
              ),
            ),
          );
  }
}
