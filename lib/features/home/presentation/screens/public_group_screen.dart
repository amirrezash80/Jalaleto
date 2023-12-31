import 'package:flutter/material.dart';
import 'package:shamsi_date/shamsi_date.dart';
import 'package:timelines/timelines.dart';

import '../../data/events.dart';

class PublicGroupsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final List<Event> listOfEvents = [
      Event(
        title: "First event",
        dateTime: DateTime.now(), // Replace this with the actual date and time
        daysBeforeToRemind: 0,
        remindByEmail: false,
        repeatInterval: 1,
        priorityLevel: 0,
        notes: "Mobile App",
      ),
      Event(
        title: "Second Event",
        dateTime: DateTime.now(), // Replace this with the actual date and time
        daysBeforeToRemind: 0,
        remindByEmail: false,
        repeatInterval: 1,
        priorityLevel: 0,
        notes: "Alaki",
      ),
      Event(
        title: "Third Event",
        dateTime: DateTime.now(), // Replace this with the actual date and time
        daysBeforeToRemind: 0,
        remindByEmail: false,
        repeatInterval: 1,
        priorityLevel: 0,
        notes: "Something",
      ),
      Event(
        title: "رویداد جدید",
        dateTime: DateTime.now(), // Replace this with the actual date and time
        daysBeforeToRemind: 0,
        remindByEmail: false,
        repeatInterval: 1,
        priorityLevel: 0,
        notes: "Web App",
      ),
    ];

    final List<Color> listOfColors = [
      Colors.red,
      Colors.green,
      Colors.blue,
      Colors.purple,
    ];

    return Timeline.tileBuilder(
      theme: TimelineThemeData(
        nodePosition: 0.1,
        indicatorTheme: IndicatorThemeData(
          size: 20.0,
        ),
        connectorTheme: ConnectorThemeData(
          thickness: 2.5,
        ),
      ),
      builder: TimelineTileBuilder.connected(
        itemCount: listOfEvents.length,
        contentsBuilder: (_, index) {
          final event = listOfEvents[index];
          return buildEventCard(event);
        },
        indicatorBuilder: (_, index) {
          return DotIndicator(
            color: listOfColors[index % listOfColors.length],
          );
        },
        connectorBuilder: (_, index, type) {
          return SolidLineConnector(
            color: Colors.blue,
          );
        },
      ),
    );
  }

  Widget buildEventCard(Event event) {
    return Card(
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
             event.dateTime.toString(),
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              event.title,
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 8),
            Text(
              event.notes,
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
