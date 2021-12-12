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
    return splash(context, status);
  }
}

splash(BuildContext context, String status) {
  return Scaffold(
    backgroundColor: Colors.black,
    body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              
              SizedBox(height: 20,),
              Container(child: Center(child: StyledText(status[0].toUpperCase()+status.substring(1)+'!'),),color: primary,width: MediaQuery.of(context).size.width/2),
              Expanded(child: Container(),),
              TextButton(
                style: TextButton.styleFrom(
                  fixedSize: Size(MediaQuery.of(context).size.width/2, MediaQuery.of(context).size.height / 10),
                  primary: Colors.white,
                  backgroundColor: darkbrown,
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