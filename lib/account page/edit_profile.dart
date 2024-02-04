import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:fotofusion/account%20page/user_account.dart';
import 'package:fotofusion/navbar.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
class Editprofile extends StatefulWidget {
  const Editprofile({Key? key}) : super(key: key);

  @override
  State<Editprofile> createState() => _EditprofileState();
}

class _EditprofileState extends State<Editprofile> {
  String? _imageUrl;
  bool _uploading = false;
  bool isverified=false;
  Future<void> fetchverification() async{
    final user=_auth.currentUser;
    final docsnap=await _firestore.collection('Verifications').doc(user!.uid).get();
    if(docsnap.exists){
      setState(() {
        isverified=docsnap.data()?['isverified'];
      });
    }
  }
  FirebaseAuth _auth=FirebaseAuth.instance;
  FirebaseFirestore _firestore=FirebaseFirestore.instance;
  final ImagePicker _imagePicker = ImagePicker();
  File? _image;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  String username='Loading';
  String name='Loading';
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
  TextEditingController _namecontroller = TextEditingController();
  TextEditingController _usernamecontroller = TextEditingController();
  TextEditingController _biocontroller=TextEditingController();
  Future<void> _loadProfilePicture() async {
    final user = _auth.currentUser;
    if (user != null) {
      try {
        final docSnapshot = await _firestore.collection('User Details').doc(user.uid).get();
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
  Future<void> _uploadImage() async {
    try {
      final user = _auth.currentUser;
      if (user != null && _image != null) {
        setState(() {
          _uploading = true;
        });
        final ref = _storage.ref().child('profile_pictures/${user.uid}');
        await ref.putFile(_image!);
        final imageUrl = await ref.getDownloadURL();

        await user.updateProfile(photoURL: imageUrl);

        // Store the URL in Firestore
        await _firestore.collection('profile_pictures').doc(user.uid).set({
          'url_user1': imageUrl,
          'time stamp': FieldValue.serverTimestamp(),
        });
        await _firestore.collection('User Details').doc(user.uid).update({
          'url_user1': imageUrl,
          'time stamp': FieldValue.serverTimestamp(),
        });

        setState(() {
          _uploading = false;
          _imageUrl = imageUrl;
        });

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: Colors.green,
          content: Text('Profile picture uploaded successfully!'),
        ));
      }
    } catch (e) {
      setState(() {
        _uploading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.red,
        content: Text('Error uploading profile picture: $e'),
      ));
    }
  }
  String userbio='';
  Future<void> fetchbio() async{
    final user=_auth.currentUser;
    try{
      final docsnap=await _firestore.collection('User Details').doc(user!.uid).get();
      if(docsnap.exists){
        setState(() {
          userbio=docsnap.data()?['bio'];
        });
      }
    }catch(e){
      print('bio error:$e');
    }
  }
  String link='';
  Future<void> fetchlink() async{
    final user=_auth.currentUser;
    try{
      final docsnap=await _firestore.collection('User Details').doc(user!.uid).get();
      if(docsnap.exists){
        setState(() {
          link=docsnap.data()?['link'];
        });
      }
    }catch(e){
      print('link error:$e');
    }
  }
  TextEditingController _linkcontroller=TextEditingController();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadProfilePicture();
    fetchusername();
    fetchbio();
    fetchlink();
    fetchverification();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(onPressed: (){
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) =>NavBar(),));
        }, icon: Icon(CupertinoIcons.back,color: Colors.white,)),
        title: Text('Edit profile',style: TextStyle(color: Colors.white),),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: 15,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                _uploading
                    ? CircularProgressIndicator(
                  color: Colors.red,
                ) // Show the progress indicator while uploading
                    : _imageUrl == null
                    ? ClipOval(
                  child: Container(
                    width: 90, // Instagram-like dimensions
                    height: 90,
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
                    width: 90, // Instagram-like dimensions
                    height: 90,
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
              ],
            ),
            TextButton(onPressed: ()async{
              await _pickImage();
              _uploadImage();
            },
                child: Text('Edit picture',style: TextStyle(fontSize: 18,
                fontWeight: FontWeight.w500),)),
            SizedBox(
              height: 20,
            ),
            Row(
              children: [
                SizedBox(
                  width: 20,
                ),
                Text('Name',style: TextStyle(color: Colors.grey,fontWeight: FontWeight.bold),),
              ],
            ),
            SizedBox(
              height: 20,
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[800]!,
              ),
              child: TextField(
                style: TextStyle(color: Colors.white),
                controller: _usernamecontroller,
                decoration: InputDecoration(
                  hintText:username,
                  hintStyle: TextStyle(color: Colors.grey),
                    suffixIcon: IconButton(onPressed: ()async{
                      if(_usernamecontroller.text.isNotEmpty){
                        final user=_auth.currentUser;
                        try{
                          await _firestore.collection('User Details').doc(user!.uid).update({
                            'user name':_usernamecontroller.text,
                            'time of changing':FieldValue.serverTimestamp(),
                          });
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            backgroundColor: Colors.green,
                            content: Text('Name updated succesfully'),
                          ));
                          fetchusername();
                          _usernamecontroller.clear();
                        }catch(e){
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            backgroundColor: Colors.red,
                            content: Text('Error updating Name'),
                          ));
                          fetchusername();
                          _usernamecontroller.clear();
                        }
                      }
                      else{
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          backgroundColor: Colors.red,
                          content: Text('Please type your name'),
                        ));
                        fetchusername();
                        _usernamecontroller.clear();
                      }
                    },
                        icon: Icon(CupertinoIcons.checkmark_alt,color: Colors.blue,))
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Row(
              children: [
                SizedBox(
                  width: 20,
                ),
                Text('Username',style: TextStyle(color: Colors.grey,fontWeight: FontWeight.bold),),
              ],
            ),
            SizedBox(
              height: 20,
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[800]!,
              ),
              child: TextField(
                style: TextStyle(color: Colors.white),
                controller: _namecontroller,
                decoration: InputDecoration(
                  hintText:name,
                  hintStyle: TextStyle(color: Colors.grey),
                    suffixIcon: IconButton(onPressed: ()async{
                      if(_namecontroller.text.isNotEmpty){
                        final user=_auth.currentUser;
                        try{
                          await _firestore.collection('User Details').doc(user!.uid).update({
                            'user names':_namecontroller.text,
                            'time of changing username':FieldValue.serverTimestamp(),
                          });
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            backgroundColor: Colors.green,
                            content: Text('Username updated succesfully'),
                          ));
                          fetchusername();
                          _namecontroller.clear();
                        }catch(e){
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            backgroundColor: Colors.red,
                            content: Text('Error updating username'),
                          ));
                          fetchusername();
                          _namecontroller.clear();
                        }
                      }
                      else{
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          backgroundColor: Colors.red,
                          content: Text('Please type your username'),
                        ));
                        fetchusername();
                        _namecontroller.clear();
                      }
                    },
                        icon: Icon(CupertinoIcons.checkmark_alt,color: Colors.blue,))
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Row(
              children: [
                SizedBox(
                  width: 20,
                ),
                Text('Bio',style: TextStyle(color: Colors.grey,fontWeight: FontWeight.bold),),
              ],
            ),
            SizedBox(
              height: 20,
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[800]!,
              ),
              child: TextField(
                style: TextStyle(color: Colors.white),
                controller: _biocontroller,
                decoration: InputDecoration(
                  hintText:userbio,
                  hintStyle: TextStyle(color: Colors.grey),
                  suffixIcon: IconButton(onPressed: ()async{
                    if(_biocontroller.text.isNotEmpty){
                      final user=_auth.currentUser;
                      try{
                        await _firestore.collection('User Details').doc(user!.uid).update({
                          'bio':_biocontroller.text,
                          'time of changing bio':FieldValue.serverTimestamp(),
                        });
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          backgroundColor: Colors.green,
                          content: Text('Bio updated succesfully'),
                        ));
                        fetchbio();
                        _biocontroller.clear();
                      }catch(e){
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          backgroundColor: Colors.red,
                          content: Text('Error updating bio'),
                        ));
                        fetchbio();
                        _biocontroller.clear();
                      }
                    }
                    else{
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        backgroundColor: Colors.red,
                        content: Text('Please type your bio'),
                      ));
                      fetchbio();
                      _biocontroller.clear();
                    }
                  },
                      icon: Icon(CupertinoIcons.checkmark_alt,color: Colors.blue,))
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Row(
              children: [
                SizedBox(
                  width: 20,
                ),
                Text('Link',style: TextStyle(color: Colors.grey,fontWeight: FontWeight.bold),),
              ],
            ),
            SizedBox(
              height: 20,
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[800]!,
              ),
              child: TextField(
                style: TextStyle(color: Colors.white),
                controller: _linkcontroller,
                decoration: InputDecoration(
                    hintText:link,
                    hintStyle: TextStyle(color: Colors.grey),
                    suffixIcon: IconButton(onPressed: ()async{
                      if(_linkcontroller.text.isNotEmpty){
                        final user=_auth.currentUser;
                        try{
                          await _firestore.collection('User Details').doc(user!.uid).update({
                            'link':_linkcontroller.text,
                            'time of changing':FieldValue.serverTimestamp(),
                          });
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            backgroundColor: Colors.green,
                            content: Text('Link updated succesfully'),
                          ));
                          fetchlink();
                          _linkcontroller.clear();
                        }catch(e){
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            backgroundColor: Colors.red,
                            content: Text('Error updating link'),
                          ));
                          fetchlink();
                          _linkcontroller.clear();
                        }
                      }
                      else{
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          backgroundColor: Colors.red,
                          content: Text('Please type your link'),
                        ));
                        fetchlink();
                        _linkcontroller.clear();
                      }
                    },
                        icon: Icon(CupertinoIcons.checkmark_alt,color: Colors.blue,))
                ),
              ),
            ),
            SizedBox(
              height: 30,
            ),
            if(!isverified)
              TextButton(onPressed: ()async{
                final user=_auth.currentUser;
                await _firestore.collection('Verifications').doc(user!.uid).set(
                    {
                      'isverified':false,
                    }
                );
              }, child: Text('Get Verified',style: TextStyle(color:Colors.white,
                fontWeight: FontWeight.bold,
              ),)),
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
        });
        _uploadImage();
      }
    } else {
      final pickedFile = await _imagePicker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
        });
        _uploadImage();
      }
    }

  }
}
