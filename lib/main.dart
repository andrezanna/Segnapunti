import 'dart:async';
import 'dart:io';

import 'package:Segnapunti/basket.dart';
import 'package:Segnapunti/biliardo.dart';
import 'package:Segnapunti/classic.dart';
import 'package:Segnapunti/pallavolo.dart';
import 'package:Segnapunti/rugby.dart';
import 'package:Segnapunti/tennis.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

/*Parte importante, creo un layout padre
//se no ho problemi col navigator.push
//perchè push prende il layout padre del chiamante
dove mettere il layout nuovo.
*/
void main() => runApp(new Parent());
bool darkTheme = false;

class Parent extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new ParentState();
  }
}

class ParentState extends State<Parent> {
  static const platform =
  const MethodChannel('andrea.zanini.segnapunti/system_version');

  ParentState() {
    _getSystemVersion();
  }

  String _systemVersion = 'Sistema sconosciuto';

  @override
  Widget build(BuildContext context) {
    getSharedPreferences();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    return new MaterialApp(
        title: 'Segnapunti',
        theme: new ThemeData(
          primaryColor: Colors.blue,
        ),
        //passaggio importante, semplificano le chiamate per il navigator.push
        routes: <String, WidgetBuilder>{
          "/classic": (BuildContext context) => new Classic(),
          "/biliardo": (BuildContext context) => new Biliardo(),
          "/basket": (BuildContext context) => new Basket(),
          "/rugby": (BuildContext context) => new Rugby(),
          "/tennis": (BuildContext context) => new Tennis(),
          "/volley": (BuildContext context) => new Volley(),
        },
        home: new Scaffold(
          appBar: new AppBar(
            title: new Text(
              "Segnapunti",
              style: new TextStyle(
                  color: (darkTheme) ? Colors.black : Colors.white),
            ),
            backgroundColor: Colors.blue,
            actions: <Widget>[
              new MaterialButton(
                onPressed: () {
                  _saveValues(!darkTheme);
                },
                child: new Text(
                  (darkTheme) ? "White Theme" : "Dark Theme",
                  style: new TextStyle(
                      color: (darkTheme) ? Colors.white : Colors.black),
                ),
              )
            ],
          ),
          body: new Flex(
            children: <Widget>[
              new MyApp(),
            ],
            direction: Axis.vertical,
          ),
          backgroundColor: (darkTheme)
              ? Color.fromARGB(255, 50, 50, 50)
              : Color.fromARGB(255, 250, 250, 250),
          bottomNavigationBar:
          new Flex(direction: Axis.horizontal, children: <Widget>[
            (Platform.isAndroid)
                ? new Expanded(
                child: new Icon(
                  Icons.android,
                  size: 32.0,
                ))
                : new Expanded(
                child: new Image.asset(
                  "icon/apple.png",
                  width: 32.0,
                  height: 32.0,
                )),
            new Expanded(child: new Text(_systemVersion))
          ]),
        ));
  }

  Future<Null> _getSystemVersion() async {
    String systemVersion;
    try {
      final String result = await platform.invokeMethod('getSystemVersion');
      systemVersion = 'System Version: $result ';
    } on PlatformException catch (e) {
      systemVersion = "Failed to get system version: '${e.message}'.";
    }

    setState(() {
      _systemVersion = systemVersion;
    });
  }

  _saveValues(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool("dark", value);
  }

  getSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      darkTheme = prefs.getBool("dark");
      if (darkTheme == null) darkTheme = false;
    });
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery
        .of(context)
        .size
        .width;
    return new Expanded(
      child: new Flex(direction: Axis.horizontal, children: <Widget>[
        new Expanded(
          child: new Flex(
            direction: Axis.vertical,
            children: <Widget>[
              new Expanded(
                child: new Center(
                  child: new MaterialButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed('/biliardo');
                    },
                    child: new Padding(
                      padding: new EdgeInsets.all(width > 600 ? 64.0 : 16.0),
                      child: new Flex(
                        direction: Axis.vertical,
                        children: <Widget>[
                          new Container(
                            child: new Expanded(
                              flex: 3,
                              child: new Image.asset(
                                //parte importante, definire gli asset per trovarli più velocemnte
                                //si inseriscono nel pubspec.yaml
                                'images/p8.png',
                              ),
                            ),
                          ),
                          new Expanded(
                            child: new Text(
                              "BILIARDO",
                              style: new TextStyle(
                                color: (darkTheme) ? Colors.blue : Colors.black,
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              new Expanded(
                child: new Center(
                  child: new MaterialButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed('/basket');
                    },
                    child: new Center(
                      child: new Padding(
                        padding: new EdgeInsets.all(width > 600 ? 64.0 : 16.0),
                        child: new Flex(
                          direction: Axis.vertical,
                          children: <Widget>[
                            new Expanded(
                              flex: 3,
                              child: new Image.asset(
                                'images/basket.png',
                              ),
                            ),
                            new Expanded(
                              child: new Text(
                                "BASKET",
                                style: new TextStyle(
                                  color:
                                  (darkTheme) ? Colors.blue : Colors.black,
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              new Expanded(
                child: new Center(
                  child: new MaterialButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed('/volley');
                    },
                    child: new Center(
                      child: new Padding(
                        padding: new EdgeInsets.all(width > 600 ? 64.0 : 16.0),
                        child: new Flex(
                          direction: Axis.vertical,
                          children: <Widget>[
                            new Expanded(
                              flex: 3,
                              child: new Image.asset(
                                'images/volley.png',
                              ),
                            ),
                            new Expanded(
                              child: new Text(
                                "PALLAVOLO",
                                style: new TextStyle(
                                  color:
                                  (darkTheme) ? Colors.blue : Colors.black,
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        new Expanded(
          child: new Flex(
            direction: Axis.vertical,
            children: <Widget>[
              new Expanded(
                child: new Center(
                  child: new MaterialButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed('/tennis');
                    },
                    child: new Center(
                      child: new Padding(
                        padding: new EdgeInsets.all(width > 600 ? 64.0 : 16.0),
                        child: new Flex(
                          direction: Axis.vertical,
                          children: <Widget>[
                            new Expanded(
                              flex: 3,
                              child: new Image.asset(
                                'images/tennis.png',
                              ),
                            ),
                            new Expanded(
                              child: new Text(
                                "TENNIS",
                                style: new TextStyle(
                                  color:
                                  (darkTheme) ? Colors.blue : Colors.black,
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              new Expanded(
                child: new Center(
                  child: new MaterialButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed('/rugby');
                    },
                    child: new Center(
                      child: new Padding(
                        padding: new EdgeInsets.all(width > 600 ? 64.0 : 16.0),
                        child: new Flex(
                          direction: Axis.vertical,
                          children: <Widget>[
                            new Expanded(
                              flex: 3,
                              child: new Image.asset(
                                'images/rugby.png',
                              ),
                            ),
                            new Expanded(
                              child: new Text(
                                "RUGBY",
                                style: new TextStyle(
                                  color:
                                  (darkTheme) ? Colors.blue : Colors.black,
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              new Expanded(
                child: new Center(
                  child: new MaterialButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed('/classic');
                    },
                    child: new Center(
                      child: new Padding(
                        padding: new EdgeInsets.all(width > 600 ? 64.0 : 16.0),
                        child: new Flex(
                          direction: Axis.vertical,
                          children: <Widget>[
                            new Expanded(
                              flex: 3,
                              child: new Image.asset(
                                'images/numbers.png',
                              ),
                            ),
                            new Expanded(
                              child: new Text(
                                "CLASSICO",
                                style: new TextStyle(
                                  color:
                                  (darkTheme) ? Colors.blue : Colors.black,
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ]),
    );
  }
}
