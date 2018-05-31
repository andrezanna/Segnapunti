import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

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

class Scores {
  int team1;
  int team2;

  Scores(this.team1, this.team2);

  void setScores(int team1, int team2) {
    this.team1 = team1;
    this.team2 = team2;
  }
}


class TeamScorePeriod extends StatefulWidget {
  TeamScorePeriod({this.scores, this.darkTheme = false, this.periodNumber});

  final List<Scores> scores;
  final bool darkTheme;
  final int periodNumber;

  @override
  createState() {
    return new TeamScorePeriodState();
  }
}

class TeamScorePeriodState extends State<TeamScorePeriod> {

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
                        widget.scores[index].team1.toString(),
                        textAlign: TextAlign.center,
                        style: new TextStyle(
                            color: (widget.darkTheme) ? Colors.blue : Colors
                                .black),
                      ),
                    ),
                    new Container(
                      constraints:
                      new BoxConstraints(minWidth: 28.0, maxWidth: 40.0),
                      child: new Text(
                        (index > widget.periodNumber - 1)
                            ? " TS${index -
                            widget.periodNumber + 1} "
                            : " ${index + 1} ",
                        style: new TextStyle(color: Colors.red, fontSize: 20.0),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    new Container(
                      constraints:
                      new BoxConstraints(minWidth: 28.0, maxWidth: 40.0),
                      child: new Text(
                        widget.scores[index].team2.toString(),
                        textAlign: TextAlign.center,
                        style: new TextStyle(
                            color: (widget.darkTheme) ? Colors.blue : Colors
                                .black),
                      ),
                    ),
                  ],
                ));
          },
          itemCount: widget.scores.length,
        ));
  }
}
