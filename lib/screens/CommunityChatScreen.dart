import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class CommunityChatScreen extends StatefulWidget {
  @override
  _CommunityChatScreenState createState() => _CommunityChatScreenState();
}

class _CommunityChatScreenState extends State<CommunityChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _messageFocusNode = FocusNode();
  List<dynamic> messages = [];
  bool _isLoading = true;
  String? currentUserEmail;
  String? firstName;
  String? lastName;
  Map<String, String> _timestampCache = {};

  @override
  void initState() {
    super.initState();
    _initializeUser();

    _messageController.addListener(() {
      if (_messageController.text.length > 500) {
        debugPrint(
            'Long input message detected: ${_messageController.text.length} characters');
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _messageFocusNode.dispose();
    super.dispose();
  }

  Future<void> _initializeUser() async {
    final prefs = await SharedPreferences.getInstance();
    currentUserEmail = prefs.getString('email');
    firstName = prefs.getString('firstName');
    lastName = prefs.getString('lastName');
    await fetchMessages();
  }

  Future<void> fetchMessages() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) return;

    final url = Uri.parse('https://momshood.runasp.net/api/Messages');
    final headers = {
      'Authorization': 'Bearer $token',
      'Cache-Control': 'no-cache',
    };

    try {
      final response = await http.get(url, headers: headers);
      debugPrint(
          'Fetch Messages Response: Status ${response.statusCode}, Body: ${response.body}');
      if (response.statusCode == 200) {
        final List<dynamic> fetchedMessages = json.decode(response.body);
        List<dynamic> validMessages = [];
        for (var message in fetchedMessages) {
          if (message['text'] == null ||
              message['timestamp'] == null ||
              message['user'] == null) {
            debugPrint('Invalid message skipped: $message');
            continue;
          }
          if ((message['text'] as String).length > 500) {
            debugPrint(
                'Long message received: ${message['text'].length} characters');
          }
          validMessages.add(message);
        }
        validMessages.sort((a, b) => DateTime.parse(a['timestamp'])
            .compareTo(DateTime.parse(b['timestamp'])));
        if (mounted && validMessages.isNotEmpty) {
          setState(() {
            messages = validMessages;
            _isLoading = false;
          });
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_scrollController.hasClients) {
              _scrollController.animateTo(
                _scrollController.position.maxScrollExtent,
                duration: Duration(milliseconds: 300),
                curve: Curves.easeOut,
              );
            }
          });
        } else {
          setState(() {
            messages = validMessages;
            _isLoading = false;
          });
        }
      } else {
        debugPrint('Failed to fetch messages: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching messages: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading messages')),
        );
      }
    }
  }

  Future<void> sendMessage() async {
    String messageText = _messageController.text.trim();
    if (messageText.isEmpty) return;

    if (messageText.length > 1000) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Message too long (max 1000 characters)')),
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) return;

    final url = Uri.parse('https://momshood.runasp.net/api/Messages');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
      'Cache-Control': 'no-cache',
    };
    final body = json.encode({
      'text': messageText,
      'user': {'fullName': '$firstName $lastName'},
    });

    try {
      debugPrint('Sending message: $messageText');
      final response = await http.post(url, headers: headers, body: body);
      debugPrint(
          'Send Message Response: Status ${response.statusCode}, Body: ${response.body}');
      if (response.statusCode == 201) {
        _messageController.clear();
        _messageFocusNode.requestFocus();
        await fetchMessages();
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        });
      } else {
        debugPrint('Failed to send message: ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send message')),
        );
      }
    } catch (e) {
      debugPrint('Error sending message: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error sending message')),
      );
    }
  }

  Future<void> editMessage(String messageId, String newText) async {
    if (newText.trim().isEmpty) return;

    if (newText.length > 1000) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Edited message too long (max 1000 characters)')),
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) return;

    final url =
        Uri.parse('https://momshood.runasp.net/api/Messages/$messageId');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
      'Cache-Control': 'no-cache',
    };
    final body = json.encode({
      'text': newText,
      'isEdited': true,
    });

    try {
      debugPrint('Editing message $messageId: $newText');
      final response = await http.put(url, headers: headers, body: body);
      debugPrint(
          'Edit Message Response: Status ${response.statusCode}, Body: ${response.body}');
      if (response.statusCode == 200) {
        await fetchMessages();
      } else {
        debugPrint('Failed to edit message: ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to edit message')),
        );
      }
    } catch (e) {
      debugPrint('Error editing message: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error editing message')),
      );
    }
  }

  Future<void> deleteMessage(String messageId,
      {bool forEveryone = false}) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) return;

    final url = forEveryone
        ? Uri.parse('https://momshood.runasp.net/api/Messages/$messageId')
        : Uri.parse(
            'https://momshood.runasp.net/api/Messages/for-me/$messageId');
    final headers = {
      'Authorization': 'Bearer $token',
      'Cache-Control': 'no-cache',
    };

    try {
      debugPrint('Deleting message $messageId, forEveryone: $forEveryone');
      final response = await http.delete(url, headers: headers);
      debugPrint(
          'Delete Message Response: Status ${response.statusCode}, Body: ${response.body}');
      if (response.statusCode == 200) {
        await fetchMessages();
      } else {
        debugPrint('Failed to delete message: ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete message')),
        );
      }
    } catch (e) {
      debugPrint('Error deleting message: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting message')),
      );
    }
  }

  Future<String> _formatTimestamp(String timestamp) async {
    if (_timestampCache.containsKey(timestamp)) {
      return _timestampCache[timestamp]!;
    }
    try {
      DateTime dateTime = DateTime.parse(timestamp);
      Duration offset = DateTime.now().timeZoneOffset;
      dateTime = dateTime.add(offset);
      final today = DateTime.now();
      final yesterday = today.subtract(Duration(days: 1));

      if (dateTime.year == today.year &&
          dateTime.month == today.month &&
          dateTime.day == today.day) {
        _timestampCache[timestamp] = 'Today';
      } else if (dateTime.year == yesterday.year &&
          dateTime.month == yesterday.month &&
          dateTime.day == yesterday.day) {
        _timestampCache[timestamp] = 'Yesterday';
      } else {
        _timestampCache[timestamp] =
            DateFormat('dd MMMM yyyy').format(dateTime);
      }
      return _timestampCache[timestamp]!;
    } catch (e) {
      debugPrint('Error formatting timestamp: $e');
      return 'Unknown Time';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFCBC3D6),
      appBar: AppBar(
        backgroundColor: Color(0xFFCBC3D6),
        leading: IconButton(
          icon: Image.asset('assets/images/back (1).png'),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Row(
          children: [
            Image.asset('assets/images/Group 87 (1).png',
                width: 70, height: 70),
            SizedBox(width: 8),
            Text(
              "Mom’s Chat",
              style:
                  TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Container(
            color: Colors.black,
            height: 1.0,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
                    controller: _scrollController,
                    padding: EdgeInsets.all(16.0),
                    cacheExtent: 1000.0,
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      String senderName =
                          message['user']?['fullName'] ?? 'Unknown';
                      String messageText = message['text'] ?? '';
                      bool isCurrentUser =
                          message['user']?['email'] == currentUserEmail;
                      String? lastTimestamp;
                      if (index > 0) {
                        lastTimestamp = messages[index - 1]['timestamp'];
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          if (index == 0 ||
                              _shouldShowDateSeparator(
                                  message['timestamp'], lastTimestamp))
                            FutureBuilder<String>(
                              future: _formatTimestamp(message['timestamp']),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return SizedBox.shrink();
                                }
                                return Padding(
                                  padding: EdgeInsets.symmetric(vertical: 8.0),
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 12.0, vertical: 6.0),
                                    decoration: BoxDecoration(
                                      color: Color(0xffB0B0B0),
                                      borderRadius: BorderRadius.circular(20.0),
                                    ),
                                    child: Text(
                                      snapshot.data!,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                );
                              },
                            ),
                          _buildChatBubble(
                            sender: senderName,
                            message: messageText,
                            time: _timestampCache[message['timestamp']] !=
                                        'Today' &&
                                    _timestampCache[message['timestamp']] !=
                                        'Yesterday'
                                ? DateFormat('hh:mm a').format(
                                    DateTime.parse(message['timestamp'])
                                        .add(DateTime.now().timeZoneOffset))
                                : '',
                            isCurrentUser: isCurrentUser,
                            messageId: message['id'],
                          ),
                        ],
                      );
                    },
                  ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  bool _shouldShowDateSeparator(
      String? currentTimestamp, String? lastTimestamp) {
    if (lastTimestamp == null) return true;
    try {
      DateTime currentDate = DateTime.parse(currentTimestamp!);
      DateTime lastDate = DateTime.parse(lastTimestamp);
      return currentDate.day != lastDate.day ||
          currentDate.month != lastDate.month ||
          currentDate.year != lastDate.year;
    } catch (e) {
      debugPrint('Error comparing timestamps: $e');
      return false;
    }
  }

  Widget _buildChatBubble({
    required String sender,
    required String message,
    required String time,
    required bool isCurrentUser,
    required String messageId,
  }) {
    return Row(
      mainAxisAlignment:
          isCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!isCurrentUser)
          CircleAvatar(
            backgroundColor: Color(0xff605B5B),
            child: Text(
              sender.isNotEmpty ? sender[0] : '?',
              style: TextStyle(color: Colors.white),
            ),
          ),
        if (!isCurrentUser) SizedBox(width: 8),
        Flexible(
          child: ConstrainedBox(
            constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.7),
            child: Container(
              margin: EdgeInsets.symmetric(vertical: 4.0),
              padding: EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: isCurrentUser ? Color(0xFF8D7D97) : Color(0xffDDD8D8),
                borderRadius: BorderRadius.circular(12.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(2, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        sender,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isCurrentUser ? Colors.white : Colors.black,
                        ),
                      ),
                      PopupMenuButton<String>(
                        icon: Icon(
                          Icons.more_vert,
                          color: isCurrentUser ? Colors.white : Colors.black,
                        ),
                        color: Colors.white,
                        itemBuilder: (BuildContext context) {
                          if (isCurrentUser) {
                            return [
                              PopupMenuItem(
                                value: 'edit',
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.8),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  padding: EdgeInsets.all(8),
                                  child: Text('Edit'),
                                ),
                              ),
                              PopupMenuItem(
                                value: 'delete_for_everyone',
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.8),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  padding: EdgeInsets.all(8),
                                  child: Text('Delete for Everyone'),
                                ),
                              ),
                              PopupMenuItem(
                                value: 'delete_for_me',
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.8),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  padding: EdgeInsets.all(8),
                                  child: Text('Delete for Me'),
                                ),
                              ),
                            ];
                          } else {
                            return [
                              PopupMenuItem(
                                value: 'delete_for_me',
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.8),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  padding: EdgeInsets.all(8),
                                  child: Text('Delete for Me'),
                                ),
                              ),
                            ];
                          }
                        },
                        onSelected: (value) async {
                          if (value == 'edit') {
                            _showEditDialog(context, messageId, message);
                          } else if (value == 'delete_for_everyone') {
                            await deleteMessage(messageId, forEveryone: true);
                          } else if (value == 'delete_for_me') {
                            await deleteMessage(messageId);
                          }
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 4),
                  Text(
                    message,
                    style: TextStyle(
                      color: isCurrentUser ? Colors.white : Colors.black,
                    ),
                    maxLines: 20,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (time.isNotEmpty) SizedBox(height: 4),
                  if (time.isNotEmpty)
                    Text(
                      time,
                      style: TextStyle(
                        color: isCurrentUser ? Colors.white70 : Colors.black54,
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        if (isCurrentUser) SizedBox(width: 8),
        if (isCurrentUser)
          CircleAvatar(
            backgroundColor: Color(0xffD9D9D9),
            child: Text(
              sender.isNotEmpty ? sender[0] : '?',
              style: TextStyle(color: Colors.white),
            ),
          ),
      ],
    );
  }

  void _showEditDialog(
      BuildContext context, String messageId, String currentText) {
    TextEditingController editController =
        TextEditingController(text: currentText);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Message'),
          content: TextField(
            controller: editController,
            decoration: InputDecoration(hintText: 'Edit your message'),
            maxLines: 3,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                editMessage(messageId, editController.text);
                Navigator.pop(context);
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMessageInput() {
    return Container(
      constraints: BoxConstraints(maxHeight: 60.0),
      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Color(0xFF8D7D97),
        borderRadius: BorderRadius.circular(30.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              focusNode: _messageFocusNode,
              decoration: InputDecoration(
                hintText: "Start Trying...",
                hintStyle: TextStyle(color: Colors.white70),
                border: InputBorder.none,
                contentPadding:
                    EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
              ),
              maxLines: 3,
              minLines: 1,
              style: TextStyle(color: Colors.white),
              onSubmitted: (value) {
                sendMessage();
                _messageFocusNode.requestFocus();
              },
              textInputAction: TextInputAction.send,
              onChanged: (text) {
                if (text.length > 500) {
                  debugPrint('Typing long message: ${text.length} characters');
                }
              },
            ),
          ),
          SizedBox(width: 8),
          FloatingActionButton(
            onPressed: sendMessage,
            child: Icon(Icons.send, color: Colors.white, size: 18),
            backgroundColor: Color(0xFF6E137A),
            elevation: 0,
            mini: true,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ],
      ),
    );
  }
}
/*import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class CommunityChatScreen extends StatefulWidget {
  @override
  _CommunityChatScreenState createState() => _CommunityChatScreenState();
}

class _CommunityChatScreenState extends State<CommunityChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<dynamic> messages = [];
  bool _isLoading = true;
  String? currentUserEmail;
  String? firstName;
  String? lastName;

  @override
  void initState() {
    super.initState();
    _initializeUser();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  Future<void> _initializeUser() async {
    final prefs = await SharedPreferences.getInstance();
    currentUserEmail = prefs.getString('email');
    firstName = prefs.getString('firstName');
    lastName = prefs.getString('lastName');
    fetchMessages();
  }

  Future<void> fetchMessages() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) return;

    final url = Uri.parse('https://localhost:7054/api/Messages');
    final headers = {'Authorization': 'Bearer $token'};

    try {
      final response = await http.get(url, headers: headers);
      if (response.statusCode == 200) {
        final List<dynamic> fetchedMessages = json.decode(response.body);
        fetchedMessages.sort((a, b) => DateTime.parse(a['timestamp'])
            .compareTo(DateTime.parse(b['timestamp'])));
        if (mounted) {
          setState(() {
            messages = fetchedMessages;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print('Error fetching messages: $e');
    }
  }

  Future<void> sendMessage() async {
    String messageText = _messageController.text.trim();
    if (messageText.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) return;

    final url = Uri.parse('https://localhost:7054/api/Messages');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token'
    };
    final body = json.encode({
      'text': messageText,
      'user': {'fullName': '$firstName $lastName'}
    });

    try {
      final response = await http.post(url, headers: headers, body: body);
      if (response.statusCode == 201) {
        _messageController.clear();
        fetchMessages().then((_) {
          Future.delayed(Duration(milliseconds: 300), () {
            if (_scrollController.hasClients) {
              _scrollController
                  .jumpTo(_scrollController.position.maxScrollExtent);
            }
          });
        });
      } else {
        print('Failed to send message: ${response.body}');
      }
    } catch (e) {
      print('Error sending message: $e');
    }
  }

  Future<void> editMessage(String messageId, String newText) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) return;

    final url = Uri.parse('https://localhost:7054/api/Messages/$messageId');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token'
    };
    final body = json.encode({
      'text': newText,
      'isEdited': true,
    });

    try {
      final response = await http.put(url, headers: headers, body: body);
      if (response.statusCode == 200) {
        fetchMessages();
      } else {
        print('Failed to edit message: ${response.body}');
      }
    } catch (e) {
      print('Error editing message: $e');
    }
  }

  Future<void> deleteMessage(String messageId,
      {bool forEveryone = false}) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) return;

    final url = forEveryone
        ? Uri.parse('https://localhost:7054/api/Messages/$messageId')
        : Uri.parse('https://localhost:7054/api/Messages/for-me/$messageId');
    final headers = {'Authorization': 'Bearer $token'};

    try {
      final response = await http.delete(url, headers: headers);
      if (response.statusCode == 200) {
        fetchMessages();
      } else {
        print('Failed to delete message: ${response.body}');
      }
    } catch (e) {
      print('Error deleting message: $e');
    }
  }

  Future<String> _formatTimestamp(String timestamp) async {
    try {
      DateTime dateTime = DateTime.parse(timestamp);
      Duration offset = DateTime.now().timeZoneOffset;
      dateTime = dateTime.add(offset);
      return DateFormat('hh:mm a').format(dateTime);
    } catch (e) {
      print('Error formatting timestamp: $e');
      return 'Unknown Time';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFCBC3D6),
      appBar: AppBar(
        backgroundColor: Color(0xFFCBC3D6),
        leading: IconButton(
          icon: Image.asset('assets/images/back (1).png'),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Row(
          children: [
            Image.asset('assets/images/Group 87 (1).png',
                width: 70, height: 70),
            SizedBox(width: 8),
            Text("Mom’s Chat",
                style: TextStyle(
                    color: Colors.black, fontWeight: FontWeight.bold)),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Container(
            color: Colors.black,
            height: 1.0,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
                    controller: _scrollController,
                    padding: EdgeInsets.all(16.0),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      String senderName =
                          message['user']?['fullName'] ?? 'Unknown';
                      String messageText = message['text'] ?? '';
                      bool isCurrentUser =
                          message['user']?['email'] == currentUserEmail;
                      return FutureBuilder<String>(
                        future: _formatTimestamp(message['timestamp']),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return CircularProgressIndicator();
                          }
                          return _buildChatBubble(
                            sender: senderName,
                            message: messageText,
                            time: snapshot.data ?? 'Unknown Time',
                            isCurrentUser: isCurrentUser,
                            messageId: message['id'],
                          );
                        },
                      );
                    },
                  ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildChatBubble({
    required String sender,
    required String message,
    required String time,
    required bool isCurrentUser,
    required String messageId,
  }) {
    return Row(
      mainAxisAlignment:
          isCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!isCurrentUser)
          CircleAvatar(
            backgroundColor: Color(0xff605B5B),
            child: Text(
              sender.isNotEmpty ? sender[0] : '?',
              style: TextStyle(color: Colors.white),
            ),
          ),
        if (!isCurrentUser) SizedBox(width: 8),
        IntrinsicWidth(
          child: Container(
            margin: EdgeInsets.symmetric(vertical: 4.0),
            padding: EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: isCurrentUser ? Color(0xFF8D7D97) : Color(0xffDDD8D8),
              borderRadius: BorderRadius.circular(12.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(2, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      sender,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isCurrentUser ? Colors.white : Colors.black,
                      ),
                    ),
                    if (isCurrentUser)
                      PopupMenuButton<String>(
                        icon: Icon(
                          Icons.more_vert,
                          color: Color(0xFFCBC3D6), // لون النقاط الثلاثة
                        ),
                        color: Colors.transparent, // خلفية القائمة شفافة
                        elevation: 0, // إزالة الظل
                        itemBuilder: (BuildContext context) {
                          return [
                            PopupMenuItem(
                              value: 'edit',
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.8),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: EdgeInsets.all(8),
                                child: Text('Edit'),
                              ),
                            ),
                            PopupMenuItem(
                              value: 'delete_for_everyone',
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.8),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: EdgeInsets.all(8),
                                child: Text('Delete for Everyone'),
                              ),
                            ),
                            PopupMenuItem(
                              value: 'delete_for_me',
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.8),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: EdgeInsets.all(8),
                                child: Text('Delete for Me'),
                              ),
                            ),
                          ];
                        },
                        onSelected: (value) {
                          if (value == 'edit') {
                            _showEditDialog(messageId, message);
                          } else if (value == 'delete_for_everyone') {
                            deleteMessage(messageId, forEveryone: true);
                          } else if (value == 'delete_for_me') {
                            deleteMessage(messageId, forEveryone: false);
                          }
                        },
                      ),
                  ],
                ),
                SizedBox(height: 4),
                Text(
                  message,
                  style: TextStyle(
                    color: isCurrentUser ? Colors.white : Colors.black,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  time,
                  style: TextStyle(
                    color: isCurrentUser ? Colors.white70 : Colors.black54,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (isCurrentUser) SizedBox(width: 8),
        if (isCurrentUser)
          CircleAvatar(
            backgroundColor: Color(0xffD9D9D9),
            child: Text(
              sender.isNotEmpty ? sender[0] : '?',
              style: TextStyle(color: Colors.white),
            ),
          ),
      ],
    );
  }

  void _showEditDialog(String messageId, String currentText) {
    TextEditingController editController =
        TextEditingController(text: currentText);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Message'),
          content: TextField(
            controller: editController,
            decoration: InputDecoration(hintText: 'Edit your message'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                editMessage(messageId, editController.text);
                Navigator.pop(context);
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.grey))),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                  hintText: "Start Typing...", border: InputBorder.none),
            ),
          ),
          FloatingActionButton(
            onPressed: sendMessage,
            child: Icon(Icons.send, color: Colors.white),
            backgroundColor: Color(0xFF8D7D9D),
            mini: true,
          ),
        ],
      ),
    );
  }
}*/
/*import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class CommunityChatScreen extends StatefulWidget {
  @override
  _CommunityChatScreenState createState() => _CommunityChatScreenState();
}

class _CommunityChatScreenState extends State<CommunityChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<dynamic> messages = [];
  bool _isLoading = true;
  String? currentUserEmail;
  String? firstName;
  String? lastName;

  @override
  void initState() {
    super.initState();
    _initializeUser();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  Future<void> _initializeUser() async {
    final prefs = await SharedPreferences.getInstance();
    currentUserEmail = prefs.getString('email');
    firstName = prefs.getString('firstName');
    lastName = prefs.getString('lastName');
    fetchMessages();
  }

  Future<void> fetchMessages() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) return;

    final url = Uri.parse('https://localhost:7054/api/Messages');
    final headers = {'Authorization': 'Bearer $token'};

    try {
      final response = await http.get(url, headers: headers);
      if (response.statusCode == 200) {
        final List<dynamic> fetchedMessages = json.decode(response.body);
        fetchedMessages.sort((a, b) => DateTime.parse(a['timestamp'])
            .compareTo(DateTime.parse(b['timestamp'])));
        if (mounted) {
          setState(() {
            messages = fetchedMessages;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print('Error fetching messages: $e');
    }
  }

  Future<void> sendMessage() async {
    String messageText = _messageController.text.trim();
    if (messageText.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) return;

    final url = Uri.parse('https://localhost:7054/api/Messages');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token'
    };
    final body = json.encode({
      'text': messageText,
      'user': {'fullName': '$firstName $lastName'}
    });

    try {
      final response = await http.post(url, headers: headers, body: body);
      if (response.statusCode == 201) {
        _messageController.clear();
        fetchMessages().then((_) {
          Future.delayed(Duration(milliseconds: 300), () {
            if (_scrollController.hasClients) {
              _scrollController
                  .jumpTo(_scrollController.position.maxScrollExtent);
            }
          });
        });
      } else {
        print('Failed to send message: ${response.body}');
      }
    } catch (e) {
      print('Error sending message: $e');
    }
  }

  Future<String> _formatTimestamp(String timestamp) async {
    try {
      // تحويل timestamp إلى DateTime (يفترض أن يكون بتوقيت UTC)
      DateTime dateTime = DateTime.parse(timestamp);

      // حساب الفرق بين التوقيت المحلي وUTC
      Duration offset = DateTime.now().timeZoneOffset;

      // تطبيق الـ offset لتحويل الوقت إلى التوقيت المحلي
      dateTime = dateTime.add(offset);

      // تنسيق الوقت باستخدام DateFormat
      return DateFormat('hh:mm a').format(dateTime); // تنسيق الوقت
    } catch (e) {
      print('Error formatting timestamp: $e');
      return 'Unknown Time'; // في حالة وجود خطأ، يتم عرض "Unknown Time"
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFCBC3D6),
      appBar: AppBar(
        backgroundColor: Color(0xFFCBC3D6),
        leading: IconButton(
          icon: Image.asset('assets/images/back (1).png'), // صورة سهم الرجوع
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Row(
          children: [
            Image.asset('assets/images/Group 87 (1).png',
                width: 70, height: 70), // الأيقونة
            SizedBox(width: 8),
            Text("Mom’s Chat",
                style: TextStyle(
                    color: Colors.black, fontWeight: FontWeight.bold)),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1.0), // ارتفاع الخط
          child: Container(
            color: Colors.black, // لون الخط
            height: 1.0, // سمك الخط
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
                    controller: _scrollController,
                    padding: EdgeInsets.all(16.0),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      String senderName =
                          message['user']?['fullName'] ?? 'Unknown';
                      String messageText = message['text'] ?? '';
                      return FutureBuilder<String>(
                        future: _formatTimestamp(message['timestamp']),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return CircularProgressIndicator();
                          }
                          return _buildChatBubble(
                            sender: senderName,
                            message: messageText,
                            time: snapshot.data ?? 'Unknown Time',
                            isCurrentUser:
                                message['user']?['email'] == currentUserEmail,
                          );
                        },
                      );
                    },
                  ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildChatBubble({
    required String sender,
    required String message,
    required String time,
    required bool isCurrentUser,
  }) {
    return Row(
      mainAxisAlignment:
          isCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!isCurrentUser)
          CircleAvatar(
            backgroundColor: Color(0xff605B5B),
            child: Text(
              sender.isNotEmpty ? sender[0] : '?',
              style: TextStyle(color: Colors.white),
            ),
          ),
        if (!isCurrentUser) SizedBox(width: 8),
        Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.7,
          ),
          margin: EdgeInsets.symmetric(vertical: 4.0),
          padding: EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            color: isCurrentUser ? Color(0xFF8D7D97) : Color(0xffDDD8D8),
            borderRadius: BorderRadius.circular(12.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 4,
                offset: Offset(2, 2),
              )
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                sender,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isCurrentUser ? Colors.white : Colors.black,
                ),
              ),
              SizedBox(height: 4),
              Text(
                message,
                style: TextStyle(
                  color: isCurrentUser ? Colors.white : Colors.black,
                ),
              ),
              SizedBox(height: 4),
              Text(
                time,
                style: TextStyle(
                  color: isCurrentUser ? Colors.white70 : Colors.black54,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        if (isCurrentUser) SizedBox(width: 8),
        if (isCurrentUser)
          CircleAvatar(
            backgroundColor: Color(0xffD9D9D9),
            child: Text(
              sender.isNotEmpty ? sender[0] : '?',
              style: TextStyle(color: Colors.white),
            ),
          ),
      ],
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.grey))),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                  hintText: "Start Typing...", border: InputBorder.none),
            ),
          ),
          FloatingActionButton(
            onPressed: sendMessage,
            child: Icon(Icons.send, color: Colors.white),
            backgroundColor: Color(0xFF8D7D9D),
            mini: true,
          ),
        ],
      ),
    );
  }
} */
