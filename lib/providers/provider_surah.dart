import 'package:e_quran/models/surah.dart';
import 'package:flutter/cupertino.dart';

class SurahProvider with ChangeNotifier {
  List<Surah> _surah = [];
  List<Surah> get surah {
    return [..._surah];
  }

  void set_surah(List<Surah> surah) {
    _surah = surah;
    notifyListeners();
  }
}
