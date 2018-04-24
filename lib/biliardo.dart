import 'dart:math' as Math;

import 'package:Segnapunti/player.dart';
import 'package:Segnapunti/util.dart' as Util;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

final List<Player> players = <Player>[
  new Player("Giocatore 1", 0),
  new Player("Giocatore 2", 0)
];
final List<Moves> moves = <Moves>[];
final List<bool> ballState = new List.filled(15, true);
bool darkTheme = false;

class Biliardo extends StatefulWidget {
  @override
  createState() {

    moves.clear();
    for (int i = 0; i < ballState.length; i++) {
      ballState[i] = true;
    }

    try {
      if (players.isEmpty) {
        players.add(new Player("Giocatore 1", 0));
        players.add(new Player("Giocatore 2", 0));
      } else {
        for (Player pl in players) {
          pl.value = 0;
        }
      }
    } catch (b) {
      print(b);
    }
    return new BiliardoState();
  }

  getSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    darkTheme = prefs.getBool("dark");
    if (darkTheme == null) darkTheme = false;
    List<String> playersSaved = prefs.getStringList("BiliardoPlayers");
    if (playersSaved.isNotEmpty) {
      players.clear();
      for (String p in playersSaved)
        players.add(new Player(p, 0));
    }
  }
}

class BiliardoState extends State<Biliardo> {
  int _playerName = 2;

