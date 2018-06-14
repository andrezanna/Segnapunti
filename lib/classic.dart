import 'package:Segnapunti/util.dart';
import 'package:flutter/material.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:shared_preferences/shared_preferences.dart';

/**
 * Gestione del segnapunti classico
 * @param darkTheme valore preso dalle preferenze
 * @param play lista dei giocanti, con relativi nomi e punteggi
 */
bool darkTheme = false;
final List<ClassicPlayer> play = <ClassicPlayer>[
  new ClassicPlayer("Giocatore 1", stValue),
  new ClassicPlayer("Giocatore 2", stValue),
];

/**
 * @param minValue valore minimo del segnapunti
 * @param maxValue massimo del segnapunti
 * @param stValue valore di partenza del gioco
 */
int minValue = 0;
int maxValue = 60;
int stValue = 0;
//usata per lo scroll per la modifica dei nomi
final ScrollController scrollController = new ScrollController();

class Classic extends StatefulWidget {
  @override
  createState() {
    getSharedPreferences();
    return new ClassicState();
  }

  getSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    darkTheme = prefs.getBool("dark");
    if (darkTheme == null) darkTheme = false;
    List<String> playersSaved = prefs.getStringList("BiliardoPlayers");
    if (playersSaved.isNotEmpty) {
      play.clear();
      for (String p in playersSaved)
        play.add(new ClassicPlayer(p, minValue));
    }
  }
}



class ClassicState extends State<Classic> {
  ClassicState();

  /**
   * @param _players numero di giocatori
   * @param _playerName numero progressivo per non dare nomi uguali ai giocatori
   *                    anche a seguito di cancellazione
   */
  int _players = 2;
  int _playerName = 2;

  void _addPlayer() {
    play.add(new ClassicPlayer("Giocatore ${_playerName + 1}", minValue));
    setState(() {
      _players++;
      _playerName++;
    });
  }

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

        title: new Text('Classico'),
        actions: <Widget>[
          new MaterialButton(
              onPressed: null,
              child: new MaterialButton(
                onPressed: () {
                  showDialog(
                      builder: (context) => new ClassicSettings(),
                      context: context);
                },
                child: new Text(
                  "IMPOSTAZIONI",
                ),
              ))
        ],
      ),
      body: _buildText(),
      backgroundColor: (darkTheme)
          ? Color.fromARGB(255, 50, 50, 50)
          : Color.fromARGB(255, 250, 250, 250),
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

  void rePaint(void b) {
    setState(() {});
  }

  void removePlayer(int index) {
    setState(() {
      play.removeAt(index);
      _players--;
    });
  }
}

class BuildRow extends StatefulWidget {
  BuildRow(this.index, this.removePlayer, this.onChanged);

  final ValueChanged<int> removePlayer;

  final ValueChanged<void> onChanged;
  final int index;

  @override
  createState() =>
      new BuildRowState();
}

class BuildRowState extends State<BuildRow> {

//parte importante, value changer sono dei riferimenti che ho
  //quando cambio il valore chiamo le funzioni referenziate
  //servono per ricostruire il layout generale.

  //Approccio child state, parent state, mixed state

  final TextEditingController _controller = new TextEditingController();
  bool maxReached = false;
  FocusNode focusNode = new FocusNode();

  Widget _buildRow(int index) {
    _controller.addListener(nameChange);
    focusNode.addListener(_ensureVisible);
    NumberPicker numberPicker = buildPickerInteger(index);
    play[index].setNumberPicker(numberPicker);
    return new Dismissible(
        key: new ObjectKey(play[index]),
        direction: DismissDirection.endToStart,
        onDismissed: (DismissDirection direction) {
          setState(() {
            widget.removePlayer(index);
          });
        },
        background:
        new Container(decoration: new BoxDecoration(color: Colors.red)),
        child: new ListTile(
          title: new Container(
            child: new TextField(
              controller: _controller,
              focusNode: focusNode,
              style: new TextStyle(
                  color: darkTheme ? Colors.blue : Colors.black),
              decoration: new InputDecoration(
                hintText: play[index].name,
                hintStyle: new TextStyle(
                    color: darkTheme ? Colors.blue : Colors.black),
              ),
            ),
          ),
          trailing: numberPicker,
        ));
  }

  void _ensureVisible() {
    ensureVisible(context, focusNode);
  }

