import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../../../register/getx/user_info_getx.dart';

class CreateGroupDialog extends StatefulWidget {
  @override
  _CreateGroupDialogState createState() => _CreateGroupDialogState();
}

class _CreateGroupDialogState extends State<CreateGroupDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController _groupNameController = TextEditingController();
  TextEditingController _participantController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  List<String> _participants = [];
  String userToken = userDataStorage.userData['token'];
  File? _image;

  @override
  void dispose() {
    _groupNameController.dispose();
    _participantController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
  Future<void> _getImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'ایجاد گروه جدید',
        textDirection: TextDirection.rtl,
      ),
      content: SingleChildScrollView(
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: _getImage,
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    child: Center(
                      child: CircleAvatar(
                        backgroundColor: Colors.blueGrey[100],
                        radius: 60,
                        child: _image != null
                            ? ClipRRect(
                          borderRadius: BorderRadius.circular(60),
                          child: Image.file(
                            _image!,
                            width: 120,
                            height: 120,
                            fit: BoxFit.cover,
                          ),
                        )
                            : Icon(
                          Icons.group,
                          size: 40,
                          color: Colors.blueGrey[700],
                        ),
                      ),
                    ),
                  ),
                ),
                TextFormField(
                  controller: _groupNameController,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'لطفا نام گروه را انتخاب کنید';
                    }
                    return null;
                  },
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.right,
                  decoration: InputDecoration(
                    labelText: 'نام گروه',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
                  ),
                ),
                SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _participantController,
                        textDirection: TextDirection.rtl,
                        textAlign: TextAlign.right,
                        decoration: InputDecoration(
                          labelText: 'اضافه کردن عضو',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
                        ),
                        onFieldSubmitted: _addParticipant,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.add),
                      onPressed: () {
                        _addParticipant(_participantController.text);
                      },
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Wrap(
                  spacing: 8.0,
                  children: _buildParticipantChips(),
                ),
                SizedBox(height: 12),
                TextFormField(
                  controller: _descriptionController,
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.right,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'توضیحات',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('لغو'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        ElevatedButton(
          child: const Text('ایجاد'),
          onPressed: _createGroup,
        ),
      ],
    );
  }

  void _addParticipant(String value) {
    if (value.isNotEmpty) {
      setState(() {
        _participants.add(value);
        _participantController.clear();
      });
    }
  }

  List<Widget> _buildParticipantChips() {
    return _participants.map((participant) {
      return Chip(
        label: Text(participant),
        backgroundColor: Colors.blueGrey[100],
        deleteIconColor: Colors.blueGrey[700],
        onDeleted: () {
          _removeParticipant(participant);
        },
      );
    }).toList();
  }

  void _removeParticipant(String participant) {
    setState(() {
      _participants.remove(participant);
    });
  }

  Future<void> _createGroup() async {
    if (_formKey.currentState!.validate()) {
      final groupName = _groupNameController.text;
      final description = _descriptionController.text;
      final url = Uri.parse('https://dev.jalaleto.ir/api/Group/Create');

      var request = http.MultipartRequest('POST', url)
        ..headers.addAll({
          'Authorization': 'Bearer $userToken',
          'accept': 'text/plain',
        });

      request.fields['Name'] = groupName;
      request.fields['Description'] = description;

      if (_image != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'Image',
          _image!.path,
        ));
      } else {
        request.fields['Image'] = ''; // If no image is selected
      }

      request.fields['InvitedEmails'] = _participants.join(',');

      try {
        final response = await request.send();

        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("گروه شما با موفقیت ایجاد شد."),
            ),
          );
        } else {
          print('Request failed with status: ${response.statusCode}');
        }
      } catch (e) {
        print('Error: $e');
      }

      Navigator.of(context).pop();
    }
  }
}

