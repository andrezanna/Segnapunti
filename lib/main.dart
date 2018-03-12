import 'package:flutter/material.dart';

void main() => runApp(new MyApp());
final List<Player> play = <Player>[new Player("Playre 1", 0)];

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Segnapunti',
      theme: new ThemeData(
        primaryColor: Colors.white,
      ),
      home: new Players(),
    );
  }
}

class Players extends StatefulWidget {
  @override
  createState() => new PlayersState();
}

class PlayersState extends State<Players> {
  PlayersState();
  int _players = 1;
  int _playerName = 1;

  void _addPlayer() {
    play.add(new Player("Player ${_playerName + 1}", 0));
    setState(() {
      _players++;
      _playerName++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('Segnapunti'),
        actions: <Widget>[
          new MaterialButton(
              onPressed: null,
              child: new Text(
                "IMPOSTAZIONI",
                style: new TextStyle(color: Colors.blue),
              ))
        ],
      ),
      body: _buildText(),
      floatingActionButton: new FloatingActionButton(
          onPressed: _addPlayer, child: new Icon(Icons.add)),
    );
  }

  Widget _buildText() {
    return new ListView.builder(
      itemBuilder: (BuildContext context, int index) {
        return new BuildRow(index, removePlayer, rePaint);
      },
      itemCount: _players,
    );
  }

  void

  rePaint

  (void b)

  {
  setState(() {});
  }

  void removePlayer(int index)

  {
    setState(() {
  print(play);
  play.removeAt(index);
  print(play);
  _players--;
    });
  }
}

class BuildRow extends StatefulWidget {
  BuildRow(this.index, this._removePlayer, this._onChanged);

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

  => new BuildRowState(
  index: index, removePlayer:

  _removePlayer

  ,

  onChanged

      :

  _onChanged

  );
}

class BuildRowState extends State<BuildRow> {
  BuildRowState({this.index, this.removePlayer, this.onChanged});

  final ValueChanged<int> removePlayer;

  final ValueChanged

  <

  void

  >

  onChanged

  ;
  final int index;
  final _biggerFont = const TextStyle(fontSize: 18.0, color: Colors.black);
  final _deleting = const TextStyle(fontSize: 18.0, color: Colors.white);
  final TextEditingController _controller = new TextEditingController();

  Widget _buildRow(int index) {
    int lasttimestamp = 0;
    bool longpress = false;
    _controller.addListener(nameChange);
    return new Dismissible(
    key: new ObjectKey(play[index]),
    direction: DismissDirection.endToStart,
    onDismissed: (DismissDirection direction) {
    setState(() {
    _removePlayer(index);
    this.dispose();
    });
    },
    background:
    new Container(decoration: new BoxDecoration(color: Colors.red)),
    child: new ListTile(
    title: new Container(
    child: new TextField(
    controller: _controller,
    style: (longpress) ? _deleting : _biggerFont,
  decoration: new InputDecoration(
  hintText: play[index].name,
  ),
  ),
  ),
  trailing: new GestureDetector(
  onHorizontalDragUpdate: (e) {
  if (e.sourceTimeStamp.inMilliseconds - lasttimestamp > 300) {
  lasttimestamp = e.sourceTimeStamp.inMilliseconds;
  if (e.delta.dx < -3 && play[index].value < 60) {
  print(e.sourceTimeStamp.inMilliseconds);
  play[index].valueUp();
  setState(() {});
  if (play[index].value == 60) {
  AlertDialog alert = new AlertDialog(
  title: new Text("Vincitore!!"),
  content: new Text("${play[index]
                          .name}, ha vinto!!.\nVuoi iniziare una nuova partita?"),
  actions: <Widget>[
  new CloseButton(),
  new MaterialButton(
  onPressed: resetGame,
  child: new Icon(
  Icons.done,
  color: Colors.black,
  ),
  )
  ],
  );
  showDialog(child: alert, context: context);
  } else {
  null;
  }
  } else
  if (e.delta.dx > 3 && play[index].value != 0) {
  print(e.sourceTimeStamp.inMilliseconds);

  setState(() {
  play[index].valueDown();
  });
  } else {
  null;
  }
  }
  },
  child: new Row(children: <Widget>[
  new MaterialButton(
  onPressed: () {
  if (play[index].value != 0) {
  setState(() {
  play[index].valueDown();
  });
  } else {
  null;
  }
  },
  child: new Text(
  '${(play[index].value!=0)?play[index].value-1:''}',
  style: new TextStyle(color: Colors.grey),
  ),
  ),
  new Text('${play[index].value}'),
  new MaterialButton(
  onPressed: () {
  if (play[index].value < 60) play[index].valueUp();
  setState(() {});
  if (play[index].value == 60) {
  AlertDialog alert = new AlertDialog(
  title: new Text("Vincitore!!"),
  content: new Text(
  "${play[index].name}, ha vinto!!.\nVuoi iniziare una nuova partita?"),
  actions: <Widget>[
  new CloseButton(),
  new MaterialButton(
  onPressed: resetGame,
  child: new Icon(
  Icons.done,
  color: Colors.black,
  ),
  )
  ],
  );
  showDialog(child: alert, context: context);
  } else {
  null;
  }
  },
  child: new Text(
  '${play[index].value+1}',
  style: new TextStyle(color: Colors.grey),
  ),
  )
  ]),
  ),
  ));
  }

  void resetGame() {
    Navigator.pop(context);
    for (var pl in play) {
      pl.setValue(0);
    }
    _resetGame();
  }

  void _removePlayer(int index) {
  removePlayer(index);
  }

  void _resetGame()

  {
  onChanged(null);
  }

  void nameChange() {
    if (_controller.text.isNotEmpty) {
      play[index].setName(_controller.text);
    } else {
      play[index].setName("Player ${index+1}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return _buildRow(index);
  }
}

class Player {
  String name;
  int value;
  Player(this.name, this.value);

  Key get key => new ObjectKey(this);

  void setValue(int value) {
    this.value = value;
  }

  void valueDown() {
    this.value -= 1;
  }

  void valueUp() {
    this.value += 1;
  }

  void setName(String name) {
    this.name = name;
  }
}
