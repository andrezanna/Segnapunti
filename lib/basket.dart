import 'dart:async';

import 'package:Segnapunti/player.dart';
import 'package:flutter/material.dart';

int quarterLength = 10;
int teamFoulThreshold = 4;
TimerTextState timerSuper;
int inQuarter = 0;
Stopwatch stopwatch = new Stopwatch();

//TODO - Riepilogo punteggio
//TODO - Qaurter restart

class Basket extends StatefulWidget {
  @override
  createState() => new BasketState();
}

class BasketState extends State<Basket> {
  BasketTeam team1 = new BasketTeam("Casa", 0);
  BasketTeam team2 = new BasketTeam("Trasferta", 0);
  final List<Scores> scores = <Scores>[
    new Scores(0, 0),
    new Scores(0, 0),
    new Scores(0, 0),
    new Scores(0, 0),
  ];
  Scores lastQuarter = new Scores(0, 0);

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
          style: new TextStyle(color: Colors.white),
        ),
      ),
    ];
    if (inQuarter == scores.length) {
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
        title: new Text('Basket'),
        actions: actions,
      ),
      body: _buildBasket(),
    );
  }

  void

  onTimeEnd

  (void a)

  {
  setState(() {
  scores[inQuarter].setScores(
  team1.value - lastQuarter.team1, team2.value - lastQuarter.team2);
  lastQuarter.setScores(team1.value, team2.value);
  if (team1.value == team2.value && inQuarter >= 3) {
  scores.add(new Scores(0, 0));
  }
  team1.fouls = 0;
  team2.fouls = 0;
  inQuarter++;

  });
  }

  Widget _buildBasket()

  {
  TimerText timerText = new TimerText(onTimeEnd);
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
  new Expanded(child: new BasketTeamScore(team1)),
  new TeamScoreQuarter(scores),
  new Expanded(child: new BasketTeamScore(team2)),
  ],
  ),
  ),
  ],
  );
  }

  void startStop()

  {
  if (stopwatch.isRunning) {
  timerSuper.startStop(quarterLength);
  } else {
  timerSuper.startStop(quarterLength);
  }
  if (stopwatch.elapsedMilliseconds >= quarterLength * 60 * 1000) {
  if (inQuarter < scores.length) {
  inQuarter++;
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
  lastQuarter.setScores(0, 0);
  stopwatch.reset();
  for (var score in scores) {
  score.setScores(0, 0);
  }
  team1.value = 0;
  team2.value = 0;
  team1.fouls = 0;
  team2.fouls = 0;
  inQuarter = 0;
  });
  }
}

class Scores {
  int team1;
  int team2;

  Scores(this.team1, this.team2);

  void setScores(int team1, int team2) {
    this.team1 = team1;
    this.team2 = team2;
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
                new Icon(
                  (team.fouls >= teamFoulThreshold) ? Icons.brightness_1 : null,
                  color: Colors.red,
                  size: 10.0,
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
                if (stopwatch.elapsedMilliseconds > 0 &&
                    stopwatch.elapsedMilliseconds < quarterLength * 1000 * 60)
                  setState(() {
                    team.value += 1;
                  });
              },
              child: new Text(
                "+1",
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
        new Expanded(
          child: new MaterialButton(
              onPressed: () {
                setState(() {
                  team.fouls += 1;
                });
              },
              child: new Text(
                "FALLO",
                style: new TextStyle(fontSize: 25.0),
              )),
        ),
      ],
    );
  }
}

class TeamScoreQuarter extends StatefulWidget {
  TeamScoreQuarter(this.scores);

  final List<Scores> scores;

  @override
  createState() {
    return new TeamScoreQuarterState(scores);
  }
}

class TeamScoreQuarterState extends State<TeamScoreQuarter> {
  TeamScoreQuarterState(this.scores);

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
                        (index > 3) ? " TS${index - 3} " : " ${index + 1} ",
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

class BasketSettings extends StatelessWidget {
  final TextEditingController _quarterLength = new TextEditingController();
  final TextEditingController _teamFoul = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    bool shown = false;

