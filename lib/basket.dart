
import 'package:Segnapunti/player.dart';
import 'package:Segnapunti/timertextformatter.dart';
import 'package:Segnapunti/util.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

int periodLength = 10;
int teamFoulThreshold = 4;
int periodNumber = 4;
int shotClock = 24;
int inPeriod = 0;
bool darkTheme = false;
TimerState timerState;

//TODO - TimeEnd


class Basket extends StatefulWidget {
  @override
  createState() {
    getSharedPreferences();
    return new BasketState();
  }

  getSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    darkTheme = prefs.getBool("dark");
    if (darkTheme == null) darkTheme = false;
    periodLength = prefs.getInt("BasketLength");
    if (periodLength == null) periodLength = 10;
    periodNumber = prefs.getInt("BasketNumber");
    if (periodNumber == null) periodNumber = 4;
    teamFoulThreshold = prefs.getInt("BasketFouls");
    if (teamFoulThreshold == null) teamFoulThreshold = 4;
    shotClock = prefs.getInt("BasketShot");
    if (shotClock == null) shotClock = 24;
  }
}

class BasketState extends State<Basket> {
  BasketTeam team1 = new BasketTeam("HOME", 0);
  BasketTeam team2 = new BasketTeam("AWAY", 0);
  final List<Scores> scores = new List();
  Scores lastPeriod = new Scores(0, 0);
  SharedPreferences prefs;
  bool gameOver = false;

  int oldPeriodNumber;
  int oldPeriodLength;

  BasketState() {
    getSharedPrefs();
    oldPeriodNumber = periodNumber;
    oldPeriodLength = periodLength;
  }


  @override
  Widget build(BuildContext context) {

    List<Widget> actions = <Widget>[
      new MaterialButton(
        onPressed: () {
          Navigator.of(context).push(new MaterialPageRoute(
              builder: (context) => new BasketSettings()));
        },
        child: new Text(
          "IMPOSTAZIONI",
          style:
          new TextStyle(color: (darkTheme) ? Colors.black : Colors.white),
        ),
      ),
    ];
    if (gameOver) {
      actions.add(
        new MaterialButton(
          onPressed: () {
            newGame();
          },
          child: new Text(
            "NUOVA",
            style:
            new TextStyle(color: (darkTheme) ? Colors.black : Colors.white),
          ),
        ),
      );
    }
    return new Scaffold(
      backgroundColor: (darkTheme)
          ? Color.fromARGB(255, 50, 50, 50)
          : Color.fromARGB(255, 250, 250, 250),
      appBar: new AppBar(
        leading: new BackButton(
          color: (darkTheme) ? Colors.black : Colors.white,
        ),
        textTheme: new TextTheme(
            title: new TextStyle(
                color: (darkTheme) ? Colors.black : Colors.white,
                fontSize: 20.0,
                fontWeight: FontWeight.bold)),
        title: new Text('Basket'),
        actions: actions,
      ),
      body: _buildBasket(),
    );
  }

  @override
  void dispose() {
    prefs.setInt("BasketNumber", periodNumber);
    prefs.setInt("BasketLength", periodLength);
    prefs.setInt("BasketFouls", teamFoulThreshold);
    prefs.setInt("BasketShot", shotClock);
    super.dispose();
  }

  getSharedPrefs() async {
    prefs = await SharedPreferences.getInstance();
    if (scores.isEmpty)
      for (int i = 0; i < periodNumber; i++) {
        scores.add(new Scores(0, 0));
      }
  }


  void onTimeEnd(void a) {
    setState(() {
      scores[inPeriod].setScores(
          team1.value - lastPeriod.team1, team2.value - lastPeriod.team2);
      lastPeriod.setScores(team1.value, team2.value);
      if (inPeriod >= periodNumber - 1) {
        if (team1.value == team2.value) {
          scores.add(new Scores(0, 0));
        } else {
          gameOver = true;
        }
      }
      team1.fouls = 0;
      team2.fouls = 0;
      inPeriod++;
    });
  }

