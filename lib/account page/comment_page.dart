import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Comment_page extends StatefulWidget {
  final int startIndex;

  Comment_page({required this.startIndex});

  @override
  State<Comment_page> createState() => _Comment_pageState();
}

class _Comment_pageState extends State<Comment_page> {
  FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String username = 'Loading';
  String? _imageUrl;
  TextEditingController _comments = TextEditingController();
  bool _uploading = false;
  List<String> profilePhotos = [];
  List<String> comments = [];
  List<String> usernames = [];
  List<String> verified = [];
  bool isVerified = false;

  Future<void> fetchVerification() async {
    final user = _auth.currentUser;
    final docSnap =
    await _firestore.collection('Verifications').doc(user!.uid).get();
    if (docSnap.exists) {
      setState(() {
        isVerified = docSnap.data()?['isverified'];
      });
    }
  }

  Future<void> updateImagesPeriodically() async {
    while (true) {
      await Future.delayed(Duration(seconds: 2));
      await fetchUsernames();
      await fetchComments();
      await fetchProfilePhoto();
      await fetchUserVerification();
    }
  }

  Future<void> fetchUserVerification() async {
    try {
      DocumentSnapshot documentSnapshot = await _firestore
          .collection('All posts')
          .doc('Commented_post_verified ${widget.startIndex}')
          .get();

      if (documentSnapshot.exists) {
        dynamic data = documentSnapshot.data();
        if (data != null) {
          List<dynamic> posts = (data['Comment_verified'] as List?) ?? [];

          setState(() {
            verified =
                posts.map((post) => post['Comments_verified'].toString()).toList();
          });
          print('user verification $verified');
        }
      }
    } catch (e) {
      print('Error fetching user verification: $e');
    }
  }

  Future<void> fetchUsernames() async {
    try {
      DocumentSnapshot documentSnapshot = await _firestore
          .collection('All posts')
          .doc('Commented_post_username ${widget.startIndex}')
          .get();

      if (documentSnapshot.exists) {
        dynamic data = documentSnapshot.data();
        if (data != null) {
          List<dynamic> posts = (data['Comment_username'] as List?) ?? [];

          setState(() {
            usernames =
                posts.map((post) => post['Comments_username'].toString()).toList();
          });
        }
      }
    } catch (e) {
      print('Error fetching usernames: $e');
    }
  }

  Future<void> fetchProfilePhoto() async {
    try {
      DocumentSnapshot documentSnapshot = await _firestore
          .collection('All posts')
          .doc('Commented_post_profile picture ${widget.startIndex}')
          .get();

      if (documentSnapshot.exists) {
        dynamic data = documentSnapshot.data();
        if (data != null) {
          List<dynamic> posts = (data['Comment_profile_pic'] as List?) ?? [];

          setState(() {
            profilePhotos =
                posts.map((post) => post['Comments_profile_pic'].toString()).toList();
          });
        }
      }
    } catch (e) {
      print('Error fetching profile photo: $e');
    }
  }

  Future<void> _loadProfilePicture() async {
    final user = _auth.currentUser;
    if (user != null) {
      try {
        final docSnapshot =
        await _firestore.collection('profile_pictures').doc(user.uid).get();
        if (docSnapshot.exists) {
          setState(() {
            _imageUrl = docSnapshot.data()?['url_user1'];
          });
        }
      } catch (e) {
        print('Error loading profile picture: $e');
      }
    }
  }

  Future<void> fetchUsername() async {
    final user = _auth.currentUser;
    try {
      final docSnap =
      await _firestore.collection('User Details').doc(user!.uid).get();
      if (docSnap.exists) {
        setState(() {
          username = docSnap.data()?['user name'];
        });
      }
    } catch (e) {
      print('Error fetching username: $e');
    }
  }

