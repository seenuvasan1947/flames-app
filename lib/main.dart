import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    home: FlamesApp(),
  ));
}

class FlamesApp extends StatefulWidget {
  @override
  _FlamesAppState createState() => _FlamesAppState();
}

class _FlamesAppState extends State<FlamesApp> {
  String name1 = '';
  String name2 = '';
  String result = '';
  String relation = '';
  String imgpath = 'assets/best_of_luck.jpeg';

  void _calculateFlames() {
    String name1Lower = name1.toLowerCase();
    String name2Lower = name2.toLowerCase();
    String combinedNames = name1Lower + name2Lower;

    // Removing common characters
    for (int i = 0; i < name1Lower.length; i++) {
      combinedNames = combinedNames.replaceAll(name1Lower[i], '');
    }

    int count = combinedNames.length;
    String flames = 'FLAMES';
    List<String> flamesList = flames.split('');

    // Calculating FLAMES result
    while (flamesList.length > 1) {
      int index = (count % flamesList.length) - 1;
      if (index < 0) {
        index = flamesList.length - 1;
      }
      flamesList.removeAt(index);
    }

    setState(() {
      result = flamesList[0];
    });

//     if(result=='F'){
// relation="Friends";
// imgpath='assets/friend.jpeg';
//     }
//     else if(result=='L'){}
//   }

    switch (result) {
      case 'F':
        {
          relation = "Friends";
          imgpath = 'assets/friend.jpeg';
          break;
        }
      case 'L':
        {
          relation = "Lovers";
          imgpath = 'assets/love.jpeg';
          break;
        }
      case 'A':
        {
          relation = "Affection";
          imgpath = 'assets/affection.jpeg';
          break;
        }
      case 'M':
        {
          relation = "Marrage";
          imgpath = 'assets/marrage.jpeg';
          break;
        }
      case 'E':
        {
          relation = "Enemy";
          imgpath = 'assets/enemy.jpeg';
          break;
        }
      case 'S':
        {
          relation = "Sister";
          imgpath = 'assets/sisters.png';
          break;
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // title: 'Flames App',
      home: Scaffold(
        appBar: AppBar(
          title: Text(
            'FLAMES App',
          ),
          centerTitle: true,
          backgroundColor: Colors.pink[300],
        ),
        body: Container(
          padding: EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  onChanged: (value) {
                    setState(() {
                      name1 = value;
                    });
                  },
                  decoration: InputDecoration(
                    labelText: 'Name 1',
                  ),
                ),
                SizedBox(height: 16.0),
                TextField(
                  onChanged: (value) {
                    setState(() {
                      name2 = value;
                    });
                  },
                  decoration: InputDecoration(
                    labelText: 'Name 2',
                  ),
                ),
                SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: _calculateFlames,
                  child: Text('Calculate FLAMES'),
                ),
                SizedBox(height: 16.0),
          
                Text(
                  'Your Relationship is : $relation',
                  style: TextStyle(fontSize: 27.0),
                ),
                Image.asset(imgpath)
                // if(result=='F')
              ],
            ),
          ),
        ),
      ),
    );
  }
}
