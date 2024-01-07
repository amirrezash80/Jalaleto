import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shamsi_date/shamsi_date.dart';
import 'package:get/get.dart';

import '../../../register/getx/user_info_getx.dart';
import '../../data/events.dart';
import 'create_event_screen.dart';

class MyEventsTimeline extends StatefulWidget {
  @override
  _MyEventsTimelineState createState() => _MyEventsTimelineState();
}

class _MyEventsTimelineState extends State<MyEventsTimeline> {
  late Jalali _selectedDate;
  late List<Event> listOfEvents;
  String userToken = userDataStorage.userData['token'];

  @override
  void initState() {
    super.initState();
    _selectedDate = Jalali.now();
    listOfEvents = [];
    _fetchEventsForSelectedDay();
  }

  Future<void> _fetchEventsForSelectedDay() async {
    final Gregorian selectedGregorianDate = _selectedDate.toGregorian();
    final DateTime startOfDay = DateTime(selectedGregorianDate.year,
        selectedGregorianDate.month, selectedGregorianDate.day, 0, 0, 0);
    final DateTime endOfDay = DateTime(selectedGregorianDate.year,
        selectedGregorianDate.month, selectedGregorianDate.day, 23, 59, 59);
  print(startOfDay);
  print(endOfDay);
    final url = Uri.parse('https://dev.jalaleto.ir/api/Reminder/Info');
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $userToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'from': startOfDay.toUtc().toIso8601String(),
        'to': endOfDay.toUtc().toIso8601String(),
      }),
    );

    if (response.statusCode == 200) {
      print(response.body);
      final Map<String, dynamic> data = jsonDecode(response.body);
      setState(() {
        listOfEvents = (data['data'] as List)
            .map((event) => Event.fromJson(event))
            .toList();
      });
    } else {
      print('Failed to fetch events: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 10),
            buildDaysOfWeek(),
            SizedBox(height: 10),
            Expanded(
              child: Card(
                color: Colors.grey[100],
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getFormattedDate(_selectedDate),
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      if (listOfEvents.isNotEmpty)
                        Expanded(
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: listOfEvents.length,
                            itemBuilder: (context, index) {
                              final event = listOfEvents[index];
                              return buildEventCard(event);
                            },
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildDaysOfWeek() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.blue, size: 20),
          onPressed: () {
            setState(() {
              _selectedDate = _selectedDate.addDays(-7);
            });
          },
        ),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(7, (index) {
                final day =
                    _selectedDate.addDays(index - _selectedDate.weekDay + 1);
                return InkWell(
                  onTap: () {
                    setState(() {
                      _selectedDate = day;
                      _fetchEventsForSelectedDay();
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(right: 3.0),
                    child: Container(
                      height: 70,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.blueGrey),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Text(
                          _getFormattedDate(day),
                          style: TextStyle(
                            color: Colors.blueGrey,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
        IconButton(
          icon: Icon(Icons.arrow_forward, color: Colors.blue, size: 20),
          onPressed: () {
            setState(() {
              _selectedDate = _selectedDate.addDays(7);
            });
          },
        ),
      ],
    );
  }

  Widget buildEventCard(Event event) {
    return GestureDetector(
      onTap: () {
       Navigator.push(context, MaterialPageRoute(builder: (context) =>  CreateEventForm(myEvent: event)),
       );
      },
      child: Card(
        elevation: 4.0,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                event.title,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                event.notes,
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              SizedBox(height: 8),
              Text(
                " ${event.dateTime.minute} : ${event.dateTime.hour}",
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getFormattedDate(Jalali date) {
    return '${date.day} ${date.formatter.mN}';
  }

  String _getCompletedDate(Jalali date) {
    return ' ${date.formatter.wN} ${date.day} ${date.formatter.mN} ${date.formatter.yyyy}';
  }
}
