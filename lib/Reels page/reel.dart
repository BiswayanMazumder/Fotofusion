import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:fotofusion/Searches/search_result.dart';
import 'package:video_player/video_player.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class reels_account extends StatefulWidget {
  @override
  _reels_accountState createState() => _reels_accountState();
}

class _reels_accountState extends State<reels_account> {
  double _currentSliderValue = 0.0;
  List<String> reelsurls = [];
  FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<String> captions = [];
  List<String> Names = [];
  List<String> profilephotos = [];
  late ChewieController _chewieController;
  bool _isVisible = false;
  int _currentVideoIndex = 0;
  bool _liked = false;
  bool _disliked = false;
  bool _isMuted = false;
  List<String> followers=[];
  List<String> follow=[];
  Future<void> fetchfollowers() async {
    await fetchuids();
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
            followers =
                posts.map((post) => post['followerUid'].toString()).toList();
          });
        }
      }
      print('Uid $uids ${uids.length}'); //8
      print('followers $followers ${followers.length}'); //3
      for (int i = 0; i < uids.length; i++) {
        if (uids[i] == user?.uid ) {
          follow.add('True');
        }
        else if(followers.contains(uids[i])){
          follow.add('true');
        }
        else {
          follow.add('false');
        }
      }

      print('follow true/false $follow ${follow.length}');
    } catch (e) {
      print('Error fetching followers: $e');
    }
  }
  @override
  void initState() {
    super.initState();
    fetchcaptions();
    fetchfollowers();
    fetchuids();
    fetchnames();
    fetchverifications();
    fetchprofilephotos();
    _initializeChewieController(_currentVideoIndex);
    Future.delayed(Duration(seconds: 5), () {
      setState(() {
        _isVisible = false;
      });
    });
  }
  bool _fetchingReels = true;
  Future<void> _initializeChewieController(int videoIndex) async {
    // Show circular progress bar while initializing ChewieController and fetching reels
    setState(() {
      _fetchingReels = true;
    });

    await fetchReels();

    if (videoIndex < reelsurls.length) {
      String nextVideoUrl = reelsurls[videoIndex];

      VideoPlayerController videoPlayerController = VideoPlayerController.network(nextVideoUrl);

      ChewieController newController = ChewieController(
        videoPlayerController: videoPlayerController,
        aspectRatio: 9 / 16,
        autoInitialize: true,
        looping: true,
        showControls: false,
        autoPlay: true,
        draggableProgressBar: true,
        allowMuting: true,
      );

      // Update the state with the initialized ChewieController
      setState(() {
        _chewieController = newController;
        _fetchingReels = false; // Set to false once fetching is complet
      });

      await videoPlayerController.initialize();
    } else {
      // If the index is out of bounds, initialize with index 0
      _initializeChewieController(0);
    }
  }
  @override
  void dispose() {
    _chewieController?.dispose(); // Dispose the controller if initialized
    super.dispose();
  }
  List<String> uids=[];
  List<bool> verifications=[];
  Future<void> fetchverifications() async {
    await fetchuids();
    try {
      for (String uids in uids) {
        final docsnap =
        await _firestore.collection('Verifications').doc(uids).get();

        if (docsnap.exists) {
          bool result = docsnap.data()?['isverified'];
          verifications.add(result);
        }
      }

      print('Verification $verifications');
    } catch (error) {
      print('Error in verification: $error');
    }
  }
  Future<void> fetchuids() async {
    final user = _auth.currentUser;

    try {
      DocumentSnapshot documentSnapshot = await _firestore
          .collection('All posts')
          .doc('Global Reels')
          .get();

      if (documentSnapshot.exists) {
        dynamic data = documentSnapshot.data();
        if (data != null) {
          List<dynamic> posts = (data['Reels'] as List?) ?? [];
          setState(() {
            uids =
                posts.map((post) => post['uid'].toString()).toList();
          });
        }
      }
      print('Uids $uids');
    } catch (e) {
      print('Error fetching uid: $e');
    }
  }
  Future<void> fetchReels() async {
    final user = _auth.currentUser;

    try {
      DocumentSnapshot documentSnapshot = await _firestore
          .collection('All posts')
          .doc('Global Reels')
          .get();

      if (documentSnapshot.exists) {
        dynamic data = documentSnapshot.data();
        if (data != null) {
          List<dynamic> posts = (data['Reels'] as List?) ?? [];
          setState(() {
            reelsurls =
                posts.map((post) => post['mediaUrl'].toString()).toList();
          });
        }
      }
      print('Reels $reelsurls');
    } catch (e) {
      print('Error fetching reels: $e');
    }
  }

  Future<void> fetchcaptions() async {
    final user = _auth.currentUser;
    try {
      DocumentSnapshot documentSnapshot = await _firestore
          .collection('All posts')
          .doc('Global Reels')
          .get();

      if (documentSnapshot.exists) {
        dynamic data = documentSnapshot.data();
        if (data != null) {
          List<dynamic> posts = (data['Reels'] as List?) ?? [];
          setState(() {
            captions =
                posts.map((post) => post['caption'].toString()).toList();
          });
        }
      }
      print('Captions $captions');
    } catch (e) {
      print('Error fetching captions: $e');
    }
  }

  Future<void> fetchnames() async {
    final user = _auth.currentUser;
    try {
      DocumentSnapshot documentSnapshot = await _firestore
          .collection('All posts')
          .doc('Global Reels')
          .get();

      if (documentSnapshot.exists) {
        dynamic data = documentSnapshot.data();
        if (data != null) {
          List<dynamic> posts = (data['Reels'] as List?) ?? [];
          setState(() {
            Names =
                posts.map((post) => post['username'].toString()).toList();
          });
        }
      }
      print('Names $Names');
    } catch (e) {
      print('Error fetching captions: $e');
    }
  }

  Future<void> fetchprofilephotos() async {
    await fetchuids();
    try {
      for (String uids in uids) {
        final docsnap =
        await _firestore.collection('profile_pictures').doc(uids).get();

        if (docsnap.exists) {
          String result = docsnap.data()?['url_user1'];
          profilephotos.add(result);
        }
      }

      print('Profile photo $profilephotos');
    } catch (error) {
      print('Error in photo: $error');
    }
  }

  void _checkUserReactions(int videoIndex) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot snapshot =
      await FirebaseFirestore.instance.collection('Bollywood genre likes').doc(user.uid).get();

      if (snapshot.exists) {
        Map<String, dynamic>? userReactions = snapshot.data() as Map<String, dynamic>?;

        if (userReactions != null &&
            userReactions.containsKey(videoIndex.toString())) {
          setState(() {
            _liked = userReactions[videoIndex.toString()]['liked'] ?? false;
            _disliked = userReactions[videoIndex.toString()]['disliked'] ?? false;
          });
        } else {
          setState(() {
            _liked = false;
            _disliked = false;
          });
        }
      }
    }
  }

  void _saveUserReaction(int videoIndex) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance.collection('Bollywood genre likes').doc(user.uid).set({
        videoIndex.toString(): {
          'liked': _liked,
          'disliked': _disliked,
        }
      }, SetOptions(merge: true));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: ListView(
        children: [
          NotificationListener<ScrollNotification>(
            onNotification: (scrollNotification) {
              if (scrollNotification is ScrollEndNotification) {
                // Handle the end of the scroll, if needed.
              }
              return false;
            },
            child: GestureDetector(
              onVerticalDragEnd: (details) {
                if (details.primaryVelocity! > 0) {
                  setState(() {
                    _currentSliderValue = 0.0;
                  });
                  _initializeChewieController(_currentVideoIndex - 1);
                } else if (details.primaryVelocity! < 0) {
                  setState(() {
                    _currentSliderValue = 0.0;
                  });
                  _initializeChewieController(_currentVideoIndex + 1);
                }
              },
              onTap: () {
                setState(() {
                  _isMuted = !_isMuted;
                  _chewieController.setVolume(_isMuted ? 0.0 : 1.0);
                  _isVisible = true;
                });

                Future.delayed(Duration(seconds: 5), () {
                  setState(() {
                    _isVisible = false;
                  });
                });
              },
              onDoubleTap: () {
                setState(() {
                  _liked = !_liked;
                  if (_disliked) _disliked = false;
                });
                _saveUserReaction(_currentVideoIndex);
              },
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_fetchingReels)
                      Center(
                        child: CircularProgressIndicator(color: Colors.white,),
                      ),
                    if (_chewieController != null)
                      AspectRatio(
                        aspectRatio: 9 / 16,
                        child: Chewie(
                          controller: _chewieController,
                        ),
                      ),
                    if (Names.isNotEmpty && profilephotos.isNotEmpty)
                      Align(
                        alignment: Alignment.bottomLeft,
                        child: Row(
                          children: [
                            SizedBox(
                              width: 10,
                            ),
                            CircleAvatar(
                              backgroundImage: NetworkImage(
                                profilephotos[_currentVideoIndex],
                              ),
                              backgroundColor: Colors.transparent,
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Row(
                              children: [
                                TextButton(onPressed: (){
                                  print('uid is ${uids[_currentVideoIndex]}');
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => Searchresult(userid: uids[_currentVideoIndex]),));
                                }, child: Text(
                                  Names[_currentVideoIndex],
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w300,
                                  ),)
                                ),
                                if(verifications[_currentVideoIndex])
                                  Image.network('https://emkldzxxityxmjkxiggw.supabase.co/storage/v1/object/public/Grovito/480-4801090_instagram-verified-badge-png-instagram-verified-icon-png-removebg-preview.png',
                                    height: 30,
                                    width: 30,
                                  ),
                                if(follow[_currentVideoIndex]=='true')
                                  Row(
                                    children: [
                                      Text('.',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),
                                      ElevatedButton(onPressed: (){},
                                          child: Text('Followed',style: TextStyle(color: Colors.white,fontWeight: FontWeight.w500,fontSize: 15),),
                                          style: ButtonStyle(
                                              backgroundColor: MaterialStatePropertyAll(Colors.black)
                                          ),
                                        ),
                                    ],
                                  ),
                                if(follow[_currentVideoIndex]=='false')
                                  Row(
                                    children: [
                                      Text('.',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),
                                      ElevatedButton(onPressed: (){},
                                          child: Text('Follow',style: TextStyle(color: Colors.white,fontWeight: FontWeight.w500),),
                                          style: ButtonStyle(
                                              backgroundColor: MaterialStatePropertyAll(Colors.black)
                                          ),
                                        ),
                                    ],
                                  ),
                              ],
                            ),
                            SizedBox(
                              height: 10,
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}