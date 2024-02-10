import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fotofusion/Searches/search_result.dart';

class Message extends StatefulWidget {
  final String userid;

  Message({required this.userid});
  @override
  State<Message> createState() => _MessageState();
}

class _MessageState extends State<Message> {
  FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String username = '';
  String profilepics = '';
  TextEditingController _messages = TextEditingController();
  final ScrollController _controller = ScrollController();

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    // Fetch username
    final userSnap = await _firestore.collection('User Details').doc(widget.userid).get();
    if (userSnap.exists) {
      setState(() {
        username = userSnap.data()?['user name'] ?? '';
      });
    }

    // Fetch profile picture
    final profileSnap = await _firestore.collection('profile_pictures').doc(widget.userid).get();
    if (profileSnap.exists) {
      setState(() {
        profilepics = profileSnap.data()?['url_user1'] ?? '';
      });
    } else {
      setState(() {
        profilepics = 'https://firebasestorage.googleapis.com/v0/'
            'b/fotofusion-53943.appspot.com/o/profile%2'
            '0pics.jpg?alt=media&token=17bc6fff-cfe9-4f2d-9'
            'a8c-18d2a5636671';
      });
    }
  }

  Future<void> sendMessage({bool repliedTo = false}) async {
    final user = _auth.currentUser;
    String chatID = user!.uid.compareTo(widget.userid) < 0
        ? '${user.uid}-${widget.userid}'
        : '${widget.userid}-${user.uid}';

    await _firestore.collection('Messages').doc(chatID).collection('chats').add({
      "role": username,
      "text": _messages.text,
      "senderUid": user.uid, // Store the UID of the sender
      "time of sending": FieldValue.serverTimestamp(),
      "repliedTo": repliedTo, // Add information about whether this message is a reply
    });
    _messages.clear();
  }


  void scrollToTheEnd() {
    _controller.jumpTo(_controller.position.maxScrollExtent);
  }

  @override
  Widget build(BuildContext context) {
    String chatID = _auth.currentUser!.uid.compareTo(widget.userid) < 0
        ? '${_auth.currentUser!.uid}-${widget.userid}'
        : '${widget.userid}-${_auth.currentUser!.uid}';

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: Colors.black,
              backgroundImage: NetworkImage(profilepics),
            ),
            SizedBox(
              width: 10,
            ),
            InkWell(
              onTap: (){
                Navigator.push(context, MaterialPageRoute(builder: (context) => Searchresult(userid: widget.userid),));
              },
              child: Text(
                username,
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
              ),
            )
          ],
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: _firestore.collection('Messages').doc(chatID).collection('chats').orderBy('time of sending').snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
                final messages = snapshot.data!.docs;
                List<Widget> messageWidgets = [];
                for (var message in messages) {
                  final messageText = message['text'];
                  final senderUid = message['senderUid']; // Get the UID of the sender
                  final currentUserUid = _auth.currentUser!.uid; // Get the UID of the current user
                  final repliedTo = message['repliedTo'] ?? false;
                  final messageWidget = MessageBubble(
                    text: messageText,
                    senderUid: senderUid,
                    currentUserUid: currentUserUid,
                    repliedTo: repliedTo,
                  );
                  messageWidgets.add(messageWidget);
                }
                return ListView(
                  controller: _controller,
                  children: messageWidgets,
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              style: TextStyle(color: Colors.white),
              controller: _messages,
              decoration: InputDecoration(
                filled: true,
                hintText: 'Message $username',
                hintStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                fillColor: Colors.grey[800],
                suffixIcon: IconButton(
                  onPressed: sendMessage,
                  icon: const Icon(Icons.send_outlined, color: Colors.white),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class MessageBubble extends StatelessWidget {
  final String text;
  final String senderUid;
  final String currentUserUid;
  final bool repliedTo;

  MessageBubble({required this.text, required this.senderUid, required this.currentUserUid, this.repliedTo = false});

  @override
  Widget build(BuildContext context) {
    final isSender = senderUid == currentUserUid; // Check if the sender is the current user

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
      child: Align(
        alignment: isSender ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(isSender ? 20.0 : 0.0),
              topRight: Radius.circular(isSender ? 0.0 : 20.0),
              bottomLeft: Radius.circular(15.0),
              bottomRight: Radius.circular(15.0),
            ),
            color: isSender ? Colors.green : Colors.grey[600], // Adjust color based on whether the sender is the current user
          ),
          padding: EdgeInsets.all(15.0),
          child: Text(
            text,
            style: TextStyle(
              fontWeight: isSender?FontWeight.w500:FontWeight.normal,
              fontSize: 16.0,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
