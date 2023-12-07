import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'favoritepage.dart';
import 'schedulepage.dart';
import 'profilepage.dart';
import 'style.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key});


  @override
  Widget build(BuildContext context) {
    final double paddingValue = 30.0;

    final List<Widget> listWidgetImages = List.generate(
      5,
          (index) => Padding(
            padding: EdgeInsets.all(paddingValue),
            child: Column(
              children: [
                GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          content: SingleChildScrollView(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: EdgeInsets.all(0), // Set padding to zero
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Material(
                                        shape: CircleBorder(),
                                        clipBehavior: Clip.antiAlias,
                                        child: IconButton(
                                          icon: Icon(Icons.close, size: 20.0),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  constraints: BoxConstraints(
                                    maxHeight: 400,
                                  ),
                                  width: double.maxFinite,
                                  child: Image.asset(
                                    'assets/background.jpg',
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text('Test of text'),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('Test of text'),
                                    Row(
                                      children: [
                                        Icon(Icons.star_border),
                                        const Text('4'),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },


                    );
                  },
                  child: Container(
                    color: const Color(0xFF99C7C1),
                    width: MediaQuery.of(context).size.width - 2 * paddingValue,
                    height: MediaQuery.of(context).size.width - 2 * paddingValue,
                    child: Container(
                      margin: EdgeInsets.all(8.0),
                      child: Image.asset(
                        'assets/background.jpg',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),

                SizedBox(
                  height: 8,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Test of text'),
                    Row(
                      children: [
                        Icon(Icons.star_border),
                        const Text('4'),
                      ],
                    )
                  ],
                ),
              ],
            ),
          ),
    );


    return MaterialApp(
      theme: ThemeData(
        primarySwatch: const MaterialColor(0xFFFCC7BF, {
          50: Color(0xFFFCC7BF),
          100: Color(0xFFFCC7BF),
          200: Color(0xFFFCC7BF),
          300: Color(0xFFFCC7BF),
          400: Color(0xFFFCC7BF),
          500: Color(0xFFFCC7BF),
          600: Color(0xFFFCC7BF),
          700: Color(0xFFFCC7BF),
          800: Color(0xFFFCC7BF),
          900: Color(0xFFFCC7BF),
        }),
      ),
      home: DefaultTabController(
        length: 5,
        child: Scaffold(
          body: Stack(
            fit: StackFit.expand,
            children: [
              ColorFiltered(
                colorFilter: ColorFilter.mode(
                  Colors.white.withOpacity(0.7),
                  BlendMode.srcATop,
                ),
                child: Image.asset(
                  'assets/background.jpg',
                  fit: BoxFit.cover,
                ),
              ),
              Container(
                child: Column(
                  children: [
                    Container(
                      height: 90, // Fixed height for the AppBar
                      child: AppBar(
                        backgroundColor: Colors.transparent,
                        elevation: 0,
                        bottom: PreferredSize(
                          preferredSize: const Size.fromHeight(48.0),
                          child: Container(
                            color: const Color(0xFFFCC7BF),
                            child: const TabBar(
                              tabs: [
                                Tab(icon: Icon(Icons.home, color: Colors.white)),
                                Tab(icon: Icon(Icons.hotel, color: Colors.white)),
                                Tab(icon: Icon(Icons.fastfood, color: Colors.white)),
                                Tab(icon: Icon(Icons.museum, color: Colors.white)),
                                Tab(icon: Icon(Icons.card_giftcard, color: Colors.white)),
                              ],
                            ),
                          ),
                        ),
                        title: const Text('Home Page', style: TextStyle(color: Colors.white)),
                        actions: [
                          IconButton(
                            icon: const Icon(Icons.search),
                            onPressed: () {
                              // SEARCH AREA
                            },
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: TabBarView(
                        children: [
                          // HOME
                          //Text('Home with random recommendations'),
                          SingleChildScrollView(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: listWidgetImages,
                            ),
                          ),

                          // HOTEL
                          const Text('Hotel recommendations'),

                          // FOOD
                          const Text('Food recommendations'),

                          // MUSEUM
                          const Text('Museum recommendations'),

                          // GIFT
                          const Text('Gift?? recommendations'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              // BUTTON FOR ADDING A NEW ELEMENT ON THE HOME PAGE
            },
            child: const Icon(Icons.add),
          ),
          bottomNavigationBar: BottomAppBar(
            color: const Color(0xFFFCC7BF),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  icon: const Icon(Icons.search, color: Colors.white),
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const HomePage()));
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.favorite, color: Colors.white),
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const FavoritePage()));
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.access_time, color: Colors.white),
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const SchedulePage()));
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.account_circle, color: Colors.white),
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfilePage()));
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