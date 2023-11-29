import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Namer App',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  var current = WordPair.random();

  //Logic for next button
  void getNext(){
    current = WordPair.random();
    notifyListeners();
  }
  //logic for adding favroite
  var favorites = <WordPair>[];
  void toggleFavorites() {
    if (favorites.contains(current)){
      favorites.remove(current);
    }else{
      favorites.add(current);
    }
    notifyListeners();
  }

}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;
  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = GeneratorPage();
      case 1:
        page = FavoritePage();
      case 2:
        page = ListPage();
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }

    return LayoutBuilder(
      builder: (context,constraints) {
        return Scaffold(
          body: Row(
            children: [
              SafeArea(
                child: NavigationRail(
                  extended: constraints.maxWidth >= 600,
                  destinations: [
                    NavigationRailDestination(
                      icon: Icon(Icons.home),
                      label: Text('Home'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.favorite),
                      label: Text('Favorites'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.checklist),
                      label: Text('List'),
                    ),
                  ],
                  selectedIndex: selectedIndex,
                  onDestinationSelected: (value) {
                    setState(() {
                      selectedIndex = value;
                    });
                    //print('selected: $value');
                  },
                ),
              ),
              Expanded(
                child: Container(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  child: page,
                ),
              ),
            ],
          ),
        );
      }
    );
  }
}

class ListPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ListPage();
}
List<String> options = ['Option 1', 'Option 2', 'Option 3'];
class _ListPage extends State<ListPage>{

  @override
  int _selectedRadio = 0;

  @override
  Widget build(BuildContext context) {
    var appState1=  context.watch<MyAppState>();
    List<bool> _isChecked = List.generate(appState1.favorites.length, (index) => false);


    if(appState1.favorites.isEmpty){
      return Center(
        child: Text('No favorities yet'),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('ListView with Radio Buttons'),
      ),
      body: ListView.builder(
        itemCount: appState1.favorites.length,
        itemBuilder: (context, index) {
          //for (var pair in appState1.favorites)
          return CheckboxListTile(
            title: Text(appState1.favorites[index] as String),
            value: _isChecked[index],
            onChanged: (value) {
              setState(() {
                _isChecked[index] = value!;
              });
            },
          );
        },
      ),
    );
  }
}

class FavoritePage extends StatefulWidget{

  @override
  State<FavoritePage> createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {

  @override
  Widget build(BuildContext context) {
   var appState=  context.watch<MyAppState>();

   if(appState.favorites.isEmpty){
     return Center(
       child: Text('No favorities yet'),
     );
   }

   return ListView(
     children:[
       Padding(padding: const EdgeInsets.all(20),
       child: Text('You have ''${appState.favorites.length} favorities:'),
       ),
       for (var pair in appState.favorites)
         ListTile(
           leading: Icon(Icons.favorite),
           title: Text(pair.asLowerCase),
         )
     ]
   );
  }
}

class GeneratorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var pair = appState.current;

    IconData icon;
    if (appState.favorites.contains(pair)) {
      icon = Icons.favorite;
    } else {
      icon = Icons.favorite_border;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          BigCard(pair: pair),
          SizedBox(height: 10),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  appState.toggleFavorites();
                },
                icon: Icon(icon),
                label: Text('Like'),
              ),
              SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  appState.getNext();
                },
                child: Text('Next'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class BigCard extends StatelessWidget {
  const BigCard({
    super.key,
    required this.pair,
  });

  final WordPair pair;

  @override
  Widget build(BuildContext context) {

    final theme =  Theme.of(context);
    final style = theme.textTheme.displayMedium!.copyWith(
        color:theme.colorScheme.onPrimary
    );
    return Card(
      color:theme.colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Text(pair.asLowerCase, style:style),
      ),
    );
  }
}