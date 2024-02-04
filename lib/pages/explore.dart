import 'dart:math';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:video_player/video_player.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({Key? key}) : super(key: key);

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  TextEditingController _searchController = TextEditingController();
  List<String> imageUrls = [];
  List<String> reelsurls = [];
  FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> fetchImages() async {
    final user = _auth.currentUser;

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
          });
        }
      }
      print('reels $imageUrls');
    } catch (e) {
      print('Error fetching images: $e');
    }
  }

  Future<void> updateImagesPeriodically() async {
    while (true) {
      await Future.delayed(Duration(seconds: 2));
      fetchImages();
      fetchReels();
    }
  }

  Future<void> fetchReels() async {
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

          // Initialize Chewie controller
        }
      }
      print('Reels $reelsurls');
    } catch (e) {
      print('Error fetching reels: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    updateImagesPeriodically();
    fetchReels();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
            child: Text(
              'Explore',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              style: TextStyle(color: Colors.white),
              controller: _searchController,
              decoration: InputDecoration(
                fillColor: Colors.grey[900],
                filled: true,
                prefixIcon: Icon(Icons.search, color: Colors.white),
                hintText: 'Search',
                hintStyle: TextStyle(color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: GridView.builder(
              itemCount: imageUrls.length + reelsurls.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 8.0,
                crossAxisSpacing: 8.0,
              ),
              itemBuilder: (context, index) {
                if (index < imageUrls.length) {
                  // Build image widget
                  return Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      image: DecorationImage(
                        image: NetworkImage(imageUrls[index]),
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                } else {
                  // Build video widget
                  int videoIndex = index - imageUrls.length;
                  VideoPlayerController videoPlayerController =
                  VideoPlayerController.network(reelsurls[videoIndex]);

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
                    showControls: false,
                    // Set to false to hide controls
                    placeholder: Center(
                      child: CircularProgressIndicator(color: Colors.white,),
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
                      width: MediaQuery.of(context).size.width * 0.5,
                      height: MediaQuery.of(context).size.width * 0.5,
                      child: Chewie(
                        controller: _chewieController,
                      ),
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
