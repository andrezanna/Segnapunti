import 'package:Segnapunti/player.dart';
import 'package:flutter/material.dart';

class Biliardo extends StatefulWidget {
  @override
  createState() => new BiliardoState();
}

class BiliardoState extends State<Biliardo> {
  final List<Player> players = <Player>[
    new Player("Player 1", 0),
    new Player("Player 2", 0)
  ];

  int _players = 2;
  int _playerName = 2;

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('Biliardo'),
      ),
      body: buildBiliardo(),
      bottomNavigationBar: new BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          new BottomNavigationBarItem(
              icon: new Icon(Icons.add), title: new Text("Nuovo Giocatore")),
          new BottomNavigationBarItem(
              icon: new Icon(Icons.arrow_back), title: new Text("Annulla")),
          new BottomNavigationBarItem(
              icon: new Icon(Icons.refresh), title: new Text("Reset")),
        ],
        onTap: (item) {
          if (item == 0) {
            _addPlayer();
          }
        },
      ),
    );
  }

  void _addPlayer() {
    players.add(new Player("Player ${_playerName + 1}", 0));
    setState(() {
      _players++;
      _playerName++;
    });
  }

  Widget buildBiliardo() {
    return new GridView.count(
      crossAxisCount: 4,
      childAspectRatio: 1.0,
      padding: const EdgeInsets.fromLTRB(16.0, 25.0, 16.0, 4.0),
      mainAxisSpacing: 4.0,
      crossAxisSpacing: 3.0,
      children: <Widget>[
        new Image(image: new AssetImage('/images/p1.png')),
        new Image(image: new AssetImage('/images/p2.png')),
        new Image(image: new AssetImage('/images/p3.png')),
        new Image(image: new AssetImage('/images/p4.png')),
        new Image(image: new AssetImage('/images/p5.png')),
        new Image(image: new AssetImage('/images/p6.png')),
        new Image(image: new AssetImage('/images/p7.png')),
        new Image(image: new AssetImage('/images/p8.png')),
        new Image(image: new AssetImage('/images/p9.png')),
        new Image(image: new AssetImage('/images/p10.png')),
        new Image(image: new AssetImage('/images/p11.png')),
        new Image(image: new AssetImage('/images/p12.png')),
        new Image(image: new AssetImage('/images/p13.png')),
        new Image(image: new AssetImage('/images/p14.png')),
        new Image(image: new AssetImage('/images/p15.png')),

      ],
    );
  }
}
