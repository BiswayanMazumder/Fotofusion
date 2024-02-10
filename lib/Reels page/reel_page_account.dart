import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fotofusion/account%20page/edit_profile.dart';
import 'package:fotofusion/main.dart';
import 'package:fotofusion/navbar.dart';
import 'package:fotofusion/posts/post_page.dart';
import 'package:fotofusion/posts/reels.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

import '../Subscribers_only/subs_special.dart';
class Reelpage_account extends StatefulWidget {
  const Reelpage_account({Key? key}) : super(key: key);

  @override
  State<Reelpage_account> createState() => _Reelpage_accountState();
}

class _Reelpage_accountState extends State<Reelpage_account> {
  FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String username = 'Loading';
  String name = 'Loading';
  String? _imageUrl;
  File? _image;
  bool isverified = false;
  bool _uploading = false;
  List<String> subsurls=[];
  Future<void>fetchsubsurls() async{
    final user = _auth.currentUser;

    try {
      DocumentSnapshot documentSnapshot = await _firestore
          .collection('Subscriber Specific')
          .doc(user?.uid)
          .get();

      if (documentSnapshot.exists) {
        dynamic data = documentSnapshot.data();
        if (data != null) {
          List<dynamic> posts = (data['posts'] as List?) ?? [];
          setState(() {
            subsurls = posts.map((post) => post['imageUrl'].toString()).toList();
          });
        }
      }
    } catch (e) {
      print('Error fetching images: $e');
    }
  }
  late VideoPlayerController _controller;
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

  Future<void> fetchverification() async {
    final user = _auth.currentUser;
    final docsnap = await _firestore.collection('Verifications')
        .doc(user!.uid)
        .get();
    if (docsnap.exists) {
      setState(() {
        isverified = docsnap.data()?['isverified'];
      });
    }
  }
  late ChewieController _chewieController;
  int followerscount = 0;
  @override
  void dispose() {
    _chewieController.dispose();
    super.dispose();
  }
  Future<void> fetchfollowerscount() async {
    final user = _auth.currentUser;
    final docsnap = await _firestore.collection('Followers Count').doc(
        user!.uid).get();
    if (docsnap.exists) {
      setState(() {
        followerscount = docsnap.data()?['followers count'];
      });
    }
  }

  int count = 0;

  Future<void> fetchpostscount() async {
    final user = _auth.currentUser;
    final docsnap = await _firestore.collection('Number of posts').doc(
        user!.uid).get();
    if (docsnap.exists) {
      setState(() {
        count = docsnap.data()?['post count'];
      });
    }
  }

  String userbio = '';

  Future<void> fetchusername() async {
    final user = _auth.currentUser;
    try {
      final docsnap =
      await _firestore.collection('User Details').doc(user!.uid).get();
      if (docsnap.exists) {
        setState(() {
          username = docsnap.data()?['user name'];
          name = docsnap.data()?['user names'];
        });
      }
    } catch (e) {
      print(e);
    }
  }

  int following = 0;

  Future<void> fetchfollowing() async {
    final user = _auth.currentUser;
    final docsnap = await _firestore.collection('Users Followers Count').doc(
        user!.uid).get();
    if (docsnap.exists) {
      setState(() {
        following = docsnap.data()?['followers count'];
      });
    }
  }

  String link = '';

