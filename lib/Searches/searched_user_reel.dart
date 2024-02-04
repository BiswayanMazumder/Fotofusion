import 'dart:io';
import 'dart:math';
import 'package:chewie/chewie.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:fotofusion/Searches/search_result.dart';
import 'package:fotofusion/account%20page/edit_profile.dart';
import 'package:fotofusion/pages/search_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';

class Searchuserreels extends StatefulWidget {
  final String userid;

  Searchuserreels({required this.userid});

  @override
  State<Searchuserreels> createState() => _SearchuserreelsState();
}

class _SearchuserreelsState extends State<Searchuserreels> {
  FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String username = 'Loading';
  String name = 'Loading';
  String? _imageUrl;
  bool _uploading = false;
  List<String> locations=[];
  bool isverified=false;
  String link = '';
  Future<void> fetchlink() async {
    final user = _auth.currentUser;
    try {
      final docsnap =
      await _firestore.collection('User Details').doc(widget.userid).get();
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
  int count=0;
  int followercount=0;
  bool isfollowed = false;
  bool issubs=false;
  List<String> subscribers = [];
  Future<void> fetchSubscribers() async {
    final user=_auth.currentUser;
    try {
      final docSnap = await _firestore.collection('Subscription').doc(widget.userid).get();

      if (docSnap.exists) {
        // Retrieve the 'SubscribedUserid' field from the document
        dynamic subscribedUserIdsDynamic = docSnap.get('SubscribedUserid');

        // Explicitly cast the dynamic list to List<String> or default to an empty list
        List<String> subscribedUserIds = List<String>.from(subscribedUserIdsDynamic) ?? [];

        // Update the subscribers list with the user IDs from the field
        subscribers = subscribedUserIds;
        print('Subscribers list after updating: $subscribers');
        if(subscribers.contains(user!.uid)){
          setState(() {
            issubs=true;
          });
          print('is subs $issubs');
        }
      } else {
        print('Document does not exist in Firestore.');
      }
    } catch (e) {
      print('Error fetching data from Firestore: $e');
    }
  }
  Future<void> fetchFollowers() async {
    final user = _auth.currentUser;
    try {
      DocumentSnapshot snapshot = await _firestore.collection('Followers').doc(widget.userid).get();

      if (snapshot.exists) {
        var followersData = snapshot.data() as Map<String, dynamic>?;

        if (followersData != null && followersData['Followers'] != null) {
          List<dynamic> followers = followersData['Followers'];
          isfollowed = followers.any((follower) => follower['followerUid'] == user?.uid);
        }
      }
    } catch (e) {
      print('Error fetching followers: $e');
    }
  }
  int following=0;
  Future<void> updatefollower() async {
    final user = _auth.currentUser;
    await fetchfollowerscount();
    setState(() {
      followerscount += 1;
      following += 1; // Increment the following count
    });

    await _firestore.collection('Followers Count').doc(widget.userid).set({
      'followers count': followerscount,
    });

    await _firestore.collection('Users Followers Count').doc(user!.uid).set({
      'followers count': following,
    });

    await _firestore.collection('Followers').doc(widget.userid).set({
      'Followers': FieldValue.arrayUnion([
        {
          'followerUid': user.uid,
        }
      ]),
    }, SetOptions(merge: true));
  }
  int followerscount=0;
  int searchedfollower=0;
  Future<void> fetchsearchedfollowercount() async{
    final docsnap=await _firestore.collection('Users Followers Count').doc(widget.userid).get();
    if(docsnap.exists){
      searchedfollower=docsnap.data()?['followers count'];
    }
  }
  Future<void>fetchfollowerscount() async{
    final user=_auth.currentUser;
    final docsnap=await _firestore.collection('Followers Count').doc(widget.userid).get();
    if(docsnap.exists){
      setState(() {
        followerscount=docsnap.data()?['followers count'];
      });
    }
  }
  Future<void> followersCount() async{
    await fetchfollowerscount();
    setState(() {
      followerscount+=1;
    });
    final user=_auth.currentUser;
    await _firestore.collection('Followers Count').doc(widget.userid).set({
      'followers count':followerscount,
    });

  }
  Future<void> fetchpostscount() async{
    final user=_auth.currentUser;
    final docsnap=await _firestore.collection('Number of posts').doc(widget.userid).get();
    if(docsnap.exists){
      setState(() {
        count=docsnap.data()?['post count'];
      });
    }
  }
  Future<void> fetchverification() async{
    final docsnap=await _firestore.collection('Verifications').doc(widget.userid).get();
    if(docsnap.exists){
      setState(() {
        isverified=docsnap.data()?['isverified'];
      });
    }
  }
  final ImagePicker _imagePicker = ImagePicker();
  File? _image;
  String location='';
  final FirebaseStorage _storage = FirebaseStorage.instance;
  List<String> imageUrls = [];
  List<String> captions=[];
  Future<void> fetchusername()async{
    final user=_auth.currentUser;
    try{
      final docsnap=await _firestore.collection('User Details').doc(widget.userid).get();
      if(docsnap.exists){
        setState(() {
          username=docsnap.data()?['user name'];
          name=docsnap.data()?['user names'];

        });
        print('user id ${widget.userid}');
      }
    }catch(e){
      print(e);
    }
  }
  void checkFollowers() async {
    await fetchFollowers();
    print('Is followed: $isfollowed');
  }
  List<String> reelsurls=[];
  Future<void> fetchreels() async {
    final user = _auth.currentUser;

    try {
      DocumentSnapshot documentSnapshot = await _firestore
          .collection('Reels')
          .doc(widget.userid)
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
  bool issubson=false;
  Future<void> fetchsubsstate()async{

    final docsnap=await _firestore.collection('Subscriber Mode').doc(widget.userid).get();
    if(docsnap.exists){
      setState(() {
        issubson=docsnap.data()?['Mode On/Off'];
      });
    }
    print('subs mode $issubson');
  }
  int price=500;
  Future<void> fetchsubsprice()async{
    final user=_auth.currentUser;
    final docsnap=await _firestore.collection('Subscription Price').doc(widget.userid).get();
    if(docsnap.exists){
      setState(() {
        price=docsnap.data()?['Price'];
      });
    }
  }
  bool isclosefriend=false;
  List<String> closeFriends = [];

  Future<void> fetchCloseFriends() async {
    final user = _auth.currentUser;

    try {
      DocumentSnapshot documentSnapshot = await _firestore
          .collection('Close Friends')
          .doc(user!.uid)
          .get();

      if (documentSnapshot.exists) {
        dynamic data = documentSnapshot.data();
        if (data != null) {
          List<dynamic> friendsList = (data['Close Friends']['close friends userid'] as List?) ?? [];

          setState(() {
            closeFriends = friendsList.map((friend) => friend.toString()).toList();
          });
        }
      }
      if(closeFriends.contains(widget.userid)){
        setState(() {
          isclosefriend=true;
        });
      }
      else{
        setState(() {
          isclosefriend=false;
        });
      }
    } catch (e) {
      print('Error fetching close friends: $e');
    }
  }
  Future<void> removeCloseFriends() async {
    final user = _auth.currentUser;

    try {
      await _firestore.collection('Close Friends').doc(user!.uid).set({
        'Close Friends': {
          'close friends userid': FieldValue.arrayRemove([widget.userid]),
        }
      }, SetOptions(merge: true));
    } catch (e) {
      print('Error adding close friend $e');
    }
  }
  Future<void> addCloseFriends() async {
    final user = _auth.currentUser;

    try {
      await _firestore.collection('Close Friends').doc(user!.uid).set({
        'Close Friends': {
          'close friends userid': FieldValue.arrayUnion([widget.userid]),
        }
      }, SetOptions(merge: true));
    } catch (e) {
      print('Error adding close friend $e');
    }
  }
  @override
  void initState() {
    super.initState();
    fetchusername();
    fetchsubsstate();
    fetchSubscribers();
    fetchsubsurls();
    updateImagesPeriodically();
    _loadProfilePicture();
    fetchlocations();
    fetchCloseFriends();
    fetchsubsprice();
    fetchverification();
    fetchbio();
    fetchlink();
    fetchuserid();
    fetchFollowers();
    checkFollowers();
    fetchfollowerscount();
    fetchfollowerscount();
    fetchsearchedfollowercount();
    fetchreels();
  }
  Future<void> unfollow() async {
    final user = _auth.currentUser;
    await fetchfollowerscount();

    // Only decrement the count if it is greater than 0
    setState(() {
      followerscount -= 1;
      if(following>0){
        following -= 1; // Decrement the following count
      }
      else{
        following=0;
      }
    });

    await _firestore.collection('Followers Count').doc(widget.userid).set({
      'followers count': followerscount,
    });

    await _firestore.collection('Users Followers Count').doc(user!.uid).set({
      'followers count': following,
    });

    await _firestore.collection('Followers').doc(widget.userid).set({
      'Followers': FieldValue.arrayRemove([
        {
          'followerUid': user.uid,
        }
      ]),
    }, SetOptions(merge: true));

    print('user id: ${user!.uid}');
    print('widget id ${widget.userid}');
  }


  int followerscounts=0;
  Future<void>fetchfollowerscounts() async{
    final user=_auth.currentUser;
    final docsnap=await _firestore.collection('Followers Count').doc(widget.userid).get();
    if(docsnap.exists){
      setState(() {
        followerscounts=docsnap.data()?['followers count'];
      });
    }
  }
  bool sameuser=false;
  Future<void> fetchuserid() async{
    try{
      final user=_auth.currentUser;
      if(user!.uid==widget.userid){
        setState(() {
          sameuser=true;
        });
        print('same user:$sameuser');
      }
    }catch(e){
      print('error same user:$e');
    }
  }
  Future<void> updateImagesPeriodically() async {
    while (true) {
      await Future.delayed(Duration(seconds: 2));
      fetchImages();
      fetchcaptions();
      fetchpostscount();
      fetchFollowers();
    }
  }
  int followers=0;

  Future<void> _loadProfilePicture() async {
    final user = _auth.currentUser;
    if (user != null) {
      try {
        final docSnapshot =
        await _firestore.collection('profile_pictures').doc(widget.userid).get();
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
          .doc(widget.userid)
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
  List<String> subsurls=[];
  Future<void>fetchsubsurls() async{
    final user = _auth.currentUser;

    try {
      DocumentSnapshot documentSnapshot = await _firestore
          .collection('Subscriber Specific')
          .doc(widget.userid)
          .get();

      if (documentSnapshot.exists) {
        dynamic data = documentSnapshot.data();
        if (data != null) {
          List<dynamic> posts = (data['posts'] as List?) ?? [];
          setState(() {
            subsurls = posts.map((post) => post['imageUrl'].toString()).toList();
          });
        }
      }
    } catch (e) {
      print('Error fetching images: $e');
    }
  }
  Future<void> fetchlocations() async {
    final user = _auth.currentUser;

    try {
      DocumentSnapshot documentSnapshot = await _firestore
          .collection('Posts')
          .doc(widget.userid)
          .get();

      if (documentSnapshot.exists) {
        dynamic data = documentSnapshot.data();
        if (data != null) {
          List<dynamic> posts = (data['posts'] as List?) ?? [];
          setState(() {
            locations = posts.map((post) => post['location'].toString()).toList();
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
          .doc(widget.userid)
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
  String userbio = '';
  Future<void> fetchbio() async {
    final user = _auth.currentUser;
    try {
      final docsnap =
      await _firestore.collection('User Details').doc(widget.userid).get();
      if (docsnap.exists) {
        setState(() {
          userbio = docsnap.data()?['bio'];
        });
      }
    } catch (e) {
      print('bio error:$e');
    }
  }
  @override
  Widget build(BuildContext context) {
    String userId = widget.userid;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        automaticallyImplyLeading: true,
        leading: IconButton(onPressed: (){
          Navigator.push(context, MaterialPageRoute(builder: (context) => Search(),));
        },
            icon: Icon(CupertinoIcons.back,color: CupertinoColors.white,)),
        backgroundColor: Colors.black,
        title: Row(
          children: [
            Text(username,style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 20),),
            SizedBox(
              width: 5,
            ),
            if(isverified)
              Image.network('https://emkldzxxityxmjkxiggw.supabase.co/storage/v1/object/public/Grovito/480-4801090_instagram-verified-badge-png-instagram-verified-icon-png-removebg-preview.png',
                height: 40,
                width: 40,
              )
          ],
        ),
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
                _uploading
                    ? CircularProgressIndicator(
                  color: Colors.red,
                ) // Show the progress indicator while uploading
                    : _imageUrl == null
                    ? ClipOval(
                  child: Container(
                    width: 110, // Instagram-like dimensions
                    height: 110,
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
                    width: 110, // Instagram-like dimensions
                    height: 110,
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
                      height: 1,
                    ),

                    Text('$followerscount',style: TextStyle(color: CupertinoColors.white, fontWeight: FontWeight.bold),),
                    if(followerscount<=1)
                      Text('Follower',style: TextStyle(color: CupertinoColors.white, fontWeight: FontWeight.bold),),
                    if(followerscount>1)
                      Text('Followers',style: TextStyle(color: CupertinoColors.white, fontWeight: FontWeight.bold),)
                  ],
                ),
                SizedBox(
                  width: 30,
                ),
                Column(
                  children: [
                    SizedBox(
                      height: 1,
                    ),

                    Text('$searchedfollower',style: TextStyle(color: CupertinoColors.white, fontWeight: FontWeight.bold),),
                    if(searchedfollower<=1)
                      Text('Following',style: TextStyle(color: CupertinoColors.white, fontWeight: FontWeight.bold),),
                    if(searchedfollower>1)
                      Text('Following',style: TextStyle(color: CupertinoColors.white, fontWeight: FontWeight.bold),)
                  ],
                )
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
                if (sameuser)
                  Center(
                    child: Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => Editprofile()),
                              );
                            },
                            style: ButtonStyle(
                              backgroundColor: MaterialStatePropertyAll(Colors.grey[900]),
                            ),
                            child: Text(
                              'Edit Profile',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )

              ],
            ),
            Row(
              children: [
                SizedBox(
                  width: 20,
                ),
                if(!sameuser)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ElevatedButton(
                              onPressed: () async {
                                isfollowed ? unfollow() : updatefollower();
                                fetchFollowers();
                              },
                              style: ButtonStyle(
                                backgroundColor: isfollowed
                                    ? MaterialStatePropertyAll(Colors.grey[800])
                                    : MaterialStatePropertyAll(Colors.blue),
                              ),
                              child: isfollowed
                                  ? Text(
                                'Following',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                                  : Text(
                                'Follow',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            isfollowed?isclosefriend?ElevatedButton(onPressed: (){
                              removeCloseFriends();
                              fetchCloseFriends();
                            },
                                style: ButtonStyle(backgroundColor: MaterialStatePropertyAll(Colors.grey[800])),
                                child:Row(
                                  children: [
                                    Text(
                                      'Remove from close friends',
                                      style: TextStyle(
                                        color: Colors.red[500],
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ) ):ElevatedButton(onPressed: (){
                              addCloseFriends();
                              fetchCloseFriends();
                            },
                              style: ButtonStyle(backgroundColor: MaterialStatePropertyAll(Colors.grey[800])),
                              child: Row(
                                children: [
                                  Icon(Icons.star,color: Colors.green,),
                                  Text(
                                    ' Add to close friends',
                                    style: TextStyle(
                                      color: Colors.green,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),):Container()
                          ],
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        issubson?isfollowed?issubs?Center(
                          child: ElevatedButton(onPressed: (){
                            showDialog(context: context, builder: (context) {
                              return AlertDialog(
                                backgroundColor: Colors.black,
                                title: Text('Are you sure to cancel subscription',style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15
                                ),),
                                scrollable: true,
                                actions: [
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Center(
                                        child: Text('Subscription once deleted need to be purchased again',style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w300,
                                            fontSize: 15
                                        ),),
                                      ),
                                      SizedBox(
                                        height: 20,
                                      ),
                                      Row(
                                        children: [
                                          ElevatedButton(onPressed: ()async{
                                            final user = _auth.currentUser;
                                            await _firestore.collection('Subscription').doc(widget.userid).set(
                                              {
                                                'SubscribedUserid': FieldValue.arrayRemove([user!.uid])
                                              },
                                              SetOptions(merge: true),
                                            );
                                            
                                            Navigator.pop(context);
                                            fetchSubscribers();
                                          }, child: Text('Go Ahead',style: TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15
                                          ),
                                          ),
                                            style: ButtonStyle(backgroundColor: MaterialStatePropertyAll(Colors.green)),
                                          ),
                                          SizedBox(
                                            width: 10,
                                          ),
                                          ElevatedButton(onPressed: (){
                                            Navigator.pop(context);
                                          },
                                            child: Text('Cancel',style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15
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
                              style: ButtonStyle(
                                  backgroundColor: MaterialStatePropertyAll(Colors.grey[600])
                              ),
                              child: Row(
                                children: [
                                  Text('Subscribed',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),
                                ],
                              )),
                        ):Center(
                          child: ElevatedButton(onPressed: (){
                            Razorpay razorpay = Razorpay();
                            var options = {
                              'key': 'rzp_test_WoKAUdpbPOQlXA',
                              'amount': price*100, // amount in the smallest currency unit
                              'timeout': 300,
                              'name': 'FotoFusion',
                              'description': 'Subscription For NetFly.Only for two screens',
                              'theme': {
                                'color': '#FF0000',
                              },
                            };

                            razorpay.open(options);
                            razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, (PaymentSuccessResponse response) async{
                              print('Payment Success');
                              final user = _auth.currentUser;
                              await _firestore.collection('Subscription').doc(widget.userid).set(
                                {
                                  'SubscribedUserid': FieldValue.arrayUnion([user!.uid])
                                },
                                SetOptions(merge: true),
                              );

                            }
                            );
                            fetchSubscribers();
                          },
                              style: ButtonStyle(
                                  backgroundColor: MaterialStatePropertyAll(Colors.blue[500])
                              ),
                              child: Row(
                                children: [
                                  Text('Subscribe',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),
                                ],
                              )),
                        ):Container():Container()
                      ],
                    ),
                  ),
                if (sameuser)
                  Center(
                    child: Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => Editprofile()),
                              );
                            },
                            style: ButtonStyle(
                              backgroundColor: MaterialStatePropertyAll(Colors.grey[900]),
                            ),
                            child: Text(
                              'Edit Profile',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
              ],
            ),
            SizedBox(
              height: 20,
            ),
            // Inside your build method
            Row(
              children: [
                SizedBox(
                  width: 110,
                ),
                IconButton(onPressed: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context) => Searchresult(userid: widget.userid),));
                }, icon: Icon(CupertinoIcons.photo,color: Colors.grey,)),
                SizedBox(
                  width: 30,
                ),
                if(reelsurls.length>0)
                  IconButton(onPressed: (){
                    // Navigator.push(context, MaterialPageRoute(builder: (context) => Reelpage_account()));
                  }, icon: Icon(Icons.movie,color: Colors.white,)),
                SizedBox(
                  width: 30,
                ),
                if(isfollowed)
                  if(issubs)
                    if(subsurls.length>0)
                      IconButton(onPressed: (){
                      }, icon: Icon(Icons.star_outline,color: Colors.grey,)),
              ],
            ),
            SizedBox(height: 20),
            if (reelsurls.isNotEmpty)
              GridView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 4.0,
                  mainAxisSpacing: 4.0,
                ),
                itemCount: reelsurls.length,
                itemBuilder: (context, index) {
                  VideoPlayerController videoPlayerController =
                  VideoPlayerController.networkUrl(Uri.parse(reelsurls[index]));

                  ChewieController chewieController = ChewieController(
                    videoPlayerController: videoPlayerController,
                    aspectRatio: 1,
                    autoInitialize: true, // Set to true for auto-initializing
                    autoPlay: true,
                    looping: true, // Set to true for looping
                    allowedScreenSleep: false,
                    showControls: false, // Set to false to hide controls
                    placeholder: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );

                  // Add error handling
                  videoPlayerController.addListener(() {
                    if (videoPlayerController.value.hasError) {
                      print(
                          'Video Player Error: ${videoPlayerController.value.errorDescription}');
                    }
                  });

                  return GestureDetector(
                    onTap: () {
                      // Handle tap on a reel (if needed)
                    },
                    child: Container(
                      width: 120,
                      height: 150,
                      child: Chewie(
                        controller: chewieController,
                      ),
                    ),
                  );
                },
              ),
// Add a gap of 20 pixels between new rows

            // Add a gap of 20 pixels between new rows
          ],
        ),
      ),
    );
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
}

