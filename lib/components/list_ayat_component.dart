
import 'package:e_quran/models/ayat.dart';
import 'package:e_quran/models/bookmark.dart';
import 'package:e_quran/values/custom_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:localstore/localstore.dart';

class ListAyat extends StatefulWidget {
  const ListAyat(
      {Key? key,
      required this.ayat,
      required this.nama_surah,
      required this.nomor_surat})
      : super(key: key);
  final Ayat ayat;
  final String nama_surah, nomor_surat;
  @override
  State<ListAyat> createState() => _ListAyatState();
}

class _ListAyatState extends State<ListAyat> {
  final db = Localstore.instance;
  List<String> tanda = [];
  List<BookmarkModel> _bookmark = [];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final bookmark = await db.collection('bookmark').get();
      print("BM =========================>");
      print(bookmark);
      if (bookmark != null) {
        print("================ Masuk Bookmark Not Null ===============");
        List<BookmarkModel> tmp = [];
        for (var key in bookmark.keys) {
          tmp.add(BookmarkModel.fromJson(bookmark[key]));
        }
        setState(() {
          _bookmark = tmp;
        });
      } else if (bookmark == null) {
        print("================ Masuk Bookmark Null ===============");
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

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 20, bottom: 20),
      decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: devider.withOpacity(0.35)))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            key: Key(widget.ayat.toString()),
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
                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 13),
                  decoration: BoxDecoration(
                    color: primary,
                    borderRadius: BorderRadius.all(Radius.elliptical(30, 30)),
                  ),
                  child: Text(
                    widget.ayat.nomor.toString(),
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
                        Clipboard.setData(ClipboardData(
                            text:
                                "${widget.ayat.arab} \n\n ${widget.ayat.indonesia}"));
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text("Berhasil disalin ke clipboard"),
                        ));
                      },
                      icon: Icon(
                        Icons.copy_outlined,
                        color: primary,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return StatefulBuilder(
                              builder: (context, setState) {
                                return AlertDialog(
                                  title: Text(
                                    "Tambahkan ke penanda",
                                    style: TextStyle(color: primary),
                                  ),
                                  content: Container(
                                    height: MediaQuery.of(context).size.height *
                                        (20 / 100),
                                    child: SingleChildScrollView(
                                      child: Column(
                                        children: _bookmark.map((bm) {
                                          return Row(
                                            children: [
                                              Checkbox(
                                                  value: tanda.contains(bm.id),
                                                  onChanged: (val) {
                                                    if (val == null) return;
                                                    setState(() {
                                                      if (val)
                                                        tanda.add(bm.id);
                                                      else
                                                        tanda.remove(bm.id);
                                                    });
                                                  }),
                                              Text(bm.nama),
                                            ],
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () async {
                                        for (var i = 0; i < tanda.length; i++) {
                                          BookmarkModel oldata =
                                              _bookmark.firstWhere((element) {
                                            return element.id == tanda[i];
                                          });
                                          print(oldata);
                                          if (oldata.jenis == 'bertumpuk') {
                                            oldata.item.add({
                                              'surah': widget.nama_surah,
                                              'nomor_surah': widget.nomor_surat,
                                              'ayat': widget.ayat.nomor
                                            });
                                          } else if (oldata.jenis ==
                                              'berganti') {
                                            oldata.item = [
                                              {
                                                'surah': widget.nama_surah,
                                                'nomor_surah':
                                                    widget.nomor_surat,
                                                'ayat': widget.ayat.nomor
                                              }
                                            ];
                                          }
                                          print(
                                              "Debug ============= On Save ===============");
                                          print(tanda[i]);
                                          print(oldata.item);
                                          db
                                              .collection('bookmark')
                                              .doc(tanda[i])
                                              .set(
                                                  BookmarkModel.toJson(oldata));
                                        }
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(SnackBar(
                                          content:
                                              Text("Sudah ditambah ke penanda"),
                                        ));
                                        Navigator.pop(context);
                                      },
                                      child: Text(
                                        "Simpan",
                                        style:
                                            TextStyle(color: Colors.blueAccent),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: Text(
                                        "Batal",
                                        style: TextStyle(
                                            color: Color.fromARGB(
                                                255, 100, 22, 16)),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        );
                      },
                      icon: Icon(
                        Icons.bookmark_add_outlined,
                        color: primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Text(
            widget.ayat.arab,
            style: TextStyle(
              color: primary,
              fontFamily: 'Amiri-Regular',
              fontSize: 24,
            ),
            textAlign: TextAlign.end,
          ),
          SizedBox(
            height: 10,
          ),
          Text(
            widget.ayat.indonesia,
            textAlign: TextAlign.start,
            style: TextStyle(
              color: primary,
              fontFamily: 'Poppins-Medium',
              fontSize: 16,
            ),
          )
        ],
      ),
    );
  }
}
