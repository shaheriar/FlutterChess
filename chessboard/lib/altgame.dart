import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'Classes/Color.dart';
import 'game.dart';
import 'winsplash.dart';
import 'Classes/Assists.dart';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class altgame extends StatefulWidget {
  altgame({Key? key, required this.assists}) : super(key: key);
  Assists assists;

  @override
  _altgameState createState() => _altgameState(assists);
}

class _altgameState extends State<altgame> {
  final _channel = WebSocketChannel.connect(
    Uri.parse('ws://localhost:8765'),
  );
  var bmin;
  var bsec;
  var wmin;
  var wsec;
  bool flag = false;
  bool winner = false;
  bool turn = false;
  int movefrom = -1;
  int moveto = -1;
  bool fromclicked = false;
  bool toclicked = false;
  List<dynamic> boardlist = [];
  ScrollController _scrollControllerw = ScrollController();
  ScrollController _scrollControllerb = ScrollController();
  List<String> moves = [];
  Assists inf = Assists(false, false, 0, false);

  _altgameState(Assists assists) {
    inf = assists;
    turn = inf.check;
  }
  _scrollw() {
    _scrollControllerw.jumpTo(_scrollControllerw.position.maxScrollExtent);
  }

  _scrollb() {
    _scrollControllerb.jumpTo(_scrollControllerb.position.maxScrollExtent);
  }

