import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'Classes/Color.dart';

class DrawSplash extends StatefulWidget {
  DrawSplash({Key? key, required this.status}) : super(key: key);
  String status;

  @override
  _DrawSplashState createState() => _DrawSplashState(status);
}

class _DrawSplashState extends State<DrawSplash> {
  @override
  String status = "";
  _DrawSplashState(String stat) {
    status = stat;
  }
  Widget build(BuildContext context) {
    return splash(status);
  }
  splash(String status) {
  return Scaffold(
    backgroundColor: Colors.transparent,
    body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(width: MediaQuery.of(context).size.width/2,height: 20,color: primary,),
              Container(child: Center(child: StyledText(status+'!')),color: primary,width: MediaQuery.of(context).size.width/2, height: MediaQuery.of(context).size.height / 10,),
              Expanded(child: Container(),),
              TextButton(
                style: TextButton.styleFrom(
                  fixedSize: Size(MediaQuery.of(context).size.width/2, MediaQuery.of(context).size.height / 10),
                  primary: Colors.white,
                  backgroundColor: buttoncolor,
                  
                ),
                onPressed: () {
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
                child: StyledText('Continue')
              ),
              SizedBox(height: 25,)
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