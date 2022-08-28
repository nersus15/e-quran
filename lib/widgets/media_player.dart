import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:audioplayers/audioplayers.dart';
import 'package:e_quran/values/custom_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:localstore/localstore.dart';
import 'package:path_provider/path_provider.dart';

class MediaPlayer extends StatefulWidget {
  MediaPlayer({required this.source, required this.nomorsurah});
  final String source, nomorsurah;
  @override
  _MediaPlayerState createState() => _MediaPlayerState();
}

class _MediaPlayerState extends State<MediaPlayer> {
  bool play = false;
  final player = AudioPlayer();
  late Duration _duration;
  late Duration _position;
  final db = Localstore.instance;
  late String dir;
  String downloadid = '';
  double time = 0;
  bool adadilokal = false;
  @override
  // TODO: implement mounted
  bool get mounted => super.mounted;
  ReceivePort _port = ReceivePort();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      dir = await _localPath;
      print("Lpcal Dir ==========> ");
      print(dir);
      adadilokal = await _audioFile;
      final data =
          await db.collection('downloadid').doc(widget.nomorsurah).get();

      if (data != null) downloadid = data['taskid'];
      final tmp = await _audioFile;
      if (tmp) {
        setState(() {
          adadilokal = tmp;
        });
      }
    });

    IsolateNameServer.registerPortWithName(
        _port.sendPort, 'downloader_send_port');
    _port.listen((dynamic data) {
      String id = data[0];
      DownloadTaskStatus status = data[1];
      int progress = data[2];
    });

    FlutterDownloader.registerCallback(downloadCallback);
  }

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  Future<bool> get _audioFile async {
    final path = await _localPath;
    return File('$path/${widget.nomorsurah}.mp3').exists();
  }

  @pragma('vm:entry-point')
  static void downloadCallback(
      String id, DownloadTaskStatus status, int progress) {
    final SendPort? send =
        IsolateNameServer.lookupPortByName('downloader_send_port');
    send?.send([id, status, progress]);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    player.stop();
    FlutterDownloader.cancelAll();
  }

  @override
  Widget build(BuildContext context) {
    print("Ada dilokal " + adadilokal.toString());
    return Container(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () {
                  print(play);
                  if (play) {
                    print("Pause Audio");
                    player.pause();
                  } else {
                    print("Start Audio");
                    player.play(adadilokal
                        ? DeviceFileSource("$dir/${widget.nomorsurah}.mp3")
                        : UrlSource(widget.source));
                    player.onPlayerComplete.listen((event) {
                      setState(() {
                        play = false;
                      });
                    });
                  }
                  setState(() {
                    play = !play;
                  });
                },
                icon: Icon(
                  play
                      ? Icons.pause_circle_outline_rounded
                      : Icons.play_circle_outline_outlined,
                  size: 35,
                  color: Colors.white,
                ),
              ),
              IconButton(
                tooltip: adadilokal
                    ? "Sudah di download"
                    : "Download audio untuk mendengarkan tanpa internet",
                onPressed: () async {
                  print(dir + '/' + widget.nomorsurah + '.mp3');
                  if (adadilokal) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text("Sudah didownload"),
                    ));
                  } else {
                    // if (downloadid != '') {
                    //   FlutterDownloader.retry(taskId: downloadid);
                    // } else {
                    final taskId = await FlutterDownloader.enqueue(
                      url: widget.source,
                      headers: {}, // optional: header send with url (auth token etc)
                      savedDir: dir,
                      fileName: widget.nomorsurah + '.mp3',
                      showNotification:
                          true, // show download progress in status bar (for Android)
                      openFileFromNotification:
                          false, // click on notification to open downloaded file (for Android)
                    );
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text("Proses download dimulai"),
                    ));
                    // Uint8List bytes = UrlSource(widget.source).

                    db
                        .collection('downloadid')
                        .doc(widget.nomorsurah)
                        .set({'taskid': taskId});
                    // }
                  }
                },
                icon: Icon(Icons.download_outlined),
                color: adadilokal ? primary : Colors.white,
              )
            ],
          ),
          // Slider(
          //   value: play ? _duration.inSeconds.toDouble() : time,
          //   min: 0,
          //   max: _duration.inSeconds.toDouble(),
          //   activeColor: Colors.white,
          //   inactiveColor: primary,
          //   onChanged: (value) {
          //     if (!play) return;

          //   },
          // ),
        ],
      ),
    );
  }
}
