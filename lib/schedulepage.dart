import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'homepage.dart';
import 'favoritepage.dart';
import 'profilepage.dart';
import 'style.dart';
import 'package:table_calendar/table_calendar.dart';

class SchedulePage extends StatelessWidget {
  const SchedulePage({Key? key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ScheduleScaffold(),
    );
  }
}

class ScheduleScaffold extends StatelessWidget {
  const ScheduleScaffold({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();

    return Scaffold(
      appBar: AppBar(
        title: Text('My Schedule'),
      ),
      body: Column(
        children: [
          Center(
            child: Container(
              child: ScheduleTableCalendar(),
            ),
          ),
          SizedBox(height: 20), // Espacio entre el calendario y la lista de eventos
          Expanded(
            child: Container(
              child: UpcomingEventsList(),
            ),
          ),
        ],
      ),
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
    );
  }
}

class ScheduleTableCalendar extends StatefulWidget {
  @override
  _ScheduleTableCalendarState createState() => _ScheduleTableCalendarState();
}

class _ScheduleTableCalendarState extends State<ScheduleTableCalendar> {
  DateTime _selectedDay = DateTime.now();
  TextEditingController _titleController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TableCalendar(
          focusedDay: _selectedDay,
          firstDay: DateTime(_selectedDay.year, _selectedDay.month - 6, 1),
          lastDay: DateTime(_selectedDay.year, _selectedDay.month + 6, 31),
          calendarFormat: CalendarFormat.month,
          calendarStyle: CalendarStyle(
            todayDecoration: BoxDecoration(
              color: Colors.lightBlue,
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
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _selectedDay = selectedDay;
            });
            _openAddDataDialog(context, selectedDay);
          },
        ),
      ],
    );
  }

  void _openAddDataDialog(BuildContext context, DateTime selectedDay) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Add Event"),
          content: SingleChildScrollView( // Utilizar SingleChildScrollView para que sea desplazable
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _titleController,
                    decoration: InputDecoration(labelText: 'Title'),
                  ),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: InputDecoration(labelText: 'Description'),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                _saveDataToFirebase(selectedDay);
                Navigator.of(context).pop();
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }


  void _saveDataToFirebase(DateTime selectedDay) {
    String title = _titleController.text;
    String description = _descriptionController.text;

    if (title.isNotEmpty && description.isNotEmpty) {
      CollectionReference events = FirebaseFirestore.instance.collection('Calendar');

      events.add({
        'date': selectedDay,
        'title': title,
        'description': description,
      }).then((value) {
        _titleController.clear();
        _descriptionController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Event added')),
        );
      }).catchError((error) {
        print(' ERROR : $error');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding event: $error')),
        );
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in all fields')),
      );
    }
  }
}

class UpcomingEventsList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<QuerySnapshot>(
      future: ScheduleFunctions.getUpcomingEvents(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('There are no upcoming events'));
        } else {
          return Expanded(
            child: ListView(
              children: snapshot.data!.docs.map((DocumentSnapshot document) {
                Map<String, dynamic> data = document.data() as Map<String, dynamic>;
                DateTime eventDate = (data['date'] as Timestamp).toDate();
                String title = data['title'];
                String description = data['description'];

                return Dismissible(
                  key: UniqueKey(),
                  onDismissed: (direction) {
                    ScheduleFunctions.deleteEvent(document.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('$title deleted'),
                      ),
                    );
                  },
                  background: Container(
                    color: Colors.red,
                    child: Icon(Icons.delete, color: Colors.white),
                    alignment: Alignment.centerRight,
                    padding: EdgeInsets.only(right: 20.0),
                  ),
                  direction: DismissDirection.endToStart,
                  child: ListTile(
                    title: Text(title),
                    subtitle: Text(description),
                    trailing: Text(
                      '${eventDate.day}/${eventDate.month}/${eventDate.year}',
                    ),
                  ),
                );
              }).toList(),
            ),
          );
        }
      },
    );
  }
}


class ScheduleFunctions {
  static Future<QuerySnapshot> getUpcomingEvents() async {
    DateTime now = DateTime.now();
    DateTime futureDate = DateTime(now.year, now.month, now.day + 7); // Obtener eventos de la próxima semana

    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('Calendar')
        .where('date', isGreaterThanOrEqualTo: now, isLessThanOrEqualTo: futureDate)
        .orderBy('date')
        .get();

    return snapshot;
  }

  static Future<void> deleteEvent(String eventId) async {
    try {
      await FirebaseFirestore.instance.collection('Calendar').doc(eventId).delete();
      print('Successfully deleted evento');
    } catch (e) {
      print('Error deleting event: $e');
      }
    }
  }


