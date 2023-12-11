import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'homepage.dart';
import 'favoritepage.dart';
import 'profilepage.dart';
import 'style.dart';
import 'bottombar.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:firebase_auth/firebase_auth.dart';


class SchedulePage extends StatefulWidget {
  const SchedulePage({Key? key});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ScheduleScaffold(),
    );
  }
}

class ScheduleScaffold extends StatefulWidget {
  const ScheduleScaffold({Key? key}) : super(key: key);

  @override
  _ScheduleScaffoldState createState() => _ScheduleScaffoldState();
}

class _ScheduleScaffoldState extends State<ScheduleScaffold> {
  int _currentIndex = 2;

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    return Scaffold(
      appBar: AppBar(
        title: Text('My Schedule'),
        automaticallyImplyLeading: false,
        backgroundColor: AppColor.SalmonPink,
      ),
      body: ListView(
        children: [
          Container(
            child: Center(
              child: Container(
                child: ScheduleTableCalendar(),
              ),
            ),
          ),
          SizedBox(height: 20),
          Container(
            height: MediaQuery.of(context).size.height * 0.5, // Ajusta la altura según sea necesario
            child: UpcomingEventsList(),
          ),
        ],
      ),
      bottomNavigationBar: CommonBottomBar(
        currentIndex: _currentIndex,
        onTabTapped: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
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
              color: AppColor.LightPink,
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
  List<String> dropdownItems = [];
  TimeOfDay selectedTime = TimeOfDay.now();
  TextEditingController _notesController = TextEditingController();

  FirebaseFirestore.instance
      .collection('recommendations')
      .get()
      .then((QuerySnapshot querySnapshot) {
    querySnapshot.docs.forEach((doc) {
      dropdownItems.add(doc['recoName'] ?? ''); // Agregar el nombre de la recomendación a la lista
    });

    String selectedDropdownValue = dropdownItems.isNotEmpty ? dropdownItems.first : '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setState) {
          return Dialog(
            child: SingleChildScrollView(
              child: Container(
                constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.7),
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      value: selectedDropdownValue,
                      items: dropdownItems.map((String item) {
                        return DropdownMenuItem<String>(
                          value: item,
                          child: Text(item),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedDropdownValue = newValue ?? '';
                        });
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
                          builder: (BuildContext context, Widget? child) {
                            return Theme(
                              data: ThemeData.light().copyWith(
                                primaryColor: AppColor.LightPink,
                              ),
                              child: child!,
                            );
                          },
                        );

                        if (pickedTime != null) {
                          setState(() {
                            selectedTime = pickedTime;
                          });
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
                      controller: _notesController,
                      decoration: InputDecoration(labelText: 'Notes'),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        String notes = _notesController.text;
                        _saveDataToFirebase(selectedDay, selectedDropdownValue, selectedTime, notes, context);
                        Navigator.of(context).pop();
                      },
                      child: Text('Save'),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
      },
    );
  }).catchError((error) {
    print('Error: $error');
  });
}


Future<void> _saveDataToFirebase(
    DateTime selectedDay,
    String eventType,
    TimeOfDay selectedTime,
    String notes,
    BuildContext context,
    ) async {
  User? currentUser = FirebaseAuth.instance.currentUser;

  if (currentUser != null) {
    CollectionReference events = FirebaseFirestore.instance.collection('Calendar');

    events
        .add({
      'userId': currentUser.uid,
      'date': Timestamp.fromDate(selectedDay),
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
  } else {
    print('No user');
  }
}

class UpcomingEventsList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        await ScheduleFunctions.getUpcomingEvents();
      },
      child: FutureBuilder<QuerySnapshot>(
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
                  return SizedBox();
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
      ),
    );
  }
}

class ScheduleFunctions {
  static Future<QuerySnapshot> getUpcomingEvents() async {
    DateTime now = DateTime.now();
    DateTime futureDate = DateTime(now.year, now.month, now.day + 7);

    String? currentUserUid = FirebaseAuth.instance.currentUser?.uid;

    if (currentUserUid != null) {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('Calendar')
          .where('userId', isEqualTo: currentUserUid)
          .where('date', isGreaterThanOrEqualTo: now, isLessThanOrEqualTo: futureDate)
          .orderBy('date')
          .get();

      return snapshot;
    } else {
      throw Exception('No user logged in');
    }
  }

  static Future<void> deleteEvent(String eventId) async {
    try {
      await FirebaseFirestore.instance.collection('Calendar').doc(eventId).delete();
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
