import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:roozdan/features/home/widgets/snackbar.dart';

import '../register/getx/user_info_getx.dart';
import 'group_screen.dart';

class GroupScreen extends StatefulWidget {
  static const routeName = "/GroupScreen";

  @override
  _GroupScreenState createState() => _GroupScreenState();
}

class _GroupScreenState extends State<GroupScreen> {
  String userToken = userDataStorage.userData['token'];
  String userMail = userDataStorage.userData['email'];
  bool isLoading = false;
  List<Map<String, dynamic>> groupData = [];
  String selectedGroupType = 'گروه‌های عمومی';
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    fetchGroupData();
    _searchController = TextEditingController();
    _searchController.addListener(() {
      searchGroups(_searchController.text);
    });
  }


  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool isUserMemberOfGroup(Map<String, dynamic> group) {
    return group['members'].any((member) =>
    member['mail'] == userMail); // Replace with user's email check
  }

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
      } else {
        print('Failed to join group: ${response.statusCode}');
      }
    } catch (error) {
      print('Error joining group: $error');
    }
  }



  Future<void> searchGroups(String query) async {
    setState(() {
      isLoading = true;
    });
    try {
      final url = Uri.parse('https://dev.jalaleto.ir/api/Group/Search?GroupName=$query');
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

  Future<void> fetchGroupData() async {
    setState(() {
      isLoading = true;
    });
    try {
      final url = Uri.parse(
          'https://dev.jalaleto.ir/api/Group/Groups?FilterMyGroups=${selectedGroupType == 'گروه‌های من'}');
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

  Future<void> fetchPopularGroupData() async {
    setState(() {
      isLoading = true;
    });
    try {
      final url = Uri.parse(
          'https://dev.jalaleto.ir/api/Group/PopularGroups?cnt=5');
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
                  padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 25),
                  child: Row(
                    children: [
                      Expanded(
                        child: DropdownButton<String>(
                          dropdownColor: Colors.blueGrey.shade300,
                          iconEnabledColor: Colors.black,
                          value: selectedGroupType,
                          onChanged: (newValue) {
                            setState(() {
                              selectedGroupType = newValue!;
                            });
                            if(selectedGroupType =="گروه های محبوب")
                              fetchPopularGroupData();
                            else
                            fetchGroupData();
                          },
                          items: <String>['گروه‌های عمومی', 'گروه‌های من' , 'گروه های محبوب']
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Container(
                          // decoration: BoxDecoration(
                          //   color: Colors.grey.shade400,
                          //   borderRadius: BorderRadius.circular(10.0),
                          // ),
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.blueGrey.shade100,
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              padding: EdgeInsets.symmetric(horizontal: 12),
                              child: Row(
                                children: [
                                  Icon(Icons.search),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: TextField(
                                      controller: _searchController,
                                      decoration: InputDecoration(
                                        hintText: 'جست و جو...',
                                        border: InputBorder.none,
                                      ),
                                      onChanged: (value) {
                                        if(value.length>2) {
                                          searchGroups(value);
                                        }
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
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
    bool isMember = isUserMemberOfGroup(group);

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
            trailing: isMember
                ? SizedBox.shrink()
                : ElevatedButton(
              onPressed: () {
                joinGroup(group['groupId']);
              },
              child: Text('عضویت'),
            ),
          ),
        ),
      ),
    );
  }
}
