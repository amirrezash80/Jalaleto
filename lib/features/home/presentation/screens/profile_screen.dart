import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:persian_datetime_picker/persian_datetime_picker.dart';

import '../../../register/getx/user_info_getx.dart';
import '../../../register/login/presentation/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  static const String routeName = "/ProfileScreen";

  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late String userToken;
  TextEditingController usernameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController birthdayController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController lastNameContoller = TextEditingController();
  bool _isLoading = false;
  late ImagePicker _picker;
  String? _pickedImagePath;

  @override
  void initState() {
    super.initState();
    _picker = ImagePicker();
    getUserToken();
  }

  Future<void> getUserToken() async {
    final userData = userDataStorage.userData;
    if (userData.containsKey('token')) {
      setState(() {
        userToken = userData['token'];
      });
      await fetchUserProfile();
    }
  }

  Future<void> fetchUserProfile() async {
    String url = 'https://dev.jalaleto.ir/api/User/ProfileInfo';
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $userToken',
          'Accept': 'text/plain',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> userProfile = json.decode(response.body);
        setState(() {
          usernameController.text = userProfile['userName'] ?? '';
          emailController.text = userProfile['email'] ?? '';
          birthdayController.text = userProfile['birthday'] ?? '';
          nameController.text = userProfile['firstName'] ?? '';
          lastNameContoller.text = userProfile['lastName'] ?? '';
        });
      } else {
        print('Request failed with status: ${response.statusCode}');
        print("response = ${response.body}");
      }
    } catch (error) {
      print('Error: $error');
    }
  }

  Future<String> pickAndEncodeImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      List<int> imageBytes = await pickedFile.readAsBytes();
      String base64Image = base64Encode(imageBytes);
      return base64Image;
    } else {
      return '';
    }
  }

  Future<void> updateProfile() async {
    setState(() {
      _isLoading = true;
    });

    print(_pickedImagePath);
    // if (_pickedImagePath != null) {
    //   binaryImage = await pickAndEncodeImage();
    // }

    Map<String, dynamic> updatedProfile = {
      "FirstName": nameController.text,
      "LastName": lastNameContoller.text,
      "UserName": usernameController.text,
      "Birthday": convertDateFormat(birthdayController.text),
      "Password": "123123123",
      "image": _pickedImagePath ?? '',
    };
    updatedProfile.forEach((key, value) {print(value);});
    String url = 'https://dev.jalaleto.ir/api/User/EditProfile';
    // try {
    //   final response = await http.post(
    //     Uri.parse(url),
    //     headers: {
    //       'Authorization': 'Bearer $userToken',
    //       'Accept': 'text/plain',
    //       'Content-Type': 'application/json',
    //     },
    //     body: json.encode(updatedProfile),
    //   );
    //
    //   if (response.statusCode == 200) {
    //     Map<String, dynamic> responseBody = json.decode(response.body);
    //     if (responseBody['success']) {
    //       ScaffoldMessenger.of(context).showSnackBar(
    //         const SnackBar(
    //           content: Directionality(
    //             textDirection: TextDirection.rtl,
    //             child: Text("اطلاعات شما به‌روزرسانی شد."),
    //           ),
    //         ),
    //       );
    //       setState(() {
    //         _isLoading = false;
    //       });
    //     } else {
    //       String error = ('Update failed: ${responseBody['message']}');
    //       ScaffoldMessenger.of(context).showSnackBar(
    //         SnackBar(
    //           content: Directionality(
    //             textDirection: TextDirection.rtl,
    //             child: Text(error),
    //           ),
    //         ),
    //       );
    //       setState(() {
    //         _isLoading = false;
    //       });
    //     }
    //   } else {
    //     ScaffoldMessenger.of(context).showSnackBar(
    //       const SnackBar(
    //         content: Directionality(
    //           textDirection: TextDirection.rtl,
    //           child: Text("مشکلی در انجام فرایند پیش آمده"),
    //         ),
    //       ),
    //     );
    //     setState(() {
    //       _isLoading = false;
    //     });
    //     print('Request failed with status: ${response.statusCode}');
    //     print("response = ${response.body}");
    //   }
    // } catch (error) {
    //   print('Error: $error');
    // }
  }

  String convertDateFormat(String originalDate) {
    List<String> dateComponents = originalDate.split('/');
    if (dateComponents.length == 3) {
      int year = int.parse(dateComponents[0]);
      int month = int.parse(dateComponents[1]);
      int day = int.parse(dateComponents[2]);
      String formattedDate =
          '$year-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
      return formattedDate;
    }
    return originalDate;
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _pickedImagePath = pickedFile.path;
      });
    }
  }

  Future<void> _showConfirmationDialog(
      String action, VoidCallback onConfirmed) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            title: const Text('تایید عملیات'),
            content: const SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text('آیا از انجام این کار اطمینان دارید؟'),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('خیر'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: const Text('بله'),
                onPressed: () {
                  onConfirmed();
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            centerTitle: true,
            backgroundColor: Colors.teal,
            expandedHeight: size.height * 0.3,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'حساب کاربری',
                style: TextStyle(color: Colors.white),
              ),
              centerTitle: true,
              background: Stack(
                children: [
                  Container(
                    width: size.width,
                    height: size.height,
                    child: _pickedImagePath != null
                        ? Image.file(
                            File(_pickedImagePath!),
                            fit: BoxFit.fill,
                          )
                        : Image.asset(
                            "assets/watercolor.png",
                            fit: BoxFit.fill,
                          ),
                  ),
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      alignment: Alignment.center,
                      child: CircleAvatar(
                        radius: size.height * 0.1,
                        backgroundImage: _pickedImagePath != null
                            ? FileImage(File(_pickedImagePath!))
                            : const AssetImage("assets/Jalalito.png")
                                as ImageProvider,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Directionality(
            textDirection: TextDirection.rtl,
            child: SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: 'نام'),
                    ),
                    TextField(
                      controller: lastNameContoller,
                      decoration:
                          const InputDecoration(labelText: 'نام خانوادگی'),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: usernameController,
                      decoration:
                          const InputDecoration(labelText: 'نام کاربری'),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: emailController,
                      enabled: false,
                      decoration: const InputDecoration(labelText: 'ایمیل'),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: birthdayController,
                      decoration: InputDecoration(
                        labelText: 'تاریخ تولد',
                        suffixIcon: InkWell(
                          onTap: () async {
                            Jalali? selectedDate = await showPersianDatePicker(
                              context: context,
                              initialDate: Jalali.now(),
                              firstDate: Jalali(1300, 1),
                              lastDate: Jalali(1404, 12),
                            );

                            if (selectedDate != null) {
                              setState(() {
                                birthdayController.text =
                                    "${selectedDate.year}/${selectedDate.month}/${selectedDate.day}";
                              });
                            }
                          },
                          child: Icon(Icons.calendar_today),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: () {
                        _showConfirmationDialog(
                          'ذخیره تغییرات',
                          () {
                            updateProfile();
                          },
                        );
                      },
                      child: _isLoading
                          ? CircularProgressIndicator()
                          : const Text("ذخیره تغییرات"),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          onPressed: () {
            _showConfirmationDialog(
              'خروج از حساب',
              () {
                Future.delayed(const Duration(milliseconds: 500), () {
                  Navigator.pushNamedAndRemoveUntil(
                      context, LoginScreen.routeName, ModalRoute.withName('/'));
                });
              },
            );
          },
          child: const Text(
            "خروج از حساب",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
