import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({Key? key}) : super(key: key);

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  TextEditingController _searchController = TextEditingController();
  List<String> imageUrls = [];
  List<double> itemHeights = [];
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
            itemHeights = List.generate(imageUrls.length, (index) => Random().nextDouble() * 300 + 100);
          });
        }
      }
      print('images $imageUrls');
    } catch (e) {
      print('Error fetching images: $e');
    }
  }

  Future<void> updateImagesPeriodically() async {
    while (true) {
      await Future.delayed(Duration(seconds: 2));
      fetchImages();
    }
  }

  @override
  void initState() {
    super.initState();
    updateImagesPeriodically();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          'Explore',
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.search,
              color: Colors.black,
            ),
            onPressed: () {
              // Handle search action
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              style: TextStyle(color: Colors.black),
              controller: _searchController,
              decoration: InputDecoration(
                fillColor: Colors.grey[200],
                filled: true,
                prefixIcon: Icon(Icons.search, color: Colors.black),
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
            child: StaggeredGridView.builder(
              itemCount: imageUrls.length,
              gridDelegate: SliverStaggeredGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 2.0,
                crossAxisSpacing: 2.0,
                staggeredTileBuilder: (index) => StaggeredTile.fit(1),
              ),
              itemBuilder: (context, index) {
                return ElevatedButton(
                  onPressed: () {
                    print('Clicked image ${imageUrls[index]}');
                  },
                  child: Image.network(
                    imageUrls[index],
                    height: itemHeights[index],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