  Widget _buildBasket() {
    if (periodLength != oldPeriodLength) {
      setState(() {
        oldPeriodLength = periodLength;
        oldPeriodNumber = periodNumber;
      });
    }
    if (periodNumber != oldPeriodNumber) {
      scores.clear();
      for (int i = 0; i < periodNumber; i++)
        scores.add(new Scores(0, 0));
    }
    return new Flex(
      direction: Axis.vertical,
      children: <Widget>[
        new Center(
          child: new Container(
            color: Colors.black,
            margin: const EdgeInsets.all(25.0),
            constraints: new BoxConstraints(
                minWidth: 200.0,
                maxWidth: 300.0,
                minHeight: 60.0,
                maxHeight: 80.0),

              child: new Center(
                child: new TimerText(periodNumber: oldPeriodNumber,
                    periodLength: oldPeriodLength,
                    inPeriod: inPeriod,
                    onTimeEnd: onTimeEnd,
                  stateChange: stateChange,
                  gameOver: gameOver,),

            ),
          ),
        ),
        new Expanded(
          child: new Row(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              new Expanded(child: new BasketTeamScore(team1)),
              new TeamScorePeriod(scores: scores,
                darkTheme: darkTheme,
                periodNumber: periodNumber,),
              new Expanded(child: new BasketTeamScore(team2)),
            ],
          ),
        ),
      ],
    );
  }


  void newGame() {
    setState(() {
      lastPeriod.setScores(0, 0);
      scores.clear();
      for (int i = 0; i < periodNumber; i++)
        scores.add(new Scores(0, 0));
      team1.value = 0;
      team2.value = 0;
      team1.fouls = 0;
      team2.fouls = 0;
      gameOver = false;
      inPeriod = 0;
    });
  }

  void stateChange(TimerState value) {
    timerState = value;
  }
}

class BasketTeamScore extends StatefulWidget {
  BasketTeamScore(this.team);

  final BasketTeam team;
  @override
  createState() => new BasketTeamScoreState(team);
}

class BasketTeamScoreState extends State<BasketTeamScore> {
  BasketTeamScoreState(this.team);

