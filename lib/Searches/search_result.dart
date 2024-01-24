import 'dart:io';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:fotofusion/account%20page/edit_profile.dart';
import 'package:fotofusion/pages/search_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';

class Searchresult extends StatefulWidget {
  final String userid;

  Searchresult({required this.userid});

  @override
  State<Searchresult> createState() => _SearchresultState();
}

class _SearchresultState extends State<Searchresult> {
  FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String username = 'Loading';
  String name = 'Loading';
  String? _imageUrl;
  bool _uploading = false;
  List<String> locations=[];
  bool isverified=false;
  String link = '';
  Future<void> fetchlink() async {
    final user = _auth.currentUser;
    try {
      final docsnap =
      await _firestore.collection('User Details').doc(widget.userid).get();
      if (docsnap.exists) {
        setState(() {
          link = docsnap.data()?['link'];
        });
        print(link);
      }
    } catch (e) {
      print('link error:$e');
    }
  }
  int count=0;
  int followercount=0;
  bool isfollowed = false;

  Future<void> fetchFollowers() async {
    final user = _auth.currentUser;
    try {
      DocumentSnapshot snapshot = await _firestore.collection('Followers').doc(widget.userid).get();

      if (snapshot.exists) {
        var followersData = snapshot.data() as Map<String, dynamic>?;

        if (followersData != null && followersData['Followers'] != null) {
          List<dynamic> followers = followersData['Followers'];
          isfollowed = followers.any((follower) => follower['followerUid'] == user?.uid);
        }
      }
    } catch (e) {
      print('Error fetching followers: $e');
    }
  }
  int following=0;
  Future<void> updatefollower() async {
    final user = _auth.currentUser;
    await fetchfollowerscount();
    setState(() {
      followerscount += 1;
      following += 1; // Increment the following count
    });

    await _firestore.collection('Followers Count').doc(widget.userid).set({
      'followers count': followerscount,
    });

    await _firestore.collection('Users Followers Count').doc(user!.uid).set({
      'followers count': following,
    });

    await _firestore.collection('Followers').doc(widget.userid).set({
      'Followers': FieldValue.arrayUnion([
        {
          'followerUid': user.uid,
        }
      ]),
    }, SetOptions(merge: true));
  }
  int followerscount=0;
  Future<void>fetchfollowerscount() async{
    final user=_auth.currentUser;
    final docsnap=await _firestore.collection('Followers Count').doc(widget.userid).get();
    if(docsnap.exists){
      setState(() {
        followerscount=docsnap.data()?['followers count'];
      });
    }
  }
  Future<void> followersCount() async{
    await fetchfollowerscount();
    setState(() {
      followerscount+=1;
    });
    final user=_auth.currentUser;
    await _firestore.collection('Followers Count').doc(widget.userid).set({
      'followers count':followerscount,
    });

  }
  Future<void> fetchpostscount() async{
    final user=_auth.currentUser;
    final docsnap=await _firestore.collection('Number of posts').doc(widget.userid).get();
    if(docsnap.exists){
      setState(() {
        count=docsnap.data()?['post count'];
      });
    }
  }
  Future<void> fetchverification() async{
    final docsnap=await _firestore.collection('Verifications').doc(widget.userid).get();
    if(docsnap.exists){
      setState(() {
        isverified=docsnap.data()?['isverified'];
      });
    }
  }
  final ImagePicker _imagePicker = ImagePicker();
  File? _image;
  String location='';
  final FirebaseStorage _storage = FirebaseStorage.instance;
  List<String> imageUrls = [];
  List<String> captions=[];
  Future<void> fetchusername()async{
    final user=_auth.currentUser;
    try{
      final docsnap=await _firestore.collection('User Details').doc(widget.userid).get();
      if(docsnap.exists){
        setState(() {
          username=docsnap.data()?['user name'];
          name=docsnap.data()?['user names'];

        });
        print('user id ${widget.userid}');
      }
    }catch(e){
      print(e);
    }
  }
  void checkFollowers() async {
    await fetchFollowers();
    print('Is followed: $isfollowed');
  }
  @override
  void initState() {
    super.initState();
    fetchusername();
    updateImagesPeriodically();
    _loadProfilePicture();
    fetchlocations();
    fetchverification();
    fetchbio();
    fetchlink();
    fetchuserid();
    fetchFollowers();
    checkFollowers();
    fetchfollowerscount();
    fetchfollowerscount();
  }
  Future<void> unfollow() async {
    final user = _auth.currentUser;
    await fetchfollowerscount();
    setState(() {
      followerscount -= 1;
      following -= 1; // Decrement the following count
    });

    await _firestore.collection('Followers Count').doc(widget.userid).set({
      'followers count': followerscount,
    });

    await _firestore.collection('Users Followers Count').doc(user!.uid).set({
      'followers count': following,
    });

    await _firestore.collection('Followers').doc(widget.userid).set({
      'Followers': FieldValue.arrayRemove([
        {
          'followerUid': user.uid,
        }
      ]),
    }, SetOptions(merge: true));
  }
  int followerscounts=0;
  Future<void>fetchfollowerscounts() async{
    final user=_auth.currentUser;
    final docsnap=await _firestore.collection('Followers Count').doc(widget.userid).get();
    if(docsnap.exists){
      setState(() {
        followerscounts=docsnap.data()?['followers count'];
      });
    }
  }
  bool sameuser=false;
  Future<void> fetchuserid() async{
    try{
      final user=_auth.currentUser;
      if(user!.uid==widget.userid){
        setState(() {
          sameuser=true;
        });
        print('same user:$sameuser');
      }
    }catch(e){
      print('error same user:$e');
    }
  }
  Future<void> updateImagesPeriodically() async {
    while (true) {
      await Future.delayed(Duration(seconds: 2));
      fetchImages();
      fetchcaptions();
      fetchpostscount();
      fetchFollowers();
    }
  }
  int followers=0;

