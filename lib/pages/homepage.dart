import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math';
class Homepage extends StatefulWidget {
  const Homepage({Key? key}) : super(key: key);

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  List<String> imageUrls = [];
  List<String> captions = [];
  List<String> usernames = [];
  List<String> profilephotos = [];
  List<List<String>> likedUsers = [];
  FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  int numberOfPosts = 0;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    initializeNumberOfPosts();
    initializeLikedUsersList();
    updateImagesPeriodically();
  }

  Future<void> initializeNumberOfPosts() async {
    try {
      DocumentSnapshot documentSnapshot = await _firestore
          .collection('All posts')
          .doc('Global Post')
          .get();

      if (documentSnapshot.exists) {
        dynamic data = documentSnapshot.data();
        if (data != null) {
          List<dynamic> posts = (data['posts'] as List?) ?? [];

          setState(() {
            numberOfPosts = posts.length;
          });
        }
      }
    } catch (e) {
      print('Error initializing numberOfPosts: $e');
    }
  }

  Future<void> initializeLikedUsersList() async {
    setState(() {
      likedUsers = List.generate(numberOfPosts, (index) => []);
    });
  }

  Future<void> updateImagesPeriodically() async {
    while (true) {
      await Future.delayed(Duration(seconds: 2));
      await fetchprofilephoto();
      await fetchusernames();
      await fetchImages();
      await fetchcaptions();
      await fetchInitialLikeStatus();
    }
  }

  Future<void> fetchInitialLikeStatus() async {
    try {
      final String currentUserUid = _auth.currentUser?.uid ?? '';

      List<List<String>> initialLikedUsers = await Future.wait(
        List.generate(min(numberOfPosts, imageUrls.length), (index) async {
          DocumentSnapshot postDoc =
          await _firestore.collection('All posts').doc('post$index').get();
          Map<String, dynamic> postData =
              postDoc.data() as Map<String, dynamic>? ?? {};
          List<dynamic>? existingLikedUsersDynamic = postData['likedUsers'];
          return existingLikedUsersDynamic?.cast<String>() ?? [];
        }),
      );

      setState(() {
        likedUsers = initialLikedUsers;
      });
    } catch (e) {
      print('Error fetching initial like status: $e');
    }
  }

  Future<void> fetchprofilephoto() async {
    try {
      DocumentSnapshot documentSnapshot = await _firestore
          .collection('All posts')
          .doc('Global Post')
          .get();

      if (documentSnapshot.exists) {
        dynamic data = documentSnapshot.data();
        if (data != null) {
          List<dynamic> posts = (data['posts'] as List?) ?? [];

          setState(() {
            profilephotos = posts
                .map((post) => post['profile photo'].toString())
                .toList();
          });
        }
      }
    } catch (e) {
      print('Error fetching profile photo: $e');
    }
  }

  Future<void> fetchusernames() async {
    try {
      DocumentSnapshot documentSnapshot = await _firestore
          .collection('All posts')
          .doc('Global Post')
          .get();

      if (documentSnapshot.exists) {
        dynamic data = documentSnapshot.data();
        if (data != null) {
          List<dynamic> posts = (data['posts'] as List?) ?? [];

          setState(() {
            usernames = posts.map((post) => post['username'].toString()).toList();
          });
        }
      }
    } catch (e) {
      print('Error fetching usernames: $e');
    }
  }

  Future<void> fetchcaptions() async {
    try {
      DocumentSnapshot documentSnapshot = await _firestore
          .collection('All posts')
          .doc('Global Post')
          .get();

      if (documentSnapshot.exists) {
        dynamic data = documentSnapshot.data();
        if (data != null) {
          List<dynamic> posts = (data['posts'] as List?) ?? [];

          setState(() {
            captions = posts.map((post) => post['caption'].toString()).toList();
          });
        }
      }
    } catch (e) {
      print('Error fetching captions: $e');
    }
  }

  Future<void> fetchImages() async {
    try {
      DocumentSnapshot documentSnapshot = await _firestore
          .collection('All posts')
          .doc('Global Post')
          .get();

      if (documentSnapshot.exists) {
        dynamic data = documentSnapshot.data();
        if (data != null) {
          List<dynamic> posts = (data['posts'] as List?) ?? [];

          setState(() {
            imageUrls = posts.map((post) => post['imageUrl'].toString()).toList();
            isLoading = true;
          });
        }
      }
    } catch (e) {
      print('Error fetching images: $e');
    }
  }

  Future<void> updateFirestoreLikedUsers(int index, List<String> newLikedUsers) async {
    final String currentUserUid = _auth.currentUser?.uid ?? '';
    try {
      CollectionReference allPostsCollection =
      FirebaseFirestore.instance.collection('All posts');
      DocumentReference postDocRef = allPostsCollection.doc('post$index');
      DocumentSnapshot postDoc = await postDocRef.get();
      Map<String, dynamic> postData = postDoc.data() as Map<String, dynamic>? ?? {};
      List<dynamic>? existingLikedUsersDynamic = postData['likedUsers'];
      List<String> existingLikedUsers =
          existingLikedUsersDynamic?.cast<String>() ?? [];
      bool userLiked = existingLikedUsers.contains(currentUserUid);

      if (userLiked) {
        existingLikedUsers.remove(currentUserUid);
      } else {
        existingLikedUsers.add(currentUserUid);
      }

      postData['likedUsers'] = existingLikedUsers;
      await postDocRef.set(postData);

      // Fetch the updated likedUsers count
      int likedUsersCount = existingLikedUsers.length;

      // Update UI with the likedUsers count
      updateUIWithLikedUsersCount(index, likedUsersCount);

      print('Firestore update successful');
    } catch (e) {
      print('Error updating Firestore: $e');
    }
  }

  void updateUIWithLikedUsersCount(int index, int count) {
    setState(() {
      likedUsers[index] = likedUsers[index] ?? [];
      likedUsers[index].length = count;
    });
  }

  @override
  Widget build(BuildContext context) {
    final String currentUserUid = _auth.currentUser?.uid ?? '';

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        automaticallyImplyLeading: false,
        title: Text(
          'FotoFusion',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 20),
            Column(
              children: List.generate(min(numberOfPosts, likedUsers.length), (index) {
                return Column(
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: Colors.black,
                          child: Image.network(
                            profilephotos[index],
                            height: 40,
                            width: 40,
                          ),
                        ),
                        SizedBox(width: 10),
                        Text(
                          usernames[index],
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Image.network(
                      imageUrls[index],
                      height: 600,
                      width: 600,
                    ),

                    SizedBox(height: 10),
                    Row(
                      children: [
                        SizedBox(width: 10),
                        Text(
                          usernames[index],
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 10),
                        Text(
                          captions[index],
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        SizedBox(
                          width: 10,
                        ),
                        IconButton(
                          onPressed: () async {
                            List<String> currentLikedUsers = likedUsers[index];
                            final bool userLiked = currentLikedUsers.contains(currentUserUid);

                            if (userLiked) {
                              currentLikedUsers.remove(currentUserUid);
                            } else {
                              currentLikedUsers.add(currentUserUid);
                            }

                            await updateFirestoreLikedUsers(index, currentLikedUsers);
                          },
                          icon: likedUsers[index].contains(currentUserUid) ? Icon(
                            Icons.favorite,
                            color: Colors.red,
                            size: 30,
                          ) : Icon(
                            Icons.favorite_border,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                        // Display the like count for each photo

                        if(likedUsers[index]?.length==1)
                          Text(
                            '${likedUsers[index]?.length ?? 0} Like',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        if(likedUsers[index].length>1)
                          Text(
                            '${likedUsers[index]?.length ?? 0} Likes',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                      ],
                    ),
                    SizedBox(height: 30),
                  ],
                );
              }),
            ),
            SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: Homepage(),
  ));
}
