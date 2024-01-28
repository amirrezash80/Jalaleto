import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:persian_datetime_picker/persian_datetime_picker.dart';

import '../register/getx/user_info_getx.dart';

class CreateEventForm extends StatefulWidget {
  static const String routeName = "/CreateEventForm";
  final int groupId;

  const CreateEventForm({super.key, required this.groupId});

  @override
  _CreateEventFormState createState() => _CreateEventFormState();
}

class _CreateEventFormState extends State<CreateEventForm> {
  String userToken = userDataStorage.userData['token'];
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  DateTime _dateTime = DateTime.now();
  String _name = '';
  String _description = '';
  String _location = '';
  int _memberLimit = 0;
  List<String> _tags = [];

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final url = Uri.parse('https://dev.jalaleto.ir/api/Event/Create');
      final Map<String, dynamic> eventData = {
        "groupId": widget.groupId,
        "name": _name,
        "description": _description,
        "when": _dateTime.toIso8601String(),
        "location": _location,
        "memberLimit": _memberLimit,
        "tag": _tags,
      };

      try {
        final response = await http.post(
          url,
          headers: <String, String>{
            'Authorization': 'Bearer $userToken',
            'Content-Type': 'application/json',
            'accept': 'application/json',
          },
          body: jsonEncode(eventData),
        );

        if (response.statusCode == 200) {
          print('اطلاعات با موفقیت ارسال شد.');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('اطلاعات با موفقیت ارسال شد.'),
            ),
          );

          Navigator.pop(context, true); // Pass a value to indicate success
        } else {
          print('خطا در ارسال درخواست: ${response.statusCode}');
          print('بدنه پاسخ: ${response.body}');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('مشکلی در ارسال اطلاعات به وجود آمد.'),
            ),
          );
        }
      } catch (e) {
        print('خطا: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('مشکلی در ارسال اطلاعات به وجود آمد.'),
          ),
        );
      }
    }
  }

  void _addTag(String value) {
    if (value.isNotEmpty) {
      setState(() {
        _tags.add(value);
        _tagController.clear();
      });
    }
  }

  List<Widget> _buildTagChips() {
    return _tags.map((tag) {
      return Chip(
        label: Text(tag),
        backgroundColor: Colors.blueGrey[100],
        deleteIconColor: Colors.blueGrey[700],
        onDeleted: () {
          _removeTag(tag);
        },
      );
    }).toList();
  }

  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
    });
  }

  TextEditingController _tagController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ایجاد رویداد جدید'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  decoration: InputDecoration(labelText: 'عنوان رویداد'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'لطفاً یک عنوان وارد نمایید';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _name = value!;
                  },
                ),
                SizedBox(height: 20),
                TextFormField(
                  decoration: InputDecoration(labelText: 'توضیحات'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'لطفاً توضیحات را وارد کنید';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _description = value!;
                  },
                ),
                SizedBox(height: 20),
                InkWell(
                  onTap: () async {
                    final pickedDate = await showPersianDatePicker(
                      context: context,
                      initialDate: Jalali.now(),
                      firstDate: Jalali(1300, 1),
                      lastDate: Jalali(1404, 12),
                    );
                    if (pickedDate != null) {
                      final pickedTime = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.fromDateTime(_dateTime),
                      );
                      if (pickedTime != null) {
                        final combinedDateTime = DateTime(
                          pickedDate.year,
                          pickedDate.month,
                          pickedDate.day,
                          pickedTime.hour,
                          pickedTime.minute,
                        );
                        setState(() {
                          _dateTime = combinedDateTime;
                        });
                      }
                    }
                  },
                  child: InputDecorator(
                    decoration: InputDecoration(labelText: 'تاریخ و زمان'),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('${DateFormat('yyyy-MM-dd   kk:mm').format(_dateTime)}'),
                        Icon(Icons.calendar_today),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20),
                TextFormField(
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: 'حداکثر تعداد اعضا'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'لطفاً تعداد اعضا را وارد کنید';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _memberLimit = int.parse(value!);
                  },
                ),
                SizedBox(height: 20),
                TextFormField(
                  decoration: InputDecoration(labelText: 'مکان'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'لطفاً مکان را وارد کنید';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _location = value!;
                  },
                ),
                SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _tagController,
                        textAlign: TextAlign.right,
                        decoration: InputDecoration(
                          labelText: 'اضافه کردن برچسب',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
                        ),
                        onFieldSubmitted: _addTag,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.add),
                      onPressed: () {
                        _addTag(_tagController.text);
                      },
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Wrap(
                  children: _buildTagChips(),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _submitForm,
                  child: Text('ذخیره'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
