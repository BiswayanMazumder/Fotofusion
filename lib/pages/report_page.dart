import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fotofusion/navbar.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';

class BugReportPage extends StatefulWidget {
  final File? imageFile;

  BugReportPage({Key? key, this.imageFile}) : super(key: key);

  @override
  _BugReportPageState createState() => _BugReportPageState();
}

class _BugReportPageState extends State<BugReportPage> {
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
  Future<String> _uploadImage() async {
    final user = _auth.currentUser;
    String imagePath = 'posts/${user!.uid}/post_${DateTime.now().millisecondsSinceEpoch}.jpg';

    TaskSnapshot uploadTask = await _storage.ref(imagePath).putFile(_image!);

    return await uploadTask.ref.getDownloadURL();
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

  Future<void> _uploadPost() async {
    final user = _auth.currentUser;
    await _pickImage();
    if (user != null && _image != null) {
      setState(() {
        _uploading = true;
      });

      try {
        _imageUrl = await _uploadImage();

        // Use set with merge option instead of update
        await _firestore.collection('Report').doc(user.uid).set({
          'screenshots': FieldValue.arrayUnion([
            {
              'imageUrl': _imageUrl,
            },
          ]),
        }, SetOptions(merge: true));

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


  TextEditingController _reportcontroller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Bug',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500, fontSize: 25),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 50,
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: TextField(
                  maxLines: 10,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.grey[500],
                    contentPadding: EdgeInsets.only(left: 20),
                    hintText: '\nTell us what happened - the\nmore detail the better!',
                    hintStyle: TextStyle(color: Colors.grey[900]),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25.0),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  controller: _reportcontroller,
                ),
              ),
              SizedBox(
                height: 50,
              ),
              _upload
                  ? Container(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    _pickImage();
                  },
                  style: ButtonStyle(
                      backgroundColor: MaterialStatePropertyAll(Colors.grey[200]),
                      elevation: MaterialStatePropertyAll(10)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.link, color: Colors.black),
                      SizedBox(
                        width: 10,
                      ),
                      Text('Add Attachment', style: TextStyle(color: Colors.black)),
                    ],
                  ),
                ),
              )
                  : _image != null
                  ? Container(
                width: 95,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  image: DecorationImage(
                    image: FileImage(_image!),
                    fit: BoxFit.cover,
                  ),
                ),
              )
                  : Container(),
              SizedBox(
                height: 80,
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: ElevatedButton(
                  onPressed: (){
                    _uploadPost();
                    Navigator.push(context, MaterialPageRoute(builder: (context) => NavBar(),));
                  },
                  style: ButtonStyle(
                      backgroundColor: MaterialStatePropertyAll(Colors.black)),
                  child: Text('Submit', style: TextStyle(color: Colors.white)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
