import 'package:Segnapunti/player.dart';
import 'package:Segnapunti/util.dart';
import 'package:flutter/material.dart';

int periodWin = 6;
int periodNumber = 3;
int inPeriod = 0;

class Tennis extends StatefulWidget {
  @override
  createState() => new TennisState();
}

class TennisState extends State<Tennis> {
  Player player1 = new Player("Giocatore 1", 0);
  Player player2 = new Player("Giocatore 2", 0);

  final List<Scores> scores = new List();
  Scores lastPeriod = new Scores(0, 0);

  @override
  Widget build(BuildContext context) {
    if (scores.isEmpty || scores.length != periodNumber) {
      scores.clear();
      for (int i = 0; i < periodNumber; i++)
        scores.add(new Scores(0, 0));
    }
    List<Widget> actions = <Widget>[
      new MaterialButton(
        onPressed: () {
          Navigator.of(context).push(new MaterialPageRoute(
              builder: (context) => new TennisSettings()));
        },
        child: new Text(
          "IMPOSTAZIONI",
          style: new TextStyle(color: Colors.white),
        ),
      ),
    ];
    if (inPeriod == scores.length) {
      actions.add(
        new MaterialButton(
          onPressed: () {
            nuovaPartita();
          },
          child: new Text(
            "NUOVA",
            style: new TextStyle(color: Colors.white),
          ),
        ),
      );
    }
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('Tennis'),
        actions: actions,
      ),
      body: _buildTennis(),
    );
  }

  Widget _buildTennis() {
    return new Flex(
      direction: Axis.vertical,
      children: <Widget>[
        new TennisScorePeriod(scores),
        new Expanded(
          child: new Row(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              new Expanded(child: new TennisScore(player1)),
              new Expanded(child: new TennisScore(player2)),
            ],
          ),
        ),
      ],
    );
  }
}

class TennisScore extends StatefulWidget {
  TennisScore(this.team);

  final Player team;

  @override
  createState() => new TennisScoreState(team);
}

class TennisScoreState extends State<TennisScore> {
  TennisScoreState(this.team);

  final Player team;

  @override
  Widget build(BuildContext context) {
    return new Column(
      children: <Widget>[
        new Expanded(
          child: new MaterialButton(
            onPressed: () {
              setState(() {
                team.value -= 1;
              });
            },
            child: new Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                new Text(
                  team.value.toString(),
                  style: new TextStyle(
                    color: Colors.red,
                    fontSize: 40.0,
                  ),
                  textAlign: TextAlign.right,
                ),
              ],
            ),
          ),
        ),
        new Expanded(
          child: new Center(
            child: new Text(
              team.name,
              style: new TextStyle(fontSize: 30.0, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        new Expanded(
          child: new MaterialButton(
              onPressed: () {
                setState(() {
                  team.value += 5;
                });
              },
              child: new Text(
                "+5",
                style: new TextStyle(fontSize: 25.0),
              )),
        ),
        new Expanded(
          child: new MaterialButton(
              onPressed: () {
                setState(() {
                  team.value += 2;
                });
              },
              child: new Text(
                "+2",
                style: new TextStyle(fontSize: 25.0),
              )),
        ),
        new Expanded(
            child: new MaterialButton(
                onPressed: () {
                  setState(() {
                    team.value += 3;
                  });
                },
                child: new Text(
                  "+3",
                  style: new TextStyle(fontSize: 25.0),
                ))),
      ],
    );
  }
}

class TennisScorePeriod extends StatefulWidget {
  TennisScorePeriod(this.scores);

  final List<Scores> scores;

  @override
  createState() {
    return new TennisScorePeriodState(scores);
  }
}

class TennisScorePeriodState extends State<TennisScorePeriod> {
  TennisScorePeriodState(this.scores);

  final List<Scores> scores;

  @override
  Widget build(BuildContext context) {
    return new Container(
        decoration: new BoxDecoration(
          border: new Border.all(
            width: 2.0,
            color: Colors.black,
          ),
        ),
        constraints: new BoxConstraints(minWidth: 80.0, maxWidth: 120.0),
        child: new ListView.builder(
          shrinkWrap: true,
          scrollDirection: Axis.vertical,
          itemBuilder: (BuildContext context, int index) {
            return new Container(
                child: new Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    new Container(
                      constraints:
                      new BoxConstraints(minWidth: 28.0, maxWidth: 40.0),
                      child: new Text(
                        scores[index].team1.toString(),
                        textAlign: TextAlign.center,
                        style: new TextStyle(fontSize: 20.0),
                      ),
                    ),
                    new Container(
                      constraints:
                      new BoxConstraints(minWidth: 28.0, maxWidth: 40.0),
                      child: new Text(
                        " ${index + 1} ",
                        style: new TextStyle(color: Colors.red, fontSize: 20.0),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    new Container(
                      constraints:
                      new BoxConstraints(minWidth: 28.0, maxWidth: 40.0),
                      child: new Text(
                        scores[index].team2.toString(),
                        textAlign: TextAlign.center,
                        style: new TextStyle(fontSize: 20.0),
                      ),
                    ),
                  ],
                ));
          },
          itemCount: scores.length,
        ));
  }
}

class TennisSettings extends StatelessWidget {
  final TextEditingController _periodWin = new TextEditingController();
  final TextEditingController _periodNumber = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    bool shown = false;

    _periodWin.addListener(() {
      if (_periodWin.text.isNotEmpty) {
        int newValue = int.parse(_periodWin.text.toString());
        if (newValue >= 0) {
          periodWin = newValue;
        } else if (!(shown)) {
          shown = true;
          showDialog(
              context: context,
              builder: (context) =>
              new AlertDialog(
                title: new Text("Valore non valido"),
                content: new Text(
                    "Il numero di giochi per vincere il set deve essere maggiore di 0"),
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
          shown = false;
        }
      }
    });
    _periodNumber.addListener(() {
      if (_periodNumber.text.isNotEmpty) {
        int newValue = int.parse(_periodNumber.text.toString());
        if (newValue >= 0)
          periodNumber = newValue;
        else if (!(shown)) {
          shown = true;
          showDialog(
              context: context,
              builder: (context) =>
              new AlertDialog(
                title: new Text("Valore non valido"),
                content: new Text("Deve esserci almeno un set"),
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
          shown = false;
        }
      }
    });
    return new Scaffold(
      appBar: new AppBar(),
      body: new Column(children: <Widget>[
        new ListTile(
            trailing: new Text("Giochi per Set"),
            title: new TextField(
              keyboardType: TextInputType.number,
              decoration: new InputDecoration(
                hintText: periodWin.toString(),
              ),
              controller: _periodWin,
            )),
        new ListTile(
            trailing: new Text("Al Meglio di (# set)"),
            title: new TextField(
              keyboardType: TextInputType.number,
              decoration: new InputDecoration(
                hintText: periodNumber.toString(),
              ),
              controller: _periodNumber,
            )),
      ]),
    );
  }
}
