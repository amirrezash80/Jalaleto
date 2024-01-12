import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../register/getx/user_info_getx.dart';
import '../data/messages.dart';

class ChatScreen extends StatefulWidget {
  static const routeName = "/ChatScreen";

  final int groupId;

  ChatScreen({required this.groupId});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final List<ChatMessage> _messages = [];
  String userToken = userDataStorage.userData['token'];

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _getMessages();
  }

  Future<void> _getMessages() async {
    setState(() {
      isLoading = true;
    });

    try {
      final url = Uri.parse(
          'https://dev.jalaleto.ir/api/Message/GetMessages?GroupId=${widget.groupId}');
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $userToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (data.containsKey('data')) {
          final List<dynamic> messages = data['data'] ?? [];
          setState(() {
            _messages.clear();
            _messages.addAll(messages.map((message) {
              return ChatMessage(
                senderName: message['senderName'] ?? '',
                senderImageUrl: message['senderImageUrl'],
                text: message['content'] ?? '',
                sender: message['senderUserId'] ?? '',
                sentTime: DateTime.tryParse(message['sentTime'] ?? '') ??
                    DateTime.now(),
                isCurrentUser: message['areYouSender'],
                messageId: message['messageId'] ?? '',
              );
            }));
          });
        } else {
          print('No messages available.');
        }
      } else {
        print('Failed to fetch messages: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching messages: $error');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _sendMessage(String message) async {
    final requestBody = {
      "message": message,
      "groupId": widget.groupId,
    };

    final url = Uri.parse('https://dev.jalaleto.ir/api/Message/SendMessage');
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $userToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(requestBody),
    );

    if (response.statusCode == 200) {
      _textController.clear();
      _getMessages();
    } else {
      print('Failed to send message: ${response.statusCode}');
    }
  }

  Widget _buildMessage(ChatMessage message) {
    final bool isCurrentUser = message.isCurrentUser;

    Widget avatarWidget = CircleAvatar(
      backgroundImage: NetworkImage(
        message.senderImageUrl ?? 'https://upload.wikimedia.org/wikipedia/commons/thumb/5/59/User-avatar.svg/2048px-User-avatar.svg.png',
      ),
    );

    return Row(
      mainAxisAlignment:
      isCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (!isCurrentUser) avatarWidget,
        Flexible(
          child: Container(
            margin: EdgeInsets.all(8),
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isCurrentUser ? Colors.blue : Colors.grey[200],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message.senderName,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isCurrentUser ? Colors.white : Colors.black,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  message.text,
                  style: TextStyle(
                    color: isCurrentUser ? Colors.white : Colors.black,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '${message.sentTime.hour}:${message.sentTime.minute}',
                  style: TextStyle(
                    fontSize: 10,
                    color: isCurrentUser ? Colors.white70 : Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (isCurrentUser) avatarWidget,
      ],
    );
  }

  Widget _buildChatArea() {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _textController,
              decoration: InputDecoration.collapsed(hintText: 'Type a message'),
              onSubmitted: (value) {
                if (value.isNotEmpty) {
                  _sendMessage(value);
                }
              },
            ),
          ),
          IconButton(
            icon: Icon(Icons.send),
            onPressed: () {
              final message = _textController.text.trim();
              if (message.isNotEmpty) {
                _sendMessage(message);
              }
            },
          ),
        ],
      ),
    );
  }


  Future<void> _getMessagesOnRefresh() async {
    await _getMessages();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: Text('چت')),
        body: RefreshIndicator(
          onRefresh: _getMessagesOnRefresh,
          child: Column(
            children: [
              Expanded(
                child: isLoading
                    ? Center(child: CircularProgressIndicator())
                    : ListView.builder(
                        itemCount: _messages.length,
                        itemBuilder: (_, index) =>
                            _buildMessage(_messages[index]),
                      ),
              ),
              SizedBox(height: 10),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: _buildChatArea(),
              ),
              SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
