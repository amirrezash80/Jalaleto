import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../../chat/presentation/chat_screen.dart';
import '../../../register/getx/user_info_getx.dart';
import 'group_screen.dart';

class GroupScreen extends StatefulWidget {
  static const routeName = "/GroupScreen";

  @override
  _GroupScreenState createState() => _GroupScreenState();
}

class _GroupScreenState extends State<GroupScreen> {
  String userToken = userDataStorage.userData['token'];
  bool isLoading = false;
  List<Map<String, dynamic>> groupData = [];
  String selectedGroupType = 'گروه‌های عمومی';

  @override
  void initState() {
    super.initState();
    fetchGroupData();
  }

  Future<void> fetchGroupData() async {
    setState(() {
      isLoading = true;
    });
    try {
      final url =
      Uri.parse('https://dev.jalaleto.ir/api/Group/Groups?FilterMyGroups=${selectedGroupType == 'گروه‌های من'}');
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $userToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        setState(() {
          groupData = List<Map<String, dynamic>>.from(data['data'] ?? []);
          isLoading = false;
        });
      } else {
        print('Failed to fetch groups: ${response.statusCode}');
        setState(() {
          isLoading = false;
        });
      }
    } catch (error) {
      print('Error: $error');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.grey.shade200, Colors.blueGrey.shade300],
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0 , horizontal: 25),
                  child: DropdownButton<String>(
                    dropdownColor: Colors.blueGrey.shade300,
                    iconEnabledColor: Colors.black,
                    value: selectedGroupType,
                    onChanged: (newValue) {
                      setState(() {
                        selectedGroupType = newValue!;
                      });
                      fetchGroupData();
                    },
                    items: <String>['گروه‌های عمومی', 'گروه‌های من'].map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ),
                Expanded(
                  child: isLoading
                      ? Center(child: CircularProgressIndicator())
                      : groupData.isEmpty
                      ? Center(child: Text('هیچ گروهی موجود نیست'))
                      : ListView.separated(
                    itemCount: groupData.length,
                    separatorBuilder: (context, index) => Divider(),
                    itemBuilder: (context, index) {
                      final group = groupData[index];
                      return buildGroupItem(group);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildGroupItem(Map<String, dynamic> group) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => GroupDetailsScreen(groupData: group),
            ),
          );
        },
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: ListTile(
            leading: group['imageUrl'].isEmpty
                ? CircleAvatar(
              child: Icon(Icons.group),
            )
                : CircleAvatar(
              backgroundImage: NetworkImage(group['imageUrl']),
            ),
            title: Text(
              group['name'],
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(group['description']),
            trailing: Icon(Icons.arrow_forward_ios),
          ),
        ),
      ),
    );
  }
}