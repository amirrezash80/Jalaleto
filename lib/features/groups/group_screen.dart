import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shamsi_date/shamsi_date.dart';

import '../chat/presentation/chat_screen.dart';
import '../home/widgets/snackbar.dart';
import '../register/getx/user_info_getx.dart';
import 'create_event.dart';

class GroupDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> groupData;
  bool isMember;
  GroupDetailsScreen({required this.groupData , required this.isMember});

  @override
  State<GroupDetailsScreen> createState() => _GroupDetailsScreenState();
}

class _GroupDetailsScreenState extends State<GroupDetailsScreen> {
  int _currentIndex = 1;
  String userToken = userDataStorage.userData['token'];

  late File? _image;

  Future<void> joinGroup(int groupId) async {
    try {
      final url = Uri.parse('https://dev.jalaleto.ir/api/Group/JoinGroup?GroupId=$groupId');
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $userToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        mySnackBar(context, "با موفقیت به گروه اضافه شدید!");
        setState(() {
          widget.isMember = true;
        });
      } else {
        print('Failed to join group: ${response.statusCode}');
      }
    } catch (error) {
      print('Error joining group: $error');
    }
  }


  Future<void> showEventDetailsDialog(Map<String, dynamic> event) async {
    bool isUserMember = event['members']
        .any((member) => member['mail'] == userDataStorage.userData['email']);
    bool isEventFull =
        event['members'].length >= event['memberLimit'];

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event['name'],
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo,
                  ),
                ),
                SizedBox(height: 15),
                Text(
                  'تاریخ برگزاری : ${Jalali
                      .fromDateTime(
                      DateTime.parse(event['when']))
                      .day} / ${Jalali
                      .fromDateTime(
                      DateTime.parse(event['when']))
                      .month } / ${Jalali
                      .fromDateTime(
                      DateTime.parse(event['when']))
                      .year}',                  style: TextStyle(fontSize: 16),
                ),
                Text(
                  'زمان برگزاری: ${DateFormat('kk:mm').format(
                      DateTime.parse(event['when']))}',
                  style: TextStyle(fontSize: 16),
                ),
                Text(
                  'تگ‌ها: ${event['tag'].join(', ')}',
                  style: TextStyle(fontSize: 16),
                ),
                Text(
                  'حداکثر تعداد اعضا: ${event['memberLimit']}',
                  style: TextStyle(fontSize: 16),
                ),
                Text(
                  'افراد شرکت‌کننده: ${event['members']
                      .map((
                      member) => '${member['firstName']} ${member['lastName']}')
                      .join(', ')}',
                  style: TextStyle(fontSize: 16),
                ),
                Text(
                  'توضیحات: ${event['description']}',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 20),
                if (!isUserMember && !isEventFull)
                  ElevatedButton(
                    onPressed: () async {
                      print(event['eventId']);
                      try {
                        final response = await http.post(
                          Uri.parse('https://dev.jalaleto.ir/api/Event/Join?groupId=${event['groupId']}&eventId=${event['eventId']}'),
                          headers: {
                            'Authorization': 'Bearer $userToken',
                          },
                        );

                        if (response.statusCode == 200) {
                          fetchGroupInfo();
                          mySnackBar(context, "با موفقیت عضو رویداد شدید.");
                          Navigator.pop(context);
                        } else {
                          print('Failed to join event. Status code: ${response
                              .statusCode}');
                        }
                      } catch (error) {
                        print('Error joining event: $error');
                      }
                    },
                    child: Text('عضویت در رویداد'),
                  ),
                if (isEventFull)
                  Text(
                    'تعداد افراد شرکت‌کننده در این رویداد به حد نصاب رسیده است.',
                    style: TextStyle(fontSize: 16, color: Colors.red),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }


  Future<void> getImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
        uploadImage();
      } else {
        print('No image selected.');
      }
    });
  }

  Future<void> uploadImage() async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse(
            'https://dev.jalaleto.ir/api/Group/UploadImage?groupId=${widget
                .groupData['groupId']}'),
      );
      request.headers['Authorization'] =
      'Bearer ${userDataStorage.userData['token']}';
      request.files
          .add(await http.MultipartFile.fromPath('image', _image!.path));

      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        print('Image uploaded successfully');
        mySnackBar(context, "عملیات با موفقیت انجام شد");
      } else {
        print('Image upload failed with status: ${response.statusCode}');
      }
    } catch (error) {
      print('Error uploading image: $error');
    }
  }

  Future<void> fetchGroupInfo() async {
    try {
      final response = await http.post(
        Uri.parse('https://dev.jalaleto.ir/api/Group/GpInfo?GroupId=${widget.groupData['groupId']}'),
        headers: {
          'accept': 'text/plain',
          'Authorization': 'Bearer ${userDataStorage.userData['token']}',
        },
      );

      if (response.statusCode == 200) {
        final dynamic responseData = json.decode(response.body);

        // Check if 'data' field is present and not empty
        if (responseData.containsKey('data') && responseData['data'] is List && responseData['data'].isNotEmpty) {
          final List<dynamic> groups = responseData['data'];

          // Check if the last group has 'events' field
          if (groups.last.containsKey('events')) {
            final List<dynamic> events = groups.last['events'];
              print(events);
            // Check if the 'events' field is not empty
            if (events.isNotEmpty) {
              setState(() {
                widget.groupData['events'] = events; // Update the events
              });

              final Map<String, dynamic> lastEvent = events.last;
              print('Last Event: $lastEvent');
            } else {
              print('No events found in the last group.');
            }
          } else {
            print('Last group does not have an "events" field.');
          }
        } else {
          print('Invalid or empty "data" field in the response.');
        }
      } else {
        print('Failed to fetch group information. Status code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching group information: $error');
    }
  }

  @override
  void initState() {
    super.initState();
    print("initstate");
    print(widget.groupData['groupId']);
    print(widget.groupData['events']);
    // fetchGroupInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(widget.groupData['name']),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xff455A64), Colors.blueGrey],
              begin: Alignment.bottomLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GestureDetector(
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  builder: (BuildContext context) {
                    return SingleChildScrollView(
                      child: Container(
                        padding: EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              backgroundImage:
                              NetworkImage(widget.groupData['imageUrl']),
                              radius: 80,
                              backgroundColor:
                              Colors.grey, // Color if the image is empty
                            ),
                            SizedBox(height: 20),
                            Text(
                              'نام گروه: ${widget.groupData['name']}',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.blueGrey,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 10),
                            Text(
                              'توضیحات: ${widget.groupData['description']}',
                              style: TextStyle(fontSize: 18),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 20),
                            Text(
                              'اعضای گروه:',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.blueGrey,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 10),
                            SizedBox(
                              child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: widget.groupData['members'].length,
                                itemBuilder: (BuildContext context, int index) {
                                  final member =
                                  widget.groupData['members'][index];
                                  return ListTile(
                                    leading: CircleAvatar(
                                      backgroundImage:
                                      member['image'].isNotEmpty
                                          ? NetworkImage(member['image'])
                                          : null,
                                      child: member['image'].isEmpty
                                          ? Icon(Icons.person)
                                          : null,
                                    ),
                                    title: Text(
                                      '${member['firstName']} ${member['lastName']}',
                                      style: TextStyle(fontSize: 16),
                                    ),
                                    subtitle: Text(
                                      '${member['mail']}',
                                      style: TextStyle(fontSize: 14),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
              child: Container(
                padding: EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(15),
                ),
                margin: EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        CircleAvatar(
                          backgroundImage:
                          NetworkImage(widget.groupData['imageUrl']),
                          radius: 80,
                          backgroundColor: Colors.grey,
                        ),
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.blueGrey,
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(3.0),
                            child: CircleAvatar(
                              radius: 20,
                              backgroundColor: Colors.transparent,
                              child: IconButton(
                                iconSize: 25,
                                icon: Icon(Icons.edit),
                                color: Colors.white,
                                onPressed: () {
                                  getImage();
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                  ],
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: Colors.blueGrey.shade200,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'رویدادهای گروه',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 15),
                  // Enhanced design for displaying events using Card
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: widget.groupData['events'].length,
                    itemBuilder: (context, index) {
                      final event = widget.groupData['events'][index];
                      return Card(
                        elevation: 5,
                        margin: EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: InkWell(
                          onTap: () {
                            showEventDetailsDialog(event);
                          },
                          child: Container(
                            padding: EdgeInsets.all(15),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  event['name'],
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.indigo,
                                  ),
                                ),
                                SizedBox(height: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'تاریخ برگزاری : ${Jalali
                                          .fromDateTime(
                                          DateTime.parse(event['when']))
                                          .day} / ${Jalali
                                          .fromDateTime(
                                          DateTime.parse(event['when']))
                                          .month } / ${Jalali
                                          .fromDateTime(
                                          DateTime.parse(event['when']))
                                          .year}',
                                      style: TextStyle(fontSize: 16),
                                    ),
                                    Text(
                                      'ساعت برگزاری : ${DateTime
                                          .parse(event['when'])
                                          .hour}:${DateTime
                                          .parse(event['when'])
                                          .minute}',
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 12),
                                Text(
                                  'توضیحات: ${event['description']}',
                                  style: TextStyle(fontSize: 16),
                                ),
                                // Add more details as needed
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      bottomNavigationBar: widget.isMember ?
      BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) async {
          setState(() {
            _currentIndex = index;
          });
          if (index == 0) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    ChatScreen(groupId: widget.groupData['groupId']),
              ),
            );
          } else if (index == 1) {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    CreateEventForm(groupId: widget.groupData['groupId']),
              ),
            );
            setState(() {
              fetchGroupInfo();
            });
          }
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'مشاهده چت',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: 'اضافه کردن رویداد جدید',
          ),
        ],
      ) :
      SizedBox(
        height: 80,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            primary: Colors.blueGrey.shade100,
            onPrimary: Colors.black,
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20), // button's shape
            ),
          ),

          onPressed: () async {
              joinGroup(widget.groupData['groupId']);
          },
          child: Text('عضویت در گروه'),
        ),
      ),
    );
  }
}