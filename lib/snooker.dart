import 'dart:math' as Math;

import 'package:Segnapunti/util.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

final List<Player> players = <Player>[
  new Player("Giocatore 1", 0),
  new Player("Giocatore 2", 0)
];
final List<Moves> moves = <Moves>[];
final List<bool> ballState = new List.filled(7, true);

bool darkTheme = false;
int inFoul = -1;

class Snooker extends StatefulWidget {
  @override
  createState() {
    getSharedPreferences();
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
    return new SnookerState();
  }

  getSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    darkTheme = prefs.getBool("dark");
    if (darkTheme == null) darkTheme = false;
    List<String> playersSaved = prefs.getStringList("SnookerPlayers");
    if (playersSaved.isNotEmpty) {
      players.clear();
      for (String p in playersSaved) players.add(new Player(p, 0));
    }

  }
}

class SnookerState extends State<Snooker> {
  int _playerName = 2;
  SharedPreferences prefs;
  int index = 0;

  @override
  Widget build(BuildContext context) {
    getSharedPreferences();

    return new Scaffold(
      appBar: new AppBar(
        leading: new BackButton(
          color: (darkTheme) ? Colors.black : Colors.white,
        ),
        textTheme: new TextTheme(
            title: new TextStyle(
                color: (darkTheme) ? Colors.black : Colors.white,
                fontSize: 20.0,
                fontWeight: FontWeight.bold)),
        title: new Text('Snooker'),
      ),
      bottomNavigationBar: new Theme(
        data: Theme.of(context).copyWith(
              // sets the background color of the `BottomNavigationBar`
              canvasColor: (darkTheme)
                  ? Color.fromARGB(255, 50, 50, 50)
                  : Color.fromARGB(255, 250, 250, 250),
            ),
        child: new BottomNavigationBar(
          currentIndex: index,
          onTap: (int index) {
            switch (index) {
              case 0:
                _addPlayer();
                break;
              case 1:
                _annulla();
                break;
              case 2:
                reset();
                break;
            }

            setState(() {
              this.index = index;
            });
          },
          items: <BottomNavigationBarItem>[
            new BottomNavigationBarItem(
              icon: new Icon(
                Icons.add,
              ),
              title: new Text(
                "Nuovo Giocatore",
                textAlign: TextAlign.center,
                style: new TextStyle(
                  color: Colors.blue,
                ),
              ),
            ),
            new BottomNavigationBarItem(
              icon: new Icon(
                Icons.arrow_back,
              ),
              title: new Text(
                "Annulla",
                textAlign: TextAlign.center,
                style: new TextStyle(
                  color: Colors.blue,
                ),
              ),
            ),
            new BottomNavigationBarItem(
              icon: new Icon(
                Icons.refresh,
              ),
              title: new Text(
                "Reset",
                textAlign: TextAlign.center,
                style: new TextStyle(
                  color: Colors.blue,
                ),
              ),
            ),
          ],
        ),
      ),
      body: new ListView(children: <Widget>[
        buildSnooker(),
        buildPlayers(),
      ]),
      backgroundColor: (darkTheme)
          ? Color.fromARGB(255, 50, 50, 50)
          : Color.fromARGB(255, 250, 250, 250),
    );
  }

  void getSharedPreferences() async {
    prefs = await SharedPreferences.getInstance();
  }

