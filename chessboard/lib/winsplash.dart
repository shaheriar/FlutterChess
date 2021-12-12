import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'Classes/Color.dart';

class WinSplash extends StatefulWidget {
  WinSplash({Key? key, required this.win}) : super(key: key);
  bool win;

  @override
  _WinSplashState createState() => _WinSplashState(win);
}

class _WinSplashState extends State<WinSplash> {
  @override
  bool winner = false;
  _WinSplashState(bool win) {
    winner = win;
  }
  Widget build(BuildContext context) {
    return WillPopScope(child: splash(winner), onWillPop: () async => false,);
  }
  

splash(bool win) {
  return Scaffold(
    backgroundColor: Colors.transparent,
    body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 20,),
              Container(child: Center(child: win ? StyledText('White Won!') : StyledText('Black Won!'),),color: primary,width: MediaQuery.of(context).size.width/2),
              Expanded(child: Container(),),
              TextButton(
                style: TextButton.styleFrom(
                  fixedSize: Size(MediaQuery.of(context).size.width/2, MediaQuery.of(context).size.height / 10),
                  primary: Colors.white,
                  backgroundColor: primary,
                ),
                onPressed: () {
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
                child: StyledText('Continue')
              ),
              SizedBox(height: 20,)
            ],
          )
      ),
  );
}
}

StyledText(String text) {
  return Text(
    text,
    style: TextStyle(
      fontSize: 50,
      color: Colors.white,
      fontWeight: FontWeight.bold
    ),
  );
}