import 'dart:math' as Math;

import 'package:Segnapunti/player.dart';
import 'package:Segnapunti/util.dart' as Util;
import 'package:flutter/material.dart';

final List<Player> players = <Player>[
  new Player("Giocatore 1", 0),
  new Player("Giocatore 2", 0)
];
final List<Moves> moves = <Moves>[];
final List<bool> ballState = new List.filled(15, true);

class Biliardo extends StatefulWidget {
  @override
  createState() {
    moves.clear();
    for (int i = 0; i < ballState.length; i++) {
      ballState[i] = true;
    }

    try {
      players.clear();
      players.add(new Player("Giocatore 1", 0));
      players.add(new Player("Giocatore 2", 0));
    } catch (b) {
      print(b);
    }
    return new BiliardoState();
  }
}

class BiliardoState extends State<Biliardo> {
  int _players = 2;
  int _playerName = 2;

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('Biliardo'),
      ),
      body: new ListView(children: <Widget>[buildBiliardo(), buildPlayers()]),
      bottomNavigationBar: new BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          new BottomNavigationBarItem(
              icon: new Icon(Icons.add), title: new Text("Nuovo Giocatore")),
          new BottomNavigationBarItem(
              icon: new Icon(Icons.arrow_back), title: new Text("Annulla")),
          new BottomNavigationBarItem(
              icon: new Icon(Icons.refresh), title: new Text("Reset")),
        ],
        onTap: (item) {
          if (item == 0) {
            _addPlayer();
          }
          if (item == 1) {
            if (moves.length > 0) {
              _annulla();
            } else {
              null;
            }
          }
          if (item == 2) {
            reset();
          }
        },
      ),
    );
  }

  void _addPlayer() {
    players.add(new Player("Giocatore ${_playerName + 1}", 0));
    setState(() {
      _players++;
      _playerName++;
    });
  }

  void removePlayer(int index) {
    setState(() {
      Player player = players[index];
      players.removeAt(index);
      _players--;
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

  void

  rePaint

  (void b) {
  setState(() {});
  }

  Widget buildBiliardo() {
  return new Container(
  child: new GridView.count(
  crossAxisCount: 4,
  childAspectRatio: 1.0,
  padding: const EdgeInsets.fromLTRB(16.0, 25.0, 16.0, 30.0),
  mainAxisSpacing: 4.0,
  crossAxisSpacing: 3.0,
  shrinkWrap: true,
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
  double width = MediaQuery.of(context).size.width;
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
  itemCount: _players,
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

  void cleanBalls(List<int> indexes)

  {
  for (var num in indexes.reversed) {
  Moves move = moves[num];
  moves.removeAt(num);
  ballState[move.value - 1] = true;
  }
  setState((){});
  Navigator.of(context).pop();
  }

  void removeMoves(List<int> indexes)

  {
  for (var num in indexes.reversed) {
  moves.removeAt(num);
  }
  }
}

class BuildPlayer extends StatefulWidget {
  BuildPlayer(this.index, this._removePlayer, this._onChanged);

  final ValueChanged<int> _removePlayer;

  final ValueChanged

  <

  void

  >

  _onChanged

  ;
  final int index;

  @override
  createState()

  => new BuildPlayerState(
  index: index, removePlayer:

  _removePlayer

  ,

  onChanged

      :

  _onChanged

  );
}

class BuildPlayerState extends State<BuildPlayer> {
  BuildPlayerState({this.index, this.removePlayer, this.onChanged});

//parte importante, value changer sono dei riferimenti che ho
  //quando cambio il valore chiamo le funzioni referenziate
  //servono per ricostruire il layout generale.

  //Approccio child state, parent state, mixed state
  final ValueChanged<int> removePlayer;

  final ValueChanged

  <

  void

  >

  onChanged

  ;
  final TextEditingController _controller = new TextEditingController();
  FocusNode focusNode = new FocusNode();
  final int index;

  @override
  Widget build(BuildContext context) {
  _controller.addListener(nameChange);
  focusNode.addListener(_ensureVisible);
  double width = MediaQuery.of(context).size.width;
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
  color: accepted.isEmpty ? null : Colors.grey.shade200,
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
  ),
  )),
  new TextField(
  controller: _controller,
  textAlign: TextAlign.center,
  focusNode: focusNode,
  decoration: new InputDecoration(
  hintText: players[index].name,
  ),
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
  players[index].setName(_controller.text);
  } else {
  players[index].setName("Giocatore ${index+1}");
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
        value: value, image: image, color: color,);
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
