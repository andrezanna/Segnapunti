import 'package:flutter/material.dart';

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