  Widget buildPickerInteger(int index) {
    return new NumberPicker.integer(
      minValue: minValue,
      maxValue: maxValue,
      horizontal: true,
      initialValue:
      (play[index].value >= minValue && play[index].value <= maxValue)
          ? play[index].value
          : play[index].value = stValue,
      listViewWidth: 150.0,
      listViewHeight: 50.0,
      itemExtent: 50.0,
      onChanged: (newValue) {
        setState(() {
          play[index].value = newValue;
          if (play[index].value == maxValue && !maxReached) {
            maxReached = true;
            showDialog(
                builder: (context) =>
                new AlertDialog(
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
                ),
                context: context,
                barrierDismissible: false);
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
    widget.onChanged(null);
  }

  void nameChange() {
    scrollController.animateTo(50.0 * widget.index,
        duration: new Duration(milliseconds: 1000), curve: Curves.easeOut);

    if (_controller.text.isNotEmpty) {
      play[widget.index].setName(_controller.text);
    } else {
      play[widget.index].setName("Giocatore ${widget.index + 1}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return _buildRow(widget.index);
  }
}

class ClassicSettings extends AlertDialog {
  final TextEditingController _minController = new TextEditingController();
  final TextEditingController _maxController = new TextEditingController();
  final TextEditingController _startController = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    bool shown = false;
    _minController.addListener(() {
      int newValue = int.parse(_minController.text.toString());
      if (newValue < maxValue)
        minValue = newValue;
      else if (!(shown)) {
        shown = true;
        showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) =>
            new AlertDialog(
              title: new Text("Valore non valido",),
              content: new Text(
                  "Il valore minimo non può essere maggiore del massimo"),
              actions: <Widget>[
                new MaterialButton(
                  onPressed: () {
                    Navigator.pop(context);
                    shown = false;
                  },
                  child: new Icon(Icons.close),
                )
              ],
            ));
      }
    });
    _maxController.addListener(() {
      int newValue = int.parse(_maxController.text.toString());
      if (newValue > minValue)
        maxValue = newValue;
      else if (!(shown)) {
        shown = true;
        showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) =>
            new AlertDialog(
              title: new Text("Valore non valido"),
              content: new Text(
                  "Il valore massimo deve essere maggiore del minimo"),
              actions: <Widget>[
                new MaterialButton(
                  onPressed: () {
                    Navigator.pop(context);
                    shown = false;
                  },
                  child: new Icon(Icons.close),
                )
              ],
            ));
      }
    });
    _startController.addListener(() {
      int newValue = int.parse(_startController.text.toString());
      if (newValue < maxValue && newValue >= minValue)
        stValue = newValue;
      else if (!(shown)) {
        shown = true;
        showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) =>
            new AlertDialog(
              title: new Text("Valore non valido",),
              content: new Text(
                  "Il valore di partenza deve essere compreso tra il minimo e il massimo"),
              actions: <Widget>[
                new MaterialButton(
                  onPressed: () {
                    Navigator.pop(context);
                    shown = false;
                  },
                  child: new Icon(Icons.close),
                )
              ],
            ));
      }
    });
    return new Scaffold(
      backgroundColor: (darkTheme)
          ? Color.fromARGB(255, 50, 50, 50)
          : Color.fromARGB(255, 250, 250, 250),
      appBar: new AppBar(leading: new BackButton(
        color: (darkTheme) ? Colors.black : Colors.white,),
        textTheme: new TextTheme(title: new TextStyle(
            color: (darkTheme) ? Colors.black : Colors.white,
            fontSize: 20.0,
            fontWeight: FontWeight.bold)),
      ),
      body: new Column(children: <Widget>[
        new Container(
          child: new ListTile(
            title: new TextField(
              keyboardType: TextInputType.number,
              decoration: new InputDecoration(
                hintText: minValue.toString(),
                hintStyle: new TextStyle(
                    color: darkTheme ? Colors.blue : Colors.black),
              ),
              style: new TextStyle(
                  color: darkTheme ? Colors.blue : Colors.black),
              controller: _minController,
            ),
            trailing: new Text("Valore minimo", style: new TextStyle(
                color: darkTheme ? Colors.blue : Colors.black),),
          ),
        ),
        new ListTile(
            trailing: new Text("Valore massimo", style: new TextStyle(
                color: darkTheme ? Colors.blue : Colors.black),),
            title: new TextField(
              keyboardType: TextInputType.number,
              decoration: new InputDecoration(
                hintText: maxValue.toString(),
                hintStyle: new TextStyle(
                    color: darkTheme ? Colors.blue : Colors.black),
              ),
              controller: _maxController,
              style: new TextStyle(
                  color: darkTheme ? Colors.blue : Colors.black),
            )),
        new ListTile(
            trailing: new Text("Valore di partenza", style: new TextStyle(
                color: darkTheme ? Colors.blue : Colors.black),),
            title: new TextField(
              keyboardType: TextInputType.number,
              decoration: new InputDecoration(
                hintText: stValue.toString(),
                hintStyle: new TextStyle(
                    color: darkTheme ? Colors.blue : Colors.black),
              ),
              controller: _startController,
              style: new TextStyle(
                  color: darkTheme ? Colors.blue : Colors.black),
            )),
      ]),
    );
  }
}

class ClassicPlayer extends Player {
  NumberPicker np;

  ClassicPlayer(name, value) : super(name, value);

  Key get key => new ObjectKey(this.hashCode);

  void setValue(int value) {
    this.value = value;
  }

  void setNumberPicker(NumberPicker p) {
    this.np = p;
  }

  void setName(String name) {
    this.name = name;
  }
}