  Future<void> fetchlink() async {
    final user = _auth.currentUser;
    try {
      final docsnap =
      await _firestore.collection('User Details').doc(user!.uid).get();
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

  Future<void> updateImagesPeriodically() async {
    while (true) {
      await Future.delayed(Duration(seconds: 2));
      fetchfollowerscount();
      fetchfollowing();
      fetchverification();
      fetchfollowings();
      fetchfollowerss();
    }
  }
  List<String> imageUrls = [];

  Future<void> fetchImages() async {
    final user = _auth.currentUser;

    try {
      DocumentSnapshot documentSnapshot = await _firestore
          .collection('Posts')
          .doc(user?.uid)
          .get();

      if (documentSnapshot.exists) {
        dynamic data = documentSnapshot.data();
        if (data != null) {
          List<dynamic> posts = (data['posts'] as List?) ?? [];
          setState(() {
            imageUrls =
                posts.map((post) => post['imageUrl'].toString()).toList();
          });
        }
      }
    } catch (e) {
      print('Error fetching images: $e');
    }
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

  List<String> reelsurls = [];

  Future<void> fetchreels() async {
    final user = _auth.currentUser;

    try {
      DocumentSnapshot documentSnapshot = await _firestore
          .collection('Reels')
          .doc(user?.uid)
          .get();

      if (documentSnapshot.exists) {
        dynamic data = documentSnapshot.data();
        if (data != null) {
          List<dynamic> posts = (data['reels'] as List?) ?? [];
          setState(() {
            reelsurls =
                posts.map((post) => post['mediaUrl'].toString()).toList();
          });
        }
      }
      print('reels $reelsurls');
    } catch (e) {
      print('Error fetching images: $e');
    }
  }

  Future<void> fetchbio() async {
    final user = _auth.currentUser;
    try {
      final docsnap =
      await _firestore.collection('User Details').doc(user!.uid).get();
      if (docsnap.exists) {
        setState(() {
          userbio = docsnap.data()?['bio'];
        });
      }
    } catch (e) {
      print('bio error:$e');
    }
  }
  List<String> followings=[];
  Future<void> fetchfollowings() async {
    final user = _auth.currentUser;
    try {
      DocumentSnapshot documentSnapshot = await _firestore
          .collection('Following')
          .doc(user?.uid)
          .get();

      if (documentSnapshot.exists) {
        dynamic data = documentSnapshot.data();
        if (data != null) {
          List<dynamic> posts = (data['Followers'] as List?) ?? [];
          setState(() {
            followings =
                posts.map((post) => post['followerUid'].toString()).toList();
          });
        }
      }
      print('following $followings');
    } catch (e) {
      print('Error fetching followers fetchfollowers: $e');
    }

  }
  List<String> followerss=[];
  Future<void> fetchfollowerss() async {
    final user = _auth.currentUser;
    try {
      DocumentSnapshot documentSnapshot = await _firestore
          .collection('Followers')
          .doc(user?.uid)
          .get();

      if (documentSnapshot.exists) {
        dynamic data = documentSnapshot.data();
        if (data != null) {
          List<dynamic> posts = (data['Followers'] as List?) ?? [];
          setState(() {
            followerss =
                posts.map((post) => post['followerUid'].toString()).toList();
          });
        }
      }
      print('followers $followerss');
    } catch (e) {
      print('Error fetching followers fetchfollowers: $e');
    }

  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchverification();
    fetchfollowings();
    fetchfollowerss();
    fetchusername();
    fetchfollowing();
    fetchsubsurls();
    fetchfollowerscount();
    fetchlink();
    fetchpostscount();
    _loadProfilePicture();
    fetchbio();
    fetchreels();
    fetchImages();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Row(
          children: [
            Text(
              username!,
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(
              width: 5,
            ),
            if(isverified)
              Image.network(
                'https://emkldzxxityxmjkxiggw.supabase.co/storage/v1/object/public/Grovito/480-4801090_instagram-verified-badge-png-instagram-verified-icon-png-removebg-preview.png',
                height: 30,
                width: 30,
              )
          ],
        ),
        backgroundColor: Colors.black,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(onPressed: () {
            showDialog(context: context, builder: (context) {
              return AlertDialog(
                backgroundColor: Colors.white,
                title: Center(
                  child: Text('Really want to sign out?', style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20
                  ),),
                ),
                actions: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Do you really want to sign out?', style: TextStyle(
                          fontWeight: FontWeight.w300
                      ),),
                      SizedBox(
                        height: 20,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(onPressed: () {
                            Navigator.pop(context);
                          },
                            child: Text('Cancel', style: TextStyle(
                                color: Colors.black
                            ),
                            ),
                            style: ButtonStyle(
                                backgroundColor: MaterialStatePropertyAll(
                                    Colors.green)),
                          ),
                          ElevatedButton(onPressed: () {
                            _auth.signOut();
                            Navigator.pushReplacement(context,
                                MaterialPageRoute(
                                  builder: (context) => MyHomePage(),));
                          },
                            child: Text('Sign Out', style: TextStyle(
                                color: Colors.white
                            ),
                            ),
                            style: ButtonStyle(
                                backgroundColor: MaterialStatePropertyAll(
                                    Colors.red)),
                          ),
                        ],
                      )
                    ],
                  )
                ],
              );
            },);
          },
              icon: Icon(Icons.logout_rounded, color: Colors.white,)),
          IconButton(
            onPressed: () {
              showDialog(context: context,
                builder: (context) {
                  return AlertDialog(
                    backgroundColor: Colors.black,
                    actions: [
                      SizedBox(
                        height: 20,
                      ),
                      Center(
                        child: TextButton(onPressed: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => Postpage()),
                          );
                        }, child: Text('Upload a Photo',
                          style: TextStyle(color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15
                          ),)),
                      ),
                      Center(
                        child: TextButton(onPressed: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Reels_page(
                                  isImage: false), // Set to true if it's an image
                            ),
                          );
                        }, child: Text(
                          'Upload Reels', style: TextStyle(color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15
                        ),)),
                      )
                    ],
                  );
                },);
            },
            icon: Icon(Icons.add_box_outlined, color: Colors.white, size: 30,),
          )
        ],
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
                        style: TextStyle(color: CupertinoColors.white,
                            fontWeight: FontWeight.bold),
                      ),
                      if(count == 0 || count == 1)
                        Text(
                          'Post',
                          style: TextStyle(color: CupertinoColors.white,
                              fontWeight: FontWeight.bold),
                        ),
                      if(count > 1)
                        Text(
                          'Posts',
                          style: TextStyle(color: CupertinoColors.white,
                              fontWeight: FontWeight.bold),
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
                      height: 2,
                    ),
                    Text('${followerss.length}', style: TextStyle(
                        color: CupertinoColors.white,
                        fontWeight: FontWeight.bold),),
                    if(followerss.length <= 1)
                      Text('Follower', style: TextStyle(
                          color: CupertinoColors.white,
                          fontWeight: FontWeight.bold),),
                    if(followerss.length > 1)
                      Text('Followers', style: TextStyle(
                          color: CupertinoColors.white,
                          fontWeight: FontWeight.bold),)
                  ],
                ),
                SizedBox(
                  width: 20,
                ),
                Column(
                  children: [
                    SizedBox(
                      height: 1,
                    ),
                    Text('${followings.length}', style: TextStyle(
                        color: CupertinoColors.white,
                        fontWeight: FontWeight.bold),),
                    if(followings.length <= 1)
                      Text('Following', style: TextStyle(
                          color: CupertinoColors.white,
                          fontWeight: FontWeight.bold),),
                    if(followings.length > 1)
                      Text('Following', style: TextStyle(
                          color: CupertinoColors.white,
                          fontWeight: FontWeight.bold),)
                  ],
                ),
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
                      ? '${userbio!.substring(0, 50)}\n${userbio!.substring(
                      50)}'
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
                Align(
                  alignment: Alignment.centerLeft,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Editprofile()),
                      );
                    },
                    style: ButtonStyle(
                        backgroundColor: MaterialStatePropertyAll(
                            Colors.grey[900])),
                    child: Text(
                      '        Edit Profile        ',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                SizedBox(
                  width: 20,
                ),

                Align(
                  alignment: Alignment.topRight,
                  child: ElevatedButton(
                    onPressed: () {
                      // Navigator.push(context, MaterialPageRoute(builder: (context) => Homepage()));
                    },
                    style: ButtonStyle(
                        backgroundColor: MaterialStatePropertyAll(
                            Colors.grey[900])),
                    child: Text(
                      '          Settings          ',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                )
              ],
            ),
            SizedBox(
              height: 20,
            ),
            Row(
              children: [
                SizedBox(
                  width: 110,
                ),
                IconButton(onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => NavBar(),));
                }, icon: Icon(CupertinoIcons.photo, color: Colors.grey,)),
                SizedBox(
                  width: 30,
                ),
                if(reelsurls.length > 0)
                  IconButton(onPressed: () {},
                      icon: Icon(Icons.movie, color: Colors.white,)),
                SizedBox(
                  width: 30,
                ),
                if(subsurls.length>0)
                  IconButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => subs_special(),));
                    },
                    icon: Icon(Icons.star_outline, color: Colors.grey),
                  ),
              ],
            ),
            SizedBox(height: 20),
            if (reelsurls.isNotEmpty)
              GridView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 4.0,
                  mainAxisSpacing: 4.0,
                ),
                itemCount: reelsurls.length,
                itemBuilder: (context, index) {
                  VideoPlayerController videoPlayerController =
                  VideoPlayerController.networkUrl(Uri.parse(reelsurls[index]));

                  ChewieController _chewieController = ChewieController(
                    videoPlayerController: videoPlayerController,
                    aspectRatio: 1,
                    autoInitialize: true,
                    autoPlay: true,
                    allowMuting: true,
                    cupertinoProgressColors: ChewieProgressColors(),
                    looping: true,
                    allowedScreenSleep: false,
                    draggableProgressBar: true,
                    allowFullScreen: true,
                    showControls: false, // Set to false to hide controls
                    placeholder: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );

                  // Add error handling
                  videoPlayerController.addListener(() {
                    if (videoPlayerController.value.hasError) {
                      print('Video Player Error: ${videoPlayerController.value.errorDescription}');
                    }
                  });

                  return GestureDetector(
                    onTap: () {
                      // Handle tap on a reel (if needed)
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.5, // Adjust width as needed
                      height: MediaQuery.of(context).size.width * 0.5, // Adjust height as needed
                      child: Chewie(
                        controller: _chewieController,
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}