    _quarterLength.addListener(() {
      if (_quarterLength.text.isNotEmpty) {
        int newValue = int.parse(_quarterLength.text.toString());
        if (newValue >= 0) {
          quarterLength = newValue;
          stopwatch.reset();
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
          shown = false;
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
          shown = false;
        }
      }
    });
    return new Scaffold(
      appBar: new AppBar(),
      body: new Column(children: <Widget>[
        new ListTile(
            trailing: new Text("Valore massimo"),
            title: new TextField(
              keyboardType: TextInputType.number,
              decoration: new InputDecoration(
                hintText: quarterLength.toString(),
              ),
              controller: _quarterLength,
            )),
        new ListTile(
            trailing: new Text("Falli per bonus"),
            title: new TextField(
              keyboardType: TextInputType.number,
              decoration: new InputDecoration(
                hintText: teamFoulThreshold.toString(),
              ),
              controller: _teamFoul,
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

class TimerText extends StatefulWidget {
  TimerText(this.onTimeEnd);

  final ValueChanged

  <

  void

  >

  onTimeEnd

  ;

  TimerTextState createState()

  {
  TimerTextState timerTextState = new TimerTextState(onTimeEnd);
  timerSuper = timerTextState;
  return timerTextState;
  }
}

class TimerTextState extends State<TimerText> {
  Timer timer;
  bool running = true;
  bool cb = false;
  String text;

  final ValueChanged

  <

  void

  >

  onTimeEnd

  ;
  int qLength = quarterLength;

  TimerTextState(this.

  onTimeEnd) {
  startStop(quarterLength);
  }

  @override
  void dispose() {
  if (timer != null) timer.cancel();
  stopwatch.stop();
  super.dispose();
  }

  void callback(Timer timer) {
  if (stopwatch.isRunning) {
  if (stopwatch.elapsedMilliseconds >= (qLength) * 1000 * 60) {
  timer.cancel();
  stopwatch.stop();
  onTimeEnd(null);
  setState(() {
  text = TimerTextFormatter.format(0, true);
  });
  } else
  if (stopwatch.elapsedMilliseconds >= (qLength - 1) * 1000 * 60 &&
  !cb) {
  timer = new Timer.periodic(new Duration(milliseconds: 30), callback);
  cb = true;
  } else
  if (stopwatch.elapsedMilliseconds < (qLength - 1) * 1000 * 60 &&
  cb) {
  timer = new Timer.periodic(new Duration(milliseconds: 1000), callback);
  cb = false;
  }
  setState(() {});
  }
  }

  void startStop(int quarterLength) {
  if (inQuarter > 3)
  qLength = (quarterLength / 2) as int;
  else
  qLength = quarterLength;
  if (!running && stopwatch.elapsedMilliseconds < (qLength) * 1000 * 60) {
  stopwatch.start();

  running = true;
  if (stopwatch.elapsedMilliseconds >= (qLength - 1) * 1000 * 60) {
  timer = new Timer.periodic(new Duration(milliseconds: 100), callback);
  } else {
  timer = new Timer.periodic(new Duration(milliseconds: 1000), callback);
  }
  } else
  if (running && timer != null) {
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
  Widget build(BuildContext context)

  {
  final TextStyle timerTextStyle = const TextStyle(
  fontSize: 60.0, fontFamily: "Open Sans", color: Colors.red);
  text = TimerTextFormatter.format(
  (quarterLength * 1000 * 60) - stopwatch.elapsedMilliseconds,
  stopwatch.elapsedMilliseconds > (quarterLength - 1) * 1000 * 60);
  return new Text(text, style: timerTextStyle);
  }
}

class TimerTextFormatter {
  static String format(int milliseconds, bool lastMinute) {
    int hundreds = (milliseconds / 10).truncate();
    int seconds = (hundreds / 100).truncate();
    int minutes = (seconds / 60).truncate();

    String minutesStr = (minutes % 60).toString().padLeft(2, '0');
    String secondsStr = (seconds % 60).toString().padLeft(2, '0');
    String hundredsStr = (hundreds % 100).toString().padLeft(2, '0');

    return (lastMinute)
        ? "$minutesStr:$secondsStr.$hundredsStr"
        : "$minutesStr:$secondsStr";
  }
}
