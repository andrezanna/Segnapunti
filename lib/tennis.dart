import 'package:Segnapunti/player.dart';
import 'package:Segnapunti/util.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

int periodWin = 6;
int periodNumber = 3;
int inPeriod = 0;
bool tieBreak = true;
bool inTieBreak = false;
bool matchWon = false;
bool darkTheme = false;

class Tennis extends StatefulWidget {
  @override
  createState() {
    getSharedPreferences();
    return new TennisState();
  }

  getSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    darkTheme = prefs.getBool("dark");
    if (darkTheme == null) darkTheme = false;
    periodWin = prefs.getInt("TennisWin");
    if (periodWin == null) periodWin = 6;
    periodNumber = prefs.getInt("TennisNumber");
    if (periodNumber == null) periodNumber = 3;
    tieBreak = prefs.getBool("TennisTie");
    if (tieBreak == null) tieBreak = true;
  }
}

class TennisState extends State<Tennis> {
  TennisPlayer player1 = new TennisPlayer(
    "Giocatore 1",
    0,
    1,
    true,
  );
  TennisPlayer player2 = new TennisPlayer(
    "Giocatore 2",
    0,
    2,
  );
  final List<Scores> scores = new List();
  Scores lastPeriod = new Scores(0, 0);

  @override
  Widget build(BuildContext context) {
    if (scores.isEmpty || scores.length != periodNumber) {
      scores.clear();
      for (int i = 0; i < periodNumber; i++)
        scores.add(new Scores(0, 0));
      inPeriod = 0;
      player1.value = 0;
      player2.value = 0;
      player1.service = true;
      player2.service = false;
      player1.setWon = 0;
      player2.setWon = 0;
      matchWon = false;
    }
    List<Widget> actions = <Widget>[
      new MaterialButton(
        onPressed: () {
          Navigator.of(context).push(new MaterialPageRoute(
              builder: (context) => new TennisSettings()));
        },
        child: new Text(
          "IMPOSTAZIONI",
          style:
          new TextStyle(color: (darkTheme) ? Colors.black : Colors.white),
        ),
      ),
    ];
    if (matchWon) {
      actions.add(
        new MaterialButton(
          onPressed: () {
            newMatch();
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
        leading: new BackButton(
          color: (darkTheme) ? Colors.black : Colors.white,
        ),
        textTheme: new TextTheme(
            title: new TextStyle(
                color: (darkTheme) ? Colors.black : Colors.white,
                fontSize: 20.0,
                fontWeight: FontWeight.bold)),
        title: new Text('Tennis'),
        actions: actions,
      ),
      body: _buildTennis(),
      backgroundColor: (darkTheme)
          ? Color.fromARGB(255, 50, 50, 50)
          : Color.fromARGB(255, 250, 250, 250),
    );
  }

  Widget _buildTennis() {
    return new Flex(
      direction: Axis.vertical,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(36.0),
          child: new TennisScorePeriod(scores, player1, player2),
        ),
        new Expanded(
          child: new Row(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              new Expanded(child: new TennisScore(player1, pointScored)),
              new Expanded(child: new TennisScore(player2, pointScored)),
            ],
          ),
        ),
      ],
    );
  }

  void pointScored(TennisPlayer player) {
    if (inPeriod == scores.length || matchWon) {
      matchWon = true;
    } else {
      TennisPlayer other = (player.name == player1.name) ? player2 : player1;
      bool setWin = false;
      if (inTieBreak) {
        if (player.value >= other.value + 2 && player.value >= 7) {
          setWin = true;
        } else if ((player.value + other.value) % 2 != 0) {
          setState(() {
            player.service = !player.service;
            other.service = !other.service;
          });
        }
      } else if ((player.value == 4 && other.value < 3) || player.value == 5) {
        setWin = true;
      } else if (player.value == 4 && other.value == 4) {
        setState(() {
          player1.value = 3;
          player2.value = 3;
        });
      }
      if (setWin) {
        setState(() {
          player1.value = 0;
          player2.value = 0;
          player.service = !player.service;
          other.service = !other.service;

          if (player.name == player1.name) {
            scores[inPeriod].team1 += 1;

            if ((scores[inPeriod].team1 >= periodWin &&
                scores[inPeriod].team1 >= scores[inPeriod].team2 + 2) ||
                inTieBreak) {
              inPeriod += 1;
              if (++player.setWon >= (periodNumber / 2).ceil()) {
                matchWon = true;
              }
            }
          } else {
            scores[inPeriod].team2 += 1;
            if ((scores[inPeriod].team2 >= periodWin &&
                scores[inPeriod].team2 >= scores[inPeriod].team1 + 2) ||
                inTieBreak) {
              inPeriod += 1;

              if (++player.setWon >= (periodNumber / 2).ceil()) {
                matchWon = true;
              }
            }
          }
          inTieBreak = false;

          if (scores[inPeriod].team2 == periodWin &&
              scores[inPeriod].team1 == periodWin &&
              tieBreak) inTieBreak = true;
        });
      }
    }
    if (matchWon) {
      showDialog(
        context: context,
        builder: (BuildContext context) =>
        new AlertDialog(
          title: new Text("La partita è stata vinta"),
          content: new Text("Vuoi fare una nuova partita?"),
          actions: <Widget>[
            new CloseButton(),
            new MaterialButton(
              onPressed: () {
                Navigator.of(context).pop();
                newMatch();
              },
              child: new Icon(Icons.done),
            )
          ],
        ),
      );
    }
  }

  void newMatch() {
    setState(() {
      inPeriod = 0;
      player1.value = 0;
      player2.value = 0;
      player1.service = true;
      player2.service = false;
      player1.setWon = 0;
      player2.setWon = 0;
      scores.clear();
      for (int i = 0; i < periodNumber; i++)
        scores.add(new Scores(0, 0));
      matchWon = false;
    });
  }
}

