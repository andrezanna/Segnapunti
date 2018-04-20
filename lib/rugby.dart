import 'dart:async';

import 'package:Segnapunti/player.dart';
import 'package:Segnapunti/timertextformatter.dart';
import 'package:Segnapunti/util.dart';
import 'package:flutter/material.dart';

int periodLength = 40;
int periodNumber = 2;
TimerTextState timerSuper;
int inPeriod = 0;
Stopwatch stopwatch = new Stopwatch();

//TODO - period Number

class Rugby extends StatefulWidget {
  @override
  createState() => new RugbyState();
}

class RugbyState extends State<Rugby> {
  Player team1 = new Player("Casa", 0);
  Player team2 = new Player("Trasferta", 0);

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
          Navigator.of(context).push(
              new MaterialPageRoute(builder: (context) => new RugbySettings()));
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
        title: new Text('Rugby'),
        actions: actions,
      ),
      body: _buildRugby(),
    );
  }

  void

  onTimeEnd

  (void a)

  {
  setState(() {
  scores[inPeriod].setScores(
  team1.value - lastPeriod.team1, team2.value - lastPeriod.team2);
  lastPeriod.setScores(team1.value, team2.value);
  inPeriod++;
  });
  }

  Widget _buildRugby()

  {
  TimerText timerText = new TimerText();
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
  child: new MaterialButton(
  onPressed: () {
  startStop();
  },
  child: new Center(
  child: timerText,
  ),
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
  new TeamScorePeriod(scores),
  new Expanded(child: new RugbyTeamScore(team2)),
  ],
  ),
  ),
  ],
  );
  }

  void startStop()

  {
  if (stopwatch.isRunning) {
  timerSuper.startStop(periodLength);
  } else {
  timerSuper.startStop(periodLength);
  }
  if (stopwatch.elapsedMilliseconds >= periodLength * 60 * 1000) {
  if (inPeriod < scores.length) {
  timerSuper.reset();
  } else {
  showDialog(
  context: context,
  builder: (context) => new AlertDialog(
  title: new Text("Impossibila avviare cronometro"),
  content: new Text(
  "La partita è finita, vuoi iniziare una nuova partita?"),
  actions: <Widget>[
  new CloseButton(),
  new MaterialButton(
  onPressed: () {
  Navigator.of(context).pop();
  nuovaPartita();
  },
  child: new Icon(Icons.done),
  )
  ],
  ));
  }
  }
  }

  void nuovaPartita()

  {
  setState(() {
  lastPeriod.setScores(0, 0);
  stopwatch.reset();
  for (var score in scores) {
  score.setScores(0, 0);
  }
  team1.value = 0;
  team2.value = 0;

  inPeriod = 0;
  });
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
                if (team.value > 0)
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
                if (stopwatch.elapsedMilliseconds > 0 && stopwatch.isRunning)
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
                if (stopwatch.isRunning)
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
                  if (stopwatch.isRunning)
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

class TeamScorePeriod extends StatefulWidget {
  TeamScorePeriod(this.scores);

  final List<Scores> scores;

  @override
  createState() {
    return new TeamScorePeriodState(scores);
  }
}

class TeamScorePeriodState extends State<TeamScorePeriod> {
  TeamScorePeriodState(this.scores);

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
          stopwatch.reset();
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
      appBar: new AppBar(),
      body: new Column(children: <Widget>[
        new ListTile(
            trailing: new Text("Durata Tempo"),
            title: new TextField(
              keyboardType: TextInputType.number,
              decoration: new InputDecoration(
                hintText: periodLength.toString(),
              ),
              controller: _periodLength,
            )),
        new ListTile(
            trailing: new Text("Numero di Tempi"),
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

class TimerText extends StatefulWidget {
  TimerText();

  TimerTextState createState() {
    TimerTextState timerTextState = new TimerTextState();
    timerSuper = timerTextState;
    return timerTextState;
  }
}

class TimerTextState extends State<TimerText> {
  Timer timer;
  bool running = true;
  bool cb = false;
  String text;

  TimerTextState() {
    startStop(periodLength);
  }

  @override
  void dispose() {
    if (timer != null) timer.cancel();
    stopwatch.stop();
    super.dispose();
  }

  void callback(Timer timer) {
    if (stopwatch.isRunning) {
      setState(() {});
    }
  }

  void startStop(int periodLength) {
    if (!running &&
        stopwatch.elapsedMilliseconds < (periodLength) * 1000 * 60) {
      stopwatch.start();

      running = true;

      timer = new Timer.periodic(new Duration(milliseconds: 1000), callback);
    } else if (running && timer != null) {
      stopwatch.stop();
      running = false;
      timer.cancel();
    } else {
      running = false;
      stopwatch.stop();
    }
  }

  void reset() {
    setState(() {
      stopwatch.reset();
    });
  }

  @override
  Widget build(BuildContext context) {
    final TextStyle timerTextStyle = const TextStyle(
        fontSize: 60.0, fontFamily: "Open Sans", color: Colors.red);
    text = TimerTextFormatter.format(stopwatch.elapsedMilliseconds);
    return new Text(text, style: timerTextStyle);
  }
}