  Future<void> fetchComments() async {
    try {
      DocumentSnapshot documentSnapshot = await _firestore
          .collection('All posts')
          .doc('Commented_post ${widget.startIndex}')
          .get();

      if (documentSnapshot.exists) {
        dynamic data = documentSnapshot.data();
        if (data != null) {
          List<dynamic> posts = (data['Comment'] as List?) ?? [];

          setState(() {
            comments = posts.map((post) => post['Comments'].toString()).toList();
          });
        }
      }
    } catch (e) {
      print('Error fetching comments: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchUsername();
    _loadProfilePicture();
    fetchComments();
    fetchProfilePhoto();
    updateImagesPeriodically();
    fetchVerification();
    fetchUserVerification();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: Column(
        children: [
          SizedBox(
            height: 50,
          ),
          Expanded(
            child: ListView.builder(
              itemCount: profilePhotos.length,
              itemBuilder: (context, index) {
                // Check if index is within bounds and lists have items
                if (index < usernames.length &&
                    index < comments.length &&
                    index < profilePhotos.length &&
                    index < verified.length) {
                  return ListTile(
                    title: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundColor: Colors.black,
                              child: Image.network(
                                profilePhotos[index],
                                height: 50,
                                width: 50,
                              ),
                            ),
                            SizedBox(
                              width: 20,
                            ),
                            Text(
                              usernames[index],
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                            if (verified[index] == 'true')
                              Image.network(
                                'https://emkldzxxityxmjkxiggw.supabase.co/storage/v1/object/public/Grovito/480-4801090_instagram-verified-badge-png-instagram-verified-icon-png-removebg-preview.png',
                                height: 30,
                                width: 30,
                              )
                          ],
                        ),
                        SizedBox(width: 10),
                        Row(
                          children: [
                            SizedBox(width: 60),
                            Text(
                              '${comments[index]}',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w300,
                                fontSize: 12,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                } else {
                  // Handle the case where index is out of bounds or lists are not fully populated
                  return Container();
                }
              },
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  prefixIcon: _uploading
                      ? Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(
                      color: Colors.red,
                    ),
                  )
                      : _imageUrl == null
                      ? ClipOval(
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: 3,
                        ),
                      ),
                      child: Image.network(
                        'https://firebasestorage.googleapis.com/v0/'
                            'b/fotofusion-53943.appspot.com/o/profile%2'
                            '0pics.jpg?alt=media&token=17bc6fff-cfe9-4f2d-9'
                            'a8c-18d2a5636671',
                        fit: BoxFit.cover,
                      ),
                    ),
                  )
                      : ClipOval(
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: 3,
                        ),
                      ),
                      child: Image.network(
                        _imageUrl!,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  suffixIcon: IconButton(
                    onPressed: () async {
                      final user = _auth.currentUser;
                      await _firestore
                          .collection('All posts')
                          .doc('Commented_post_username ${widget.startIndex}')
                          .set(
                        {
                          'Comment_username': FieldValue.arrayUnion([
                            {
                              'Comments_username': username
                            }
                          ])
                        },
                        SetOptions(merge: true),
                      );
                      await _firestore
                          .collection('All posts')
                          .doc('Commented_post_uid ${widget.startIndex}')
                          .set(
                        {
                          'Comment_uid': FieldValue.arrayUnion([
                            {
                              'Comments_uid': user!.uid
                            }
                          ])
                        },
                        SetOptions(merge: true),
                      );
                      await _firestore
                          .collection('All posts')
                          .doc(
                          'Commented_post_profile picture ${widget.startIndex}')
                          .set(
                        {
                          'Comment_profile_pic': FieldValue.arrayUnion([
                            {
                              'Comments_profile_pic': _imageUrl
                            }
                          ])
                        },
                        SetOptions(merge: true),
                      );
                      await _firestore
                          .collection('All posts')
                          .doc('Commented_post ${widget.startIndex}')
                          .set(
                        {
                          'Comment': FieldValue.arrayUnion([
                            {
                              'Comments': _comments.text
                            }
                          ])
                        },
                        SetOptions(merge: true),
                      );
                      await _firestore
                          .collection('All posts')
                          .doc('Commented_post_verified ${widget.startIndex}')
                          .set(
                        {
                          'Comment_verified': FieldValue.arrayUnion([
                            {
                              'Comments_verified': isVerified
                            }
                          ])
                        },
                        SetOptions(merge: true),
                      );
                      _comments.clear();
                      fetchProfilePhoto();
                      fetchUsernames();
                      fetchComments();
                    },
                    icon: Icon(
                      Icons.send,
                      color: Colors.white,
                    ),
                  ),
                  hintText: '  Add a comment',
                  hintStyle: TextStyle(color: Colors.white),
                  filled: true,
                  fillColor: Colors.grey[900],
                ),
                controller: _comments,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
