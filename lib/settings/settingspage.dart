import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class Settings_page extends StatefulWidget {
  const Settings_page({Key? key}) : super(key: key);

  @override
  State<Settings_page> createState() => _Settings_pageState();
}

class _Settings_pageState extends State<Settings_page> {
  bool showCloseFriend = false;
  TextEditingController _priceController=TextEditingController();
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  FirebaseAuth _auth = FirebaseAuth.instance;
  List<String> closeFriendsUid = [];
  List<String> closeFriendUsernames = [];
  List<String> profilePhoto = [];
  List<bool> verificationStatus = [];

  Future<void> fetchCloseFriends() async {
    final user = _auth.currentUser;
    try {
      final docSnap =
      await _firestore.collection('Close Friends').doc(user!.uid).get();
      if (docSnap.exists) {
        setState(() {
          List<dynamic> closeFriendsList =
          docSnap.data()?['Close Friends']['close friends userid'];
          closeFriendsUid = List<String>.from(closeFriendsList);
        });
      }
      print('Close Friends $closeFriendsUid');
    } catch (e) {
      print('Error in close friends: $e');
    }
  }
  int price=500;
  Future<void> fetchsubsprice()async{
    final user=_auth.currentUser;
    final docsnap=await _firestore.collection('Subscription Price').doc(user!.uid).get();
    if(docsnap.exists){
      setState(() {
        price=docsnap.data()?['Price'];
      });
    }
  }
  Future<void> fetchUserDetailsCloseFriends() async {
    await fetchCloseFriends();
    try {
      for (String ids in closeFriendsUid) {
        final results =
        await _firestore.collection('User Details').doc(ids).get();
        if (results.exists) {
          String docSnap = results.data()?['user names'];
          closeFriendUsernames.add(docSnap);
        }
      }
      print('Close friend usernames $closeFriendUsernames');
    } catch (e) {
      print('Close friend username error $e');
    }
  }

