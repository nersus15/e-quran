import 'package:e_quran/values/custom_colors.dart';
import 'package:flutter/material.dart';

class CustomTabView extends StatelessWidget {
  const CustomTabView(
      {Key? key,
      this.activeWidget = 0,
      required this.widgets,
      required this.onClickTab,
      required this.tabs})
      : super(key: key);

  final void Function(int index) onClickTab;
  final List<Widget> widgets;
  final int activeWidget;
  final List<String> tabs;
  Widget getWidget() {
    return widgets[this.activeWidget];
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> _listOfTabBar = [];
    String? swipeDirection;
    for (var i = 0; i < tabs.length; i++) {
      _listOfTabBar.add(
        Container(
          decoration: i == activeWidget
              ? BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: primary, width: 3),
                  ),
                )
              : null,
          child: TextButton(
            onPressed: () {
              onClickTab(i);
            },
            child: Text(
              tabs[i],
              style: TextStyle(
                  color: i == activeWidget ? primary : secondary,
                  fontSize: 18,
                  fontFamily: 'Poppins-SemiBold',
                  fontWeight: FontWeight.w500),
            ),
          ),
        ),
      );
    }
    return Expanded(
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                    color: Color.fromARGB(255, 235, 228, 228), width: 3),
              ),
            ),
            margin: EdgeInsets.only(top: 30),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: _listOfTabBar,
            ),
          ),
          getWidget(),
        ],
      ),
    );
  }
}
