import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'assistmenu.dart';
import 'Classes/Color.dart';
import 'homepage.dart';

class difficulty extends StatefulWidget {
  difficulty({Key? key}) : super(key: key);

  @override
  _difficultyState createState() => _difficultyState();
}

class _difficultyState extends State<difficulty> {
  bool check = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Color(0xFF747474),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniStartTop,
      floatingActionButton: FloatingActionButton(
        backgroundColor: darkbrown,
        onPressed: () => Navigator.pop(context),
        child: Icon(CupertinoIcons.back),
      ),
      body: Stack(
        children: [
          background(),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                colorpicker(),
                SizedBox(height: 20,),
                MyButton(context, 'AI vs AI', assists(human: 3, check: check)),
                SizedBox(height: 20,),
                MyButton(context, 'Easy', assists(human: 2, check: check)),
                SizedBox(height: 20,),
                MyButton(context, 'Hard', assists(human: 2, check: check))
              ],
            ),
          ),
        ],
      ),
    );
  }

  colorpicker() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Player Color:',
          style: TextStyle(
              fontWeight: FontWeight.bold, fontSize: 35, color: Colors.white),
        ),
        SizedBox(
          width: 10,
        ),
        GestureDetector(
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: darkbrown, width: 2),
              borderRadius: BorderRadius.circular(5),
              color: check ? Colors.black : Colors.white,
            ),
            height: 60,
            width: 60,
          ),
          onTap: () {
            setState(() {
              check = !check;
            });
          },
        ),
      ],
    );
  }
}
