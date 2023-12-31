import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../widgets/chatmessage.dart';
import '../widgets/newmessage.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat Screen App'),
        actions: [
          IconButton(
            onPressed: () {
              FirebaseAuth.instance.signOut();
            },
            icon: Icon(Icons.logout),
            color: Colors.green,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
              child:
                  ChatMessages()), //make sure that it takes as much space it is required so that we can push newmessadge widegt to bottom
          NewMessage(),
        ],
      ),
    );
  }
}
