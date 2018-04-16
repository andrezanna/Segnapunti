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