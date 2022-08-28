import 'package:e_quran/values/custom_colors.dart';
import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget {
  const CustomAppBar(
      {Key? key, this.bisaKembali = false, this.title = "e-Qur'an"})
      : super(key: key);
  final bool bisaKembali;
  final String title;

  @override
  Widget build(BuildContext context) {
    List<Widget> Function;
    getWidget() {
      List<Widget> tmp = [];
      if (bisaKembali) {
        tmp.add(IconButton(
          onPressed: (() => Navigator.pop(context)),
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: secondary,
            size: 25,
          ),
        ));
      }
      tmp.add(Text(
        title,
        style: TextStyle(
          color: primary,
          fontSize: 25,
          fontFamily: 'Poppins-Medium',
          fontWeight: FontWeight.bold,
        ),
      ));
      // tmp.add(IconButton(
      //   onPressed: () {},
      //   icon: Icon(
      //     Icons.search,
      //     color: secondary,
      //     size: 25,
      //   ),
      // ));
      return tmp;
    }

    return Container(
      margin: EdgeInsets.only(top: 50, bottom: 30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: getWidget(),
      ),
    );
  }
}