class TennisScore extends StatefulWidget {
  TennisScore(this.team, this.pointScored);

  final ValueChanged<TennisPlayer> pointScored;
  final TennisPlayer team;

  @override
  createState() => new TennisScoreState(team, pointScored);
}

class TennisScoreState extends State<TennisScore> {
  TennisScoreState(this.team, this.pointScored);

  final ValueChanged<TennisPlayer> pointScored;

  final TennisPlayer team;
  final TextEditingController _controller = new TextEditingController();
  FocusNode focusNode = new FocusNode();

  @override
  Widget build(BuildContext context) {
    _controller.addListener(nameChange);
    focusNode.addListener(_ensureVisible);

    List<String> points = ["0", "15", "30", "40", "ADV"];
    return new Flex(
      direction: Axis.vertical,
      children: <Widget>[
        new Expanded(
          child: new MaterialButton(
            onPressed: () {
              setState(() {
                if (team.value > 0 && !matchWon) team.value -= 1;
              });
            },
            child: new Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                new Center(
                  child: new Text(
                    (inTieBreak) ? team.value.toString() : points[team.value],
                    style: new TextStyle(
                      color: Colors.red,
                      fontSize: 40.0,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
                new Icon(
                  (team.service) ? Icons.brightness_1 : null,
                  color: Colors.red,
                  size: 10.0,
                ),
              ],
            ),
          ),
        ),
        new Expanded(
          child: new Center(
            child: new TextField(
              controller: _controller,
              focusNode: focusNode,
              textAlign: TextAlign.center,
              decoration: new InputDecoration(
                hintText: team.name,
                hintStyle: new TextStyle(
                    color: (darkTheme) ? Colors.blue : Colors.black),
              ),
              style: new TextStyle(
                  fontSize: 30.0,
                  fontWeight: FontWeight.bold,
                  color: (darkTheme) ? Colors.blue : Colors.black),
            ),
          ),
        ),
        new Expanded(
          child: new FittedBox(
            fit: BoxFit.fill,
            child: new MaterialButton(
              onPressed: () {
                setState(() {
                  if (!matchWon) team.value += 1;
                });
                pointScored(team);
              },
              child: new Padding(
                padding: const EdgeInsets.all(16.0),
                child: new Text(
                  "Punto",
                  style: new TextStyle(

                      color: (darkTheme) ? Colors.blue : Colors.black),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt("TennisWin", periodWin);
    prefs.setInt("TennisNumber", periodNumber);
    prefs.setBool("TennisTie", tieBreak);
    super.dispose();
  }

  void _ensureVisible() {
    ensureVisible(context, focusNode);
  }

  void nameChange() {
    if (_controller.text.isNotEmpty) {
      if (_controller.text.length <= 20) {
        team.setName(_controller.text);
      } else {
        _controller.text = team.name;
      }
    } else {
      team.setName("Giocatore ${team.index}");
    }
  }
}

class TennisScorePeriod extends StatefulWidget {
  final TennisPlayer team1;
  final TennisPlayer team2;

  TennisScorePeriod(this.scores, this.team1, this.team2);

  final List<Scores> scores;

  @override
  createState() {
    return new TennisScorePeriodState(scores, team1, team2);
  }
}

class TennisScorePeriodState extends State<TennisScorePeriod> {
  TennisScorePeriodState(this.scores, this.team1, this.team2);

  final TennisPlayer team1;
  final TennisPlayer team2;
  final List<Scores> scores;

  @override
  Widget build(BuildContext context) {
    List<Widget> scoresTeam1 = <Widget>[];
    for (int i = 0; i < scores.length; i++)
      scoresTeam1.add(new Expanded(
        child: new Text(
          scores[i].team1.toString(),
          textAlign: TextAlign.center,

          style: new TextStyle(
              fontSize: 20.0,

              color: (darkTheme) ? Colors.blue : Colors.black),
        ),
      ));
    List<Widget> scoresTeam2 = <Widget>[];
    for (int i = 0; i < scores.length; i++)
      scoresTeam2.add(new Expanded(
        child: new Text(
          scores[i].team2.toString(),
          textAlign: TextAlign.center,
          style: new TextStyle(
              fontSize: 20.0,

              color: (darkTheme) ? Colors.blue : Colors.black),
        ),
      ));
    return new Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        new Flex(
          direction: Axis.horizontal,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            new Padding(
              padding: const EdgeInsets.all(8.0),
              child: new Text(
                team1.name,
                textAlign: TextAlign.center,
                style: new TextStyle(
                    fontSize: 20.0,

                    color: (darkTheme) ? Colors.blue : Colors.black),
              ),
            ),
            new Expanded(
                child: new Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: new Flex(
                    children: scoresTeam1,
                    direction: Axis.horizontal,
                  ),
                )),
          ],
        ),
        new Flex(
          direction: Axis.horizontal,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            new Padding(
              padding: const EdgeInsets.all(8.0),
              child: new Text(
                team2.name,
                textAlign: TextAlign.center,
                style: new TextStyle(
                    fontSize: 20.0,

                    color: (darkTheme) ? Colors.blue : Colors.black),
              ),
            ),
            new Expanded(
                child: new Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: new Flex(
                    children: scoresTeam2,
                    direction: Axis.horizontal,
                  ),
                )),
          ],
        ),
      ],
    );
  }
}

class TennisSettings extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new TennisSettingsState();
  }
}

