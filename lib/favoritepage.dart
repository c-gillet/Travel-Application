import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'bottombar.dart';
import 'homepage.dart';
import 'schedulepage.dart';
import 'profilepage.dart';
import 'style.dart';

class FavoritePage extends StatefulWidget {
  const FavoritePage({super.key});

  @override
  State<FavoritePage> createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  int _currentIndex = 1;
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
            title: const Text('My Favorites'),
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
              Text('Home with random favorites'),

              // HOTEL
              Text('Hotel favorites'),

              // FOOD
              Text('Food favorites'),

              // MUSEUM
              Text('Museum favorites'),

              // GIFT
              Text('Gift?? favorites'),
            ],
          ),

          // BOTTOM NAVIGATION BAR
          bottomNavigationBar: CommonBottomBar(
            currentIndex: _currentIndex,
            onTabTapped: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
          ),
        ),
      ),
    );
  }
}