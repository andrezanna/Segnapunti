
import 'package:Segnapunti/classicplayer.dart';
import 'package:Segnapunti/util.dart' as Util;
import 'package:flutter/material.dart';
import 'package:numberpicker/numberpicker.dart';

class Classic extends StatefulWidget {
  @override
  createState() => new ClassicState();
}

final List<ClassicPlayer> play = <ClassicPlayer>[
  new ClassicPlayer("Player 1", minValue),
  new ClassicPlayer("Player 2", minValue),
];

int minValue = 0;
int maxValue = 60;
final ScrollController scrollController = new ScrollController();

class ClassicState extends State<Classic> {
  ClassicState();

  int _players = 2;
  int _playerName = 2;

  void _addPlayer() {
    play.add(new ClassicPlayer("Player ${_playerName + 1}", minValue));
    setState(() {
      _players++;
      _playerName++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('Classico'),
        actions: <Widget>[
          new MaterialButton(
              onPressed: null,
              child: new MaterialButton(
                onPressed: () {
                  AlertDialog alert = new ClassicSettings();

                  showDialog(child: alert, context: context);
                },
                child: new Text(
                  "IMPOSTAZIONI",
                  style: new TextStyle(color: Colors.white),
                ),
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
      controller: scrollController,
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
  final int index;
  final TextEditingController _controller = new TextEditingController();
  bool maxReached = false;
  FocusNode focusNode = new FocusNode();

  Widget _buildRow(int index) {
  _controller.addListener(nameChange);
  focusNode.addListener(_ensureVisible);
  NumberPicker p = buildPickerInteger(index);
  play[index].setNumberPicker(p);
  return new Dismissible(
  key: new ObjectKey(play[index]),
  direction: DismissDirection.endToStart,
  onDismissed: (DismissDirection direction) {
  setState(() {
  removePlayer(index);
  });
  },
  background:
  new Container(decoration: new BoxDecoration(color: Colors.red)),
  child: new ListTile(
  title: new Container(
  child: new TextField(
  controller: _controller,
  focusNode: focusNode,
  decoration: new InputDecoration(
  hintText: play[index].name,
  ),
  ),
  ),
  trailing: p,
  ));
  }


  void _ensureVisible(){
  Util.ensureVisible(context, focusNode);
  }
  Widget buildPickerInteger(int index) {
  return new NumberPicker.integer(
  minValue: minValue,
  maxValue: maxValue,
  horizontal: true,
  initialValue:
  (play[index].value >= minValue && play[index].value <= maxValue)
  ? play[index].value
      : play[index].value = minValue,
  listViewWidth: 150.0,
  listViewHeight: 50.0,
  itemExtent: 50.0,
  onChanged: (newValue) {
  setState(() {
  play[index].value = newValue;
  if (play[index].value == maxValue && !maxReached) {
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
  onPressed: () {
  maxReached = false;
  resetGame();
  },
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
  }

  void resetGame() {
  Navigator.pop(context);
  for (var pl in play) {
  pl.setValue(minValue);
  pl.np.animateIntfor(minValue, 10000);
  }
  onChanged(null);
  }

  void nameChange() {
  scrollController.animateTo(50.0 * index,
  duration: new Duration(milliseconds: 1000), curve: Curves.easeOut);

  if (_controller.text.isNotEmpty) {
  play[index].setName(_controller.text);
  } else {
  play[index].setName("Player ${index+1}");
  }
  }

  @override
  Widget build(BuildContext context)

  {
  return _buildRow(index);
  }
}

class ClassicSettings extends AlertDialog {
  final TextEditingController _mincontroller = new TextEditingController();
  final TextEditingController _maxcontroller = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    bool shown = false;
    _mincontroller.addListener(() {
      int newValue = int.parse(_mincontroller.text.toString());
      if (newValue <= maxValue)
        minValue = newValue;
      else if (!(shown)) {
        shown = true;
        AlertDialog errorDialog = new AlertDialog(
          title: new Text("Valore non valido"),
          content:
          new Text("Il valore minimo non può essere maggiore del massimo"),
          actions: <Widget>[
            new MaterialButton(
              onPressed: () {
                Navigator.pop(context);
                shown = false;
              },
              child: new Icon(Icons.close),
            )
          ],
        );
        showDialog(context: context, child: errorDialog);
      }
    });
    _maxcontroller.addListener(() {
      int newValue = int.parse(_maxcontroller.text.toString());
      if (newValue >= minValue)
        minValue = newValue;
      else if (!(shown)) {
        shown = true;
        AlertDialog errorDialog = new AlertDialog(
          title: new Text("Valore non valido"),
          content:
          new Text("Il valore massimo non può essere minore del minimo"),
          actions: <Widget>[
            new MaterialButton(
              onPressed: () {
                Navigator.pop(context);
                shown = false;
              },
              child: new Icon(Icons.close),
            )
          ],
        );
        showDialog(context: context, child: errorDialog);
      }
    });
    return new Scaffold(
      appBar: new AppBar(),
      body: new Column(children: <Widget>[
        new Container(
          child: new ListTile(
            title: new TextField(
              keyboardType: TextInputType.number,
              decoration: new InputDecoration(
                hintText: minValue.toString(),
              ),
              controller: _mincontroller,
            ),
            trailing: new Text("Valore minimo"),
          ),
        ),
        new ListTile(
            trailing: new Text("Valore massimo"),
            title: new TextField(
              keyboardType: TextInputType.number,
              decoration: new InputDecoration(
                hintText: maxValue.toString(),
              ),
              controller: _maxcontroller,
            )),
      ]),
    );
  }
}