  @override
  Widget build(BuildContext context) {
    return new Scaffold(

      appBar: new AppBar(
        leading: new BackButton(
          color: (darkTheme) ? Colors.black : Colors.white,),
        textTheme: new TextTheme(title: new TextStyle(
            color: (darkTheme) ? Colors.black : Colors.white,
            fontSize: 20.0,
            fontWeight: FontWeight.bold)),
        title: new Text('Biliardo'),
      ),
      body: new Flex(
        direction: Axis.vertical,
        children: <Widget>[
          buildBiliardo(),
          buildPlayers(),
          new Expanded(
            child: new Container(
              margin: EdgeInsets.all(12.0),
              child: new Flex(
                direction: Axis.horizontal,
                children: <Widget>[
                  new Expanded(
                    child: new MaterialButton(
                        onPressed: _addPlayer,
                        child: new Column(children: <Widget>[
                          new Icon(
                            Icons.add,
                            color: Colors.blue,
                          ),
                          new Center(
                              child: new Text(
                                "Nuovo Giocatore",
                                textAlign: TextAlign.center,
                                style: new TextStyle(
                                  color: Colors.blue,
                                ),
                              ))
                        ])),
                  ),
                  new Expanded(
                    child: new MaterialButton(
                        onPressed: (moves.length > 0) ? _annulla : null,
                        child: new Column(children: <Widget>[
                          new Icon(
                            Icons.arrow_back,
                            color: Colors.blue,
                          ),
                          new Text(
                            "Annulla",
                            style: new TextStyle(
                              color: Colors.blue,
                            ),
                          )
                        ])),
                  ),
                  new Expanded(
                    child: new MaterialButton(
                        onPressed: reset,
                        child: new Column(children: <Widget>[
                          new Icon(
                            Icons.refresh,
                            color: Colors.blue,
                          ),
                          new Text(
                            "Reset",
                            style: new TextStyle(
                              color: Colors.blue,
                            ),
                          )
                        ])),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      backgroundColor: (darkTheme)
          ? Color.fromARGB(255, 50, 50, 50)
          : Color.fromARGB(255, 250, 250, 250),
    );
  }

  @override
  void dispose() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> pl = new List();
    for (Player p in players)
      pl.add(p.name);
    prefs.setStringList("BiliardoPlayers", pl);
    super.dispose();
  }

  void _addPlayer() {
    players.add(new Player("Giocatore ${_playerName + 1}", 0));
    setState(() {
      _playerName++;
    });
  }

  void removePlayer(int index) {
    setState(() {
      Player player = players[index];
      players.removeAt(index);
      List<int> indexes = new List();
      for (int i = 0; i < moves.length; i++) {
        if (moves[i].player == index) {
          indexes.add(i);
        }
      }
      if (indexes.length > 0) {
        showDialog(
            context: context,
            builder: (context) =>
            new AlertDialog(
                title: new Text(
                  "Attenzione!!",
                ),
                content: new Text("${player
                .name} possiede ancora delle palle, vuoi rimetterle in gioco?"),
                actions: <Widget>[
                  new MaterialButton(
                    onPressed: () {
                      cleanBalls(indexes);
                    },
                    child: new Text("SI"),
                  ),
                  new MaterialButton(
                    onPressed: () {
                      removeMoves(indexes);
                      Navigator.of(context).pop();
                    },
                    child: new Text("NO"),
                  )
                ]),
            barrierDismissible: false);
      }
    });
  }

  void rePaint(void b) {
    setState(() {});
  }

  Widget buildBiliardo() {
    return new Expanded(
      flex: 4,
      child: new GridView.count(
        crossAxisCount: 4,
        controller: new ScrollController(
            initialScrollOffset: 0.0, keepScrollOffset: true),
        childAspectRatio: 1.0,
        padding: const EdgeInsets.fromLTRB(16.0, 25.0, 16.0, 30.0),
        children: <Widget>[
          new MovableBall(
            1,
            '/images/p1.png',
            Colors.yellow,
          ),
          new MovableBall(
            2,
            '/images/p2.png',
            Colors.blue,
          ),
          new MovableBall(
            3,
            '/images/p3.png',
            Colors.red,
          ),
          new MovableBall(
            4,
            '/images/p4.png',
            Colors.purple,
          ),
          new MovableBall(
            5,
            '/images/p5.png',
            Colors.orange,
          ),
          new MovableBall(
            6,
            '/images/p6.png',
            Colors.green,
          ),
          new MovableBall(
            7,
            '/images/p7.png',
            Colors.brown,
          ),
          new MovableBall(
            8,
            '/images/p8.png',
            Colors.black,
          ),
          new MovableBall(
            9,
            '/images/p9.png',
            Colors.yellow,
          ),
          new MovableBall(
            10,
            '/images/p10.png',
            Colors.blue,
          ),
          new MovableBall(
            11,
            '/images/p11.png',
            Colors.red,
          ),
          new MovableBall(
            12,
            '/images/p12.png',
            Colors.purple,
          ),
          new MovableBall(
            13,
            '/images/p13.png',
            Colors.orange,
          ),
          new MovableBall(
            14,
            '/images/p14.png',
            Colors.green,
          ),
          new MovableBall(
            15,
            '/images/p15.png',
            Colors.brown,
          ),
        ],
      ),
    );
  }

  Widget buildPlayers() {
    double width = MediaQuery
        .of(context)
        .size
        .width;
    return new Container(
      padding: const EdgeInsets.fromLTRB(
        16.0,
        4.0,
        16.0,
        4.0,
      ),
      constraints: new BoxConstraints(
        minWidth: 0.0,
        maxWidth: width,
        minHeight: 50.0,
        maxHeight: 100.0,
      ),
      child: new ListView.builder(
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        itemBuilder: (BuildContext context, int index) {
          return new BuildPlayer(
            index,
            removePlayer,
            rePaint,
          );
        },
        itemCount: players.length,
      ),
    );
  }

  void _annulla() {
    setState(() {
      Moves move = moves.last;
      moves.removeLast();
      players[move.player].value -= move.value;
      ballState[move.value - 1] = true;
    });
  }

  void reset() {
    moves.clear();
    for (int i = 0; i < ballState.length; i++) {
      ballState[i] = true;
    }
    for (int i = 0; i < players.length; i++) {
      players[i].value = 0;
    }
    setState(() {});
  }

  void cleanBalls(List<int> indexes) {
    for (var num in indexes.reversed) {
      Moves move = moves[num];
      moves.removeAt(num);
      ballState[move.value - 1] = true;
    }
    setState(() {});
    Navigator.of(context).pop();
  }

  void removeMoves(List<int> indexes) {
    for (var num in indexes.reversed) {
      moves.removeAt(num);
    }
  }
}

class BuildPlayer extends StatefulWidget {
  BuildPlayer(this.index, this._removePlayer, this._onChanged);

  final ValueChanged<int> _removePlayer;

  final ValueChanged<void> _onChanged;
  final int index;

  @override
  createState() =>
      new BuildPlayerState(
          index: index, removePlayer: _removePlayer, onChanged: _onChanged);
}

class BuildPlayerState extends State<BuildPlayer> {
  BuildPlayerState({this.index, this.removePlayer, this.onChanged});

//parte importante, value changer sono dei riferimenti che ho
  //quando cambio il valore chiamo le funzioni referenziate
  //servono per ricostruire il layout generale.

  //Approccio child state, parent state, mixed state
  final ValueChanged<int> removePlayer;

  final ValueChanged<void> onChanged;
  final TextEditingController _controller = new TextEditingController();
  FocusNode focusNode = new FocusNode();
  final int index;

  @override
  Widget build(BuildContext context) {
    _controller.addListener(nameChange);
    focusNode.addListener(_ensureVisible);
    double width = MediaQuery
        .of(context)
        .size
        .width;
    return new Dismissible(
      direction: DismissDirection.down,
      key: new ObjectKey(players[index].name),
      onDismissed: (DismissDirection direction) {
        setState(() {
          removePlayer(index);
        });
      },
      child: new DragTarget<BallMove>(onAccept: (BallMove data) {
        addValue(data.value);
      }, builder: (BuildContext context, List<BallMove> accepted,
          List<dynamic> rejected) {
        return new Container(
          width: Math.max((width - 32.0) / players.length, 110.0),
          decoration: new BoxDecoration(
            color: accepted.isEmpty
                ? null
                : (darkTheme
                ? accepted.last.color.withAlpha(50)
                : Colors.grey.shade200),
            border: new Border.all(
                width: 3.0,
                color: accepted.isEmpty
                    ? Colors.transparent
                    : accepted.last.color),
          ),
          padding: const EdgeInsets.fromLTRB(4.0, 4.0, 16.0, 4.0),
          child: new Column(
            children: <Widget>[
              new Expanded(
                  child: new Center(
                    child: new Text(
                      players[index].value.toString(),
                      style: new TextStyle(
                          color: darkTheme ? Colors.blue : Colors.black),
                    ),
                  )),
              new TextField(
                controller: _controller,
                textAlign: TextAlign.center,
                focusNode: focusNode,
                decoration: new InputDecoration(
                  hintText: players[index].name,
                  hintStyle: new TextStyle(
                      color: darkTheme ? Colors.blueAccent : Colors.black),
                ),
                style: new TextStyle(
                    color: darkTheme ? Colors.blue : Colors.black),
              ),
            ],
          ),
        );
      }),
    );
  }

  void addValue(int value) {
    setState(() {
      players[index].value += value;
      ballState[value - 1] = false;
      moves.add(new Moves(value, index));
      onChanged(null);
    });
  }

  void _ensureVisible() {
    Util.ensureVisible(context, focusNode);
  }

  void nameChange() {
    if (_controller.text.isNotEmpty) {
      if (_controller.text.length <= 20) {
        players[index].setName(_controller.text);
      } else {
        _controller.text = players[index].name;
      }
    } else {
      players[index].setName("Giocatore $index");
    }
  }
}

class MovableBall extends StatefulWidget {
  const MovableBall(this.value, this.image, this.color);

  final Color color;
  final int value;
  final String image;

  @override
  createState() =>
      new MovableBallState(
        value: value,
        image: image,
        color: color,
      );
}

class MovableBallState extends State<MovableBall> {
  MovableBallState({this.value, this.image, this.color});

  final Color color;
  final int value;
  final String image;
  static final GlobalKey kBallKey = new GlobalKey();
  static const double kBallSize = 100.0;

  @override
  Widget build(BuildContext context) {
    final Widget ball = new DefaultTextStyle(
        style: Theme
            .of(context)
            .primaryTextTheme
            .body1,
        textAlign: TextAlign.center,
        child: new Image.asset(
          image,
          width: kBallSize,
          height: kBallSize,
        ));
    final Widget dashedBall = new Container(
        width: kBallSize,
        height: kBallSize,
        child: new Image.asset(
          'images/emptyBall.png',
          width: kBallSize,
          height: kBallSize,
        ));
    if (ballState[value - 1]) {
      return new Draggable<BallMove>(
          data: new BallMove(value, color),
          child: ball,
          childWhenDragging: dashedBall,
          feedback: ball,
          maxSimultaneousDrags: 1);
    } else {
      return dashedBall;
    }
  }
}

class Moves {
  int player;
  int value;

  Moves(this.value, this.player);
}

class BallMove {
  int value;
  Color color;

  BallMove(this.value, this.color);
}
