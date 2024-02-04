import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
class Notifications extends StatefulWidget {
  const Notifications({Key? key}) : super(key: key);

  @override
  State<Notifications> createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<String> followerUids = [];
  List<String> usernames = [];
  List<String> profilepicurls = [];
  List<bool> verificationsstatuses = [];

  Future<void> fetchFollowersList() async {
    final user = _auth.currentUser;
    try {
      var snapshot =
      await _firestore.collection('Followers').doc(user!.uid).get();

      if (snapshot.exists) {
        var followersData = snapshot.data();

        if (followersData != null && followersData['Followers'] != null) {
          for (var follower in followersData['Followers']) {
            var followerUid = follower['followerUid'];
            if (followerUid != null && followerUid is String) {
              followerUids.add(followerUid);
            }
          }

          print('user id ${user!.uid}');
          print('Follower UIDs: $followerUids');
        } else {
          print('No Followers data found or Followers array is empty.');
        }
      } else {
        print('Document with ID ${user!.uid} does not exist.');
      }
    } catch (e) {
      print('Error fetching Followers: $e');
    }
  }

  Future<void> fetchusernames() async {
    try {
      List<String> followerUidsCopy = List.from(followerUids);

      for (String uids in followerUidsCopy) {
        final docsnap =
        await _firestore.collection('User Details').doc(uids).get();

        if (docsnap.exists) {
          String result = docsnap.data()?['user name'];
          usernames.add(result);
        }
      }

      print('usernames $usernames');
    } catch (error) {
      print('Error in fetchusernames: $error');
    }
  }

  Future<void> fetchprofilepics() async {
    try {
      List<String> followerUidsCopy = List.from(followerUids);

      for (String uids in followerUidsCopy) {
        final docsnap =
        await _firestore.collection('profile_pictures').doc(uids).get();

        if (docsnap.exists) {
          String result = docsnap.data()?['url_user1'];
          profilepicurls.add(result);
        } else {
          profilepicurls.add(
              'https://i.pinimg.com/736x/66/b8/58/66b858099df3127e83cb1f1168f7a2c6.jpg');
        }
      }

      print('Photos $profilepicurls');
    } catch (error) {
      print('Error in photos: $error');
    }
  }

  Future<void> fetchverifications() async {
    try {
      List<String> followerUidsCopy = List.from(followerUids);

      for (String uids in followerUidsCopy) {
        final docsnap =
        await _firestore.collection('Verifications').doc(uids).get();

        if (docsnap.exists) {
          bool result = docsnap.data()?['isverified'];
          verificationsstatuses.add(result);
        }
      }

      print('Verification $verificationsstatuses');
    } catch (error) {
      print('Error in verification: $error');
    }
  }

  Future<void> _fetchData() async {
    try {
      await fetchFollowersList();
      await fetchusernames();
      await fetchprofilepics();
      await fetchverifications();
      setState(() {}); // Trigger UI update after data is fetched
    } catch (error) {
      print('Error fetching data: $error');
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text('Notifications',style: TextStyle(color: Colors.white,fontWeight: FontWeight.w500),),
        leading: IconButton(onPressed: (){
          Navigator.pop(context);
        }, icon: Icon(CupertinoIcons.back,color: Colors.white,)),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: 20,
            ),
            for(int i=0;i<usernames.length;i++)
              Column(
                children: [
                  Row(
                    children: [
                      SizedBox(
                        width: 10,
                      ),
                      CircleAvatar(
                        backgroundColor: Colors.grey,
                        backgroundImage: NetworkImage(profilepicurls[i]),
                      ),
                      SizedBox(
                        width: 20,
                      ),
                      Text('${usernames[i]}',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,
                      fontSize:13.5
                      ),),
                      if(verificationsstatuses[i])
                        Image.network('https://emkldzxxityxmjkxiggw.supabase.co/storage/v1/object/public/Grovito/480-'
                            '4801090_instagram-verified-badge-png-instagram-verified-icon-png-removebg-preview.png',
                          height: 20,
                          width: 20,
                        ),
                      Text(' started following you',style: TextStyle(color: Colors.white,fontWeight: FontWeight.w400,
                          fontSize:13.5
                      ),),
                    ],
                  ),
                  SizedBox(
                    height: 40,
                  )
                ],
              )
          ],
        ),
      ),
    );
  }
}