  Future<void> fetchProfilePhoto() async {
    await fetchCloseFriends();
    try {
      for (String ids in closeFriendsUid) {
        final results =
        await _firestore.collection('profile_pictures').doc(ids).get();
        if (results.exists) {
          setState(() {
            String imageUrl = results.data()?['url_user1'];
            profilePhoto.add(imageUrl);
          });
        } else {
          // If the profile photo URL does not exist, add the default URL
          setState(() {
            profilePhoto.add(
                'https://images.pexels.com/photos/2568539/pexels-photo-2568539.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1');
          });
        }
      }

      // Check if the profilePhoto list is empty for any user and set a default picture
      profilePhoto = profilePhoto.isNotEmpty
          ? profilePhoto
          : [
        'https://images.pexels.com/photos/2568539/pexels-photo-2568539.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1'
      ];

      print('Profile photos $profilePhoto');
    } catch (e) {
      print('Profile photo error $e');
    }
  }
  Future<void> updateImagesPeriodically() async {
    while (true) {
      await Future.delayed(Duration(seconds: 2));
      await fetchCloseFriends();
      await fetchsubsstate();
      await fetchprofessional();
    }
  }
  bool issubson=false;
  Future<void> fetchsubsstate()async{
    final user=_auth.currentUser;
    if(user!=null){
      final docsnap=await _firestore.collection('Subscriber Mode').doc(user.uid).get();
      if(docsnap.exists){
        setState(() {
          issubson=docsnap.data()?['Mode On/Off'];
        });
      }
      else{
        setState(() {
          issubson=false;
        });
      }
    }
    print('subs mode $issubson');
  }
  bool isprofessional=false;
  Future<void> fetchprofessional()async{
    final user=_auth.currentUser;
    if(user!=null){
      final docsnap=await _firestore.collection('Professional Mode').doc(user.uid).get();
      if(docsnap.exists){
        setState(() {
          isprofessional=docsnap.data()?['Mode On/Off'];
        });
      }

    }
    print('is proffesional $isprofessional');
  }
  @override
  void initState() {
    super.initState();
    fetchCloseFriends();
    fetchsubsprice();
    fetchUserDetailsCloseFriends();
    fetchProfilePhoto();
    updateImagesPeriodically();
    fetchsubsstate();
    fetchprofessional();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(
            CupertinoIcons.back,
            color: Colors.white,
          ),
        ),
        title: Text(
          'Settings And privacy',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 50),
            TextButton(
              onPressed: () {
                setState(() {
                  showCloseFriend = !showCloseFriend;
                  print(showCloseFriend);
                });
              },
              child: Text(
                '  Close Friends',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                ),
              ),
            ),
            if (showCloseFriend)
              Column(
                children: [
                  SizedBox(height: 20),
                  for (int i = 0; i < closeFriendUsernames.length; i++)
                    Row(
                      children: [
                        SizedBox(width: 20),
                        Text('${i + 1}.', style: TextStyle(color: Colors.white)),
                        SizedBox(width: 10),
                        CircleAvatar(
                          radius: 20,
                          backgroundImage: NetworkImage(profilePhoto[i]),
                        ),
                        SizedBox(width: 20),
                        Text(
                          closeFriendUsernames[i],
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        SizedBox(width: 30),
                        Align(
                          alignment: Alignment.topRight,
                          child: TextButton(
                            onPressed: () async {
                              final user = _auth.currentUser;
                          
                              try {
                                await _firestore
                                    .collection('Close Friends')
                                    .doc(user!.uid)
                                    .set(
                                  {
                                    'Close Friends': {
                                      'close friends userid':
                                      FieldValue.arrayRemove(
                                          [closeFriendsUid[i]]),
                                    }
                                  },
                                  SetOptions(merge: true),
                                );
                              } catch (e) {
                                print('Error removing close friend $e');
                              }
                              fetchCloseFriends();
                              print('Clicked ${closeFriendsUid[i]}');
                            },
                            child: Text(
                              'Remove',
                              style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                      ],
                    ),
                ],
              ),
            SizedBox(
              height: 50,
            ),
            Row(
              children: [
                SizedBox(
                  width: 15,
                ),
                Text('Subscribers Mode',style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                ),),
                SizedBox(
                  width: 85,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if(issubson)
                      InkWell(
                        onTap: ()async{
                          final user=_auth.currentUser;
                          await _firestore.collection('Subscriber Mode').doc(user!.uid).set({
                            'Mode On/Off':false
                          });
                          fetchsubsstate();
                        },
                        child: Text('On',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 15),),
                      ),
                    if(!issubson)
                      InkWell(
                        onTap: ()async{
                          final user=_auth.currentUser;
                          await _firestore.collection('Subscriber Mode').doc(user!.uid).set({
                            'Mode On/Off':true
                          });
                          fetchsubsstate();
                        },
                        child: Text('Off',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 15),),
                      )
                  ],
                ),
              ],
            ),
            SizedBox(
              height: 30,
            ),
            if(issubson)
              TextField(
                style: TextStyle(color: Colors.white),
                keyboardType: TextInputType.number,
                controller: _priceController,
                decoration: InputDecoration(
                  hintText: 'Current Subscription Price: $price',
                  hintStyle: TextStyle(color: Colors.white,fontSize: 15),
                  suffixIcon: IconButton(onPressed: ()async{
                    final user=_auth.currentUser;
                    await _firestore.collection('Subscription Price').doc(user!.uid).set(
                        {
                          'Price':(_priceController.text)
                        });
                  },
                      icon:Icon(CupertinoIcons.checkmark_alt,color: CupertinoColors.white,)),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white,style: BorderStyle.solid),
                    borderRadius: BorderRadius.circular(100)
                  )
                ),
              ),
            SizedBox(
              height: 50,
            ),
            Row(
              children: [
                SizedBox(
                  width: 15,
                ),
                Text('Professional Account',style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                ),),
                SizedBox(
                  width: 60,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if(isprofessional)
                      InkWell(
                        onTap: ()async{
                          final user=_auth.currentUser;
                          await _firestore.collection('Professional Mode').doc(user!.uid).set({
                            'Mode On/Off':false
                          });
                          fetchprofessional();
                        },
                        child: Text('On',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 15),),
                      ),
                    if(!isprofessional)
                      InkWell(
                        onTap: ()async{
                          final user=_auth.currentUser;
                          await _firestore.collection('Professional Mode').doc(user!.uid).set({
                            'Mode On/Off':true
                          });
                          fetchprofessional();
                        },
                        child: Text('Off',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 15),),
                      )
                  ],
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}

