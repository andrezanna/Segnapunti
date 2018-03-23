import 'package:Segnapunti/biliardo.dart';
import 'package:Segnapunti/classic.dart';
import 'package:flutter/material.dart';

/*Parte importante, creo un layout padre
//se no ho problemi col navigator.push
//perchè push prende il layout padre del chiamante
dove mettere il layout nuovo.
*/
void main() => runApp(new Parent());

class Parent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
        title: 'Segnapunti',
        theme: new ThemeData(
          primaryColor: Colors.blue,
        ),
        //passaggio importante, semplificano le chiamate per il navigator.push
        routes: <String, WidgetBuilder>{
          "/classic": (BuildContext context) => new Classic(),
          "/biliardo": (BuildContext context) => new Biliardo(),
        },
        home: new Scaffold(
          appBar: new AppBar(
            title: new Text(
              "Segnapunti",
              style: new TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.blue,
          ),
          body: new MyApp(),
        ));
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new GridView.count(
        crossAxisCount: 2,
        childAspectRatio: 1.0,
        padding: const EdgeInsets.fromLTRB(16.0, 25.0, 16.0, 4.0),
        mainAxisSpacing: 4.0,
        crossAxisSpacing: 3.0,
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
                new Text("BILIARDO")
              ],
            ),
          ),
          new MaterialButton(
            onPressed: null,
            child: new Column(
              children: <Widget>[
                new Image(
                  image: new AssetImage('/images/basket.png'),
                  height: 100.0,
                  width: 100.0,
                ),
                new Text("BASKET")
              ],
            ),
          ),
          new MaterialButton(
            onPressed: null,
            child: new Column(
              children: <Widget>[
                new Image(
                  image: new AssetImage('/images/volley.png'),
                  height: 100.0,
                  width: 100.0,
                ),
                new Text("PALLAVOLO")
              ],
            ),
          ),
          new MaterialButton(
            onPressed: null,
            child: new Column(
              children: <Widget>[
                new Image(
                  image: new AssetImage('/images/tennis.png'),
                  height: 100.0,
                  width: 100.0,
                ),
                new Text("TENNIS")
              ],
            ),
          ),
          new MaterialButton(
            onPressed: null,
            child: new Column(
              children: <Widget>[
                new Image(
                  image: new AssetImage('/images/rugby.png'),
                  height: 100.0,
                  width: 100.0,
                ),
                new Text("RUGBY")
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
                new Text("CLASSICO")
              ],
            ),
          ),
        ]);
  }
}
