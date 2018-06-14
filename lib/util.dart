import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';


class Player {
  String name;
  int value;

  Player(this.name, this.value);

  Key get key => new ObjectKey(this.hashCode);

  void setValue(int value) {
    this.value = value;
  }

  void valueDown() {
    this.value -= 1;
  }

  void valueUp() {
    this.value += 1;
  }

  void setName(String name) {
    this.name = name;
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


class VerticalScorePeriod extends StatelessWidget {
  VerticalScorePeriod({this.scores, this.darkTheme = false, this.periodNumber});

  final List<Scores> scores;
  final bool darkTheme;
  final int periodNumber;

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
                        style: new TextStyle(
                            color: (darkTheme) ? Colors.blue : Colors
                                .black),
                      ),
                    ),
                    new Container(
                      constraints:
                      new BoxConstraints(minWidth: 28.0, maxWidth: 40.0),
                      child: new Text(
                        (index > periodNumber - 1)
                            ? " TS${index -
                            periodNumber + 1} "
                            : " ${index + 1} ",
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
                        style: new TextStyle(
                            color: (darkTheme) ? Colors.blue : Colors
                                .black),
                      ),
                    ),
                  ],
                ));
          },
          itemCount: scores.length,
        ));
  }
}

class HorizontalScorePeriod extends StatelessWidget {
  final Player team1;
  final Player team2;
  final List<Scores> scores;
  final bool darkTheme;

  HorizontalScorePeriod(this.scores, this.team1, this.team2,
      [this.darkTheme = false]);

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

Future<Null> ensureVisible(BuildContext context, FocusNode focusNode) async {
  // Wait for the keyboard to come into view
  // TODO: position doesn't seem to notify listeners when metrics change,
  // perhaps a NotificationListener around the scrollable could avoid
  // the need insert a delay here.
  await new Future.delayed(const Duration(milliseconds: 300));

  if (!focusNode.hasFocus) return;

  final RenderObject object = context.findRenderObject();
  final RenderAbstractViewport viewport = RenderAbstractViewport.of(object);
  assert(viewport != null);

  ScrollableState scrollableState = Scrollable.of(context);
  assert(scrollableState != null);

  ScrollPosition position = scrollableState.position;
  double alignment;
  if (position.pixels > viewport.getOffsetToReveal(object, 0.0)) {
    // Move down to the top of the viewport
    alignment = 0.0;
  } else if (position.pixels < viewport.getOffsetToReveal(object, 1.0)) {
    // Move up to the bottom of the viewport
    alignment = 1.0;
  } else {
    // No scrolling is necessary to reveal the child
    return;
  }
  position.ensureVisible(
    object,
    alignment: alignment,
    duration: new Duration(milliseconds: 300),
    curve: Curves.easeIn,
  );
}
