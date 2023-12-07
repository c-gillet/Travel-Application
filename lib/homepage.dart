import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'favoritepage.dart';
import 'schedulepage.dart';
import 'profilepage.dart';
import 'commentpage.dart';
import 'style.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DefaultTabController(
        length: 5,
        child: Scaffold(
          appBar: AppBar(
            bottom: const TabBar(
              tabs: [
                Tab(icon: Icon(Icons.home)),
                Tab(icon: Icon(Icons.hotel)),
                Tab(icon: Icon(Icons.fastfood)),
                Tab(icon: Icon(Icons.museum)),
                Tab(icon: Icon(Icons.card_giftcard)),
              ],
            ),
            title: const Text('Home Page'),
            actions: [
              IconButton(
                icon: const Icon(Icons.search),
                onPressed: () {
                  // SEARCH AREA
                },
              ),
            ],
          ),
          body: const TabBarView(
            children: [
              // HOME
              Text('Home with random recommendations'),

              // HOTEL
              Text('Hotel recommendations'),

              // FOOD
              Text('Food recommendations'),

              // MUSEUM
              Text('Museum recommendations'),

              // GIFT
              Text('Gift?? recommendations'),
            ],
          ),

          floatingActionButton: FloatingActionButton(
            onPressed: () {
              // BUTTON FOR ADDING A NEW ELEMENT ON THE HOME PAGE
            },
            child: Icon(Icons.add),
          ),


          // BOTTOM NAVIGATION BAR
          bottomNavigationBar: BottomAppBar(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => HomePage()));
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.favorite),
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => FavoritePage()));
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.access_time),
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => SchedulePage()));
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.account_circle),
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => ProfilePage()));
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}