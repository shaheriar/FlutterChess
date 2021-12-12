import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'Classes/Color.dart';
import 'drawsplash.dart';
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
  bool ischeck = false;
  int movefrom = -1;
  int moveto = -1;
  bool fromclicked = false;
  bool toclicked = false;
  bool thinking = false;
  List<dynamic> boardlist = [];
  List<dynamic> legalmoves = [];
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
    legalmoves = ['g1h3', 'g1f3', 'b1c3', 'b1a3', 'h2h3', 'g2g3', 'f2f3', 'e2e3', 'd2d3', 'c2c3', 'b2b3', 'a2a3', 'h2h4', 'g2g4', 'f2f4', 'e2e4', 'd2d4', 'c2c4', 'b2b4', 'a2a4'];
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
                width: MediaQuery.of(context).size.width / 4,
                child: Center(
                  child: Text(
                    formattime(wmin, wsec),
                    style: TextStyle(
                        fontSize: MediaQuery.of(context).size.width / 20,
                        color: primary),
                  ),
                ),
              ),
              ischeck ? Text('Check!',style: TextStyle(color: Colors.white, fontSize: 50)) : turn ? Text('Black\'s Turn',style: TextStyle(color: Colors.white, fontSize: 50)) : Text('White\'s Turn',style: TextStyle(color: Colors.white, fontSize: 50)),
              Container(height: 50,width: 50,child: (turn != inf.check && inf.h != 1) ?  CircularProgressIndicator(color: Colors.white,) : Container(),),
              Text('Move ${moves.length}', style: TextStyle(color: Colors.white, fontSize: 50),),
              Container(
                color: darkbrown,
                width: MediaQuery.of(context).size.width / 4,
                child: Center(
                  child: Text(
                    formattime(bmin, bsec),
                    style: TextStyle(
                        fontSize: MediaQuery.of(context).size.width / 20,
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
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          height: MediaQuery.of(context).size.width / 3,
          width: 20,
          child: ListView.builder(
              itemCount: 8,
              reverse: true,
              itemBuilder: (BuildContext context, int index) {
                int i = index+1;
                return Container(
                    height: (MediaQuery.of(context).size.width / 3)/8,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        '$i',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                );
              }),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.width / 3,
              width: MediaQuery.of(context).size.width / 3,
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 8,
                ),
                itemBuilder: _buildGridItems,
                itemCount: 64,
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width / 3,
              height: 20,
              child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: 8,
                  itemBuilder: (BuildContext context, int index) {
                    String c = String.fromCharCode(index + 97);
                    return SizedBox(
                      width: (MediaQuery.of(context).size.width / 3)/8,
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
            if (turn) {
              bsec += 1;
            } else {
              wsec += 1;
            }
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
              color: moves.length > 0 ? ((moves[moves.length-1].substring(0,2) == squares[translate(index)] || moves[moves.length-1].substring(2) == squares[translate(index)]) ? Colors.amber : getcolor(index)) : getcolor(index),
            ),
            
            Center(child: getpiece(boardlist[index].toString())),
            Center(
              child: Container(
                width: 20,
                height: 20,
          decoration: BoxDecoration(
              color: decidecolor(movefrom, index),
              shape: BoxShape.circle
          ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  decidecolor(int movefrom, int index) {
    if (boardlist[index].toString() == 'K' && turn) {
      if (ischeck) {
        return Colors.red;
      }
    } else if (boardlist[index].toString() == 'k' && !turn) {
      if (ischeck) {
        return Colors.red;
      }
    }
    if (movefrom == index) {
      return Colors.green;
    } else if (legalmoves.length > 0 && movefrom != -1) {
      for (int i = 0; i < legalmoves.length; i++) {
      if (legalmoves[i].substring(0,2) == squares[translate(movefrom)]) {
        for (int j = 0; j < squares.length; j++) {
          if (squares[j] == legalmoves[i].substring(2) && j == translate(index)) {
            return Colors.yellow;
          }
        }
      }
    }
    }
    return Colors.transparent;
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
            if (data["ischeck"] != null) {
              ischeck = data["ischeck"];
            }
            if (data["status"] != null) {
              String status = data["status"];
              if (status == "checkmate" || status == "stalemate" || status == "repetition") {
                if (status == "checkmate") {
                  WidgetsBinding.instance!.addPostFrameCallback(
     (_) => Navigator.push(
          context,
          PageRouteBuilder(
            opaque: false,
            pageBuilder: (context, animation1, animation2) =>
                WinSplash(win: turn),
          ),
        ),);
                } else {
                   WidgetsBinding.instance!.addPostFrameCallback(
     (_) => Navigator.push(
          context,
          PageRouteBuilder(
            opaque: false,
            pageBuilder: (context, animation1, animation2) =>
                DrawSplash(status: status),
          ),
        ),);
                }
              }
            }
            if (data["legalmoves"] != null) {
              legalmoves = data["legalmoves"];
            }
            print(data);
          } else {
            thinking = true;
          }
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                color: lightbrown,
                width: MediaQuery.of(context).size.width / 4,
                height: MediaQuery.of(context).size.height - 200,
                child: ListView.builder(
                  controller: _scrollControllerw,
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
                width: MediaQuery.of(context).size.width / 4,
                height: MediaQuery.of(context).size.height - 200,
                child: ListView.builder(
                  controller: _scrollControllerb,
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
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(color: lightbrown,height: MediaQuery.of(context).size.height / 10,width: MediaQuery.of(context).size.width / 4,),
          offerdraw(),
          altresignbutton(),
          Container(color: darkbrown,height: MediaQuery.of(context).size.height / 10,width: MediaQuery.of(context).size.width / 4,),
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
        fixedSize: Size(MediaQuery.of(context).size.width / 4,
            MediaQuery.of(context).size.height / 10),
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
        style: TextStyle(fontSize: 50),
      ),
    );
  }

  Widget offerdraw() {
    return TextButton(
      style: TextButton.styleFrom(
        fixedSize: Size(MediaQuery.of(context).size.width / 4,
            MediaQuery.of(context).size.height / 10),
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
        style: TextStyle(fontSize: 50),
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

List<String> squares = [
    'a1', 'b1', 'c1', 'd1', 'e1', 'f1', 'g1', 'h1',
    'a2', 'b2', 'c2', 'd2', 'e2', 'f2', 'g2', 'h2',
    'a3', 'b3', 'c3', 'd3', 'e3', 'f3', 'g3', 'h3',
    'a4', 'b4', 'c4', 'd4', 'e4', 'f4', 'g4', 'h4',
    'a5', 'b5', 'c5', 'd5', 'e5', 'f5', 'g5', 'h5',
    'a6', 'b6', 'c6', 'd6', 'e6', 'f6', 'g6', 'h6',
    'a7', 'b7', 'c7', 'd7', 'e7', 'f7', 'g7', 'h7',
    'a8', 'b8', 'c8', 'd8', 'e8', 'f8', 'g8', 'h8',
];
