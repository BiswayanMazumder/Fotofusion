import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
class Followers extends StatefulWidget {
  const Followers({Key? key}) : super(key: key);

  @override
  State<Followers> createState() => _FollowersState();
}

class _FollowersState extends State<Followers> {
  FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String username = 'Loading';
  String name = 'Loading';
  String? _imageUrl;
  bool isverified=false;
  List<String> followers = [];
  final FirebaseStorage _storage = FirebaseStorage.instance;
  Future<String> fetchUsernameFromId(String userId) async {
    try {
      final docSnapshot = await _firestore.collection('User Details').doc(userId).get();
      if (docSnapshot.exists) {
        return docSnapshot.data()?['user name'] ?? ''; // Return an empty string if 'user name' is not found.
      }
    } catch (e) {
      print('Error fetching username for user ID $userId: $e');
    }

    return ''; // Return an empty string or handle the case when the username is not found.
  }

  Future<String> fetchProfilePictureUrl(String userId) async {
    try {
      final docSnapshot = await _firestore.collection('profile_pictures').doc(userId).get();
      if (docSnapshot.exists) {
        return docSnapshot.data()?['url_user1'] ?? ''; // Return an empty string if 'url_user1' is not found.
      }
    } catch (e) {
      print('Error fetching profile picture for user ID $userId: $e');
    }

    return ''; // Return an empty string or handle the case when the profile picture is not found.
  }
  List<bool> verificationStatus = [];
  Future<bool> fetchVerificationStatus(String userId) async {
    try {
      final docSnapshot = await _firestore.collection('Verifications').doc(userId).get();
      if (docSnapshot.exists) {
        return docSnapshot.data()?['isverified'] ?? false;
      }
    } catch (e) {
      print('Error fetching verification status for user ID $userId: $e');
    }

    return false;
  }
  Future<void> fetchFollowersAndUsernames() async {
    final user = _auth.currentUser;

    try {
      // Fetch 'user names' from 'User Details' collection
      final userSnapshot = await _firestore.collection('User Details').doc(user?.uid).get();
      if (userSnapshot.exists) {
        setState(() {
          name = userSnapshot.data()?['user names'];
        });
      }

      // Fetch followers, usernames, and profile pictures
      DocumentSnapshot documentSnapshot = await _firestore
          .collection('Followers')
          .doc(user?.uid)
          .get();

      if (documentSnapshot.exists) {
        dynamic data = documentSnapshot.data();
        if (data != null) {
          List<dynamic> posts = (data['Followers'] as List?) ?? [];

          List<String> followerUsernames = [];
          List<String> followerProfilePictures = [];
          List<bool> followerVerificationStatus = [];

          for (dynamic post in posts) {
            String followerUid = post['followerUid'].toString();

            String username = await fetchUsernameFromId(followerUid);
            followerUsernames.add(username);

            String profilePictureUrl = await fetchProfilePictureUrl(followerUid);
            followerProfilePictures.add(profilePictureUrl);
            bool isVerified = await fetchVerificationStatus(followerUid);
            followerVerificationStatus.add(isVerified);
          }

          setState(() {
            followers = followerUsernames;
            profilePictureUrls = followerProfilePictures;
            verificationStatus = followerVerificationStatus;
          });
        }
      }

      // Fetch 'user names' from 'User Details' collection again (for clarity, you can optimize this)
      final userSnapshotAfter = await _firestore.collection('User Details').doc(user?.uid).get();
      if (userSnapshotAfter.exists) {
        setState(() {
          name = userSnapshotAfter.data()?['user names'];
        });
      }
    } catch (e) {
      print('Error fetching followers, usernames, and profile pictures: $e');
    }
  }


// Ensure you have a list to store profile picture URLs
  List<String> profilePictureUrls = [];
  Future<void> updateImagesPeriodically() async {
    while (true) {
      await Future.delayed(Duration(seconds: 2));
      fetchFollowersAndUsernames();
    }
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchFollowersAndUsernames();
    updateImagesPeriodically();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text('Followers',style: TextStyle(color: Colors.white),),
        automaticallyImplyLeading: false,
      ),
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: 30,
            ),
            for (int i = 0; i < followers.length; i++)
              Column(
                children: [
                  Row(
                    children: [
                      SizedBox(
                        width: 30,
                      ),
                      CircleAvatar(
                        radius: 22, // Adjust the size as needed
                        backgroundColor: Colors.grey, // Background color for the avatar
                        backgroundImage: profilePictureUrls[i].isEmpty
                            ? NetworkImage(
                            'https://firebasestorage.googleapis.com/v0/'
                                'b/fotofusion-53943.appspot.com/o/profile%2'
                                '0pics.jpg?alt=media&token=17bc6fff-cfe9-4f2d-9'
                                'a8c-18d2a5636671') // Provide a default image
                            : NetworkImage(profilePictureUrls[i]) as ImageProvider<Object>?,
                      ),

                      SizedBox(
                        width: 10,
                      ),
                          InkWell(
                            child: Text(
                              followers[i],
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ),
                      if(verificationStatus[i])
                        Image.network('https://emkldzxxityxmjkxiggw.supabase.co/storage/v1/object/public/Grovito/480-4801090_instagram-verified-badge-png-instagram-verified-icon-png-removebg-preview.png',
                          height: 30,
                          width: 30,
                        )
                    ],
                  ),
                  SizedBox(
                    height: 40,
                  ),
                ],
              ),

          ],
          ),
      ),
    );
  }
}
