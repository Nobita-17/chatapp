import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class NewMessage extends StatefulWidget {
  const NewMessage({super.key});

  @override
  State<NewMessage> createState() => _NewMessageState();
}

class _NewMessageState extends State<NewMessage> {
  var messagecontroller = TextEditingController(); //for reading text
  @override
  void dispose() {
    //whenver we are using text controller we should use dispose method
    messagecontroller.dispose();
    super.dispose();
  }

  Future<void> submitMessage() async {
    final entermessage = messagecontroller.text;
    if (entermessage.isEmpty) {
      return;
    }

    FocusScope.of(context).unfocus();  //clear keyboard
    messagecontroller
        .clear(); //once the message is send this text is send back to emplty text again

    //logic to send data to firebase
    //Process for storing message in firebase will be same as that ofn image but the only diffrence wouldbe in case
    //of image we did not set own name for documents but we use automatically genrated value



    final user = FirebaseAuth
        .instance.currentUser!; //helps in identifying currently loggen in user
    final userdata =
        await FirebaseFirestore.instance.collection('user').doc(user.uid).get();
    await FirebaseFirestore.instance.collection('chat').add(
      {
        'text': entermessage,
        'createdAt': Timestamp.now(),
        'userId': user.uid,
        'userName': userdata.data()!['username'],
        'image': userdata.data()!['imageurl'],
      },
    );


  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 14, right: 1, bottom: 15),
      child: Row(
        children: [
          Expanded(
            //we are wrapping it with expanded widegt since it can give error as it is insde row
            child: TextField(
              controller: messagecontroller,
              autocorrect: true,
              textCapitalization: TextCapitalization.sentences,
              enableSuggestions: true,
              decoration: InputDecoration(
                labelText: 'Send Message..',
              ),
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.send),
            color: Colors.purple,
          ),
        ],
      ),
    );
  }
}
