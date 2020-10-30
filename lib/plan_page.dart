import 'package:device_calendar/device_calendar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_week_view/flutter_week_view.dart';

class PlanPage extends StatefulWidget {
  List<String> chosenCalendarIds;
  PlanPage({Key key, this.chosenCalendarIds}) : super(key: key);

  @override
  _PlanPageState createState() => _PlanPageState(chosenCalendarIds);
}

class _PlanPageState extends State<PlanPage> {
  DeviceCalendarPlugin _deviceCalendarPlugin;
  List<Event> _events;
  List<FlutterWeekViewEvent> _viewEvents = [];
  List<String> chosenCalendarIds;
  bool _validate = false;

  _PlanPageState(this.chosenCalendarIds);

  void _retrieveEvents(String calendarId) async {
    final now = DateTime.now();
    final firstMinute = new DateTime(now.year, now.month, now.day, 0, 0);
    final lastMinute = new DateTime(now.year, now.month, now.day, 23, 59);
    final eventsResult = await _deviceCalendarPlugin.retrieveEvents(
      calendarId,
      RetrieveEventsParams(
        startDate: firstMinute,
        endDate: lastMinute,
      ),
    );
    setState(() {
      _events = eventsResult?.data;
      print(_events);
      _populateViewEvents();
    });
  }

  void _populateViewEvents() {
    //_viewEvents = new List<FlutterWeekViewEvent>();
    for (var x = 0; x < _events.length; x++) {
      Event event = _events[x];
      _viewEvents.add(
        new FlutterWeekViewEvent(
          margin: EdgeInsets.symmetric(horizontal: 5),
          title: event.title,
          description: event.description,
          start: event.start,
          end: event.end,
          backgroundColor: Colors.blue,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15), color: Colors.green),
          // onTap: () {
          //   showDialog(context: null)
          // }
        ),
      );
      setState(() {
        _viewEvents = _viewEvents;
      });
    }
  }

  void createNewTemporaryEvent(
    String inputTitle,
    TimeOfDay startTime,
    TimeOfDay endTime,
  ) {
    int currentIndex = _viewEvents.length;
    final now = DateTime.now();
    setState(() {
      print('adding event');
      _viewEvents.add(
        new FlutterWeekViewEvent(
            margin: EdgeInsets.symmetric(horizontal: 5),
            title: inputTitle,
            description: "",
            start: // DateTime.now(),
                new DateTime(now.year, now.month, now.day, startTime.hour,
                    startTime.minute),
            end: //DateTime.now().add(new Duration(minutes: 30)),
                new DateTime(
                    now.year, now.month, now.day, endTime.hour, endTime.minute),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15), color: Colors.pink),
            onLongPress: () {
              setState(() {
                _viewEvents.removeAt(currentIndex);
              });
            }),
      );
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    _deviceCalendarPlugin = new DeviceCalendarPlugin();
    for (var id in chosenCalendarIds) {
      _retrieveEvents(id);
    }

    super.initState();
  }

  Widget _buildDayView() {
    if (_viewEvents != null) {
      DateTime now = DateTime.now();
      DateTime date = DateTime(now.year, now.month, now.day);
      return DayView(
          minimumTime: const HourMinute(hour: 6),
          maximumTime: const HourMinute(hour: 23),
          userZoomable: false,
          date: now,
          events: _viewEvents,
          style: DayViewStyle(
              currentTimeCircleRadius: 10,
              currentTimeCircleColor: Colors.orange,
              currentTimeRuleColor: Colors.orange,
              headerSize: 0,
              backgroundColor: Colors.black54,
              backgroundRulesColor: Colors.blue.shade200),
          hoursColumnStyle: HoursColumnStyle(
            timeFormatter: (time) {
              if (time.hour > 12) {
                return '${time.hour - 12} PM';
              } else if (time.hour == 12) {
                return '12 PM';
              } else {
                return '${time.hour} AM';
              }
            },
            //color: Colors.white
            color: Colors.black45,
            textStyle: TextStyle(color: Colors.orange.shade200),
          ));
    } else {
      return Center(
        child: CircularProgressIndicator(),
      );
    }
  }

  final _formKey = GlobalKey<FormState>();
  final myController = TextEditingController();

  var selectedTime = TimeOfDay.now();
  TimeOfDay selectedStartTime =
      TimeOfDay(hour: TimeOfDay.now().hour + 1, minute: 0);
  TimeOfDay selectedEndTime =
      TimeOfDay(hour: TimeOfDay.now().hour + 1, minute: 30);

  Future<void> _selectTime(BuildContext context, bool isStart) async {
    final TimeOfDay picked =
        await showTimePicker(context: context, initialTime: selectedTime);
    if (picked != null && picked != selectedTime) {
      setState(() {
        if (isStart) {
          print('setting start time');
          selectedStartTime = picked;
        } else {
          print('setting end time');
          selectedEndTime = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const TextStyle topStyle = TextStyle(
      color: Colors.white,
      fontSize: 35,
      //fontWeight: FontWeight.bold,
    );

    //_populateViewEvents(); //delete
    return Scaffold(
      backgroundColor: Colors.grey.shade800,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 30, 0, 20),
              child: Text(
                DateFormat.yMMMMd().format(DateTime.now()),
                style: topStyle,
                textAlign: TextAlign.center,
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: _buildDayView(),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
              context: context,
              barrierDismissible: true,
              builder: (context) {
                return StatefulBuilder(
                  builder: (context, setState) {
                    return AlertDialog(
                      title: Text('Create Event'),
                      content: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextFormField(
                              controller: myController,
                              validator: (value) {
                                if (value.isEmpty) {
                                  return 'Event Name Can\'t be Empty';
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: 'Event Name',
                              ),
                            ),
                            FlatButton(
                                onPressed: () async {
                                  // _selectTime(context, true);
                                  final TimeOfDay picked = await showTimePicker(
                                      context: context,
                                      initialTime: selectedTime);
                                  if (picked != null &&
                                      picked != selectedTime) {
                                    setState(() {
                                      print('setting start time');
                                      selectedStartTime = picked;
                                    });
                                  }
                                },
                                child: Text(selectedStartTime.format(context))),
                            Text("To"),
                            FlatButton(
                                onPressed: () async {
                                  final TimeOfDay picked = await showTimePicker(
                                      context: context,
                                      initialTime: selectedTime);
                                  if (picked != null &&
                                      picked != selectedTime) {
                                    setState(() {
                                      print('setting end time');
                                      selectedEndTime = picked;
                                    });
                                  }
                                },
                                child: Text(selectedEndTime.format(context)))
                          ],
                        ),
                      ),
                      actions: <Widget>[
                        FlatButton(
                          child: Text("Submit"),
                          onPressed: () {
                            if (_formKey.currentState.validate()) {
                              String eventName = myController.text;
                              createNewTemporaryEvent(eventName,
                                  selectedStartTime, selectedEndTime);
                              myController.clear();
                              Navigator.of(context).pop();
                            }
                            if (!_validate) {}
                          },
                        ),
                        FlatButton(
                          child: Text("Cancel"),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        )
                      ],
                    );
                  },
                );
              });
        },
        child: Icon(
          Icons.add,
        ),
      ),
    );
  }
}
