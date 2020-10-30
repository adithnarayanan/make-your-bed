import 'package:flutter/material.dart';
import 'package:device_calendar/device_calendar.dart';
import 'package:make_your_bed_v1/plan_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Make Your Bed',
      theme: ThemeData(
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: CalendarPage(),
    );
  }
}

class CalendarPage extends StatefulWidget {
  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DeviceCalendarPlugin _deviceCalendarPlugin;
  List<String> chosenCalendarIds = [];
  bool isChecked = false;

  List<Calendar> _calendars;
  Map<String, bool> calendarChecked;
  List<Event> _events;
  Calendar _selectedCalendar;

  @override
  initState() {
    _deviceCalendarPlugin = new DeviceCalendarPlugin();
    super.initState();
    _retrieveCalendars();
  }

  Future<List<Calendar>> _retrieveCalendars() async {
    //Retrieve user's calendars from mobile device
    //Request permissions first if they haven't been granted
    try {
      var permissionsGranted = await _deviceCalendarPlugin.hasPermissions();
      if (permissionsGranted.isSuccess && !permissionsGranted.data) {
        permissionsGranted = await _deviceCalendarPlugin.requestPermissions();
        if (!permissionsGranted.isSuccess || !permissionsGranted.data) {
          return null;
        }
      }

      final calendarsResult = await _deviceCalendarPlugin.retrieveCalendars();
      setState(() {
        _calendars = calendarsResult?.data;
        print(_calendars);
        calendarChecked = Map.fromIterable(
          _calendars,
          key: (element) => element.id,
          value: (element) => false,
        );
        return _calendars;
      });
    } catch (e) {
      print(e);
    }
    return null;
  }

  Widget renderCalendarsListView() {
    if (_calendars != null) {
      // return Center(child: Text(_calendars[0].accountName));
      return ListView.builder(
        shrinkWrap: true,
        itemCount: _calendars.length,
        itemBuilder: (context, index) {
          Calendar calendar = _calendars[index];
          return CheckboxListTile(
            title: Text(calendar.name),
            subtitle: Text(calendar.accountName),
            //secondary: Icon(Icons.calendar_today),
            value: calendarChecked[calendar.id],
            onChanged: (value) {
              setState(() {
                calendarChecked[calendar.id] = value;
                if (value) {
                  chosenCalendarIds.add(calendar.id);
                } else {
                  chosenCalendarIds.remove(calendar.id);
                }
                print(chosenCalendarIds);
              });
            },
            activeColor: Colors.green,
            checkColor: Colors.black,
            controlAffinity: ListTileControlAffinity.leading,
          );
        },
      );
    }

    return Center(
      child: CircularProgressIndicator(),
    );
  }

  @override
  Widget build(BuildContext context) {
    const TextStyle topStyle = TextStyle(
      fontSize: 35,
      fontWeight: FontWeight.bold,
    );

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 40, 0, 0),
              child: Text(
                'Choose Calendar',
                style: topStyle,
                textAlign: TextAlign.center,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 80),
              child: SizedBox(
                height: 20.0,
                width: 150.0,
                child: Divider(
                  thickness: 3,
                  color: Colors.teal.shade100,
                ),
              ),
            ),
            Expanded(
              child: renderCalendarsListView(),
            ),
            FlatButton(
              child: Text("Done"),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          PlanPage(chosenCalendarIds: chosenCalendarIds)),
                );
              },
            )
          ],
        ),
      ),
    );
  }
}

// return FutureBuilder(
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.none &&
//             snapshot.hasData == null) {
//           //print('project snapshot data is: ${projectSnap.data}');
//           return Center(
//             child: CircularProgressIndicator(),
//           );
//         }
//         return ListView.builder(
//           itemCount: snapshot.data.length,
//           itemBuilder: (context, index) {
//             Calendar calendar = snapshot.data[index];
//             return Padding(
//               padding: EdgeInsets.all(8),
//               child: InkWell(
//                 onTap: () {},
//                 child: Card(
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(10.0),
//                     ),
//                     color: Colors.amber.shade700,
//                     child: ListTile(
//                       title: Text(calendar.accountName),
//                       subtitle: Text(calendar.accountType),
//                       leading: Icon(Icons.calendar_today),
//                     )),
//               ),
//             );
//           },
//         );
//       },
//       future: _retrieveCalendars(),
//     );
