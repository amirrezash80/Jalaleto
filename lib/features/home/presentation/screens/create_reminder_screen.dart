import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:persian_datetime_picker/persian_datetime_picker.dart';
import 'package:roozdan/features/register/getx/user_info_getx.dart';

import '../../data/events.dart';

class CreateReminderForm extends StatefulWidget {
  static const String routeName = "/CreateEventForm";
  final Event? myEvent;

  CreateReminderForm({super.key, required this.myEvent});

  @override
  _CreateReminderFormState createState() => _CreateReminderFormState();
}

class _CreateReminderFormState extends State<CreateReminderForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String userToken = userDataStorage.userData['token'];
  late int? reminderId;
  late String title;
  late DateTime dateTime;
  late int daysBeforeToRemind;
  late bool remindByEmail;
  late int repeatInterval;
  late int priorityLevel;
  late String notes;

  @override
  void initState() {
    super.initState();
    getEvent();
    print(widget.myEvent?.reminderId);
  }

  void getEvent() {
    if (widget.myEvent != null) {
      print("event ${widget.myEvent!.title}");
      final initialEvent = widget.myEvent!;
      reminderId = initialEvent.reminderId;
      title = initialEvent.title;
      dateTime = initialEvent.dateTime;
      daysBeforeToRemind = initialEvent.daysBeforeToRemind;
      remindByEmail = initialEvent.remindByEmail;
      repeatInterval = initialEvent.repeatInterval;
      priorityLevel = initialEvent.priorityLevel;
      notes = initialEvent.notes;
    } else {
      reminderId = null;
      title = '';
      dateTime = DateTime.now();
      daysBeforeToRemind = 0;
      remindByEmail = false;
      repeatInterval = 1;
      priorityLevel = 0;
      notes = '';
    }
  }

  String gregorianToJalali(DateTime gregorianDate) {
    final jalaliDate = Jalali.fromDateTime(gregorianDate);
    return '${jalaliDate.year}/${jalaliDate.month}/${jalaliDate.day}';
  }

  DateTime jalaliWithTimeToGregorian(Jalali jalaliDate, TimeOfDay timeOfDay) {
    print(timeOfDay.hour);
    print(timeOfDay.minute);
    final gregorianDate = jalaliDate.toGregorian();
    print(gregorianDate.day);

    return DateTime(
      gregorianDate.year,
      gregorianDate.month,
      gregorianDate.day,
      timeOfDay.hour,
      timeOfDay.minute,
    );
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final gregorianDateTime = jalaliWithTimeToGregorian(
        Jalali.fromDateTime(dateTime),
        TimeOfDay.fromDateTime(dateTime),
      );
      final formattedGregorianDateTime = gregorianDateTime.toIso8601String();
      print("gregorianDateTime ${gregorianDateTime.hour}");
      print("gregorianDateTime ${gregorianDateTime.minute}");
      print("reminderId ${reminderId ?? null}");

      final requestBody = {
        "reminderId": reminderId ?? null,
        "title": title,
        "dateTime": formattedGregorianDateTime,
        "daysBeforeToRemind": daysBeforeToRemind,
        "remindByEmail": remindByEmail,
        "repeatInterval": repeatInterval,
        "priorityLevel": priorityLevel,
        "notes": notes,
      };

      try {
        final url = Uri.parse('https://dev.jalaleto.ir/api/Reminder/Create');
        final response = await http.post(
          url,
          headers: {
            'Authorization': 'Bearer $userToken',
            'Content-Type': 'application/json',
            'accept': 'application/json',
          },
          body: jsonEncode(requestBody),
        );

        if (response.statusCode == 200) {
          final responseBody = jsonDecode(response.body);
          print(responseBody);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("رویداد شما ثبت شد."),
            ),
          );
          Navigator.pop(context);
        } else {
          print('Request failed with status: ${response.statusCode}');
          print('Response body: ${response.body}');
        }
      } catch (e) {
        print('Error: $e');
      }
    }
  }

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
                  initialValue: title,
                  decoration: InputDecoration(
                    labelText: 'عنوان رویداد',
                    border: OutlineInputBorder(),
                  ),
                  style: TextStyle(fontSize: 18.0),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'لطفا یک عنوان وارد نمایید';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    title = value!;
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
                        initialTime: TimeOfDay.fromDateTime(dateTime),
                      );

                      if (pickedTime != null) {
                        final combinedDateTime = jalaliWithTimeToGregorian(
                          pickedDate,
                          pickedTime,
                        );
                        // print("pickedTime.hour");
                        print(pickedTime.hour);
                        // print("pickedTime.minute");
                        print(pickedTime.minute);

                        setState(() {
                          dateTime = combinedDateTime;
                        });
                      }
                    }
                  },
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'تاریخ و زمان',
                      border: OutlineInputBorder(),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                            '${DateFormat('yyyy-MM-dd   kk:mm').format(dateTime)}'),
                        Icon(Icons.calendar_today),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20),
                TextFormField(
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Days before reminder',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    daysBeforeToRemind = int.tryParse(value) ?? 0;
                  },
                ),
                SizedBox(height: 20),
                SwitchListTile(
                  title: Text('فعال سازی یادآوری'),
                  value: remindByEmail,
                  onChanged: (newValue) {
                    setState(() {
                      remindByEmail = newValue;
                    });
                  },
                ),
                SizedBox(height: 20),
                DropdownButtonFormField<int>(
                  value: repeatInterval,
                  items: [
                    DropdownMenuItem<int>(
                      value: 1,
                      child: Text('روزانه'),
                    ),
                    DropdownMenuItem<int>(
                      value: 7,
                      child: Text('هفتگی'),
                    ),
                    DropdownMenuItem<int>(
                      value: 30,
                      child: Text('ماهانه'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      repeatInterval = value!;
                    });
                  },
                  decoration: InputDecoration(
                    labelText: 'تکرار',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 20),
                Slider(
                  value: priorityLevel.toDouble(),
                  onChanged: (newValue) {
                    setState(() {
                      priorityLevel = newValue.round();
                    });
                  },
                  min: 0,
                  max: 2,
                  divisions: 2,
                  label: 'اولویت: $priorityLevel',
                ),
                SizedBox(height: 20),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'توضیحات',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    notes = value;
                  },
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
