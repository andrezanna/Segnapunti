import 'package:flutter/material.dart';
import 'package:numberpicker/numberpicker.dart';

void main() => runApp(new MyApp());
final List<Player> play = <Player>[new Player("Player 1", 0)];

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
  play.removeAt(index);
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
    bool longpress = false;
    bool maxReached = false;
    _controller.addListener(nameChange);
    NumberPicker p=new NumberPicker.integer(
    minValue: 0,
    maxValue: 60,
    horizontal: true,
    initialValue: play[index].value,
    listViewWidth: 150.0,
    listViewHeight: 50.0,
    itemExtent: 50.0,
    onChanged: (newValue) {
    setState(() {
    play[index].value = newValue;
    if (play[index].value == 60 && !maxReached) {
    maxReached = true;
    AlertDialog alert = new AlertDialog(
    title: new Text("Vincitore!!"),
    content: new Text("${play[index]
        .name}, ha vinto!!.\nVuoi iniziare una nuova partita?"),
    actions: <Widget>[
    new MaterialButton(
    onPressed: () {
    maxReached = false;
    Navigator.pop(context);
    },
    child: new Icon(
    Icons.close,
    color: Colors.black,
    ),
    ),
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
    });
    },
    );
    play[index].setNumberPicker(p);
    return new Dismissible(
    key: new ObjectKey(play[index]),
  direction: DismissDirection.endToStart,
  onDismissed: (DismissDirection direction) {
  setState(() {
  _removePlayer(index);
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
  trailing: p,
  ));
  }

  void resetGame() {
    Navigator.pop(context);
    for (var pl in play) {
      pl.setValue(0);
      pl.np.animateInt(0);
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
  NumberPicker np;
  Player(this.name, this.value);

  Key get key => new ObjectKey(this.hashCode);

  void setValue(int value) {
    this.value = value;
  }

  void setNumberPicker(NumberPicker p) {
    this.np = p;
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
