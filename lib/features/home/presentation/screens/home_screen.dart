import 'dart:convert';

import 'package:analog_clock/analog_clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:roozdan/features/groups/public_group_screen.dart';
import 'package:roozdan/features/home/presentation/screens/timeline_screen.dart';
import 'package:shamsi_date/shamsi_date.dart';
import 'package:timelines/timelines.dart';
import 'package:http/http.dart' as http;
import '../../../register/getx/user_info_getx.dart';
import '../../data/events.dart';
import '../../widgets/drawer/main_drawer.dart';
import '../../widgets/floating_action_button.dart';

class HomeScreen extends StatefulWidget {
  static const routeName = "/HomeScreen";
   HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late final TabController _tabController;
  late final PageController _pageController; // Add PageController
  late final AnimationController _animationController;

  final Jalali jNow = Jalali.now();

  Future<void> _handleNotificationTap() async {

    String authToken  = userDataStorage.userData['token'];

    try {
      final response = await http.post(
        Uri.parse('https://dev.jalaleto.ir/api/Notification/Get'),
        headers: {
          'accept': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> notifications = json.decode(response.body)['items'];
      notifications.forEach((e) {
        print(e['title']);
      });
        _showNotifications(notifications);
      } else {
        print('Error: ${response.statusCode}');
      }
    } catch (error) {
      print('Error: $error');
    }
  }

  void _showNotifications(List<dynamic> notifications) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('یادآوری ها'),
          content: Container(
            width: double.maxFinite,
            height: MediaQuery.of(context).size.height*0.5,
            child: ListView.builder(
              itemCount: notifications.length,
              itemBuilder: (BuildContext context, int index) {
                return _buildNotificationItem(notifications[index]);
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('باشه'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildNotificationItem(Map<String, dynamic> notification) {
    return Card(
      elevation: 3.0,
      margin: EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: ListTile(
        leading: _buildNotificationIcon(notification['type'].toString()), // Convert to string
        title: Text(
          notification['title'].toString(), // Convert to string
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(notification['description'].toString()), // Convert to string
        onTap: () {
          // Add your logic for handling notification tap
        },
      ),
    );
  }

  Widget _buildNotificationIcon(String notificationType) {
    IconData iconData = Icons.notification_important; // Default icon

    // Map notification types to corresponding icons
    if (notificationType == 'reminder') {
      iconData = Icons.alarm;
    } else if (notificationType == 'event') {
      iconData = Icons.event;
    }

    return Icon(
      iconData,
      color: Colors.blue,
    );
  }


  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: 0,
    );

    _pageController = PageController(initialPage: 0);

    _animationController = AnimationController(
      vsync: this,
      duration:
          Duration(milliseconds: 0),

    );

    void _animateTransition(int index) {
      _animationController.reset();
      _animationController.forward();
      _pageController.animateToPage(
        index,
        duration: Duration(milliseconds: 250),
        curve: Curves.ease,
      );
    }

    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        _animateTransition(_tabController.index);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print("username => ${userDataStorage.userData['userName']}");
    print("password => ${userDataStorage.userData['password']}");
    print("mail => ${userDataStorage.userData['mail']}");
    print("firstname => ${userDataStorage.userData['firstName']}");
    print("lastname => ${userDataStorage.userData['lastName']}");
    print("birthday => ${userDataStorage.userData['birthday']}");
    print("token => ${userDataStorage.userData["token"]}");

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          actions: [
            IconButton(
              onPressed: _handleNotificationTap,
              icon: Icon(Icons.notifications),
              color: Colors.yellowAccent,
            )
          ],
          title: Text(
            "جلالتو",
            style: TextStyle(letterSpacing: 0.8),
          ),
          backgroundColor: Color(0xff455A64),
        ),
        drawer: MainDrawer(),
        body: Directionality(
          textDirection: TextDirection.ltr,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              buildHeader(),
              SizedBox(height: 20),
              TabBar(
                controller: _tabController,
                tabs: [
                  Tab(text: 'رویدادهای من'),
                  Tab(text: 'گروه ها'),
                ],
                onTap: (index) {
                  _tabController.animateTo(index);
                },
              ),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (index) {
                    _tabController.animateTo(index);
                  },
                  children: [
                    MyEventsTimeline(),
                    GroupScreen(),
                  ],
                ),
              ),
            ],
          ),
        ),
        floatingActionButtonLocation: ExpandableFab.location,
        floatingActionButton: myFloatingActionButton(widget.key),
        backgroundColor: Colors.grey[200],
        // backgroundColor: Colors.white,
      ),
    );
  }

  // Widget buildBody() {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.stretch,
  //     children: [
  //       buildHeader(),
  //       SizedBox(height: 20),
  //       Text(
  //         'رویدادها',
  //         textAlign: TextAlign.center,
  //         style: TextStyle(
  //           fontSize: 24,
  //           fontWeight: FontWeight.bold,
  //           color: Colors.black,
  //         ),
  //       ),
  //       Expanded(
  //         child: buildTimeline(),
  //       ),
  //     ],
  //   );
  // }

  Widget buildHeader() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.blueGrey[700]!,
            Colors.blueGrey[900]!
            // Colors.lightBlue.shade600,
            // Colors.lightBlue.shade900
          ], // Updated header gradient colors
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          buildAnalogClock(),
          buildDateInfo(),
        ],
      ),
    );
  }

  Widget buildAnalogClock() {
    return SizedBox(
      width: 150,
      height: 150,
      child: AnalogClock(
        isLive: true,
        decoration: BoxDecoration(
          border: Border.all(width: 2.0, color: Colors.white38),
          shape: BoxShape.circle,
        ),
        showTicks: true,
        showNumbers: true,
        hourHandColor: Colors.black,
        minuteHandColor: Colors.black,
        numberColor: Colors.white,
        secondHandColor: Colors.red,
        digitalClockColor: Colors.teal,
        textScaleFactor: 1.5,
      ),
    );
  }

  Widget buildDateInfo() {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.calendar_today, color: Colors.white),
              SizedBox(width: 8),
              Text(
                'تاریخ امروز',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            '${jNow.day}',
            style: TextStyle(
              fontSize: 46,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
          Text(
            '${_getMonth(jNow.month)} ${jNow.year}',
            style: TextStyle(
              fontSize: 24,
              color: Colors.teal,
            ),
          ),
        ],
      ),
    );
  }

  // Widget buildTimeline() {
  //   return Timeline.tileBuilder(
  //     theme: TimelineThemeData(
  //       nodePosition: 0.1,
  //       indicatorTheme: IndicatorThemeData(
  //         size: 20.0,
  //       ),
  //       connectorTheme: ConnectorThemeData(
  //         thickness: 2.5,
  //       ),
  //     ),
  //     builder: TimelineTileBuilder.connected(
  //       itemCount: listOfEvents.length,
  //       contentsBuilder: (_, index) {
  //         final event = listOfEvents[index];
  //         return buildEventCard(event);
  //       },
  //       indicatorBuilder: (_, index) {
  //         return DotIndicator(
  //           color: listOfColors[index % listOfColors.length],
  //         );
  //       },
  //       connectorBuilder: (_, index, type) {
  //         return SolidLineConnector(
  //           color: Colors.blue,
  //         );
  //       },
  //     ),
  //   );
  // }

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

  String _getMonth(int monthIndex) {
    const List<String> months = [
      'فروردین',
      'اردیبهشت',
      'خرداد',
      'تیر',
      'مرداد',
      'شهریور',
      'مهر',
      'آبان',
      'آذر',
      'دی',
      'بهمن',
      'اسفند'
    ];
    return months[monthIndex - 1];
  }
}

// class ProfileButton extends StatelessWidget {
//   const ProfileButton({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return IconButton(
//       icon: CircleAvatar(
//         backgroundColor: Colors.blue,
//       ),
//       onPressed: () {
//         Navigator.pushNamed(context, ProfileScreen.routeName);
//       },
//     );
//   }
// }
