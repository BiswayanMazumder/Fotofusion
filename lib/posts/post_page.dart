import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:fotofusion/account%20page/user_account.dart';
import 'package:fotofusion/navbar.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class Postpage extends StatefulWidget {
  const Postpage({Key? key}) : super(key: key);

  @override
  State<Postpage> createState() => _PostpageState();
}

class _PostpageState extends State<Postpage> {
  String? _imageUrl;
  String username = 'Loading';
  bool _uploading = false;
  TextEditingController _captionController = TextEditingController();
  FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImagePicker _imagePicker = ImagePicker();
  File? _image;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  bool _upload = true;

  Future<int> _getCurrentPostNumber(String userId) async {
    try {
      // Get the document containing the user's profile picture data
      DocumentSnapshot docSnapshot =
      await _firestore.collection('Posts').doc(userId).get();

      // Check if the document exists
      if (docSnapshot.exists) {
        // Extract the data as a Map
        Map<String, dynamic> data =
        docSnapshot.data() as Map<String, dynamic>;

        // Count the number of 'url_' fields to determine the current number of posts
        int numberOfPosts =
            data.keys.where((key) => key.startsWith('url_')).length;
        return numberOfPosts;
      } else {
        // If the document doesn't exist, there are no posts yet
        return 0;
      }
    } catch (e) {
      print('Error getting current post number: $e');
      return 0;
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
  Future<void> fetchusername()async{
    final user=_auth.currentUser;
    try{
      final docsnap=await _firestore.collection('User Details').doc(user!.uid).get();
      if(docsnap.exists){
        setState(() {
          username=docsnap.data()?['user name'];

        });
      }
    }catch(e){
      print(e);
    }
  }
  @override
  void initState() {
    super.initState();
    _loadProfilePicture();
    fetchpostscount();
    fetchusername();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          'Upload a post',
          style: TextStyle(
              color: CupertinoColors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => Account_page()),
            );
          },
          icon: Icon(Icons.close, color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () {
              _uploadPost();
              _uploadPosts();
            },
            child: Text(
              'Post',
              style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: 50,
            ),
            TextField(
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                contentPadding: EdgeInsets.only(left: 20),
                prefixIcon: _uploading
                    ? CircularProgressIndicator(
                  color: Colors.red,
                )
                    : _imageUrl == null
                    ? Container(
                  width: 50,
                  height: 50,
                  margin: EdgeInsets.only(right: 20),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.black,
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    backgroundImage: NetworkImage(
                      'https://firebasestorage.googleapis.com/v0/'
                          'b/fotofusion-53943.appspot.com/o/profile%2'
                          '0pics.jpg?alt=media&token=17bc6fff-cfe9-4f2d-9'
                          'a8c-18d2a5636671',
                    ),
                  ),
                )
                    : Container(
                  width: 50,
                  height: 50,
                  margin: EdgeInsets.only(right: 20),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.black,
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    backgroundImage: NetworkImage(_imageUrl!),
                  ),
                ),
                hintText: 'Write a caption...',
                hintStyle: TextStyle(color: Colors.white),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.0),
                  borderSide: BorderSide.none,
                ),
                suffixIcon: _upload
                    ? IconButton(
                  onPressed: _pickImage,
                  icon: Icon(Icons.upload, color: CupertinoColors.white),
                )
                    : _image != null
                    ? Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    image: DecorationImage(
                      image: FileImage(_image!),
                      fit: BoxFit.cover,
                    ),
                  ),
                )
                    : Container(),
              ),
              controller: _captionController,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    final user = _auth.currentUser;
    if (user!.emailVerified) {
      final pickedFile = await _imagePicker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
          _upload = false;
        });
      }
    } else {
      final pickedFile = await _imagePicker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
          _upload = false;
        });
      }
    }
  }
  int count=0;
  Future<void> fetchpostscount() async{
    final user=_auth.currentUser;
    final docsnap=await _firestore.collection('Number of posts').doc(user!.uid).get();
    if(docsnap.exists){
      setState(() {
        count=docsnap.data()?['post count'];
      });
    }
  }
  Future<void> uploadpostcount() async {
    final user = _auth.currentUser;
    setState(() {
      count += 1;
    });
    await _firestore.collection('Number of posts').doc(user!.uid).set({
      'post count': count,
    });
  }
  Future<void> _uploadPosts() async {
    final user = _auth.currentUser;
    if (user != null && _image != null) {
      setState(() {
        _uploading = true;
      });

      try {
        // Use set with merge option instead of update
        await _firestore.collection('All posts').doc('Global Post').set({
          'posts': FieldValue.arrayUnion([
            {
              'imageUrl': await _uploadImage(),
              'caption': _captionController.text,
              'username':username,
              'profile photo':_imageUrl,
              'likes':[]
            },
          ]),
        }, SetOptions(merge: true));
        await uploadpostcount();
        await fetchpostscount();

        setState(() {
          _uploading = false;
        });

        // Navigate to the user's account page after posting
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => NavBar()),
        );
      } catch (e) {
        print('Error uploading post: $e');
        setState(() {
          _uploading = false;
        });
      }
    } else if (_image == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.red,
        content: Text('Please select an image'),
      ));
    }
  }
  Future<void> _uploadPost() async {
    final user = _auth.currentUser;
    if (user != null && _image != null) {
      setState(() {
        _uploading = true;
      });

      try {
        // Use set with merge option instead of update
        await _firestore.collection('Posts').doc(user.uid).set({
          'posts': FieldValue.arrayUnion([
            {
              'imageUrl': await _uploadImage(),
              'caption': _captionController.text,
            },
          ]),
        }, SetOptions(merge: true));
        await uploadpostcount();
        await fetchpostscount();

        setState(() {
          _uploading = false;
        });

        // Navigate to the user's account page after posting
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Account_page()),
        );
      } catch (e) {
        print('Error uploading post: $e');
        setState(() {
          _uploading = false;
        });
      }
    } else if (_image == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.red,
        content: Text('Please select an image'),
      ));
    }
  }


  Future<String> _uploadImage() async {
    // Define the path for the new image in Firebase Storage
    final user=_auth.currentUser;
    String imagePath = 'posts/${user!.uid}/post_${DateTime.now().millisecondsSinceEpoch}.jpg';

    // Upload the image to Firebase Storage
    TaskSnapshot uploadTask = await _storage.ref(imagePath).putFile(_image!);

    // Get the download URL of the uploaded image
    return await uploadTask.ref.getDownloadURL();
  }
}
