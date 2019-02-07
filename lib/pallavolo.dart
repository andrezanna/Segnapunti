import 'package:Segnapunti/util.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_recognition/speech_recognition.dart';

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
  VolleyPlayer lastPoint;
  SpeechRecognition _speech;
  bool _speechRecognitionAvailable;
  String _currentLocale;
  bool _isListening = false;
  bool speechActive = false;

  @override
  void initState() {
    super.initState();
    activateSpeechRecognizer();
  }

  void activateSpeechRecognizer() {
    _speech = SpeechRecognition();
    _speech.setAvailabilityHandler(
        (bool result) => setState(() => _speechRecognitionAvailable = result));
    _speech.setCurrentLocaleHandler(
        (String locale) => setState(() => _currentLocale = locale));

    _speech.setRecognitionCompleteHandler((text) {
        getSpeech(text);
        setState(() {_isListening=false;});
    });

    _speech.setErrorHandler(errorHandler);

    _speech
        .activate()
        .then((res) => setState(() => _speechRecognitionAvailable = res));
  }

  void errorHandler(int error) {
    switch (error) {

      case 6:
        if (!_isListening) {
          _speech.listen(locale: _currentLocale);
        }
        break;
      case 7:
        if (!_isListening) {
          _speech.listen(locale: _currentLocale);
        }
          break;

      case 8:
        _speech.cancel();
        if (!_isListening) {
          activateSpeechRecognizer();
        }
        break;

      default:
        activateSpeechRecognizer();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (scores.isEmpty || scores.length != periodNumber) {
      scores.clear();
      for (int i = 0; i < periodNumber; i++) scores.add(new Scores(0, 0));
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
          child: new HorizontalScorePeriod(scores, player1, player2, darkTheme),
        ),
        new FloatingActionButton(
          onPressed: () {
            setState(() {
              speechActive = !speechActive;
              if (_isListening) {
                _speech.stop();
              }
              if (speechActive) {
                _speech.listen(locale: _currentLocale);
              }
            });
          },
          child: new Icon(
            (speechActive) ? Icons.mic : Icons.mic_off,
            color: (speechActive) ? Colors.red : Colors.black12,
          ),
          backgroundColor: Colors.grey,
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
    lastPoint = player;
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
        builder: (BuildContext context) => new AlertDialog(
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

    if (speechActive && !_isListening) {
      _speech.listen(locale: _currentLocale);
    }
  }

  void revertPoint() {
    if (matchWon) {
      setState(() {
        matchWon = false;
      });
    }
    if (player1.value == 0 && player2.value == 0) {
      inPeriod -= 1;

      player1.value = scores[inPeriod].team1;
      player2.value = scores[inPeriod].team2;

      if (player1.setWon == (periodNumber / 2).floor() &&
          player2.setWon == (periodNumber / 2).floor() &&
          tieBreak) inTieBreak = true;
    }
    if (lastPoint == player1) {
      setState(() {
        player1.value -= 1;
      });
    } else if (lastPoint == player2) {
      setState(() {
        player2.value -= 1;
      });
    }
    if (speechActive && !_isListening) {
      _speech.listen(locale: _currentLocale);
    }
    lastPoint = null;

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
      lastPoint = null;
      scores.clear();
      for (int i = 0; i < periodNumber; i++) scores.add(new Scores(0, 0));
      matchWon = false;
    });
    if (speechActive && !_isListening) {
      _speech.listen(locale: _currentLocale);
    }
  }

  void getSpeech(String speech) {
    print("RICEVUTO $speech, $_isListening");
    List<String> words = speech.split(" ");
    switch (words.length) {
      case 1:
        oneWord(speech);
        break;
      default:
        if (!_isListening) {
          _speech.listen(locale: _currentLocale);
        }break;

    }
  }

  void oneWord(String speech) {
    print("ONEWORD");
    List<String> revertLast = ["ANNULLA", "CANCELLA"];
    List<String> reMatch = ["NUOVA", "RIVINCITA"];

    if (speech.toUpperCase() == player1.name.toUpperCase()) {
      setState(() {
        if (!matchWon) player1.value += 1;
      });
      pointScored(player1);
    } else if (speech.toUpperCase() == player2.name.toUpperCase()) {
      setState(() {
        if (!matchWon) player2.value += 1;
      });
      pointScored(player2);
    } else if (revertLast.contains(speech.toUpperCase()) && lastPoint != null) {
      revertPoint();
    } else if (reMatch.contains(speech.toUpperCase()) && matchWon) {
      newMatch();
    }
  }
}

class VolleyScore extends StatefulWidget {
  VolleyScore(this.team, this.pointScored);

  final ValueChanged<VolleyPlayer> pointScored;
  final VolleyPlayer team;

  @override
  createState() => new VolleyScoreState();
}

class VolleyScoreState extends State<VolleyScore> {
  final TextEditingController _controller = new TextEditingController();
  FocusNode focusNode = new FocusNode();

  @override
  Widget build(BuildContext context) {
    _controller.addListener(nameChange);

    return new Flex(
      direction: Axis.vertical,
      children: <Widget>[
        new Expanded(
          child: new MaterialButton(
            onPressed: () {
              setState(() {
                if (widget.team.value > 0 && !matchWon) widget.team.value -= 1;
              });
            },
            child: new Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                new Text(
                  widget.team.value.toString(),
                  style: new TextStyle(
                    color: Colors.red,
                    fontSize: 40.0,
                  ),
                  textAlign: TextAlign.right,
                ),
                new Icon(
                  (widget.team.service) ? Icons.brightness_1 : null,
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
                hintText: widget.team.name,
                hintStyle: new TextStyle(
                    color: (darkTheme) ? Colors.blue : Colors.black),
              ),
              style: new TextStyle(
                  fontSize: 30.0,
                  fontWeight: FontWeight.bold,
                  color: (darkTheme) ? Colors.blue : Colors.black54),
            ),
          ),
        ),
        new Expanded(
          child: new MaterialButton(
              onPressed: () {
                setState(() {
                  if (!matchWon) widget.team.value += 1;
                });
                widget.pointScored(widget.team);
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

  void nameChange() {
    if (_controller.text.isNotEmpty) {
      if (_controller.text.length <= 20) {
        widget.team.setName(_controller.text);
      } else {
        _controller.text = widget.team.name;
      }
    } else {
      widget.team.setName("Giocatore ${widget.team.index}");
    }
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
              builder: (context) => new AlertDialog(
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
              builder: (context) => new AlertDialog(
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
                    color: (darkTheme) ? Colors.blue : Colors.black),
              ),
              controller: _periodWin,
              style: new TextStyle(
                  color: (darkTheme) ? Colors.blue : Colors.black),
            )),
        new ListTile(
            trailing: new Text(
              "Tie Break",
              style: new TextStyle(
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
            trailing: new Text(
              "Al Meglio di (# set)",
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
