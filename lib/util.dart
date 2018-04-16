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
