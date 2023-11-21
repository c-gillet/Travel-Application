import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

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
              Text('Test'),

              // HOTEL
              Text('Test'),

              // FOOD
              Text('Test'),

              // MUSEUM
              Text('Test'),

              // GIFT
              Text('Test'),
            ],
          ),
          bottomNavigationBar: BottomAppBar(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.favorite),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.access_time),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.account_circle),
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}