  @override
  void dispose() {
    List<String> pl = new List();
    for (Player p in players) {
      pl.add(p.name);
    }
    prefs.setStringList("SnookerPlayers", pl);
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
            builder: (context) => new AlertDialog(
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

  Widget buildSnooker() {
    return Padding(
      padding: const EdgeInsets.all(64.0),
      child: new Flex(
        direction: Axis.vertical,
        children: <Widget>[
          new DragTarget<BallMove>(
              onAccept: (BallMove data) {},
              builder: (BuildContext context, List<BallMove> accepted,
                  List<dynamic> rejected) {
                if (accepted.isNotEmpty) {
                    inFoul = accepted.last.index;
                    accepted.last.value = Math.max(4, accepted.last.value);

                }
                return new Container(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: new Text(
                      "FALLO",
                      style: new TextStyle(color: Colors.blue),
                    ),
                  ),
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
                );
              }),
          new GridView.count(
            shrinkWrap: true,
            crossAxisCount: 4,
            controller: new ScrollController(
                initialScrollOffset: 0.0, keepScrollOffset: true),
            childAspectRatio: 1.0,
            padding: const EdgeInsets.fromLTRB(0.0, 32.0, 0.0, 32.0),
            children: <Widget>[
              new MovableBall(
                1,
                'images/rossa.png',
                Colors.red,
              ),
              new MovableBall(
                2,
                'images/gialla.png',
                Colors.yellow,
              ),
              new MovableBall(
                3,
                'images/verde.png',
                Colors.green,
              ),
              new MovableBall(
                4,
                'images/marrone.png',
                Colors.brown,
              ),
              new MovableBall(
                5,
                'images/blu.png',
                Colors.blue,
              ),
              new MovableBall(
                6,
                'images/rosa.png',
                Colors.pinkAccent,
              ),
              new MovableBall(
                7,
                'images/nera.png',
                Colors.black,
              ),
            ],
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
        itemCount: players.length,
      ),
    );
  }

  void _annulla() {
    try {
      Moves move = moves.last;
      setState(() {
        moves.removeLast();
        players[move.player].value -= move.value;
        ballState[move.index - 1] = true;
      });
    } catch (e) {
      print("nessuna mossa da annullare");
    }

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
  BuildPlayer(this.index, this.removePlayer, this.onChanged);

  final ValueChanged<int> removePlayer;

  final ValueChanged<void> onChanged;
  final int index;

  @override
  createState() => new BuildPlayerState();
}

class BuildPlayerState extends State<BuildPlayer> {
  final TextEditingController _controller = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    _controller.addListener(nameChange);
    double width = MediaQuery.of(context).size.width;
    return new Dismissible(
      direction: DismissDirection.down,
      key: new ObjectKey(players[widget.index]),
      onDismissed: (DismissDirection direction) {
        setState(() {
          widget.removePlayer(widget.index);
        });
      },
      child: new DragTarget<BallMove>(onAccept: (BallMove data) {
        addValue(data.value,data.index);
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
                  players[widget.index].value.toString(),
                  style: new TextStyle(
                      color: darkTheme ? Colors.blue : Colors.black),
                ),
              )),
              new TextField(
                controller: _controller,
                textAlign: TextAlign.center,
                decoration: new InputDecoration(
                  hintText: players[widget.index].name,
                  hintStyle: new TextStyle(
                      color: darkTheme ? Colors.blue : Colors.black),
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

  void addValue(int value, int index) {
    setState(() {
      players[widget.index].value += value;
      moves.add(new Moves(value, widget.index,index));
      widget.onChanged(null);
      inFoul = -1;
    });

  }

  void nameChange() {
    if (_controller.text.length <= 30) {
      if (_controller.text.isNotEmpty) {
        players[widget.index].setName(_controller.text);
      } else {
        players[widget.index].setName("Giocatore ${widget.index + 1}");
      }
    } else {
      setState(() {
        _controller.text = players[widget.index].name;
      });
    }
  }
}

class MovableBall extends StatefulWidget {
  const MovableBall(this.value, this.image, this.color);

  final Color color;
  final int value;
  final String image;

  @override
  createState() => new MovableBallState();
}

class MovableBallState extends State<MovableBall> {
  static final GlobalKey kBallKey = new GlobalKey();
  static const double kBallSize = 100.0;
  @override
  Widget build(BuildContext context) {
    final Widget ball = new DefaultTextStyle(
        style: Theme.of(context).primaryTextTheme.body1,
        textAlign: TextAlign.center,
        child: new Image.asset(
          widget.image,
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
    if (ballState[widget.value - 1]) {

      return new Draggable<BallMove>(

              data: new BallMove(widget.value, widget.color),
              child: ball,
              childWhenDragging: dashedBall,
              feedback: ball,
              onDragCompleted: () {
                inFoul = -1;
              },
              onDraggableCanceled: (v, o) {
                inFoul = -1;
              },
              maxSimultaneousDrags: 1);


    } else {
      return dashedBall;
    }
  }
}

class Moves {
  int player;
  int value;
  int index;

  Moves(this.value, this.player,this.index);
}

class BallMove {
  int value;
  Color color;
  int index;
  BallMove(this.value, this.color){this.index=this.value;}
}

