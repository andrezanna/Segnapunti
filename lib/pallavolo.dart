import 'package:Segnapunti/player.dart';
import 'package:Segnapunti/util.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

int periodWin = 25;
int periodNumber = 5;
int inPeriod = 0;
bool tieBreak = true;
bool inTieBreak = false;
bool matchWon = false;
bool darkTheme = false;

class Volley extends StatefulWidget {
  @override
  createState() {
    getSharedPreferences();
    return new VolleyState();
  }

  getSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    darkTheme = prefs.getBool("dark");
    if (darkTheme == null) darkTheme = false;
    periodWin = prefs.getInt("VolleyWin");
    if (periodWin == null) periodWin = 25;
    periodNumber = prefs.getInt("VolleyNumber");
    if (periodNumber == null) periodNumber = 5;
    tieBreak = prefs.getBool("VolleyTie");
    if (tieBreak == null) tieBreak = true;
  }
}

class VolleyState extends State<Volley> {
  VolleyPlayer player1 = new VolleyPlayer("Giocatore 1", 0, 1, true);
  VolleyPlayer player2 = new VolleyPlayer("Giocatore 2", 0, 2);
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
              builder: (context) => new VolleySettings()));
        },
        child: new Text(
          "IMPOSTAZIONI",
          style: new TextStyle(
              color: (darkTheme) ? Colors.black : Colors.white),
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
            style: new TextStyle(
                color: (darkTheme) ? Colors.black : Colors.white),
          ),
        ),
      );
    }
    return new Scaffold(
      appBar: new AppBar(
        leading: new BackButton(
          color: (darkTheme) ? Colors.black : Colors.white,),
        textTheme: new TextTheme(title: new TextStyle(
            color: (darkTheme) ? Colors.black : Colors.white,
            fontSize: 20.0,
            fontWeight: FontWeight.bold)),

        title: new Text('Volley'),
        actions: actions,
      ),
      body: _buildVolley(),
      backgroundColor: (darkTheme)
          ? Color.fromARGB(255, 50, 50, 50)
          : Color.fromARGB(255, 250, 250, 250),
    );
  }

  Widget _buildVolley() {
    return new Flex(
      direction: Axis.vertical,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(36.0),
          child: new VolleyScorePeriod(scores, player1, player2),
        ),
        new Expanded(
          child: new Row(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              new Expanded(child: new VolleyScore(player1, pointScored)),
              new Expanded(child: new VolleyScore(player2, pointScored)),
            ],
          ),
        ),
      ],
    );
  }

  void pointScored(VolleyPlayer player) {
    if (inPeriod == scores.length || matchWon) {
      matchWon = true;
    } else {
      VolleyPlayer other = (player.name == player1.name) ? player2 : player1;
      bool setWin = false;

      if (inTieBreak) {
        if (player.value >= other.value + 2 && player.value >= 15) {
          setWin = true;
        }
      } else if (player.value >= other.value + 2 && player.value >= periodWin) {
        setWin = true;
      }
      if (setWin) {
        setState(() {
          scores[inPeriod].team1 = player1.value;
          scores[inPeriod].team2 = player2.value;
          inPeriod += 1;
          if (++player.setWon >= (periodNumber / 2).ceil()) {
            matchWon = true;
          }
          player1.value = 0;
          player2.value = 0;

          inTieBreak = false;

          if (player1.setWon == (periodNumber / 2).floor() &&
              player2.setWon == (periodNumber / 2).floor() &&
              tieBreak) inTieBreak = true;
        });
      } else {
        setState(() {
          player.service = true;
          other.service = false;
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

class VolleyScore extends StatefulWidget {
  VolleyScore(this.team, this.pointScored);

  final ValueChanged<VolleyPlayer> pointScored;
  final VolleyPlayer team;

  @override
  createState() => new VolleyScoreState(team, pointScored);
}

class VolleyScoreState extends State<VolleyScore> {
  VolleyScoreState(this.team, this.pointScored);

  final ValueChanged<VolleyPlayer> pointScored;

  final VolleyPlayer team;
  final TextEditingController _controller = new TextEditingController();
  FocusNode focusNode = new FocusNode();

  @override
  Widget build(BuildContext context) {
    _controller.addListener(nameChange);
    focusNode.addListener(_ensureVisible);

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
                new Text(
                  team.value.toString(),
                  style: new TextStyle(
                    color: Colors.red,
                    fontSize: 40.0,
                  ),
                  textAlign: TextAlign.right,
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
              style: new TextStyle(fontSize: 30.0,
                  fontWeight: FontWeight.bold,
                  color: (darkTheme) ? Colors.blue : Colors.black54),
            ),
          ),
        ),
        new Expanded(
          child: new MaterialButton(
              onPressed: () {
                setState(() {
                  if (!matchWon) team.value += 1;
                });
                pointScored(team);
              },
              child: new Text(
                "Punto",
                style: new TextStyle(
                    fontSize: 25.0,

                    color: (darkTheme) ? Colors.blue : Colors.black),
              )),
        ),
      ],
    );
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

class VolleyScorePeriod extends StatefulWidget {
  final VolleyPlayer team1;
  final VolleyPlayer team2;

  VolleyScorePeriod(this.scores, this.team1, this.team2);

  final List<Scores> scores;

  @override
  createState() {
    return new VolleyScorePeriodState(scores, team1, team2);
  }
}

class VolleyScorePeriodState extends State<VolleyScorePeriod> {
  VolleyScorePeriodState(this.scores, this.team1, this.team2);

  final VolleyPlayer team1;
  final VolleyPlayer team2;
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

class VolleySettings extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new VolleySettingsState();
  }
}

class VolleySettingsState extends State<VolleySettings> {
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
      appBar: new AppBar(leading: new BackButton(
        color: (darkTheme) ? Colors.black : Colors.white,),
        textTheme: new TextTheme(title: new TextStyle(
            color: (darkTheme) ? Colors.black : Colors.white,
            fontSize: 20.0,
            fontWeight: FontWeight.bold)),
      ),
      backgroundColor: (darkTheme)
          ? Color.fromARGB(255, 50, 50, 50)
          : Color.fromARGB(255, 250, 250, 250),
      body: new Column(children: <Widget>[
        new ListTile(
            trailing: new Text("Giochi per Set", style: new TextStyle(
                color: (darkTheme) ? Colors.blue : Colors.black),
            ),
            title: new TextField(
              keyboardType: TextInputType.number,
              decoration: new InputDecoration(
                hintText: periodWin.toString(),
                hintStyle: new TextStyle(
                    color: (darkTheme) ? Colors.blue : Colors.black),

              ),
              controller: _periodWin,
              style: new TextStyle(
                  color: (darkTheme) ? Colors.blue : Colors.black),

            )),
        new ListTile(
            trailing: new Text("Tie Break", style: new TextStyle(
                color: (darkTheme) ? Colors.blue : Colors.black),
            ),
            title: new Switch(
              value: tieBreak,
              onChanged: (value) {
                setState(() {
                  tieBreak = value;
                });
              },
            )),
        new ListTile(
            trailing: new Text("Al Meglio di (# set)", style: new TextStyle(
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
      ]),
    );
  }
}

class VolleyPlayer extends Player {
  bool service = false;
  int index;

  int setWon = 0;

  VolleyPlayer(name, value, index, [bool service = false])
      : super(name, value) {
    this.service = service;
    this.index = index;
  }
}
