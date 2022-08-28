import 'dart:convert';
import 'dart:io';

import 'package:e_quran/models/surah.dart';
import 'package:e_quran/providers/provider_surah.dart';
import 'package:e_quran/screens/home_screen.dart';
import 'package:e_quran/values/custom_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:http/http.dart' as http;
import 'package:localstore/localstore.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool isWaiting = false;
  List<Surah> list_surah = [];
  final db = Localstore.instance;
  void Function;
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

  void Function2;
  fetchSurah() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        final response =
            await http.get(Uri.parse('https://equran.id/api/surat')).catchError(
          (err) {
            print("RES");
            print(err);
          },
          test: (error) {
            print("RES");
            print(error);
            return error is int && error >= 400;
          },
        );
        if (response.statusCode == 200) {
          isWaiting = false;
          List<dynamic> body = await jsonDecode(response.body);
          for (var i = 0; i < body.length; i++) {
            db.collection('surah').doc(i.toString()).set(body[i]);
            list_surah.add(Surah.fromJson(body[i]));
          }
          // Store to State
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
      final data = await db.collection('surah').get();
      if (data == null) {
        print("Use API");
        await fetchSurah();
      } else {
        print("Use Local Storage");
        for (var key in data.keys) {
          list_surah.add(Surah.fromJson(data[key]));
        }
        // for (var i = 0; i < data.keys.length; i++) {
        //   db.collection('surah').doc(i.toString()).delete();
        // }
      }

      while (isWaiting) {
        await fetchSurah();
      }

      Future.delayed(Duration(seconds: 1), () {
        if (!isWaiting) {
          // Set Data to Provider
          final provider = Provider.of<SurahProvider>(context, listen: false);
          provider.set_surah(list_surah);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomeScreen(),
            ),
          );
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            "Al-Qur'an Digital",
            style: TextStyle(
              color: primary,
              decoration: TextDecoration.none,
              fontSize: 35,
              fontFamily: 'Poppins-SemiBold',
            ),
          ),
          Container(
            child: Image.asset('assets/images/splashicon.png'),
          ),
          Column(
            children: [
              Text(
                "API By",
                style: TextStyle(
                  fontSize: 15,
                  fontFamily: 'Poppins-Light',
                  color: secondary,
                  decoration: TextDecoration.none,
                ),
              ),
              Text(
                "equran.id",
                style: TextStyle(
                  fontSize: 20,
                  fontFamily: 'Poppins-Light',
                  color: secondary,
                  decoration: TextDecoration.none,
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}
