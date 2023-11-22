import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'homepage.dart';
import 'favoritepage.dart';
import 'profilepage.dart';
import 'package:table_calendar/table_calendar.dart';
import 'style.dart';

class SchedulePage extends StatelessWidget {
  const SchedulePage({Key? key});

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('My Schedule'),
        ),
        body: Column(
          children: [
            TableCalendar(
              focusedDay: now,
              firstDay: DateTime(now.year, now.month, 1),
              lastDay: DateTime(now.year, now.month + 1, 0),
              calendarFormat: CalendarFormat.month,
              calendarStyle: CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: AppColor.LightBlue,
                  shape: BoxShape.circle,
                ),
                selectedDecoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  shape: BoxShape.circle,
                ),
              ),
              headerStyle: HeaderStyle(
                formatButtonVisible: false,
              ),
              startingDayOfWeek: StartingDayOfWeek.monday,
            ),
          ],
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
                onPressed: () {},
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
    );
  }
}
