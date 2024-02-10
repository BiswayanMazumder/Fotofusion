import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:shimmer_image/shimmer_image.dart';
class Saved_post extends StatefulWidget {
  const Saved_post({Key? key}) : super(key: key);

  @override
  State<Saved_post> createState() => _Saved_postState();
}

class _Saved_postState extends State<Saved_post> {
  List<String> captions = [];
  List<String> usernames = [];
  List<String> profilephotos = [];
  FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<String> uids=[];
  Future<void> fetchuids() async {
    final user = _auth.currentUser;

    try {
      DocumentSnapshot documentSnapshot = await _firestore
          .collection('Saved')
          .doc(user?.uid)
          .get();

      if (documentSnapshot.exists) {
        dynamic data = documentSnapshot.data();
        if (data != null) {
          List<dynamic> posts = (data['Saved'] as List?) ?? [];
          setState(() {
            uids =
                posts.map((post) => post['uid'].toString()).toList();
          });
        }
      }
      print('Uids saved $uids');
    } catch (e) {
      print('Error fetching uid: $e');
    }
  }
  Future<void> fetchprofilephotos()async{
    await fetchuids();
    for(String Uid in uids){
      final docsnap=await _firestore.collection('profile_pictures').doc(Uid).get();
      if(docsnap.exists){
        setState(() {
          String result=docsnap.data()?['url_user1'];
          profilephotos.add(result);
        });
      }
      else{
        profilephotos.add('https://i.pinimg.com/736x/66/b8/58/66b858099df3127e83cb1f1168f7a2c6.jpg');
      }
    }
    print('Saved profile photo $profilephotos');
  }
  Future<void> fetchusernames() async {
    final user = _auth.currentUser;
    try {
      DocumentSnapshot documentSnapshot = await _firestore
          .collection('Saved')
          .doc(user?.uid)
          .get();

      if (documentSnapshot.exists) {
        dynamic data = documentSnapshot.data();
        if (data != null) {
          List<dynamic> posts = (data['Saved'] as List?) ?? [];
          setState(() {
            usernames =
                posts.map((post) => post['username'].toString()).toList();
          });
        }
      }
      print('username saved $usernames');
    } catch (e) {
      print('Error fetching uid: $e');
    }
  }
  List<String> imageUrls=[];
  Future<void> fetchimageurl() async {
    final user = _auth.currentUser;

    try {
      DocumentSnapshot documentSnapshot = await _firestore
          .collection('Saved')
          .doc(user?.uid)
          .get();

      if (documentSnapshot.exists) {
        dynamic data = documentSnapshot.data();
        if (data != null) {
          List<dynamic> posts = (data['Saved'] as List?) ?? [];
          setState(() {
            imageUrls =
                posts.map((post) => post['image link'].toString()).toList();
          });
        }
      }
      print('Image url saved $imageUrls');
    } catch (e) {
      print('Error fetching uid: $e');
    }
  }
  Future<void> fetchcaptions() async {
    final user = _auth.currentUser;

    try {
      DocumentSnapshot documentSnapshot = await _firestore
          .collection('Saved')
          .doc(user?.uid)
          .get();

      if (documentSnapshot.exists) {
        dynamic data = documentSnapshot.data();
        if (data != null) {
          List<dynamic> posts = (data['Saved'] as List?) ?? [];
          setState(() {
            captions =
                posts.map((post) => post['captions'].toString()).toList();
          });
        }
      }
      print('captions saved $captions');
    } catch (e) {
      print('Error fetching uid: $e');
    }
  }
  List<String> locations=[];
  Future<void> fetchlocations() async {
    final user = _auth.currentUser;

    try {
      DocumentSnapshot documentSnapshot = await _firestore
          .collection('Saved')
          .doc(user?.uid)
          .get();

      if (documentSnapshot.exists) {
        dynamic data = documentSnapshot.data();
        if (data != null) {
          List<dynamic> posts = (data['Saved'] as List?) ?? [];
          setState(() {
            locations =
                posts.map((post) => post['location'].toString()).toList();
          });
        }
      }
      print('locations saved $locations');
    } catch (e) {
      print('Error fetching uid: $e');
    }
  }
  Future<void> updateImagesPeriodically() async {
    while (true) {
      await Future.delayed(Duration(seconds: 2));
      await fetchusernames();
      await fetchcaptions();
      await fetchimageurl();
      await fetchlocations();
    }
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchuids();
    fetchprofilephotos();
    fetchusernames();
    fetchimageurl();
    fetchcaptions();
    fetchlocations();
    updateImagesPeriodically();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        actions: [
          if (imageUrls.isNotEmpty)
            IconButton(
              onPressed: () async {
                final user = _auth.currentUser;
                await _firestore.collection('Saved').doc(user!.uid).delete();
              },
              icon: Icon(
                CupertinoIcons.delete,
                color: Colors.red,
              ),
            )
        ],
        title: Text(
          'Saved Posts',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.black,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(
            CupertinoIcons.back,
            color: Colors.white,
          ),
        ),
      ),
      body: LiquidPullToRefresh(
        onRefresh: fetchusernames,
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                SizedBox(
                  height: 30,
                ),
                // Conditionally rendering circular progress indicator
                if (usernames.isEmpty ||
                    captions.isEmpty ||
                    imageUrls.isEmpty ||
                    locations.isEmpty)
                  Center(
                    child: CircularProgressIndicator(
                      color: Colors.white,
                    ),
                  )
                else
                // Render the data once it's loaded
                  for (int i = 0; i < imageUrls.length; i++)
                    Column(
                      children: [
                        Row(
                          children: [
                            SizedBox(
                              width: 30,
                            ),
                            CircleAvatar(
                              radius: 20,
                              backgroundImage: NetworkImage(
                                profilephotos[i],
                              ),
                            ),
                            SizedBox(
                              width: 20,
                            ),
                            Text(
                              usernames[i],
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        if (locations.isNotEmpty)
                          Row(
                            children: [
                              SizedBox(
                                width: 90,
                              ),
                              Text(
                                locations[i],
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        SizedBox(
                          height: 10,
                        ),
                        ProgressiveImage(
                          width: 350.0,
                          baseColor: Colors.grey.shade900,
                          highlightColor: Colors.white,
                          imageError: 'Failed To Load Image',
                          image: imageUrls[i],
                          height: 400.0,
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              onPressed: () async {
                                print('deleted image $i');
                                try {
                                  final user = _auth.currentUser;
                                  // Get a reference to the document
                                  DocumentReference docRef = _firestore
                                      .collection('Saved')
                                      .doc(user!.uid);

                                  // Fetch the current data
                                  DocumentSnapshot doc = await docRef.get();
                                  Map<String, dynamic> data =
                                  doc.data() as Map<String, dynamic>;

                                  // Remove the specific item from the list based on index 'i'
                                  List<dynamic> savedData =
                                  List.from(data['Saved']);
                                  savedData.removeAt(i);

                                  // Update the Firestore document with the modified list
                                  await docRef.set({'Saved': savedData});
                                } catch (e) {
                                  print('Error deleting $e');
                                }
                              },
                              icon: Icon(CupertinoIcons.delete, color: Colors.red),
                            )
                          ],
                        ),
                        SizedBox(
                          height: 50,
                        ),
                      ],
                    ),
                SizedBox(
                  height: 50,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
