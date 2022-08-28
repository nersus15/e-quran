import 'package:flutter/cupertino.dart';

class CardGradient extends StatelessWidget {
  const CardGradient({Key? key, required this.child}) : super(key: key);
  final Widget child;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: FractionalOffset.topLeft,
          end: FractionalOffset.bottomRight,
          colors: [Color(0xFFDF98FA), Color(0xFF9055FF)],
        ),
        borderRadius: BorderRadius.all(Radius.circular(15)),
      ),
      child: child,
    );
  }
}
