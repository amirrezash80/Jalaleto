import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shamsi_date/shamsi_date.dart';

import '../chat/presentation/chat_screen.dart';
import '../home/widgets/snackbar.dart';
import '../register/getx/user_info_getx.dart';
import 'create_event.dart';

class GroupDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> groupData;

  GroupDetailsScreen({required this.groupData});

  @override
  State<GroupDetailsScreen> createState() => _GroupDetailsScreenState();
}

class _GroupDetailsScreenState extends State<GroupDetailsScreen> {
  int _currentIndex = 1;

  late File? _image; // To store the selected image file

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
            'https://dev.jalaleto.ir/api/Group/UploadImage?groupId=${widget.groupData['groupId']}'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.groupData['name']),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blueGrey, Colors.indigo],
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
                                      '${member['userName']} - ${member['mail']}',
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
                color: Colors.blue.shade200,
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
                            // Handle event tap if needed
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
                                      'تاریخ برگزاری : ${Jalali.fromDateTime(DateTime.parse(event['when'])).day} / ${Jalali.fromDateTime(DateTime.parse(event['when'])).month } / ${Jalali.fromDateTime(DateTime.parse(event['when'])).year}',
                                      style: TextStyle(fontSize: 16),
                                    ),
                                    Text(
                                      'ساعت برگزاری : ${DateTime.parse(event['when']).hour}:${DateTime.parse(event['when']).minute}',
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

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
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
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    CreateEventForm(groupId: widget.groupData['groupId']),
              ),
            );
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
      ),
    );
  }
}