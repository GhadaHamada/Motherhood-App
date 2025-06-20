import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  final String messagesUrl =
      'https://localhost:7054/api/Messages'; // استبدل بعنوان السيرفر الفعلي
  final _storage = FlutterSecureStorage();

  Future<String?> getToken() async {
    return await _storage.read(key: 'auth_token');
  }

  Future<String?> getId() async {
    return await _storage.read(key: 'Id'); // تعديل اسم المتغير هنا
  }

  Future<String?> getFirstName() async {
    return await _storage.read(key: 'first_name');
  }

  Future<String?> getLastName() async {
    return await _storage.read(key: 'last_name');
  }

  Future<List<Map<String, dynamic>>> fetchMessages() async {
    try {
      final token = await getToken();
      if (token == null) throw Exception("User not authenticated!");

      final response = await http.get(
        Uri.parse(messagesUrl),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(json.decode(response.body));
      } else {
        throw Exception('Failed to fetch messages: ${response.body}');
      }
    } catch (e) {
      print('Error fetching messages: $e');
      throw Exception('Messages retrieval error: $e');
    }
  }

  Future<void> sendMessage(Map<String, dynamic> messageData) async {
    try {
      final token = await getToken();
      if (token == null) throw Exception("User not authenticated!");

      final response = await http.post(
        Uri.parse(messagesUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(messageData),
      );

      if (response.statusCode != 201) {
        throw Exception('Failed to send message: ${response.body}');
      }
    } catch (e) {
      print('Error sending message: $e');
      throw Exception('Message sending error: $e');
    }
  }
}

class CommunityChatScreen extends StatefulWidget {
  @override
  _CommunityChatScreenState createState() => _CommunityChatScreenState();
}

class _CommunityChatScreenState extends State<CommunityChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ApiService apiService = ApiService();
  List<Map<String, dynamic>> messages = [];
  String? userId; // تغيير الاسم هنا ليصبح Id
  String? firstName;
  String? lastName;

  @override
  void initState() {
    super.initState();
    _initializeUser();
  }

  Future<void> _initializeUser() async {
    userId = await apiService.getId(); // تعديل استرجاع الـ Id هنا
    firstName = await apiService.getFirstName();
    lastName = await apiService.getLastName();

    if (userId == null || firstName == null || lastName == null) {
      print("User data is incomplete. Redirect to login.");
      return;
    }
    _fetchMessages();
  }

  Future<void> _fetchMessages() async {
    try {
      List<Map<String, dynamic>> fetchedMessages =
          await apiService.fetchMessages();
      setState(() {
        messages = fetchedMessages;
      });
    } catch (e) {
      print("Error fetching messages: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch messages: $e')),
      );
    }
  }

  Future<void> _sendMessage(String messageText) async {
    if (messageText.trim().isEmpty) return;

    String currentTime = DateFormat('hh:mm a').format(DateTime.now());
    final messageData = {
      "text": messageText,
      "time": currentTime,
      "date": DateFormat('yyyy-MM-dd').format(DateTime.now()),
      "Id": userId, // تعديل هنا لاستخدام Id
      "userName": "$firstName $lastName",
    };

    final token = await apiService.getToken();
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User is not authenticated!')),
      );
      return;
    }

    try {
      await apiService.sendMessage(messageData);
      setState(() {
        messages.add(messageData);
        _messageController.clear();
      });
    } catch (e) {
      print("Error sending message: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to send message')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFCBC3D6),
      appBar: AppBar(
        backgroundColor: const Color(0xFFCBC3D6),
        elevation: 0,
        leading: IconButton(
          icon:
              Image.asset('assets/images/back (1).png', width: 26, height: 26),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Image.asset('assets/images/Group 87 (1).png', height: 24),
            const SizedBox(width: 8),
            const Text("Mom’s Chat",
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.bold)),
          ],
        ),
      ),
      body: Column(
        children: [
          const Divider(color: Colors.black, thickness: 1),
          Expanded(
            child: messages.isEmpty
                ? const Center(child: Text("No messages yet."))
                : ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      return _buildChatBubble(
                        sender: message['userName'] ?? 'User',
                        message: message['text'],
                        time: message['time'],
                        isCurrentUser:
                            message['Id'] == userId, // تعديل هنا للتحقق من Id
                      );
                    },
                  ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildChatBubble(
      {required String sender,
      required String message,
      required String time,
      required bool isCurrentUser}) {
    return Align(
      alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Row(
        mainAxisAlignment:
            isCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isCurrentUser)
            CircleAvatar(
              radius: 18.0,
              backgroundColor: Color(0xFF605B5B),
              child: Text(sender[0].toUpperCase(),
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold)),
            ),
          if (!isCurrentUser) const SizedBox(width: 8.0),
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            padding: const EdgeInsets.all(12.0),
            constraints: const BoxConstraints(maxWidth: 250),
            decoration: BoxDecoration(
              color: isCurrentUser ? const Color(0xFFD9D9D9) : Colors.white,
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(sender,
                    style: TextStyle(color: Colors.black54, fontSize: 12)),
                const SizedBox(height: 4.0),
                Text(message,
                    style: TextStyle(color: Colors.black, fontSize: 16)),
                const SizedBox(height: 4.0),
                Text(time,
                    style: TextStyle(color: Colors.black54, fontSize: 10)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.grey.shade300))),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: const InputDecoration(
                  hintText: "Type your message...", border: InputBorder.none),
            ),
          ),
          FloatingActionButton(
            onPressed: () => _sendMessage(_messageController.text),
            child: const Icon(Icons.send, color: Colors.white),
            backgroundColor: const Color(0xFF8D7D9D),
            mini: true,
          ),
        ],
      ),
    );
  }
}
