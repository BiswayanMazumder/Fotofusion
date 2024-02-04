import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fotofusion/navbar.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:elegant_notification/elegant_notification.dart';

class Reels_page extends StatefulWidget {
  final bool isImage;

  Reels_page({required this.isImage});

  @override
  _Reels_pageState createState() => _Reels_pageState();
}

class _Reels_pageState extends State<Reels_page> {
  String? _imageUrl;
  bool _uploading = false;
  File? _mediaFile;
  TextEditingController _captionController = TextEditingController();
  TextEditingController _locationController = TextEditingController();
  FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImagePicker _imagePicker = ImagePicker();
  final FirebaseStorage _storage = FirebaseStorage.instance;
  bool _upload = true;
  String username = 'Loading';

  @override
  void initState() {
    super.initState();
    _loadProfilePicture();
    fetchpostscount();
    fetchusername();
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

  Future<void> fetchusername() async {
    final user = _auth.currentUser;
    try {
      final docsnap =
      await _firestore.collection('User Details').doc(user!.uid).get();
      if (docsnap.exists) {
        setState(() {
          username = docsnap.data()?['user name'];
        });
      }
    } catch (e) {
      print(e);
    }
  }

  int count = 0;

  Future<void> fetchpostscount() async {
    final user = _auth.currentUser;
    final docsnap =
    await _firestore.collection('Number of posts').doc(user!.uid).get();
    if (docsnap.exists) {
      setState(() {
        count = docsnap.data()?['post count'];
      });
    }
  }
  Future<void> _uploadPost() async {
    final user = _auth.currentUser;
    if (user != null && _mediaFile != null) {
      setState(() {
        _uploading = true;
      });

      try {
        // Use set with merge option instead of update
        await _firestore.collection('Reels').doc(user.uid).set({
          'reels': FieldValue.arrayUnion([
            {
              'mediaUrl': await _uploadMediaFile(),
              'caption': _captionController.text,
              'location': _locationController.text,
              'isImage': _mediaFile!.path.endsWith('.jpg'), // Check if it's an image or video
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
    } else if (_mediaFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.red,
        content: Text('Please select a media file'),
      ));
    }
  }

  Future<void> uploadpostcount() async {
    try {
      final user = _auth.currentUser;
      setState(() {
        count += 1;
      });
      await _firestore.collection('Number of posts').doc(user!.uid).set({
        'post count': count,
      });

    } catch (e) {
      print('reel $e');
    }
  }

  Future<void> _uploadMedia() async {
    final user = _auth.currentUser;

    if (user != null && _mediaFile != null) {
      setState(() {
        _uploading = true;
      });

      try {
        await _firestore.collection('All posts').doc('Global Reels').set({
          'Reels': FieldValue.arrayUnion([
            {
              'mediaUrl': await _uploadMediaFile(),
              'caption': _captionController.text,
              'username': username,
              'profile photo': _imageUrl,
              'location': _locationController.text,
              'isImage': widget.isImage,
              'uid':user?.uid
            },
          ]),
        }, SetOptions(merge: true));

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
    } else if (_mediaFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.red,
        content: Text('Please select a video'),
      ));

    }
  }

  Future<String> _uploadMediaFile() async {
    final user = _auth.currentUser;

    // Define the path for the new media file in Firebase Storage
    String mediaPath = 'Reels/${user!.uid}/reels_${DateTime.now().millisecondsSinceEpoch}';

    // Upload the media file to Firebase Storage
    TaskSnapshot uploadTask =
    await _storage.ref('$mediaPath.${widget.isImage ? 'jpg' : 'mp4'}').putFile(_mediaFile!);

    // Get the download URL of the uploaded media file
    return await uploadTask.ref.getDownloadURL();
  }

  Future<void> _pickMedia() async {
    final user = _auth.currentUser;
    if (user!.emailVerified) {
      final pickedFile = await (widget.isImage
          ? _imagePicker.pickImage(source: ImageSource.gallery)
          : _imagePicker.pickVideo(source: ImageSource.gallery));
      if (pickedFile != null) {
        setState(() {
          _mediaFile = File(pickedFile.path);
          _upload = false;
        });
      }
    } else {
      final pickedFile = await (widget.isImage
          ? _imagePicker.pickImage(source: ImageSource.gallery)
          : _imagePicker.pickVideo(source: ImageSource.gallery));
      if (pickedFile != null) {
        setState(() {
          _mediaFile = File(pickedFile.path);
          _upload = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          'Upload a ${widget.isImage ? 'Image' : 'Video'}',
          style: TextStyle(
              color: CupertinoColors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => NavBar()),
            );
          },
          icon: Icon(Icons.close, color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () {
              _uploadMedia();
              _uploadPost();
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
                  onPressed: () {
                    _pickMedia();
                  },
                  icon: Icon(Icons.upload, color: CupertinoColors.white),
                )
                    : _mediaFile != null
                    ? Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    image: widget.isImage
                        ? DecorationImage(
                      image: FileImage(_mediaFile!),
                      fit: BoxFit.cover,
                    )
                        : null, // Displaying video thumbnail is more complex and may require additional packages.
                  ),
                )
                    : Container(),
              ),
              controller: _captionController,
            ),
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
                hintText: 'Write your location...',
                hintStyle: TextStyle(color: Colors.white),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.0),
                  borderSide: BorderSide.none,
                ),
              ),
              controller: _locationController,
            ),
          ],
        ),
      ),
    );
  }
}

class ImageUploader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Reels_page(isImage: true);
  }
}

class VideoUploader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Reels_page(isImage: false);
  }
}
