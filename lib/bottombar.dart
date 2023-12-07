import 'package:flutter/material.dart';
import 'package:travel_application/style.dart';
import 'homepage.dart';
import 'favoritepage.dart';
import 'schedulepage.dart';
import 'profilepage.dart';

class CommonBottomBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTabTapped;

  const CommonBottomBar({required this.currentIndex, required this.onTabTapped});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        canvasColor: AppColor.LightPink, // Set the background color here
      ),
      child: BottomNavigationBar(
        backgroundColor: Colors.black,
        selectedItemColor: Colors.white, // Set the color of the selected item
        unselectedItemColor: Colors.white, // Set the color of the unselected items

        currentIndex: currentIndex,
        onTap: (index) {
          // Call the onTabTapped callback
          onTabTapped(index);

          // Navigate to a new page with a custom fade transition
          switch (index) {
            case 0:
              _navigateWithFadeTransition(context, HomePage());
              break;
            case 1:
              _navigateWithFadeTransition(context, FavoritePage());
              break;
            case 2:
              _navigateWithFadeTransition(context, SchedulePage());
              break;
            case 3:
              _navigateWithFadeTransition(context, ProfilePage());
              break;
          }
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.search,),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite,),
            label: 'Favorite',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.access_time),
            label: 'Schedule',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  void _navigateWithFadeTransition(BuildContext context, Widget page) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = 0.0;
          const end = 1.0;
          const curve = Curves.easeInOut;

          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

          var opacity = animation.drive(tween);
          return FadeTransition(
            opacity: opacity,
            child: child,
          );
        },
      ),
    );
  }
}
