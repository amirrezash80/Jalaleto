import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:signalr_pure/signalr_pure.dart';

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
  ScrollController _scrollController = ScrollController();
  late HubConnection _hubConnection;
  late String userId ;

  // var timer;

  String getUserIdFromToken(String token) {
    Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
    print(decodedToken);
    return decodedToken['UserId'] ?? '';
  }

  @override
  void initState() {
    super.initState();
    _getMessages();
     userId = getUserIdFromToken(userToken);
    _scrollController = ScrollController();
    _initSignalR();
  }

  void dispose() {
    // timer.cancel();
    super.dispose();
  }

  Future<void> _getMessages() async {
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

      if (mounted) {
        if (response.statusCode == 200) {
          final Map<String, dynamic> data = jsonDecode(response.body);
          if (data.containsKey('data')) {
            final List<dynamic> messages = data['data'] ?? [];
            setState(() {
              _messages.clear();
              _messages.addAll(messages.map((message) {
                return ChatMessage(
                  senderName: message['senderName'] ?? '',
                  senderImageUrl: message['senderImageUrl'] ??
                      'https://upload.wikimedia.org/wikipedia/commons/thumb/5/59/User-avatar.svg/2048px-User-avatar.svg.png',
                  text: message['content'] ?? '',
                  sender: message['senderUserId'] ?? '',
                  sentTime: DateTime.tryParse(message['sentTime'] ?? '') ??
                      DateTime.now(),
                  isCurrentUser: message['areYouSender'],
                  messageId: message['messageId'] ?? '',
                );
              }));
            });
            _initSignalR();
            WidgetsBinding.instance!.addPostFrameCallback((_) {
              _scrollController
                  .jumpTo(_scrollController.position.maxScrollExtent);
            });
          } else {
            print('No messages available.');
          }
        } else {
          print('Failed to fetch messages: ${response.statusCode}');
        }
      }
    } catch (error) {
      if (mounted) {
        print('Error fetching messages: $error');
      }
    }
  }

  void _initSignalR() async {
    try {
      final builder = HubConnectionBuilder()
        ..url = 'https://dev.jalaleto.ir/MessageHub'
        ..logLevel = LogLevel.information
        ..reconnect = true;

      _hubConnection = builder.build();

      _hubConnection.onclose((error) {
        print("Connection Closed: $error");
      });

      _hubConnection.on("NewMessage", _handleNewMessage);

      // Start the connection
      await _hubConnection.startAsync().then((_) async {
        if (_hubConnection.state == HubConnectionState.connected) {
          print("Connection established");

          await _hubConnection
              .invokeAsync("joinGroupHub", [widget.groupId])
              .catchError((error) {
            print("Error joining group: $error");
          });
        } else {
          print("Connection is not in the 'Connected' state.");
        }
      });
    } catch (error) {
      print("Error initializing SignalR: $error");
    }
  }

  void _handleNewMessage(List<dynamic>? parameters) {
    if (parameters != null && parameters.isNotEmpty) {
      final dynamic data = parameters.first;
      setState(() {
        print(userId == data['senderUserId']);
        print(data['areYouSender']);
        _messages.add(
          ChatMessage(
            senderName: data['senderName'] ?? '',
            senderImageUrl: data['senderImageUrl'],
            text: data['content'] ?? '',
            sender: data['senderUserId'] ?? '',
            sentTime:
                DateTime.tryParse(data['sentTime'] ?? '') ?? DateTime.now(),
            isCurrentUser: userId == data['userId'],
            messageId: data['messageId'] ?? '',
          ),
        );
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
      backgroundImage: NetworkImage(message.senderImageUrl),
    );

    return Row(
      mainAxisAlignment:
          isCurrentUser ? MainAxisAlignment.start : MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (isCurrentUser) avatarWidget,
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
        if (!isCurrentUser) avatarWidget,
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
              decoration: InputDecoration.collapsed(
                  hintText: 'پیام خود را بنویسید ...'),
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
        appBar: AppBar(
          centerTitle: true,
          title: Text("چت"),
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xff455A64), Colors.blueGrey],
                begin: Alignment.bottomLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
        ),
        body: RefreshIndicator(
          onRefresh: _getMessagesOnRefresh,
          child: Column(
            children: [
              Expanded(
                child: isLoading
                    ? Center(child: CircularProgressIndicator())
                    : ListView.builder(
                        controller: _scrollController,
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
