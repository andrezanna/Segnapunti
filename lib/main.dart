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

  ParentState() {
    getSharedPreferences();
  }

  @override
  Widget build(BuildContext context) {
    getSharedPreferences();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    return new MaterialApp(
        title: 'Segnapunti',
        theme: new ThemeData(
            primaryColor: Colors.blue,
            splashColor: Colors.blue,
            accentColor: Colors.black
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
        ));
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
    return new Expanded(
      child: new GridView.count(
          crossAxisCount: 2,
          padding: const EdgeInsets.fromLTRB(16.0, 25.0, 16.0, 4.0),
          children: <Widget>[
            new MaterialButton(
              onPressed: () {
                Navigator.of(context).pushNamed('/biliardo');
              },
              child: new Column(
                children: <Widget>[
                  new Image(
                    //parte importante, definire gli asset per trovarli più velocemnte
                    //si inseriscono nel pubspec.yaml
                    image: new AssetImage('/images/p8.png'),
                    height: 100.0,
                    width: 100.0,
                  ),
                  new Text(
                    "BILIARDO",
                    style: new TextStyle(
                      color: (darkTheme) ? Colors.blue : Colors.black,
                    ),
                  )
                ],
              ),
            ),
            new MaterialButton(
              onPressed: () {
                Navigator.of(context).pushNamed('/basket');
              },
              child: new Column(
                children: <Widget>[
                  new Image(
                    image: new AssetImage('/images/basket.png'),
                    height: 100.0,
                    width: 100.0,
                  ),
                  new Text(
                    "BASKET",
                    style: new TextStyle(
                      color: (darkTheme) ? Colors.blue : Colors.black,
                    ),
                  )
                ],
              ),
            ),
            new MaterialButton(
              onPressed: () {
                Navigator.of(context).pushNamed('/volley');
              },
              child: new Column(
                children: <Widget>[
                  new Image(
                    image: new AssetImage('/images/volley.png'),
                    height: 100.0,
                    width: 100.0,
                  ),
                  new Text(
                    "PALLAVOLO",
                    style: new TextStyle(
                      color: (darkTheme) ? Colors.blue : Colors.black,
                    ),
                  )
                ],
              ),
            ),
            new MaterialButton(
              onPressed: () {
                Navigator.of(context).pushNamed('/tennis');
              },
              child: new Column(
                children: <Widget>[
                  new Image(
                    image: new AssetImage('/images/tennis.png'),
                    height: 100.0,
                    width: 100.0,
                  ),
                  new Text(
                    "TENNIS",
                    style: new TextStyle(
                      color: (darkTheme) ? Colors.blue : Colors.black,
                    ),
                  )
                ],
              ),
            ),
            new MaterialButton(
              onPressed: () {
                Navigator.of(context).pushNamed('/rugby');
              },
              child: new Column(
                children: <Widget>[
                  new Image(
                    image: new AssetImage('/images/rugby.png'),
                    height: 100.0,
                    width: 100.0,
                  ),
                  new Text(
                    "RUGBY",
                    style: new TextStyle(
                      color: (darkTheme) ? Colors.blue : Colors.black,
                    ),
                  )
                ],
              ),
            ),
            new MaterialButton(
              onPressed: () {
                Navigator.of(context).pushNamed('/classic');
              },
              child: new Column(
                children: <Widget>[
                  new Image(
                    image: new AssetImage('/images/numbers.png'),
                    height: 100.0,
                    width: 100.0,
                  ),
                  new Text(
                    "CLASSICO",
                    style: new TextStyle(
                      color: (darkTheme) ? Colors.blue : Colors.black,
                    ),
                  )
                ],
              ),
            ),
          ]),
    );
  }
}
