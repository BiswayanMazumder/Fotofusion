import 'dart:io';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:fotofusion/account%20page/user_account.dart';
import 'package:image_picker/image_picker.dart';
class Homepage extends StatefulWidget {
  const Homepage({Key? key}) : super(key: key);

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  List<String> imageUrls = [];
  List<String> captions=[];
  List<String> usernames = [];
  List<String> profilephotos=[];
  FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  Future<void> updateImagesPeriodically() async {
    while (true) {
      await Future.delayed(Duration(seconds: 2));
      fetchprofilephoto();
      fetchusernames();
      fetchImages();
      fetchcaptions();
    }
  }
  Future<void> fetchprofilephoto() async {
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
            profilephotos = posts.map((post) => post['profile photo'].toString()).toList();
          });
        }
      }
    } catch (e) {
      print('Error fetching caption: $e');
    }
  }
  Future<void> fetchusernames() async {
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
            usernames = posts.map((post) => post['username'].toString()).toList();
          });
        }
      }
    } catch (e) {
      print('Error fetching caption: $e');
    }
  }
  Future<void> fetchcaptions() async {
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
            captions = posts.map((post) => post['caption'].toString()).toList();
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
            SizedBox(
              height: 20,
            ),
            Column(
              children: [
                for (int i = 0; i < imageUrls.length; i++)
                  Column(
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: Colors.black,
                            child: Image.network(profilephotos[i],
                            height: 40,
                            width: 40,),
                          ),
                        SizedBox(width: 10,),
                        Text(usernames[i],style: TextStyle(color: Colors.white,
                        fontSize: 15),)
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Image.network(imageUrls[i],
                      height: 600,
                      width: 600,
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          SizedBox(
                            width: 10,
                          ),
                          Text(usernames[i],style: TextStyle(color: Colors.white,
                              fontSize: 18,fontWeight: FontWeight.bold),),
                          SizedBox(
                            width: 10,
                          ),
                          Text(captions[i],style: TextStyle(color: Colors.white,
                              fontSize: 18),),
                        ],
                      ),

                      // Add any additional styling or widgets as needed
                      SizedBox(height: 50),
                    ],
                  ),
                SizedBox(
                  height: 30,
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
