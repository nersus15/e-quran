
import 'package:e_quran/models/bookmark.dart';
import 'package:e_quran/screens/surah_screen.dart';
import 'package:e_quran/values/custom_colors.dart';
import 'package:flutter/material.dart';
import 'package:localstore/localstore.dart';

class BookMark extends StatefulWidget {
  const BookMark({Key? key}) : super(key: key);

  @override
  State<BookMark> createState() => _BookMarkState();
}

class _BookMarkState extends State<BookMark> {
  List<BookmarkModel> _bookmark = [];
  final db = Localstore.instance;

  static void Function;
  tambah(data) async {
    String id = BookmarkModel.randomid();
    data['id'] = id;
    db.collection('bookmark').doc(id).set(data);
    setState(() {
      _bookmark.add(BookmarkModel.fromJson(data));
    });
  }

  @override
  void initState() {
    print("Init State");
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final bookmark = await db.collection('bookmark').get();
      print("=================== Debug Bookmark ==============");
      print(bookmark);
      if (bookmark != null) {
        List<BookmarkModel> tmp = [];
        for (var key in bookmark.keys) {
          tmp.add(BookmarkModel.fromJson(bookmark[key]));
          // db.collection('bookmark').doc(bookmark[key]['id']).delete();
        }
        setState(() {
          _bookmark = tmp;
        });
      } else {
        BookmarkModel tmp = BookmarkModel(
          id: 'terakhir_dibaca',
          nama: "Terakhir Dibaca",
          jenis: "berganti",
          item: [],
        );
        db.collection('bookmark').doc(tmp.id).set(BookmarkModel.toJson(tmp));
        setState(() {
          _bookmark.add(tmp);
        });
      }
    });
  }

  onBack() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print("Welcome Back =============");
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView.builder(
        itemCount: _bookmark.length,
        itemBuilder: (context, index) {
          BookmarkModel bm = _bookmark[index];
          return GestureDetector(
            onTap: (() {
              if (bm.jenis == 'berganti') {
                if (bm.item.length == 0) return;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SurahScreen(
                      nomor_surat: int.parse(bm.item[0]['nomor_surah']),
                      nomor_ayat: bm.item[0]['ayat'].toString(),
                    ),
                  ),
                );
              } else if (bm.jenis == 'bertumpuk') {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text(
                        "Isi Penanda ${bm.nama}",
                        style: TextStyle(color: primary),
                      ),
                      content: Container(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height * (20 / 100),
                        child: SingleChildScrollView(
                          child: Column(
                            children: bm.item.map((item) {
                              return Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("${item['surah']}: ${item['ayat']}"),
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: Icon(Icons.delete),
                                        onPressed: () {
                                          BookmarkModel old = bm;
                                          old.item.removeWhere((element) =>
                                              element['nomor_surah'] ==
                                                  item['nomor_surah'] &&
                                              element['ayat'] == item['ayat']);
                                          print(old.item);
                                          db
                                              .collection('bookmark')
                                              .doc(bm.id)
                                              .set(BookmarkModel.toJson(old));
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(SnackBar(
                                            content: Text(
                                                "Item telah dihapus dari penanda"),
                                          ));
                                          setState(() {});
                                        },
                                      ),
                                      IconButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => SurahScreen(
                                                nomor_ayat:
                                                    item['ayat'].toString(),
                                                nomor_surat: int.parse(
                                                    item['nomor_surah']),
                                              ),
                                            ),
                                          );
                                        },
                                        icon:
                                            Icon(Icons.remove_red_eye_outlined),
                                      ),
                                    ],
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text(
                            "Batal",
                            style: TextStyle(
                                color: Color.fromARGB(255, 100, 22, 16)),
                          ),
                        ),
                      ],
                    );
                  },
                );
              }
            }),
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 0),
              decoration: BoxDecoration(
                border: Border(
                    bottom:
                        BorderSide(color: devider.withOpacity(0.35), width: 1)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        bm.nama,
                        style: TextStyle(
                          color: primary,
                          fontSize: 20,
                        ),
                      ),
                      Text(
                        bm.jenis,
                        style: TextStyle(color: secondary),
                      )
                    ],
                  ),
                  bm.jenis == 'berganti'
                      ? Text(
                          bm.item.length > 0
                              ? "${bm.item[0]['surah']}: ${bm.item[0]['ayat']}"
                              : 'Tidak ada',
                          style: TextStyle(color: primary),
                        )
                      : Text("Klik untuk melihat"),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: Text("Hapus Penanda"),
                                content: Container(
                                  child: Text(
                                      "Apakah anda yakin ingin menghapus penanda ${bm.nama}"),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () async {
                                      await db
                                          .collection('bookmark')
                                          .doc(bm.id)
                                          .delete();

                                      setState(() {
                                        _bookmark.removeWhere(
                                            (element) => element.id == bm.id);
                                      });
                                      Navigator.pop(context);
                                    },
                                    child: Text(
                                      "Hapus",
                                      style: TextStyle(
                                        color: Colors.blueAccent,
                                      ),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: Text(
                                      "Batal",
                                      style: TextStyle(
                                        color: Color.fromARGB(255, 129, 30, 23),
                                      ),
                                    ),
                                  )
                                ],
                              );
                            },
                          );
                        },
                        icon: Icon(
                          Icons.delete,
                          color: primary,
                          size: 20,
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
