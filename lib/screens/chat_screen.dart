import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flash_chat/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatScreen extends StatefulWidget {
  static String id = 'chat_screen';
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _fireStore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  User loggedInUser;
  String message;

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  void getCurrentUser() async {
    try {
      final user = await _auth.currentUser;
      if (user != null) {
        loggedInUser = user;
        print(loggedInUser.email);
      }
    } catch (e) {
      print(e);
    }
  }

  // void messagesStream() async {
  //   await for (var snapshot in _fireStore.collection('messages').snapshots()) {
  //     for (var message in snapshot.docs) {
  //       print(message.data());
  //       var messageData = message.data();
  //       var messageSender = messageData['sender'];
  //       var messageText = messageData['message'];
  //       print('message from: $messageSender = $messageText');
  //     }
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                //Implement logout functionality
                // messagesStream();
                _auth.signOut();
                Navigator.pop(context);
              }),
        ],
        title: Text('⚡️Chat'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            StreamBuilder(
              stream: _fireStore.collection('messages').snapshots(),
              builder: (context, snapshot) {
                List<Text> messageWidgets = [];
                if (snapshot.hasData) {
                  final messages = snapshot.data.docs;

                  for (var message in messages) {
                    final messageData = message.data();
                    final messageText = messageData['message'];
                    final messageSender = messageData['sender'];
                    final messageWidget =
                        Text('$messageText from $messageSender');
                    messageWidgets.add(messageWidget);
                  }
                  return Column(
                    children: messageWidgets,
                  );
                }
                return Text('');
              },
            ),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      onChanged: (value) {
                        message = value;
                        //Do something with the user input.
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  FlatButton(
                    onPressed: () {
                      _fireStore.collection('messages').add({
                        'message': message,
                        'sender': loggedInUser.email,
                      });
                      //Implement send functionality.
                    },
                    child: Text(
                      'Send',
                      style: kSendButtonTextStyle,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
