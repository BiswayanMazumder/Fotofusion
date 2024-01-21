import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:fotofusion/account%20page/user_account.dart';
import 'package:image_picker/image_picker.dart';

class detailpostpage extends StatefulWidget {
  final int startIndex;

  detailpostpage({required this.startIndex});

  @override
  _detailpostpageState createState() => _detailpostpageState();
}

class _detailpostpageState extends State<detailpostpage> {
  FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String username = 'Loading';
  String name = 'Loading';
  String? _imageUrl;
  bool _uploading = false;
  final ImagePicker _imagePicker = ImagePicker();
  File? _image;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  List<String> imageUrls = [];
  List<String> captions=[];
  Future<void> fetchusername()async{
    final user=_auth.currentUser;
    try{
      final docsnap=await _firestore.collection('User Details').doc(user!.uid).get();
      if(docsnap.exists){
        setState(() {
          username=docsnap.data()?['user name'];
          name=docsnap.data()?['user names'];

        });
      }
    }catch(e){
      print(e);
    }
  }
  @override
  void initState() {
    super.initState();
    fetchusername();
    updateImagesPeriodically();
    _loadProfilePicture();
  }

  Future<void> updateImagesPeriodically() async {
    while (true) {
      await Future.delayed(Duration(seconds: 2));
      fetchImages();
      fetchcaptions();
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
  Future<void> fetchcaptions() async {
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
          .collection('Posts')
          .doc(user?.uid)
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(onPressed: (){
          Navigator.push(context, MaterialPageRoute(builder: (context) => Account_page(),));
        }, icon: Icon(CupertinoIcons.back,color: CupertinoColors.white,)),
        title:Text('Posts',style: TextStyle(color: Colors.white),)
      ),
      body:SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  SizedBox(width: 20,),
                  _uploading
                      ? CircularProgressIndicator(
                    color: Colors.red,
                  ) // Show the progress indicator while uploading
                      : _imageUrl == null
                      ? ClipOval(
                    child: Container(
                      width: 50, // Instagram-like dimensions
                      height: 50,
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
                      width: 50, // Instagram-like dimensions
                      height: 50,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          // Border width
                        ),
                      ),
                      child: Image.network(
                        _imageUrl!,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  Text(username,style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),
                ],
              ),
              SizedBox(
                height: 20,
              ),
              if (imageUrls.isNotEmpty && widget.startIndex < imageUrls.length)
                Image.network(
                  imageUrls[widget.startIndex],
                  height: 500,
                  width: 500,
                )
              else
                CircularProgressIndicator(color: Colors.white,),
              SizedBox(
                height: 20,
              ),
              if (captions.isNotEmpty && widget.startIndex < captions.length)
                Row(
                  children: [
                    SizedBox(
                      width: 20,
                    ),
                    Text(name,style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),
                    SizedBox(
                      width: 10,
                    ),
                    Text('${captions[widget.startIndex]}',style: TextStyle(
                      color: Colors.white,
                    ),),
                  ],
                )
              else
                CircularProgressIndicator(color: Colors.black,)
            ],
          ),
        ),

    );
  }
}
