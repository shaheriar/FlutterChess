import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'Classes/Color.dart';
import 'homepage.dart';

class history extends StatefulWidget {
  history({Key? key}) : super(key: key);

  @override
  _historyState createState() => _historyState();
}

class _historyState extends State<history> {
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              title(),
              gameList(),
            ],
          ),
        ],
      ),
    );
  }

  title() {
    return Column(
      children: [
        Text(
          'History',
          style: TextStyle(
            color: Colors.white,
            fontSize: 80,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(
          height: 20,
        ),
      ],
    );
  }

  gameList() {
    return SizedBox(
      height: MediaQuery.of(context).size.height - 135,
      child: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: 6,
        itemBuilder: (BuildContext context, int index) {
          return Padding(
            padding: const EdgeInsets.all(10.0),
            child: TextButton(
              style: TextButton.styleFrom(
                fixedSize: Size(300, 100),
                primary: Colors.white,
                backgroundColor: darkbrown,
              ),
              onPressed: () {
                //OPEN GAME VIEW
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width / 4,
                    child: Text(
                      times[index],
                      style: TextStyle(fontSize: 35),
                    ),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width / 4,
                    child: Text(
                      winner[index],
                      style: TextStyle(fontSize: 35),
                    ),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width / 4,
                    child: Text(
                      moves[index],
                      style: TextStyle(fontSize: 35),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

List<String> times = [
  '5:00AM',
  '1:00AM',
  '10:00PM',
  '8:00PM',
  '12:00PM',
  '3:00PM'
];
List<String> winner = [
  'Black Won',
  'White Won',
  'White Won',
  'Black Won',
  'Black Won',
  'Black Won'
];
List<String> moves = [
  '30 Moves',
  '15 Moves',
  '23 Moves',
  '5 Moves',
  '50 Moves',
  '13 Moves'
];
