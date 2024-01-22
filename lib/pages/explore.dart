import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
class ExplorePage extends StatefulWidget {
  const ExplorePage({Key? key}) : super(key: key);

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  TextEditingController _SearchController=TextEditingController();
  List<String> imageUrls = [];
  List<String> captions=[];
  List<String> usernames = [];
  List<String> profilephotos=[];
  FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

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
    // TODO: implement initState
    super.initState();
    updateImagesPeriodically();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Column(
         children: [
           SizedBox(
             height: 50,
           ),
           TextField(
             style: TextStyle(color: Colors.white),
             controller: _SearchController,
             decoration: InputDecoration(
               fillColor: Colors.grey[900],
               filled: true,
               prefixIcon: Icon(Icons.search,color: Colors.white,),
               hintText:'Search',
               hintStyle: TextStyle(color: Colors.grey)
             ),
           ),
           SizedBox(
             height: 10,
           ),
           for (int i = 0; i < imageUrls.length; i += 2)
           Column(
             children: [
               SizedBox(height: 20),
               Row(
                 mainAxisAlignment: MainAxisAlignment.start,
                 children: [
                   SizedBox(width: 10),
                   if (i < imageUrls.length)
                     Image.network(
                       imageUrls[i],
                       width: 120,
                       height: 120,
                       fit: BoxFit.cover,
                     ),
                   SizedBox(width: 10),
                   if (i + 1 < imageUrls.length)
                     Image.network(
                       imageUrls[i + 1],
                       width: 120,
                       height: 120,
                       fit: BoxFit.cover,
                     ),
                   SizedBox(width: 10),
                   if (i + 2 < imageUrls.length)
                     Image.network(
                       imageUrls[i + 2],
                       width: 120,
                       height: 120,
                       fit: BoxFit.cover,
                     ),
                 ],
               ),
             ],
           ),
         ],
        ),
      ),
    );
  }
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }
}
