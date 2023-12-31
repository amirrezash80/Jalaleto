import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../chat/presentation/chat_screen.dart';
import '../register/getx/user_info_getx.dart';
import '../home/widgets/snackbar.dart';
import '../home/presentation/screens/create_event_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:io';

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
        Uri.parse('https://dev.jalaleto.ir/api/Group/UploadImage?groupId=${widget.groupData['groupId']}'),
      );
      request.headers['Authorization'] = 'Bearer ${userDataStorage.userData['token']}';
      request.files.add(await http.MultipartFile.fromPath('image', _image!.path));

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
                        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 40),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              backgroundImage: NetworkImage(widget.groupData['imageUrl']),
                              radius: 50,
                              backgroundColor: Colors.grey, // Color if the image is empty
                            ),
                            SizedBox(height: 20),
                            Text(
                              'نام گروه: ${widget.groupData['name']}',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 10),
                            Text(
                              'توضیحات: ${widget.groupData['description']}',
                              style: TextStyle(fontSize: 16),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 20),
                            Text(
                              'اعضای گروه:',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 10),
                            SizedBox(
                              child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: widget.groupData['members'].length,
                                itemBuilder: (BuildContext context, int index) {
                                  final member = widget.groupData['members'][index];
                                  return ListTile(
                                    leading: CircleAvatar(
                                      backgroundImage: member['image'].isNotEmpty
                                          ? NetworkImage(member['image'])
                                          : null,
                                      child: member['image'].isEmpty ? Icon(Icons.person) : null,
                                    ),
                                    title: Text('${member['firstName']} ${member['lastName']}'),
                                    subtitle: Text('${member['userName']} - ${member['mail']}'),
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
                color: Colors.grey.shade300,
                child: Center(
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        backgroundImage: NetworkImage(widget.groupData['imageUrl']),
                        radius: 100,
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
                            radius: 17,
                            backgroundColor: Colors.transparent,
                            child: IconButton(
                              iconSize: 20,
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
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.all(20.0),
              color: Colors.blue.shade200,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'رویدادهای گروه',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
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
                builder: (context) => ChatScreen(groupId: widget.groupData['groupId']),
              ),
            );
          } else if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CreateEventForm(myEvent: null,),
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
