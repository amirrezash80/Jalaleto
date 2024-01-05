import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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

  @override
  void dispose() {
    _groupNameController.dispose();
    _participantController.dispose();
    _descriptionController.dispose();
    super.dispose();
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
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  child: Center(
                    child: CircleAvatar(
                      backgroundColor: Colors.blueGrey[100],
                      radius: 60,
                      child: Icon(
                        Icons.group,
                        size: 40,
                        color: Colors.blueGrey[700],
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
      request.fields['Image'] = '';
      request.fields['InvitedEmails'] = _participants[0];

      try {
        final url = Uri.parse('https://dev.jalaleto.ir/api/Group/Create');
        final response = await request.send();

        // final response = await http.post(
        //   url,
        //   headers: {
        //     'Authorization': 'Bearer $userToken',
        //     'accept': 'text/plain',
        //   },
        //   body: jsonEncode(requestBody),
        // );

        if (response.statusCode == 200) {
          // final responseBody = jsonDecode(response.body);
          // print(responseBody);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("گروه شما با موفقیت ایجاد شد."),
            ),
          );
        } else {
          print('Request failed with status: ${response.statusCode}');
          // print('Response body: ${response.body}');
        }
      } catch (e) {
        print('Error: $e');
      }

      Navigator.of(context).pop();
    }
  }
}
