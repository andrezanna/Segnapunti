import 'package:Segnapunti/player.dart';
import 'package:flutter/material.dart';
import 'package:numberpicker/numberpicker.dart';

class ClassicPlayer extends Player {
  String name;
  int value;
  NumberPicker np;

  ClassicPlayer(this.name, this.value) : super(name, value);

  Key get key => new ObjectKey(this.hashCode);

  void setValue(int value) {
    this.value = value;
  }

  void setNumberPicker(NumberPicker p) {
    this.np = p;
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