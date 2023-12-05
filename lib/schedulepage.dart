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
          SizedBox(height: 20),
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
              color: Theme
                  .of(context)
                  .primaryColor,
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
}

void _openAddDataDialog(BuildContext context, DateTime selectedDay) {
  List<String> dropdownItems = ['Meeting', 'Appointment', 'Reminder', 'Other'];
  String? selectedDropdownItem = dropdownItems.first;
  String selectedValue = selectedDropdownItem ?? "Default Value";
  TimeOfDay selectedTime = TimeOfDay.now();

  TextEditingController _notesController = TextEditingController(); // Definir el controlador aquí

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.9,
              alignment: Alignment.topCenter,
              child: Card(
                elevation: 5,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DropdownButtonFormField<String>(
                        value: selectedDropdownItem,
                        items: dropdownItems.map((String item) {
                          return DropdownMenuItem<String>(
                            value: item,
                            child: Text(item),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            selectedDropdownItem = newValue;
                          }
                        },
                        decoration: InputDecoration(
                          labelText: 'Type',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 20),
                      InkWell(
                        onTap: () async {
                          TimeOfDay? pickedTime = await showTimePicker(
                            context: context,
                            initialTime: selectedTime,
                          );

                          if (pickedTime != null) {
                            selectedTime = pickedTime;
                          }
                        },
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: 'Start Time',
                            hintText: 'Select Time',
                            border: OutlineInputBorder(),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text(
                                selectedTime.format(context),
                              ),
                              Icon(Icons.access_time),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      TextFormField(
                        controller: _notesController, // Asignar el controlador al campo de texto
                        decoration: InputDecoration(labelText: 'Notes'),
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          String notes = _notesController.text; // Obtener las notas ingresadas
                          _saveDataToFirebase(selectedDay, selectedValue, selectedTime, notes, context);
                          Navigator.of(context).pop();
                        },
                        child: Text('Save'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    },
  );
}



void _saveDataToFirebase(
    DateTime selectedDay,
    String eventType,
    TimeOfDay selectedTime,
    String notes,
    BuildContext context,
    ) {
  CollectionReference events = FirebaseFirestore.instance.collection('Calendar');

  events
      .add({
    'date': selectedDay,
    'type': eventType,
    'start_time': selectedTime.format(context),
    'notes': notes,
  })
      .then((value) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Event added')),
    );
  })
      .catchError((error) {
    print(' ERROR : $error');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error adding event: $error')),
    );
  });
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
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              DocumentSnapshot document = snapshot.data!.docs[index];
              Map<String, dynamic>? data = document.data() as Map<String, dynamic>?;

              if (data == null) {
                return SizedBox(); // O un Widget de manejo de datos nulos
              }

              DateTime eventDate = (data['date'] as Timestamp).toDate();
              String title = data['type'] ?? 'Title not available';
              String description = data['notes'] ?? 'Description not available';

              return Dismissible(
                key: UniqueKey(),
                onDismissed: (direction) {
                  ScheduleFunctions.deleteEvent(document.id).then((value) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('$title deleted'),
                      ),
                    );
                  }).catchError((error) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error deleting $title: $error'),
                      ),
                    );
                  });
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
            },
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
      print('Successfully deleted event');
    } catch (e) {
      print('Error deleting event: $e');
      }
    }
  }


