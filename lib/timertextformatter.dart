import 'dart:async';

import 'package:flutter/material.dart';

enum TimerState {
  running,
  stopped,
  ready,
}

enum TimerType {
  chronometer,
  timer,
}

class TimerText extends StatefulWidget {
  TimerText({ this.onTimeEnd,
    this.periodNumber,
    this.periodLength,
    this.inPeriod,
    this.stateChange,
    this.type = TimerType.timer,
    this.gameOver,
  });

  final int periodNumber;
  final int periodLength;
  final int inPeriod;
  final ValueChanged<void> onTimeEnd;
  final ValueChanged<TimerState> stateChange;
  final TimerType type;
  final bool gameOver;

  TimerTextState createState() {
    return new TimerTextState();
  }
}

class TimerTextState extends State<TimerText> {
  Timer timer;
  bool running = false;
  String text;
  Stopwatch stopwatch = new Stopwatch();
  int oldPeriod = 0;
  int qLength;
  bool lastMinute = false;


  @override
  void initState() {
    oldPeriod = widget.inPeriod;
    qLength = widget.periodLength;
    super.initState();
  }


  @override
  void dispose() {
    if (timer != null) timer.cancel();
    stopwatch.stop();
    super.dispose();
  }

  void callback(Timer timer) {
    if (stopwatch.isRunning) {
      if (widget.type == TimerType.timer &&
          stopwatch.elapsedMilliseconds >= (qLength) * 1000 * 60)
        notifyEndTimer();
      else
        changeTimerCallback(shouldChangeTimerCallback());

      setState(() {});
    }
  }

  void notifyEndTimer() {
    timer.cancel();
    stopwatch.stop();
    running = false;
    widget.onTimeEnd(null);
    widget.stateChange(TimerState.stopped);
  }

  void startStop() {
    if (!widget.gameOver) {
      if (widget.inPeriod > widget.periodNumber - 1)
        qLength = (widget.periodLength / 2).ceil();
      else
        qLength = widget.periodLength;
      if (widget.inPeriod > oldPeriod) {
        stopwatch.reset();
        oldPeriod++;
        running = false;
        lastMinute = false;
        widget.stateChange(TimerState.ready);
        setState(() {});
      } else if (shouldEnd()) {
        notifyEndTimer();
      } else {
        if (!running) {
          stopwatch.start();
          widget.stateChange(TimerState.running);
          setState(() {});
          running = true;
          changeTimerCallback();
        } else {
          stopwatch.stop();
          running = false;
          widget.stateChange(TimerState.stopped);
          timer.cancel();
        }
      }
    }
  }

  bool shouldEnd() {
    if (stopwatch.elapsedMilliseconds >= (qLength) * 1000 * 60)
      return true;

    return false;
  }

  bool shouldChangeTimerCallback() {
    if (widget.type == TimerType.timer &&
        stopwatch.elapsedMilliseconds >= (qLength - 1) * 1000 * 60 &&
        !lastMinute) {
      lastMinute = true;
      return true;
    }
    return false;
  }

  void changeTimerCallback([bool mustChange = true]) {
    if (mustChange) {
      if (shouldChangeTimerCallback()) {
        timer = new Timer.periodic(new Duration(milliseconds: 30), callback);
      } else {
        timer =
        new Timer.periodic(new Duration(milliseconds: 1000), callback);
      }
    }
  }

  void reset() {
    setState(() {
      stopwatch.reset();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.gameOver) {
      stopwatch.reset();
      oldPeriod = 0;
      running = false;
      lastMinute = false;
      widget.stateChange(TimerState.ready);
      setState(() {});
    }
    final TextStyle timerTextStyle = const TextStyle(
        fontSize: 80.0, fontFamily: "ShotClock", color: Colors.red);
    if (widget.type == TimerType.timer) {
      text = TimerTextFormatter.format(
          (stopwatch.elapsedMilliseconds >= (qLength) * 1000 * 60)
              ? 0
              : (widget.periodLength * 1000 * 60) -
              stopwatch.elapsedMilliseconds,
          lastMinute);
    } else {
      text = TimerTextFormatter.format(
          stopwatch.elapsedMilliseconds);
    }
    return new MaterialButton(
      onPressed: startStop,
      child: new Text(text, style: timerTextStyle),

    );
  }

}

class TimerTextFormatter {
  static String format(int milliseconds, [bool lastMinute = false]) {
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