  @override
  void initState() {
    super.initState();
    bmin = 30;
    bsec = 0;
    wmin = 30;
    wsec = 0;
    boardlist = List.from(defaultboard.reversed);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: primary,
      body: Container(
        height: MediaQuery.of(context).size.height,
        child: Column(
          children: [
            times(),
            Container(
              height: 10,
              color: primary,
            ),
            moveslist(),
            buttons(),
          ],
        ),
      ),
    );
  }

  times() {
    return StreamBuilder(
        stream: Stream.periodic(const Duration(seconds: 1)),
        builder: (context, snapshot) {
          if (moves.length % 2 == 0) {
            turn = false;
            whitetime();
          } else {
            turn = true;
            blacktime();
          }
          if (bsec == 0 && bmin == 0) {
            Map mp = {
              'status': 'Time'
            };
            _channel.sink.add(jsonEncode(mp));
            flag = true;
            winner = flag;
            Future.delayed(Duration.zero, () async {
              Navigator.pushReplacement(
                context,
                PageRouteBuilder(
                  opaque: false,
                  pageBuilder: (context, animation1, animation2) =>
                      WinSplash(win: true),
                ),
              );
            });
          } else if (wsec == 0 && wmin == 0) {
            _channel.sink.add('Time');
            flag = true;
            winner = !flag;
            Future.delayed(Duration.zero, () async {
              Navigator.pushReplacement(
                context,
                PageRouteBuilder(
                  opaque: false,
                  pageBuilder: (context, animation1, animation2) =>
                      WinSplash(win: false),
                ),
              );
            });
          }
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                color: lightbrown,
                width: MediaQuery.of(context).size.width / 2 - 5,
                child: Center(
                  child: Text(
                    formattime(wmin, wsec),
                    style: TextStyle(
                        fontSize: MediaQuery.of(context).size.width / 8,
                        color: primary),
                  ),
                ),
              ),
              Container(
                color: darkbrown,
                width: MediaQuery.of(context).size.width / 2 - 5,
                child: Center(
                  child: Text(
                    formattime(bmin, bsec),
                    style: TextStyle(
                        fontSize: MediaQuery.of(context).size.width / 8,
                        color: Colors.white),
                  ),
                ),
              ),
            ],
          );
        });
  }

  Widget chessboard() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          height: 400,
          width: 20,
          child: ListView.builder(
              itemCount: 8,
              itemBuilder: (BuildContext context, int index) {
                int i = 8 - index;
                return SizedBox(
                    height: 50,
                    child: Text(
                      '$i',
                      style: TextStyle(color: Colors.white),
                    ),
                );
              }),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            SizedBox(
              height: 400,
              width: 400,
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 8,
                ),
                itemBuilder: _buildGridItems,
                itemCount: 64,
              ),
            ),
            Container(
              width: 400,
              height: 20,
              child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: 8,
                  itemBuilder: (BuildContext context, int index) {
                    String c = String.fromCharCode(index + 97);
                    return SizedBox(
                      width: 50,
                      child: Center(
                        child: Text(
                          '$c',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    );
                  }),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGridItems(BuildContext context, int index) {
    return GridTile(
      child: GestureDetector(
        onTap: () {
          setState(() {
            
          if (!fromclicked) {
            movefrom = index;
            fromclicked = true;
          } else if (fromclicked && !toclicked) {
            moveto = index;
            toclicked = true;
          } else {
            fromclicked = false;
            toclicked = false;
            movefrom = -1;
            moveto = -1;
          }
          if (movefrom != -1 && moveto != -1) {
            if (movefrom == moveto) {
              fromclicked = false;
              toclicked = false;
              movefrom = -1;
              moveto = -1;
            } else {

          Map map = {
          'from': translate(movefrom), 
          'to': translate(moveto),
          'status': 'inprogress'
          };
          String mp = jsonEncode(map);
          _channel.sink.add(mp);
          
            fromclicked = false;
            toclicked = false;
            movefrom = -1;
            moveto = -1;

            }
            
          }
          });
        },
        child: Stack(
          children: [
            Container(
              width: 90,
              height: 90,
              color: movefrom == index ? Colors.green : getcolor(index),
            ),
            Center(child: getpiece(boardlist[index].toString())),
          ],
        ),
      ),
    );
  }

  translate(int n) {
    int j = (n / 8).floor();
    int k = n % 8;
    int h = 64 - (8 - k) - (8*j);
    return h;
  }

  moveslist() {
    return StreamBuilder(
        stream: _channel.stream,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            var data = jsonDecode(snapshot.data.toString());
            if (data["move"] != null) {
              if (!moves.contains(data["move"])) {
                moves.add(data["move"]);
              }
            }
            if (data["board"] != null) {
              boardlist = data["board"];
              boardlist = List.from(boardlist);
            }
            print(data);
          }
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                color: lightbrown,
                width: MediaQuery.of(context).size.width / 4 - 5,
                height: MediaQuery.of(context).size.height / 2,
                child: ListView.builder(
                  controller: _scrollControllerw,
                  reverse: true,
                  shrinkWrap: true,
                  itemCount: moves.length,
                  itemBuilder: (context, index) {
                    _scrollw();
                    return Center(child: getMove(true, index));
                  },
                ),
              ),
              chessboard(),
              Container(
                color: darkbrown,
                width: MediaQuery.of(context).size.width / 5 - 5,
                height: MediaQuery.of(context).size.height / 2,
                child: ListView.builder(
                  controller: _scrollControllerb,
                  reverse: true,
                  shrinkWrap: true,
                  itemCount: moves.length,
                  itemBuilder: (context, index) {
                    _scrollb();
                    return Center(child: getMove(false, index));
                  },
                ),
              ),
            ],
          );
        });
  }

  buttons() {
    return Container(
      color: primary,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          offerdraw(),
          altresignbutton(),
        ],
      ),
    );
  }

  whitetime() {
    if (!flag) {
      wsec--;
      if (wsec < 0) {
        wsec = 59;
        wmin--;
      }
    }
  }

  blacktime() {
    if (!flag) {
      bsec--;
      if (bsec < 0) {
        bsec = 59;
        bmin--;
      }
    }
  }

  formattime(int min, int sec) {
    if (sec < 10) {
      if (min < 10) {
        return "0$min:0$sec";
      }
      return "$min:0$sec";
    } else {
      if (min < 10) {
        return "0$min:$sec";
      }
      return "$min:$sec";
    }
  }

  Widget getMove(bool p, int index) {
    if (p) {
      if (index % 2 == 0) {
        return Text(
          moves[index],
          style: TextStyle(fontSize: 50, color: primary),
        );
      } else {
        return Container();
      }
    } else {
      if (index % 2 == 1) {
        return Text(
          moves[index],
          style: TextStyle(fontSize: 50, color: Colors.white),
        );
      } else {
        return Container();
      }
    }
  }

  Widget altresignbutton() {
    return TextButton(
      style: TextButton.styleFrom(
        fixedSize: Size(MediaQuery.of(context).size.width / 3,
            MediaQuery.of(context).size.height / 8),
        primary: Colors.white,
        backgroundColor: primary,
      ),
      onPressed: () {
        Map mp = {
                    'status': 'Resign'
                  };
        _channel.sink.add(jsonEncode(mp));
        Navigator.push(
          context,
          PageRouteBuilder(
            opaque: false,
            pageBuilder: (context, animation1, animation2) =>
                WinSplash(win: turn),
          ),
        );
      },
      child: Text(
        'Resign',
        style: TextStyle(fontSize: MediaQuery.of(context).size.width / 16),
      ),
    );
  }

  Widget offerdraw() {
    return TextButton(
      style: TextButton.styleFrom(
        fixedSize: Size(MediaQuery.of(context).size.width / 3,
            MediaQuery.of(context).size.height / 8),
        primary: Colors.white,
        backgroundColor: primary,
      ),
      onPressed: () {
        Navigator.push(
          context,
          PageRouteBuilder(
            opaque: false,
            pageBuilder: (context, animation1, animation2) => splash(),
          ),
        );
      },
      child: Text(
        'Offer Draw',
        style: TextStyle(fontSize: MediaQuery.of(context).size.width / 16),
      ),
    );
  }

  splash() {
    return Scaffold(
      backgroundColor: Colors.black87,
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          StyledText('Accept Draw?'),
          SizedBox(
            height: 20,
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                style: TextButton.styleFrom(
                  fixedSize: Size(200, 60),
                  primary: Colors.white,
                  backgroundColor: darkbrown,
                ),
                onPressed: () {
                  Map mp = {
                    'status': 'Draw'
                  };
                  _channel.sink.add(jsonEncode(mp));
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
                child: Text(
                  'Yes',
                  style: TextStyle(fontSize: 35),
                ),
              ),
              SizedBox(
                width: 20,
              ),
              TextButton(
                style: TextButton.styleFrom(
                  fixedSize: Size(200, 60),
                  primary: Colors.white,
                  backgroundColor: darkbrown,
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  'No',
                  style: TextStyle(fontSize: 35),
                ),
              ),
            ],
          ),
        ],
      )),
    );
  }

  StyledText(String text) {
    return Text(
      text,
      style: TextStyle(
          fontSize: 50, color: Colors.white, fontWeight: FontWeight.bold),
    );
  }
}

List<String> defaultboard = [
  'R',
  'N',
  'B',
  'K',
  'Q',
  'B',
  'N',
  'R',
  'P',
  'P',
  'P',
  'P',
  'P',
  'P',
  'P',
  'P',
  '.',
  '.',
  '.',
  '.',
  '.',
  '.',
  '.',
  '.',
  '.',
  '.',
  '.',
  '.',
  '.',
  '.',
  '.',
  '.',
  '.',
  '.',
  '.',
  '.',
  '.',
  '.',
  '.',
  '.',
  '.',
  '.',
  '.',
  '.',
  '.',
  '.',
  '.',
  '.',
  'p',
  'p',
  'p',
  'p',
  'p',
  'p',
  'p',
  'p',
  'r',
  'n',
  'b',
  'k',
  'q',
  'b',
  'n',
  'r'
];