  Future<void> _loadProfilePicture() async {
    final user = _auth.currentUser;
    if (user != null) {
      try {
        final docSnapshot =
        await _firestore.collection('profile_pictures').doc(widget.userid).get();
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
  Future<void> fetchcaptions() async {
    final user = _auth.currentUser;

    try {
      DocumentSnapshot documentSnapshot = await _firestore
          .collection('Posts')
          .doc(widget.userid)
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
      print('Error fetching caption: $e');
    }
  }
  Future<void> fetchlocations() async {
    final user = _auth.currentUser;

    try {
      DocumentSnapshot documentSnapshot = await _firestore
          .collection('Posts')
          .doc(widget.userid)
          .get();

      if (documentSnapshot.exists) {
        dynamic data = documentSnapshot.data();
        if (data != null) {
          List<dynamic> posts = (data['posts'] as List?) ?? [];
          setState(() {
            locations = posts.map((post) => post['location'].toString()).toList();
          });
        }
      }
    } catch (e) {
      print('Error fetching caption: $e');
    }
  }
  Future<void> fetchImages() async {
    final user = _auth.currentUser;

    try {
      DocumentSnapshot documentSnapshot = await _firestore
          .collection('Posts')
          .doc(widget.userid)
          .get();

      if (documentSnapshot.exists) {
        dynamic data = documentSnapshot.data();
        if (data != null) {
          List<dynamic> posts = (data['posts'] as List?) ?? [];
          setState(() {
            imageUrls = posts.map((post) => post['imageUrl'].toString()).toList();
          });
        }
      }
    } catch (e) {
      print('Error fetching images: $e');
    }
  }
  String userbio = '';
  Future<void> fetchbio() async {
    final user = _auth.currentUser;
    try {
      final docsnap =
      await _firestore.collection('User Details').doc(widget.userid).get();
      if (docsnap.exists) {
        setState(() {
          userbio = docsnap.data()?['bio'];
        });
      }
    } catch (e) {
      print('bio error:$e');
    }
  }
  @override
  Widget build(BuildContext context) {
    String userId = widget.userid;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        automaticallyImplyLeading: true,
        leading: IconButton(onPressed: (){
          Navigator.push(context, MaterialPageRoute(builder: (context) => Search(),));
        },
            icon: Icon(CupertinoIcons.back,color: CupertinoColors.white,)),
        backgroundColor: Colors.black,
        title: Row(
          children: [
            Text(username,style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 20),),
            SizedBox(
              width: 5,
            ),
            if(isverified)
              Image.network('https://emkldzxxityxmjkxiggw.supabase.co/storage/v1/object/public/Grovito/480-4801090_instagram-verified-badge-png-instagram-verified-icon-png-removebg-preview.png',
              height: 40,
                width: 40,
              )
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: 15,
            ),
            Row(
              children: [
                SizedBox(
                  width: 20,
                ),
                _uploading
                    ? CircularProgressIndicator(
                  color: Colors.red,
                ) // Show the progress indicator while uploading
                    : _imageUrl == null
                    ? ClipOval(
                  child: Container(
                    width: 110, // Instagram-like dimensions
                    height: 110,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 3, // Border width
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
                    width: 110, // Instagram-like dimensions
                    height: 110,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 3, // Border width
                      ),
                    ),
                    child: Image.network(
                      _imageUrl!,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SizedBox(
                  width: 30,
                ),
                Align(
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$count',
                        style: TextStyle(color: CupertinoColors.white, fontWeight: FontWeight.bold),
                      ),
                      if(count==0 || count==1)
                        Text(
                          'Post',
                          style: TextStyle(color: CupertinoColors.white, fontWeight: FontWeight.bold),
                        ),
                      if(count>1)
                        Text(
                          'Posts',
                          style: TextStyle(color: CupertinoColors.white, fontWeight: FontWeight.bold),
                        ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 30,
                ),
                Column(
                  children: [
                    SizedBox(
                      height: 4,
                    ),

                    Text('$followerscount',style: TextStyle(color: CupertinoColors.white, fontWeight: FontWeight.bold),),
                    if(followerscount<=1)
                      Text('Follower',style: TextStyle(color: CupertinoColors.white, fontWeight: FontWeight.bold),),
                    if(followerscount>1)
                      Text('Followers',style: TextStyle(color: CupertinoColors.white, fontWeight: FontWeight.bold),)
                  ],
                ),
                SizedBox(
                  width: 30,
                ),
                Column(
                  children: [
                    SizedBox(
                      height: 4,
                    ),

                    Text('$following',style: TextStyle(color: CupertinoColors.white, fontWeight: FontWeight.bold),),
                    if(following<=1)
                      Text('Following',style: TextStyle(color: CupertinoColors.white, fontWeight: FontWeight.bold),),
                    if(following>1)
                      Text('Following',style: TextStyle(color: CupertinoColors.white, fontWeight: FontWeight.bold),)
                  ],
                )
              ],
            ),
            SizedBox(
              height: 15,
            ),
            Row(
              children: [
                SizedBox(
                  width: 20,
                ),
                Text(
                  name!,
                  style: TextStyle(color: Colors.white, fontSize: 15),
                ),
              ],
            ),
            SizedBox(
              height: 15,
            ),
            Row(
              children: [
                SizedBox(width: 20),

                Text(
                  userbio != null && userbio!.length > 50
                      ? '${userbio!.substring(0, 50)}\n${userbio!.substring(50)}'
                      : userbio!,
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
            Row(
              children: [
                SizedBox(
                  width: 9,
                ),
                TextButton(
                  onPressed: () {
                    // Open the link
                    _launchURl();
                  },
                  child: Text(
                    '$link',
                    style: TextStyle(
                      color: Colors.white,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                SizedBox(
                  width: 20,
                ),
                if(!sameuser)
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(onPressed: ()async{
                          isfollowed?unfollow():updatefollower();
                          fetchFollowers();
                        },
                        style: ButtonStyle(
                          backgroundColor: isfollowed?MaterialStatePropertyAll(Colors.grey[800]):MaterialStatePropertyAll(Colors.blue)
                        ),    
                            child: isfollowed?Text('Following',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),):
                            Text('Follow',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),)
                        )
                      ],
                    ),
                  ),
                if (sameuser)
                  Center(
                    child: Container(
                      // Adjust the width of the container as needed
                      width: 200,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => Editprofile()),
                              );
                            },
                            style: ButtonStyle(
                              backgroundColor: MaterialStatePropertyAll(Colors.grey[900]),
                            ),
                            child: Text(
                              'Edit Profile',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )

              ],
            ),
            SizedBox(
              height: 20,
            ),
            // Inside your build method
            for (int i = 0; i < imageUrls.length; i += 2)
              Column(
                children: [
                  SizedBox(height: 20), // Add a gap of 20 pixels between new rows
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(width: 20),
                      if (i < imageUrls.length)
                        ElevatedButton(
                          onPressed: () {
                            // Navigator.push(
                            //   context,
                            //   MaterialPageRoute(
                            //     builder: (context) => detailpostpage(startIndex: i),
                            //   ),
                            // );
                          },
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(Colors.black),
                          ),
                          child: Image.network(
                            imageUrls[i],
                            width: 120,
                            height: 120,
                            fit: BoxFit.cover,
                          ),
                        ),
                      SizedBox(width: 10),
                      if (i + 1 < imageUrls.length)
                        ElevatedButton(
                          onPressed: () {
                            // Navigator.push(
                            //   context,
                            //   MaterialPageRoute(
                            //     builder: (context) => detailpostpage(startIndex: i + 1),
                            //   ),
                            // );
                          },
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(Colors.black),
                          ),
                          child: Image.network(
                            imageUrls[i + 1],
                            width: 120,
                            height: 120,
                            fit: BoxFit.cover,
                          ),
                        ),
                      SizedBox(width: 10), // Add a gap of 10 pixels at the end of each row
                    ],
                  ),
                ],
              ),
// Add a gap of 20 pixels between new rows

            // Add a gap of 20 pixels between new rows
          ],
        ),
      ),
    );
  }
  Future<void> _launchURl() async {
    final user = _auth.currentUser;
    try {
      await fetchlink();
      final Uri _url = Uri.parse(link);
      if (!await launchUrl(_url)) {
        throw "Cannot Launch $_url";
      }
    } catch (e) {
      print('Error launching URL: $e');
    }
  }
}

