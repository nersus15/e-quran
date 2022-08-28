import 'package:e_quran/components/list_bookmark.dart';
import 'package:e_quran/components/list_surah_component.dart';
import 'package:e_quran/components/tab_bar_component.dart';
import 'package:e_quran/models/bookmark.dart';
import 'package:e_quran/values/custom_colors.dart';
import 'package:e_quran/widgets/appbar.dart';
import 'package:e_quran/widgets/cardgradient.dart';
import 'package:flutter/material.dart';
import 'package:localstore/localstore.dart';

class HomeScreen extends StatefulWidget {
  static final namespce = '/homescreen';
  const HomeScreen();

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int activeIndex = 0;
  final _namaPenandaController = TextEditingController();
  String _jenisBookmark = 'berganti';
  final db = Localstore.instance;
  Map<String, dynamic> _bookmark = {};
  void Function;
  tambah(data) async {
    String id = BookmarkModel.randomid();
    data['id'] = id;
    db.collection('bookmark').doc(id).set(data);
    setState(() {
      _jenisBookmark = 'berganti';
      _namaPenandaController.value = TextEditingValue.empty;
      activeIndex = 0;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      Map<String, dynamic>? b =
          await db.collection('bookmark').doc('terakhir_dibaca').get();
      setState(() {
        _bookmark = b!;
      });
    });
  }

  void moveTab(index) {
    setState(() {
      activeIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<dynamic> item = [];
    // if (_bookmark.keys.length == 0) {
    //   print(_bookmark);
    //   return Scaffold(
    //     body: Container(
    //       child: Center(child: Text("Loading")),
    //     ),
    //   );
    // } else {
    print(_bookmark);
    item = _bookmark['item'] ?? [];
    // ignore: unnecessary_null_comparison
    if (item == null || item.length == 0) {
      item.add({'surah': 'Tidak tercatat', 'ayat': null});
    }
    return Scaffold(
      body: Container(
        margin: EdgeInsets.only(left: 25, right: 25),
        color: Colors.white,
        child: Column(
          children: [
            CustomAppBar(),
            CardGradient(
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.menu_book,
                            color: Colors.white,
                          ),
                          Text(
                            "Terakhir Dibaca",
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.white,
                              fontFamily: 'Poppins-Regular',
                            ),
                          )
                        ],
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Text(
                        item[0]['surah'],
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontFamily: 'Poppins-SemiBold',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "Ayat No: ${item[0]['ayat']}",
                        style: TextStyle(color: Colors.white, fontSize: 15),
                      )
                    ],
                  ),
                  Image.asset(
                    'assets/images/quran.png',
                  )
                ],
              ),
            ),
            CustomTabView(
                activeWidget: activeIndex,
                onClickTab: moveTab,
                widgets: [ListSurah(), BookMark()],
                tabs: ['Surah', 'Penanda'])
          ],
        ),
      ),
      floatingActionButton: Visibility(
        visible: activeIndex == 1,
        child: FloatingActionButton(
          backgroundColor: primary,
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) {
                return StatefulBuilder(
                  builder: (context, setState) {
                    return AlertDialog(
                      title: Text("Tambah Penanda"),
                      content: Container(
                        height: MediaQuery.of(context).size.height * (20 / 100),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Nama Penanda"),
                            TextField(
                              controller: _namaPenandaController,
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text("Jenis Penanda"),
                            DropdownButton(
                              value: _jenisBookmark,
                              items: [
                                DropdownMenuItem(
                                  child: Text(
                                    "Berganti",
                                    style: TextStyle(
                                        color: _jenisBookmark == 'berganti'
                                            ? primary
                                            : secondary),
                                  ),
                                  value: 'berganti',
                                ),
                                DropdownMenuItem(
                                  child: Text(
                                    "Bertumpuk",
                                    style: TextStyle(
                                        color: _jenisBookmark == 'bertumpuk'
                                            ? primary
                                            : secondary),
                                  ),
                                  value: 'bertumpuk',
                                )
                              ],
                              onChanged: (value) {
                                print(value.toString());
                                setState(() {
                                  _jenisBookmark = value.toString();
                                });
                              },
                            )
                          ],
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () async {
                            await tambah({
                              'nama':
                                  _namaPenandaController.value.text.toString(),
                              'jenis': _jenisBookmark,
                              'item': []
                            });
                            Navigator.pop(context);
                          },
                          child: Text(
                            "Simpan",
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
            );
          },
          child: Icon(Icons.add),
        ),
      ),
    );
  }
  // }
}