class TennisSettingsState extends State<TennisSettings> {
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
      appBar: new AppBar(
        leading: new BackButton(
          color: (darkTheme) ? Colors.black : Colors.white,
        ),
        textTheme: new TextTheme(
            title: new TextStyle(
                color: (darkTheme) ? Colors.black : Colors.white,
                fontSize: 20.0,
                fontWeight: FontWeight.bold)),
      ),
      backgroundColor: (darkTheme)
          ? Color.fromARGB(255, 50, 50, 50)
          : Color.fromARGB(255, 250, 250, 250),
      body: new Column(children: <Widget>[
        new ListTile(
            trailing: new Text(
              "Giochi per Set",
              style: new TextStyle(
                  color: (darkTheme) ? Colors.blue : Colors.black),
            ),
            title: new TextField(
                keyboardType: TextInputType.number,
                decoration: new InputDecoration(
                    hintText: periodWin.toString(),
                    hintStyle: new TextStyle(
                        color: (darkTheme) ? Colors.blue : Colors.black)),
                controller: _periodWin,
                style: new TextStyle(
                    color: (darkTheme) ? Colors.blue : Colors.black))),
        new ListTile(
            trailing: new Text("Tie Break",
                style: new TextStyle(
                    color: (darkTheme) ? Colors.blue : Colors.black)),
            title: new Switch(
              value: tieBreak,
              onChanged: (value) {
                setState(() {
                  tieBreak = value;
                });
              },
            )),
        new ListTile(
            trailing: new Text("Al Meglio di (# set)",
                style: new TextStyle(
                    color: (darkTheme) ? Colors.blue : Colors.black)),
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

class TennisPlayer extends Player {
  bool service = false;
  int setWon = 0;
  int index;

  TennisPlayer(name, value, index, [bool service = false])
      : super(name, value) {
    this.service = service;
    this.index = index;
  }
}
