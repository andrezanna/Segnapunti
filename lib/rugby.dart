
import 'package:Segnapunti/player.dart';
import 'package:Segnapunti/timertextformatter.dart';
import 'package:Segnapunti/util.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

int periodLength = 40;
int periodNumber = 2;
TimerState timerState;
int inPeriod = 0;
bool darkTheme = false;


//TODO - period Number

class Rugby extends StatefulWidget {
  @override
  createState() {
    getSharedPreferences();
    return new RugbyState();
  }

  getSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    darkTheme = prefs.getBool("dark");
    if (darkTheme == null) darkTheme = false;
    periodLength = prefs.getInt("RugbyLength");
    if (periodLength == null) periodLength = 40;
    periodNumber = prefs.getInt("RugbyNumber");
    if (periodNumber == null) periodNumber = 2;
  }
}

class RugbyState extends State<Rugby> {
  Player team1 = new Player("HOME", 0);
  Player team2 = new Player("AWAY", 0);

  final List<Scores> scores = new List();
  Scores lastPeriod = new Scores(0, 0);
  SharedPreferences prefs;
  int oldPeriodLength;
  int oldPeriodNumber;
  bool gameOver = false;

  @override
  void initState() {
    getSharedPreferences();
    oldPeriodNumber = periodNumber;
    oldPeriodLength = periodLength;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    List<Widget> actions = <Widget>[
      new MaterialButton(
        onPressed: () {
          Navigator.of(context).push(
              new MaterialPageRoute(builder: (context) => new RugbySettings()));
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
      appBar: new AppBar(
        title: new Text('Rugby'),
        leading: new BackButton(
          color: (darkTheme) ? Colors.black : Colors.white,
        ),
        textTheme: new TextTheme(
            title: new TextStyle(
                color: (darkTheme) ? Colors.black : Colors.white,
                fontSize: 20.0,
                fontWeight: FontWeight.bold)),
        actions: actions,
      ),
      backgroundColor: (darkTheme)
          ? Color.fromARGB(255, 50, 50, 50)
          : Color.fromARGB(255, 250, 250, 250),
      body: _buildRugby(),
    );
  }

  void getSharedPreferences() async {
    prefs = await SharedPreferences.getInstance();
    if (scores.isEmpty) {
      scores.clear();
      for (int i = 0; i < periodNumber; i++)
        scores.add(new Scores(0, 0));
    }
  }

  @override
  void dispose() {
    prefs.setInt("RugbyNumber", periodNumber);
    prefs.setInt("RugbyLength", periodLength);
    super.dispose();
  }

  void onTimeEnd(void a) {
    setState(() {
      scores[inPeriod].setScores(
          team1.value - lastPeriod.team1, team2.value - lastPeriod.team2);
      lastPeriod.setScores(team1.value, team2.value);
      inPeriod++;
      if (inPeriod == periodNumber)
        gameOver = true;
    });
  }

  Widget _buildRugby() {
    if (oldPeriodLength != periodLength) {
      setState(() {
        oldPeriodNumber = periodNumber;
        oldPeriodLength = periodLength;
      });
    }
    if (oldPeriodNumber != periodNumber) {
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
            child: new TimerText(periodLength: oldPeriodLength,
              periodNumber: oldPeriodNumber,
              inPeriod: inPeriod,
              type: TimerType.chronometer,
              onTimeEnd: onTimeEnd,
              stateChange: stateChange,
              gameOver: gameOver,
            ),

          ),
        ),
        new Expanded(
          child: new Row(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              new Expanded(child: new RugbyTeamScore(team1)),
              new TeamScorePeriod(scores: scores,
                darkTheme: darkTheme,
                periodNumber: periodNumber,),
              new Expanded(child: new RugbyTeamScore(team2)),
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
      gameOver = false;
      inPeriod = 0;
    });
  }

  void stateChange(TimerState value) {
    timerState = value;
  }
}

class RugbyTeamScore extends StatefulWidget {
  RugbyTeamScore(this.team);

  final Player team;

  @override
  createState() => new RugbyTeamScoreState(team);
}

class RugbyTeamScoreState extends State<RugbyTeamScore> {
  RugbyTeamScoreState(this.team);

  final Player team;

  @override
  Widget build(BuildContext context) {
    return new Column(
      children: <Widget>[
        new Expanded(
          child: new MaterialButton(
            onPressed: () {
              setState(() {
                if (team.value > 0) team.value -= 1;
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
          child: new FittedBox(
            child: new Text(
              team.name,
              style: new TextStyle(fontSize: 30.0,
                  fontWeight: FontWeight.bold,
                  color: (darkTheme) ? Colors.blue : Colors.black),
            ),
          ),
        ),
        new Expanded(
          child: new MaterialButton(
              onPressed: () {
                if (timerState != TimerState.ready)
                  setState(() {
                    team.value += 5;
                  });
              },
              child: new Text(
                "+5",
                style: new TextStyle(fontSize: 25.0,
                    color: (darkTheme) ? Colors.blue : Colors.black),
              )),
        ),
        new Expanded(
          child: new MaterialButton(
              onPressed: () {
                if (timerState == TimerState.running)
                  setState(() {
                    team.value += 2;
                  });
              },
              child: new Text(
                "+2",
                style: new TextStyle(fontSize: 25.0,
                    color: (darkTheme) ? Colors.blue : Colors.black),
              )),
        ),
        new Expanded(
            child: new MaterialButton(
                onPressed: () {
                  if (timerState == TimerState.running)
                    setState(() {
                      team.value += 3;
                    });
                },
                child: new Text(
                  "+3",
                  style: new TextStyle(fontSize: 25.0,
                      color: (darkTheme) ? Colors.blue : Colors.black),
                ))),
      ],
    );
  }
}


class RugbySettings extends StatelessWidget {
  final TextEditingController _periodLength = new TextEditingController();
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
                    "La durata del tempo deve essere maggiore di 0"),
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
          shown = false;
        }
      }
    });
    return new Scaffold(
      appBar: new AppBar(leading: new BackButton(
        color: (darkTheme) ? Colors.black : Colors.white,
      ),),
      backgroundColor: (darkTheme)
          ? Color.fromARGB(255, 50, 50, 50)
          : Color.fromARGB(255, 250, 250, 250),
      body: new Column(children: <Widget>[
        new ListTile(
            trailing: new Text("Durata Tempo", style: new TextStyle(
                color: (darkTheme) ? Colors.blue : Colors.black),),
            title: new TextField(
              keyboardType: TextInputType.number,
              style: new TextStyle(
                  color: (darkTheme) ? Colors.blue : Colors.black),
              decoration: new InputDecoration(
                hintText: periodLength.toString(),
                hintStyle: new TextStyle(
                    color: (darkTheme) ? Colors.blue : Colors.black),
              ),
              controller: _periodLength,
            )),
        new ListTile(
            trailing: new Text("Numero di Tempi", style: new TextStyle(
                color: (darkTheme) ? Colors.blue : Colors.black),),
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
      ]),
    );
  }
}


