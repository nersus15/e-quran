import 'dart:convert';
import 'dart:io';

import 'package:e_quran/values/custom_colors.dart';
import 'package:e_quran/widgets/appbar.dart';
import 'package:e_quran/widgets/cardgradient.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:http/http.dart' as http;
import 'package:localstore/localstore.dart';

class TafsirScreen extends StatefulWidget {
  const TafsirScreen({Key? key, required this.nomor_surah}) : super(key: key);
  final int nomor_surah;
  @override
  State<TafsirScreen> createState() => _TafsirScreenState();
}

class _TafsirScreenState extends State<TafsirScreen> {
  final _scrollController = ScrollController();
  final db = Localstore.instance;
  late Map<String, dynamic> tafsir = {};
  bool isWaiting = false;
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

  Future fetchTafsir() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        final response = await http.get(Uri.parse(
            'https://equran.id/api/tafsir/' + widget.nomor_surah.toString()));
        if (response.statusCode == 200) {
          isWaiting = false;
          Map<String, dynamic> body = await jsonDecode(response.body);
          return body;
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
      var data = await db
          .collection('tafsir')
          .doc((widget.nomor_surah).toString())
          .get();

      if (data == null) {
        print("Fetching Tafsir");
        Map<String, dynamic> a = await fetchTafsir();
        while (isWaiting) {
          await fetchTafsir();
        }
        db.collection('tafsir').doc((widget.nomor_surah).toString()).set(a);
        setState(() {
          tafsir = a;
        });
      } else {
        print("Use Local data");
        setState(() {
          tafsir = data;
        });
      }
    });
  }

  List<Widget> getWidget(List data) {
    data.sort(
      (a, b) => a['ayat'].compareTo(b['ayat']),
    );
    return data.map((e) {
      return Container(
          padding: EdgeInsets.only(top: 20, bottom: 20),
          decoration: BoxDecoration(
              border:
                  Border(bottom: BorderSide(color: devider.withOpacity(0.35)))),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                key: Key(e['ayat'].toString()),
                margin: EdgeInsets.only(bottom: 20),
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: backgroundAction.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding:
                          EdgeInsets.symmetric(vertical: 8, horizontal: 13),
                      decoration: BoxDecoration(
                        color: primary,
                        borderRadius:
                            BorderRadius.all(Radius.elliptical(30, 30)),
                      ),
                      child: Text(
                        e['ayat'].toString(),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: e['tafsir']));
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text("Berhasil disalin ke clipboard"),
                            ));
                          },
                          icon: Icon(
                            Icons.copy_outlined,
                            color: primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Html(
              //   data: "<p>${e['tafsir']}</p>",
              //   style: {
              //     'p': Style(
              //       color: primary,
              //       fontFamily: 'Poppins-Medium',
              //       fontSize: FontSize.medium,
              //     )
              //   },
              // ),
              Text(
                e['tafsir'],
                textAlign: TextAlign.start,
                style: TextStyle(
                  color: primary,
                  fontFamily: 'Poppins-Medium',
                  fontSize: 16,
                ),
              )
            ],
          ));
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return tafsir['status'] == null
        ? Scaffold(
            body: Container(
              child: Center(
                child: Text("Loading"),
              ),
            ),
          )
        : Scaffold(
            body: Dismissible(
              key: Key(widget.nomor_surah.toString()),
              onDismissed: (direction) {
                if (direction == DismissDirection.startToEnd) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          TafsirScreen(nomor_surah: widget.nomor_surah - 1),
                    ),
                  );
                } else if (direction == DismissDirection.endToStart) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          TafsirScreen(nomor_surah: widget.nomor_surah + 1),
                    ),
                  );
                }
              },
              confirmDismiss: (direction) async {
                if (direction == DismissDirection.startToEnd) {
                  return widget.nomor_surah > 1;
                } else if (direction == DismissDirection.endToStart) {
                  return widget.nomor_surah < 144;
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
                        title: 'Tafsir Surah',
                      ),
                      CardGradient(
                        child: Column(
                          children: [
                            Text(
                              "${tafsir['nama_latin']} (${widget.nomor_surah})",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 25,
                                fontFamily: 'Poppins-Medium',
                              ),
                            ),
                            Text(
                              tafsir['arti'],
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
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
                              "Deskripsi Surah",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Html(data: "<p>${tafsir['deskripsi']}</p>", style: {
                              'p': Style(
                                  color: Colors.white,
                                  textAlign: TextAlign.justify,
                                  fontSize: FontSize.rem(1.13))
                            })
                          ],
                        ),
                      ),
                      ...getWidget(tafsir['tafsir'])
                    ],
                  ),
                ),
              ),
            ),
          );
  }
}