  final BasketTeam team;
  @override
  Widget build(BuildContext context) {
    return new Column(
      children: <Widget>[
        new MaterialButton(
          onPressed: () {
            setState(() {
              if (team.value > 0) team.value -= 1;
            });
          },
          child: new Flex(
            direction: Axis.horizontal,
            children: <Widget>[
              new Expanded(
                child: new Container(
                  child: new FittedBox(
                    child: new Text(
                      team.value.toString().padLeft(3, '0'),
                      style: new TextStyle(
                        color: Colors.red,
                        fontFamily: "ShotClock",
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),),

              ),
              new Icon(
                (team.fouls >= teamFoulThreshold) ? Icons.brightness_1 : null,
                color: Colors.red,
              ),
            ],
          ),
        ),
        new Expanded(
          child: new FittedBox(
            child: new Text(
              team.name,
              style: new TextStyle(
                color: (darkTheme) ? Colors.blue : Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        new Expanded(
          child: new FittedBox(
            child: new MaterialButton(
              onPressed: () {
                if (timerState != TimerState.ready)
                  setState(() {
                    team.value += 1;
                  });
              },
              child: new Text(
                "+1",
                style: new TextStyle(
                    color: (darkTheme) ? Colors.blue : Colors.black),
              ),
            ),
          ),
        ),
        new Expanded(
          child: new FittedBox(
            child: new MaterialButton(
              onPressed: () {
                if (timerState == TimerState.running)
                  setState(() {
                    team.value += 2;
                  });
              },
              child: new Text(
                "+2",
                style: new TextStyle(
                    color: (darkTheme) ? Colors.blue : Colors.black),
              ),
            ),
          ),
        ),
        new Expanded(
            child: new FittedBox(
              child: new MaterialButton(
                onPressed: () {
                  if (timerState == TimerState.running)
                    setState(() {
                      team.value += 3;
                    });
                },
                child: new Text(
                  "+3",
                  style: new TextStyle(
                      color: (darkTheme) ? Colors.blue : Colors.black),
                ),
              ),
            )),
        new Expanded(
          child: new FittedBox(
            child: new MaterialButton(
              onPressed: () {
                setState(() {
                  team.fouls += 1;
                });
              },
              child: new Text(
                "FALLO",
                style: new TextStyle(
                    color: (darkTheme) ? Colors.blue : Colors.black),
              ),
            ),
          ),
        ),
      ],
    );
  }
}


class BasketSettings extends StatelessWidget {
  final TextEditingController _periodLength = new TextEditingController();
  final TextEditingController _teamFoul = new TextEditingController();
  final TextEditingController _periodNumber = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    bool shown = false;

    _periodLength.addListener(() {
      if (_periodLength.text.isNotEmpty) {
        int newValue = int.parse(_periodLength.text.toString());
        if (newValue >= 0) {
          periodLength = newValue;
        } else if (!(shown)) {
          shown = true;
          showDialog(
              context: context,
              builder: (context) =>
              new AlertDialog(
                title: new Text("Valore non valido"),
                content: new Text(
                    "La durata del quarto deve essere maggiore di 0"),
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
                content: new Text("Deve esserci almeno un tempo"),
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
      }
    });
    _teamFoul.addListener(() {
      if (_teamFoul.text.isNotEmpty) {
        int newValue = int.parse(_teamFoul.text.toString());
        if (newValue >= 0)
          teamFoulThreshold = newValue;
        else if (!(shown)) {
          shown = true;
          showDialog(
              context: context,
              builder: (context) =>
              new AlertDialog(
                title: new Text("Valore non valido"),
                content: new Text(
                    "Il limite di falli per il bonus deve essere maggiore di 0"),
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
      }
    });
    return new Scaffold(
      backgroundColor: (darkTheme)
          ? Color.fromARGB(255, 50, 50, 50)
          : Color.fromARGB(255, 250, 250, 250),
      appBar: new AppBar(
        leading: new BackButton(
          color: (darkTheme) ? Colors.black : Colors.white,
        ),
      ),
      body: new Column(children: <Widget>[
        new ListTile(
            trailing: new Text(
              "Durata Quarto",
              style: new TextStyle(
                  color: (darkTheme) ? Colors.blue : Colors.black),
            ),
            title: new TextField(
              keyboardType: TextInputType.number,
              decoration: new InputDecoration(
                hintText: periodLength.toString(),
                hintStyle: new TextStyle(
                    color: (darkTheme) ? Colors.blue : Colors.black),
              ),
              controller: _periodLength,
              style: new TextStyle(
                  color: (darkTheme) ? Colors.blue : Colors.black),
            )),
        new ListTile(
            trailing: new Text(
              "Numero di Tempi",
              style: new TextStyle(
                  color: (darkTheme) ? Colors.blue : Colors.black),
            ),
            title: new TextField(
              keyboardType: TextInputType.number,
              decoration: new InputDecoration(
                hintText: periodNumber.toString(),
                hintStyle: new TextStyle(
                    color: (darkTheme) ? Colors.blue : Colors.black),
              ),
              controller: _periodNumber,
              style: new TextStyle(
                  color: (darkTheme) ? Colors.blue : Colors.black),
            )),
        new ListTile(
            trailing: new Text(
              "Falli per bonus",
              style: new TextStyle(
                  color: (darkTheme) ? Colors.blue : Colors.black),
            ),
            title: new TextField(
              keyboardType: TextInputType.number,
              decoration: new InputDecoration(
                hintText: teamFoulThreshold.toString(),
                hintStyle: new TextStyle(
                    color: (darkTheme) ? Colors.blue : Colors.black),
              ),
              controller: _teamFoul,
              style: new TextStyle(
                  color: (darkTheme) ? Colors.blue : Colors.black),
            )),
      ]),
    );
  }
}

class BasketTeam extends Player {
  int fouls = 0;
  BasketTeam(name, value) : super(name, value);

  void foul() {
    fouls++;
  }
}

