import 'package:insta_image_viewer/insta_image_viewer.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fotofusion/Reels%20page/reel_page_account.dart';
import 'package:fotofusion/account%20page/edit_profile.dart';
import 'package:fotofusion/account%20page/followers.dart';
import 'package:fotofusion/main.dart';
import 'package:fotofusion/pages/homepage.dart';
import 'package:fotofusion/posts/detailed_post.dart';
import 'package:fotofusion/posts/post_page.dart';
import 'package:fotofusion/posts/reels.dart';
import 'package:fotofusion/posts/story.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/cupertino.dart';
class Account_page extends StatefulWidget {
  const Account_page({Key? key}) : super(key: key);

  @override
  State<Account_page> createState() => _Account_pageState();
}

class _Account_pageState extends State<Account_page> {
  FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String username = 'Loading';
  String name = 'Loading';
  String? _imageUrl;
  bool _uploading = false;
  final ImagePicker _imagePicker = ImagePicker();
  File? _image;
  bool isverified=false;
  String? storyurl;
  bool storyuploaded=false;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  Future<void> _loadstory()async{
    final user=_auth.currentUser;
    try{
      final docsnap=await _firestore.collection('Story').doc(user!.uid).get();
      if(docsnap.exists){
        storyurl=docsnap.data()?['story'];
        storyuploaded=true;
      }
    }catch(e){
      print("Error getting story: $e");
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
  Future<void> fetchverification() async{
    final user=_auth.currentUser;
    final docsnap=await _firestore.collection('Verifications').doc(user!.uid).get();
    if(docsnap.exists){
      setState(() {
        isverified=docsnap.data()?['isverified'];
      });
    }
  }
  int followerscount=0;
  Future<void>fetchfollowerscount() async{
    final user=_auth.currentUser;
    final docsnap=await _firestore.collection('Followers Count').doc(user!.uid).get();
    if(docsnap.exists){
      setState(() {
        followerscount=docsnap.data()?['followers count'];
      });
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
  Future<void> _uploadImage() async {
    try {
      final user = _auth.currentUser;
      if (user != null && _image != null) {
        setState(() {
          _uploading = true;
        });
        final ref =
        _storage.ref().child('profile_pictures/${user.uid}');
        await ref.putFile(_image!);
        final imageUrl = await ref.getDownloadURL();

        await user.updateProfile(photoURL: imageUrl);

        // Store the URL in Firestore
        await _firestore.collection('profile_pictures').doc(user.uid).set({
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

  String userbio = '';
  Future<void> fetchusername() async {
    final user = _auth.currentUser;
    try {
      final docsnap =
      await _firestore.collection('User Details').doc(user!.uid).get();
      if (docsnap.exists) {
        setState(() {
          username = docsnap.data()?['user name'];
          name = docsnap.data()?['user names'];
        });
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> fetchbio() async {
    final user = _auth.currentUser;
    try {
      final docsnap =
      await _firestore.collection('User Details').doc(user!.uid).get();
      if (docsnap.exists) {
        setState(() {
          userbio = docsnap.data()?['bio'];
        });
      }
    } catch (e) {
      print('bio error:$e');
    }
  }
  int following=0;
  Future<void> fetchfollowing() async{
    final user=_auth.currentUser;
    final docsnap=await _firestore.collection('Users Followers Count').doc(user!.uid).get();
    if(docsnap.exists){
      setState(() {
        following=docsnap.data()?['followers count'];
      });
    }
  }
  String link = '';
  Future<void> fetchlink() async {
    final user = _auth.currentUser;
    try {
      final docsnap =
      await _firestore.collection('User Details').doc(user!.uid).get();
      if (docsnap.exists) {
        setState(() {
          link = docsnap.data()?['link'];
        });
        print(link);
      }
    } catch (e) {
      print('link error:$e');
    }
  }
  List<String> imageUrls = [];
  Future<void> updateImagesPeriodically() async {
    while (true) {
      await Future.delayed(Duration(seconds: 2));
      fetchImages();
      fetchfollowerscount();
      fetchfollowing();
      fetchverification();
      _loadstory();
      fetchstoryseen();
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
  List<String> reelsurls=[];
  Future<void> fetchreels() async {
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
            reelsurls = posts.map((post) => post['mediaUrl'].toString()).toList();
          });
        }
      }
    } catch (e) {
      print('Error fetching images: $e');
    }
  }
  Future<void> writestoryseen() async{
    final user=_auth.currentUser;
    await _firestore.collection('Story').doc(user!.uid).update(
        {
          'story seen':true
        });
  }
  bool storyseen=false;
  Future<void> fetchstoryseen()async{
    final user=_auth.currentUser;
    final docsnap=await _firestore.collection('Story').doc(user!.uid).get();
    if(docsnap.exists){
      storyseen=docsnap.data()?['story seen'];
    }
    print('Story seen $storyseen');
  }
  @override
  void initState() {
    super.initState();
    fetchusername();
    fetchbio();
    _loadProfilePicture();
    fetchlink();
    fetchpostscount();
    updateImagesPeriodically();
    fetchfollowerscount();
    fetchfollowing();
    fetchverification();
    fetchreels();
    _loadstory();
    fetchstoryseen();
  }

  Future<void> _launchURl() async {
    final user = _auth.currentUser;
    try {
      await fetchlink();
      final Uri _url = Uri.parse(link);
      if (!await launchUrl(_url)) {
        throw "Cannot Launch $_url";
      }
    } catch (e) {
      print('Error launching URL: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Row(
          children: [
            Text(
              username!,
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(
              width: 5,
            ),
            if(isverified)
              Image.network('https://emkldzxxityxmjkxiggw.supabase.co/storage/v1/object/public/Grovito/480-4801090_instagram-verified-badge-png-instagram-verified-icon-png-removebg-preview.png',
                height: 30,
                width: 30,
              )
          ],
        ),
        backgroundColor: Colors.black,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(onPressed: (){
            showDialog(context: context, builder: (context) {
              return AlertDialog(
                backgroundColor: Colors.white,
                title: Center(
                  child: Text('Really want to sign out?',style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20
                  ),),
                ),
                actions: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Do you really want to sign out?',style: TextStyle(
                        fontWeight: FontWeight.w300
                      ),),
                      SizedBox(
                        height: 20,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(onPressed: (){
                            Navigator.pop(context);
                          },
                              child: Text('Cancel',style: TextStyle(
                            color: Colors.black
                          ),
                              ),
                            style: ButtonStyle(backgroundColor: MaterialStatePropertyAll(Colors.green)),
                          ),
                          ElevatedButton(onPressed: (){
                            _auth.signOut();
                            Navigator.pushReplacement(context, MaterialPageRoute(builder:(context) => MyHomePage(),));
                          },
                            child: Text('Sign Out',style: TextStyle(
                                color: Colors.white
                            ),
                            ),
                            style: ButtonStyle(backgroundColor: MaterialStatePropertyAll(Colors.red)),
                          ),
                        ],
                      )
                    ],
                  )
                ],
              );
            },);
          },
              icon: Icon(Icons.logout_rounded,color: Colors.white,)),
          IconButton(
            onPressed: () {
              showDialog(context: context,
                builder: (context) {
                  return AlertDialog(
                    backgroundColor: Colors.black,
                    actions: [
                      SizedBox(
                        height: 20,
                      ),
                      Center(
                        child: TextButton(onPressed: (){
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) =>Postpage() ),
                          );

                        }, child: Text('Upload a Photo',style: TextStyle(color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15
                        ),)),
                      ),
                      Center(
                        child: TextButton(onPressed: (){
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Reels_page(isImage: false), // Set to true if it's an image
                            ),
                          );

                        }, child: Text('Upload Reels',style: TextStyle(color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15
                        ),)),
                      ),
                      Center(
                        child: TextButton(onPressed: (){
                          Navigator.pop(context);
                          Navigator.push(context, MaterialPageRoute(builder: (context) => Story(),));
                        }, child: Text('Upload Story',style: TextStyle(color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15
                        ),)),
                      ),
                    ],
                  );
                },);
            },
            icon: Icon(Icons.add_box_outlined, color: Colors.white,size: 30,),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: 15,
            ),
            Row(
              children: [
                SizedBox(
                  width: 20,
                ),
        InkWell(
          onTap: () async {
            writestoryseen();
            if (storyurl != null) {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    backgroundColor: Colors.black,
                    actions: [
                      InstaImageViewer(
                        child: Image(
                          image: Image.network(storyurl!).image,
                        ),
                      ),
                    ],
                  );
                },
              );
            }


          },
          child: _uploading
              ? CircularProgressIndicator(
            color: Colors.red,
          )
              : _imageUrl == null
              ? ClipOval(
            child: Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: 3,
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
              : Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: (storyuploaded && !storyseen)
                    ? Colors.green
                    : (storyuploaded && storyseen)
                    ? Colors.yellow
                    : Colors.red,
                width: (storyuploaded && !storyseen)
                    ? 3
                    : (storyuploaded && storyseen)
                    ? 0.5
                    : 3,
              ),
            ),
            child: ClipOval(
              child: Image.network(
                _imageUrl!,
                fit: BoxFit.cover,
              ),
            ),
          ),

        ),
        SizedBox(
                  width: 30,
                ),
                Align(
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$count',
                        style: TextStyle(color: CupertinoColors.white, fontWeight: FontWeight.bold),
                      ),
                      if(count==0 || count==1)
                        Text(
                          'Post',
                          style: TextStyle(color: CupertinoColors.white, fontWeight: FontWeight.bold),
                        ),
                      if(count>1)
                        Text(
                          'Posts',
                          style: TextStyle(color: CupertinoColors.white, fontWeight: FontWeight.bold),
                        ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 30,
                ),
                Column(
                  children: [
                    SizedBox(
                      height: 1.5,
                    ),
                    InkWell(
                        onTap: (){
                          Navigator.push(context, MaterialPageRoute(builder: (context) => Followers(),));
                        },
                        child: Text('$followerscount',style: TextStyle(color: CupertinoColors.white, fontWeight: FontWeight.bold),)),
                    if(followerscount<=1)
                      Text('Follower',style: TextStyle(color: CupertinoColors.white, fontWeight: FontWeight.bold),),
                    if(followerscount>1)
                      Text('Followers',style: TextStyle(color: CupertinoColors.white, fontWeight: FontWeight.bold),)
                  ],
                ),
                SizedBox(
                  width: 20,
                ),
                Column(
                  children: [
                    SizedBox(
                      height: 1,
                    ),
                    Text('$following',style: TextStyle(color: CupertinoColors.white, fontWeight: FontWeight.bold),),
                    if(following<=1)
                      Text('Following',style: TextStyle(color: CupertinoColors.white, fontWeight: FontWeight.bold),),
                    if(following>1)
                      Text('Following',style: TextStyle(color: CupertinoColors.white, fontWeight: FontWeight.bold),)
                  ],
                ),
              ],
            ),
            SizedBox(
              height: 15,
            ),
            Row(
              children: [
                SizedBox(
                  width: 20,
                ),
                Text(
                  name!,
                  style: TextStyle(color: Colors.white, fontSize: 15),
                ),
              ],
            ),
            SizedBox(
              height: 15,
            ),
            Row(
              children: [
                SizedBox(width: 20),
                Text(
                  userbio != null && userbio!.length > 50
                      ? '${userbio!.substring(0, 50)}\n${userbio!.substring(50)}'
                      : userbio!,
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
            Row(
              children: [
                SizedBox(
                  width: 9,
                ),
                TextButton(
                  onPressed: () {
                    // Open the link
                    _launchURl();
                  },
                  child: Text(
                    '$link',
                    style: TextStyle(
                      color: Colors.white,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                SizedBox(
                  width: 20,
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Editprofile()),
                      );
                    },
                    style: ButtonStyle(
                        backgroundColor: MaterialStatePropertyAll(
                            Colors.grey[900])),
                    child: Text(
                      '        Edit Profile        ',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                SizedBox(
                  width: 20,
                ),
                Align(
                  alignment: Alignment.topRight,
                  child: ElevatedButton(
                    onPressed: () {
                      // Navigator.push(context, MaterialPageRoute(builder: (context) => Homepage()));
                    },
                    style: ButtonStyle(
                        backgroundColor: MaterialStatePropertyAll(
                            Colors.grey[900])),
                    child: Text(
                      '          Settings          ',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                )
              ],
            ),
            SizedBox(
              height: 20,
            ),
            Row(
              children: [
                SizedBox(
                  width: 110,
                ),
                IconButton(onPressed: (){}, icon: Icon(CupertinoIcons.photo,color: Colors.white,)),
                SizedBox(
                  width: 80,
                ),
                if(reelsurls.length>0)
                  IconButton(onPressed: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context) => Reelpage_account()));
                  }, icon: Icon(Icons.movie,color: Colors.grey,)),
              ],
            ),

            for (int i = 0; i < imageUrls.length; i += 2)
              Column(
                children: [
                  SizedBox(height: 20), // Add a gap of 20 pixels between new rows
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(width: 20),
                      if (i < imageUrls.length)
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => detailpostpage(startIndex: i),
                              ),
                            );
                          },
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(Colors.black),
                          ),
                          child: Image.network(
                            imageUrls[i],
                            width: 120,
                            height: 120,
                            fit: BoxFit.cover,
                          ),
                        ),
                      SizedBox(width: 10),
                      if (i + 1 < imageUrls.length)
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => detailpostpage(startIndex: i + 1),
                              ),
                            );
                          },
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(Colors.black),
                          ),
                          child: Image.network(
                            imageUrls[i + 1],
                            width: 120,
                            height: 120,
                            fit: BoxFit.cover,
                          ),
                        ),
                      SizedBox(width: 10), // Add a gap of 10 pixels at the end of each row
                    ],
                  ),
                ],
              ),
// Add a gap of 20 pixels between new rows

            // Add a gap of 20 pixels between new rows
          ],
        ),
      ),
    );
  }
}
